"""Verify a debug-signed AAB and record its exact-source evidence; never authorize publication."""
import argparse
import hashlib
import json
import os
import re
import subprocess
import xml.etree.ElementTree as ET
from pathlib import Path

from verify_android_test_apk import validate_metadata, validate_archive_paths

ANDROID = "{http://schemas.android.com/apk/res/android}"


def parse_manifest(text):
    root = ET.fromstring(text)
    sdk = root.find("uses-sdk")
    if sdk is None:
        raise ValueError("AAB manifest has no uses-sdk")
    return {"application_id": root.attrib["package"],
            "version": root.attrib[ANDROID + "versionName"],
            "version_code": int(root.attrib[ANDROID + "versionCode"]),
            "min_sdk": int(sdk.attrib[ANDROID + "minSdkVersion"]),
            "target_sdk": int(sdk.attrib[ANDROID + "targetSdkVersion"]),
            "max_sdk": int(sdk.attrib[ANDROID + "maxSdkVersion"]) if ANDROID + "maxSdkVersion" in sdk.attrib else None,
            "permissions": sorted({x.attrib[ANDROID + "name"] for x in root if x.tag.startswith("uses-permission")})}


def run(command, binary=False):
    result = subprocess.run(command, check=True, capture_output=True, timeout=180)
    return result.stdout if binary else result.stdout.decode("utf-8")


def verify(bundle, bundletool, keystore, expected_path, output):
    expected = json.loads(expected_path.read_text(encoding="utf-8"))
    source = run(["git", "rev-parse", "HEAD"]).strip()
    if source != os.environ["GITHUB_SHA"]:
        raise ValueError("AAB checkout differs from workflow source")
    output.mkdir(parents=True, exist_ok=True)
    signature = run(["jarsigner", "-J-Duser.language=en", "-J-Duser.country=US", "-verify", str(bundle)])
    (output / "bundle-signature.txt").write_text(signature, encoding="utf-8")
    if "jar verified." not in signature:
        raise ValueError("AAB JAR signature was not verified")
    cert = run(["keytool", "-exportcert", "-alias", "androiddebugkey",
                "-keystore", str(keystore), "-storepass", "android"], binary=True)
    expected_certificate = hashlib.sha256(cert).hexdigest()
    cert_info = run(["keytool", "-J-Duser.language=en", "-J-Duser.country=US",
                     "-printcert", "-jarfile", str(bundle)])
    digests = {value.replace(":", "").lower() for value in re.findall(r"SHA256:\s*([A-Fa-f0-9:]+)", cert_info)}
    if digests != {expected_certificate}:
        raise ValueError("AAB signer differs from this job's debug certificate")
    manifest = run(["java", "-jar", str(bundletool), "dump", "manifest", "--bundle=" + str(bundle)])
    (output / "bundle-manifest.xml").write_text(manifest, encoding="utf-8")
    observed = parse_manifest(manifest)
    import zipfile
    with zipfile.ZipFile(bundle) as archive:
        if archive.testzip() is not None:
            raise ValueError("AAB ZIP integrity failed")
        validate_archive_paths(archive.namelist(), expected)
        abis = {n.split("/")[2] for n in archive.namelist()
                if n.startswith("base/lib/") and n.endswith(".so") and len(n.split("/")) == 4}
    validate_metadata(observed, expected, abis)
    with bundle.open("rb") as f:
        digest = hashlib.file_digest(f, "sha256").hexdigest()
    result = {"classification": "store-format-validation-debug-only", "source_commit": source,
              "workflow_run_id": int(os.environ["GITHUB_RUN_ID"]), "bundle": bundle.name,
              "bundle_bytes": bundle.stat().st_size, "bundle_sha256": digest,
              **observed, "architectures": sorted(abis), "signature_verified": True,
              "signer_certificate_sha256": expected_certificate,
              "production_signing": False, "public_distribution_allowed": False,
              "physical_device_qa": "pending", "gold_decision": "NO-GO"}
    (output / "BUNDLE_VALIDATION_MANIFEST.json").write_text(json.dumps(result, indent=2) + "\n", encoding="utf-8")
    print("RQ_ANDROID_BUNDLE_VALIDATION_OK", source, digest)


if __name__ == "__main__":
    p = argparse.ArgumentParser()
    p.add_argument("bundle", type=Path)
    p.add_argument("--bundletool", type=Path, required=True)
    p.add_argument("--debug-keystore", type=Path, required=True)
    p.add_argument("--manifest", type=Path, default=Path("docs/release/rc/STORE_VALIDATION_MANIFEST.json"))
    p.add_argument("--output", type=Path, required=True)
    a = p.parse_args()
    verify(a.bundle, a.bundletool, a.debug_keystore, a.manifest, a.output)
