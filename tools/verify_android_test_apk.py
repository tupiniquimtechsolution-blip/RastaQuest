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
    minimum = re.search(r"^(?:minSdkVersion|sdkVersion):'(\d+)'", text, re.MULTILINE)
    target = re.search(r"^targetSdkVersion:'(\d+)'", text, re.MULTILINE)
    maximum = re.search(r"^maxSdkVersion:'(\d+)'", text, re.MULTILINE)
    if minimum is None or target is None:
        raise ValueError("APK minimum/target Android SDK metadata is missing")
    return {"application_id": fields["name"], "version": fields["versionName"],
            "version_code": int(fields["versionCode"]), "permissions": permissions,
            "min_sdk": int(minimum.group(1)), "target_sdk": int(target.group(1)),
            "max_sdk": int(maximum.group(1)) if maximum else None}


def validate_metadata(observed, expected, native_abis):
    for key in ("application_id", "version", "version_code"):
        if observed[key] != expected[key]:
            raise ValueError(f"Packaged {key} differs from RC manifest")
    if observed["permissions"] != sorted(set(expected["declared_permissions"])):
        raise ValueError(f"Packaged permissions differ from declaration: {observed['permissions']}")
    if sorted(native_abis) != sorted(expected["architectures"]):
        raise ValueError(f"Packaged native architectures differ from declaration: {sorted(native_abis)}")
    for key in ("min_sdk", "target_sdk"):
        if key in expected and observed[key] != expected[key]:
            raise ValueError(f"Packaged {key} differs from declaration")
    device_api = expected.get("installation_target", {}).get("android_api")
    if device_api is not None and (observed["min_sdk"] > device_api or
            (observed["max_sdk"] is not None and observed["max_sdk"] < device_api)):
        raise ValueError("Packaged Android SDK range excludes the reported test device")
    if expected["release_signed"] or expected["distribution_published"]:
        raise ValueError("This verifier is restricted to unpublished debug test candidates")


def validate_orientation(xml, expected):
    # aapt2 prints integer values as decimal; older SDK variants include a
    # typed hexadecimal prefix. Both represent the actual compiled attribute.
    declarations = re.findall(r"android:screenOrientation[^\n]*", xml)
    values = []
    for declaration in declarations:
        raw = declaration.rsplit("=", 1)[-1].strip()
        raw = re.sub(r"^\(type [^)]+\)", "", raw).strip()
        match = re.match(r"^(0x[0-9a-fA-F]+|[0-9]+)\b", raw)
        if match:
            value = match.group(1)
            values.append(int(value, 16 if value.startswith("0x") else 10))
    if not declarations or len(values) != len(declarations) or set(values) != {expected}:
        raise ValueError(f"Actual APK activity orientation mismatch: {declarations!r}")


def validate_engine_libraries(archive, architectures):
    expected_elf = {"armeabi-v7a": (1, 40), "arm64-v8a": (2, 183)}
    evidence = {}
    for abi in architectures:
        name = f"lib/{abi}/libgodot_android.so"
        if name not in archive.namelist():
            raise ValueError(f"Missing Godot engine library for {abi}")
        with archive.open(name) as source:
            header = source.read(20)
        elf_class, machine = expected_elf[abi]
        if (len(header) != 20 or header[:4] != b"\x7fELF" or header[4] != elf_class or
                header[5] != 1 or int.from_bytes(header[18:20], "little") != machine):
            raise ValueError(f"Godot library ELF architecture does not match {abi}")
        evidence[abi] = {"file": name, "elf_bits": 32 if elf_class == 1 else 64,
                         "elf_machine": machine}
    return evidence


def validate_archive_paths(paths, expected):
    # Segment matching catches APK assets/... and AAB base/assets/... equally.
    forbidden = {"production_drafts", *expected.get("forbidden_archive_segments", [])}
    for name in paths:
        segments = set(name.replace("\\", "/").casefold().split("/"))
        if segments & {str(value).casefold() for value in forbidden}:
            raise ValueError(f"Forbidden release payload path: {name}")


def signer_fingerprints(text):
    # SDKs can label signers by ordinal or min/max Android version.
    matches = re.findall(r"certificate SHA-256 digest:\s*([0-9a-fA-F: \t]+)\s*$", text, re.MULTILINE)
    fingerprints = {re.sub(r"[:\s]", "", value).lower() for value in matches}
    if not fingerprints or any(not re.fullmatch(r"[0-9a-f]{64}", value) for value in fingerprints):
        raise ValueError("Verified APK signer certificate fingerprint missing or malformed")
    return fingerprints


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
    (output / "signature-verification.txt").write_text(signature, encoding="utf-8")
    print(signature)
    certificate_digests = signer_fingerprints(signature)
    keytool = Path(os.environ["JAVA_HOME"]) / "bin/keytool"
    # The password is the public CI debug convention, never a production credential.
    certificate = subprocess.run([str(keytool), "-exportcert", "-alias", "androiddebugkey",
        "-keystore", str(debug_keystore), "-storepass", "android"], check=True,
        capture_output=True, timeout=60).stdout
    certificate_sha256 = hashlib.sha256(certificate).hexdigest()
    if certificate_digests != {certificate_sha256}:
        raise ValueError("APK signer differs from this job's ephemeral debug certificate")
    badging = run_text([str(sdk / "aapt2"), "dump", "badging", str(apk)])
    (output / "apk-badging.txt").write_text(badging, encoding="utf-8")
    print(badging)
    observed = parse_badging(badging)
    if "screen_orientation_android" in expected:
        xml = run_text([str(sdk / "aapt2"), "dump", "xmltree", str(apk), "--file", "AndroidManifest.xml"])
        (output / "android-manifest-tree.txt").write_text(xml, encoding="utf-8")
        validate_orientation(xml, expected["screen_orientation_android"])
        observed["screen_orientation_android"] = expected["screen_orientation_android"]
    with zipfile.ZipFile(apk) as archive:
        if archive.testzip() is not None:
            raise ValueError("APK ZIP integrity failed")
        native_abis = {path.split("/")[1] for path in archive.namelist()
                       if path.startswith("lib/") and path.endswith(".so") and len(path.split("/")) == 3}
        validate_archive_paths(archive.namelist(), expected)
        engine_libraries = validate_engine_libraries(archive, expected["architectures"])
    validate_metadata(observed, expected, native_abis)
    with apk.open("rb") as source:
        digest = hashlib.file_digest(source, "sha256").hexdigest()
    (output / "SHA256SUMS.txt").write_text(f"{digest}  {apk.name}\n", encoding="utf-8")
    report = {"product": "Rasta Quest", "classification": "technical-debug-test-only",
        "generated_at_utc": datetime.now(timezone.utc).isoformat(),
        "source_commit": source_commit, "workflow_run_id": int(os.environ["GITHUB_RUN_ID"]),
        "workflow_run_attempt": int(os.environ["GITHUB_RUN_ATTEMPT"]),
        "apk": apk.name, "apk_bytes": apk.stat().st_size, "apk_sha256": digest,
        **observed, "architectures": sorted(native_abis), "engine": expected["engine"],
        "engine_libraries": engine_libraries,
        "installation_target": expected.get("installation_target"),
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
