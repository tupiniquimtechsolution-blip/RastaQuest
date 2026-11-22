#!/usr/bin/env python3
"""Read-only, privacy-safe summary of local Unity Windows native-gate evidence.

The generated JSON excludes user paths, editor paths, raw logs, certificate
details and device identifiers. It cannot prove a physical Android test.

Usage:
  python tools/unity_native_evidence_summary.py --gate NATIVE_GATE_REPORT.json \
      --probe NATIVE_REPORT.json --output UNITY_NATIVE_EVIDENCE_SUMMARY.json
"""
from __future__ import annotations

import argparse
from datetime import datetime, timezone
import hashlib
import json
from pathlib import Path
import re


def digest_file(path: Path) -> str:
    digest = hashlib.sha256()
    with path.open("rb") as source:
        for part in iter(lambda: source.read(1024 * 1024), b""):
            digest.update(part)
    return digest.hexdigest()


def read_json(path: Path) -> dict:
    data = json.loads(path.read_text(encoding="utf-8-sig"))
    if not isinstance(data, dict):
        raise ValueError(f"Expected JSON object in {path.name}")
    return data


def clean_capture_names(captures) -> list[str]:
    if not isinstance(captures, list):
        raise ValueError("Native probe captures must be an array")
    names = []
    for name in captures:
        if not isinstance(name, str) or not name.endswith(".png"):
            raise ValueError("Unexpected screenshot name in probe")
        if not re.fullmatch(r"[A-Za-z0-9_-]+_[0-9]+x[0-9]+\.png", name):
            raise ValueError("Unexpected or potentially sensitive screenshot basename")
        names.append(name)
    if len(set(names)) != len(names):
        raise ValueError("Duplicate screenshot entries in probe")
    return names


def summarize(gate_path: Path, probe_path: Path, asserted_source: str = "") -> dict:
    gate, probe = read_json(gate_path), read_json(probe_path)
    if gate.get("status") != "PASS" or probe.get("status") != "PASS":
        raise ValueError("Native reports must both have status PASS")
    if probe.get("failures"):
        raise ValueError("Probe claims PASS but includes failures")
    source = gate.get("repository_head")
    if source is not None and not re.fullmatch(r"[0-9a-f]{40}", str(source)):
        source = None
    if asserted_source:
        if not re.fullmatch(r"[0-9a-f]{40}", asserted_source):
            raise ValueError("--source-commit must be a complete 40-character Git SHA")
        if source and source != asserted_source:
            raise ValueError("Reported repository HEAD differs from asserted source commit")

    captures = clean_capture_names(probe.get("captures"))
    if len(captures) < 8:
        raise ValueError("Probe has fewer than 8 captured screenshots")
    capture_present = sum((probe_path.parent / name).is_file() for name in captures)

    artifacts = []
    for item in gate.get("artifacts", []):
        if not isinstance(item, dict):
            raise ValueError("Malformed artifact entry")
        recorded_sha = str(item.get("sha256", "")).lower()
        if not re.fullmatch(r"[0-9a-f]{64}", recorded_sha):
            raise ValueError("Artifact missing SHA-256 in native gate report")
        recorded_size = item.get("bytes")
        if not isinstance(recorded_size, int) or recorded_size < 1024:
            raise ValueError("Artifact has an invalid reported size")
        path = Path(str(item.get("path", "")))
        verified = path.is_file()
        if verified:
            actual_sha = digest_file(path)
            actual_size = path.stat().st_size
            if actual_sha != recorded_sha or actual_size != recorded_size:
                raise ValueError("Current artifact differs from reported SHA-256 or byte size")
        artifacts.append({
            "kind": re.sub(r"[^A-Za-z0-9_-]", "_", str(item.get("type", "unknown")))[:80],
            "bytes": recorded_size,
            "sha256_from_gate": recorded_sha,
            "current_local_file_verified": verified,
        })

    # Only safe, explicitly whitelisted data is copied into this JSON.
    return {
        "schema": 1,
        "generated_utc": datetime.now(timezone.utc).isoformat(),
        "scope": "unity-windows-review-player",
        "source_commit": source or asserted_source or None,
        "source_commit_provenance": (
            "native_gate_git_head" if source else
            "operator_asserted_not_independently_verified" if asserted_source else "missing"
        ),
        "editor_version_from_gate": str(gate.get("required_unity", "")) if re.fullmatch(r"[0-9]+\.[0-9]+\.[0-9]+[a-z][0-9]+", str(gate.get("required_unity", ""))) else "unknown",
        "engine_version_from_probe": str(probe.get("engine", "")) if re.fullmatch(r"[0-9]+\.[0-9]+\.[0-9]+[a-z][0-9]+", str(probe.get("engine", ""))) else "unknown",
        "native_gate_status": "PASS",
        "native_probe_status": "PASS",
        "probe_failure_count": 0,
        "screenshot_count_reported": len(captures),
        "screenshots_present_next_to_probe": capture_present,
        "screenshot_names": captures,
        "artifacts": artifacts,
        "physical_android_verified": False,
        "commercial_approved": False,
        "limits": [
            "Reports from the local Windows agent; not a substitute for independent rerun.",
            "Windows automated/synthetic controls do not prove real Android touch gestures.",
            "APK metadata, ELF alignment and signing are not reaudited by this summary.",
            "Do not interpret this summary as approval for release or merge.",
        ],
    }


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--gate", type=Path, required=True)
    parser.add_argument("--probe", type=Path, required=True)
    parser.add_argument("--output", type=Path, required=True)
    parser.add_argument("--source-commit", default="")
    args = parser.parse_args()
    report = summarize(args.gate, args.probe, args.source_commit)
    args.output.parent.mkdir(parents=True, exist_ok=True)
    args.output.write_text(json.dumps(report, indent=2, ensure_ascii=False) + "\n",
                           encoding="utf-8")
    print("RQ_UNITY_EVIDENCE_SUMMARY_OK")
    print(f"probe_captures={report['screenshot_count_reported']} local_screenshots={report['screenshots_present_next_to_probe']}")
    print("Only sanitized artifact hashes; no local paths or personal details included.")


if __name__ == "__main__":
    main()
