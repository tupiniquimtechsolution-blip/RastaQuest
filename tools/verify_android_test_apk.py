"""Verify the produced debug APK; write evidence, never modify the APK or sign it."""
import argparse
import hashlib
import json
import os
import re
import subprocess
import zipfile
from datetime import datetime, timezone
from pathlib import Path


def parse_badging(text):
    package_line = next((line for line in text.splitlines() if line.startswith("package:")), None)
    if package_line is None:
        raise ValueError("APK badging has no package metadata")
    fields = dict(re.findall(r"(\w+)='([^']*)'", package_line))
    required = {"name", "versionCode", "versionName"}
    if not required <= fields.keys():
        raise ValueError("APK package/version metadata is incomplete")
    if not fields["versionCode"].isdigit():
        raise ValueError("APK versionCode is not an integer")
    permissions = sorted(set(re.findall(
        r"^uses-permission(?:-sdk-\d+)?: name='([^']+)'", text, re.MULTILINE)))
    return {"application_id": fields["name"], "version": fields["versionName"],
            "version_code": int(fields["versionCode"]), "permissions": permissions}


def validate_metadata(observed, expected, native_abis):
    for key in ("application_id", "version", "version_code"):
        if observed[key] != expected[key]:
            raise ValueError(f"Packaged {key} differs from RC manifest")
    if observed["permissions"] != sorted(set(expected["declared_permissions"])):
        raise ValueError(f"Packaged permissions differ from declaration: {observed['permissions']}")
    if sorted(native_abis) != sorted(expected["architectures"]):
        raise ValueError(f"Packaged native architectures differ from declaration: {sorted(native_abis)}")
    if expected["release_signed"] or expected["distribution_published"]:
        raise ValueError("This verifier is restricted to unpublished debug test candidates")


def find_build_tools(sdk):
    versions = []
    for path in (sdk / "build-tools").iterdir():
        if re.fullmatch(r"\d+\.\d+(?:\.\d+)?", path.name) and all(
                (path / tool).is_file() for tool in ("apksigner", "aapt2")):
            versions.append(path)
    if not versions:
        raise ValueError("Android SDK has no stable build-tools with apksigner and aapt2")
    return max(versions, key=lambda path: tuple(map(int, path.name.split("."))))


def run_text(command):
    return subprocess.run(command, check=True, capture_output=True, text=True, timeout=60).stdout


def verify(apk, manifest_path, output, debug_keystore):
    expected = json.loads(manifest_path.read_text(encoding="utf-8"))
    source_commit = run_text(["git", "rev-parse", "HEAD"]).strip()
    workflow_commit = os.environ["GITHUB_SHA"]
    if source_commit != workflow_commit:
        raise ValueError("APK checkout differs from the GitHub workflow source commit")
    sdk = find_build_tools(Path(os.environ["ANDROID_HOME"]))
    output.mkdir(parents=True, exist_ok=True)
    signature = run_text([str(sdk / "apksigner"), "verify", "--verbose", "--print-certs", str(apk)])
    certificate_match = re.search(r"Signer #1 certificate SHA-256 digest: ([0-9a-fA-F]{64})", signature)
    if certificate_match is None:
        raise ValueError("Verified APK signer certificate fingerprint not found")
    keytool = Path(os.environ["JAVA_HOME"]) / "bin/keytool"
    # The password is the public CI debug convention, never a production credential.
    certificate = subprocess.run([str(keytool), "-exportcert", "-alias", "androiddebugkey",
        "-keystore", str(debug_keystore), "-storepass", "android"], check=True,
        capture_output=True, timeout=60).stdout
    certificate_sha256 = hashlib.sha256(certificate).hexdigest()
    if certificate_match.group(1).lower() != certificate_sha256:
        raise ValueError("APK signer differs from this job's ephemeral debug certificate")
    badging = run_text([str(sdk / "aapt2"), "dump", "badging", str(apk)])
    observed = parse_badging(badging)
    with zipfile.ZipFile(apk) as archive:
        if archive.testzip() is not None:
            raise ValueError("APK ZIP integrity failed")
        native_abis = {path.split("/")[1] for path in archive.namelist()
                       if path.startswith("lib/") and path.endswith(".so") and len(path.split("/")) == 3}
        if any("production_drafts" in path for path in archive.namelist()):
            raise ValueError("Production draft path unexpectedly present in APK")
    validate_metadata(observed, expected, native_abis)
    with apk.open("rb") as source:
        digest = hashlib.file_digest(source, "sha256").hexdigest()
    (output / "signature-verification.txt").write_text(signature, encoding="utf-8")
    (output / "apk-badging.txt").write_text(badging, encoding="utf-8")
    (output / "SHA256SUMS.txt").write_text(f"{digest}  {apk.name}\n", encoding="utf-8")
    report = {"product": "Rasta Quest", "classification": "technical-debug-test-only",
        "generated_at_utc": datetime.now(timezone.utc).isoformat(),
        "source_commit": source_commit, "workflow_run_id": int(os.environ["GITHUB_RUN_ID"]),
        "workflow_run_attempt": int(os.environ["GITHUB_RUN_ATTEMPT"]),
        "apk": apk.name, "apk_bytes": apk.stat().st_size, "apk_sha256": digest,
        **observed, "architectures": sorted(native_abis), "engine": expected["engine"],
        "save_schema": expected["save_schema"], "signature_verified": True,
        "signer_certificate_sha256": certificate_sha256,
        "signing": "this-job-ephemeral-debug-certificate", "sdk_build_tools": sdk.name,
        "release_signed": False, "public_distribution_allowed": False,
        "physical_device_qa": "pending", "external_playtests": "pending",
        "production_art_audio": "pending", "rights_clearance": "pending",
        "cultural_review": "pending", "gold_decision": "NO-GO"}
    (output / "TEST_RELEASE_MANIFEST.json").write_text(json.dumps(report, indent=2) + "\n", encoding="utf-8")
    print(f"RQ_ANDROID_TEST_APK_OK source={source_commit} sha256={digest}")


if __name__ == "__main__":
    parser = argparse.ArgumentParser()
    parser.add_argument("apk", type=Path)
    parser.add_argument("--manifest", type=Path, default=Path("docs/release/rc/RELEASE_MANIFEST.json"))
    parser.add_argument("--output", type=Path, required=True)
    parser.add_argument("--debug-keystore", type=Path, required=True)
    args = parser.parse_args()
    verify(args.apk, args.manifest, args.output, args.debug_keystore)
