"""Audit release evidence completeness/consistency. Never write GO, approvals or release state."""
import argparse
import csv
import json
import re
from pathlib import Path

DEVICE_CHECKS = ("clean_install", "launch", "offline", "touch", "fps_target",
                 "memory_stable", "thermal", "background_resume", "save_restart", "boss", "death_return")
REVIEWS = ("visual_final", "cultural_final", "privacy_store", "content_rating", "commercial_model", "support_ready")


def inspect(evidence, assets):
    pending = []
    candidate = evidence.get("candidate", {})
    commit, digest = candidate.get("source_commit", ""), candidate.get("artifact_sha256", "")
    if not isinstance(commit, str) or not re.fullmatch(r"[a-f0-9]{40}", commit):
        pending.append("candidate.source_commit")
    if not isinstance(digest, str) or not re.fullmatch(r"[a-f0-9]{64}", digest):
        pending.append("candidate.artifact_sha256")
    if not candidate.get("version"):
        pending.append("candidate.version")
    if candidate.get("production_signed") is not True:
        pending.append("production_signed")
    if candidate.get("ci_green") is not True:
        pending.append("final_candidate_ci")

    def same_build(record, name):
        if record.get("source_commit") != commit or record.get("artifact_sha256") != digest:
            pending.append(name + ":wrong-build")

    devices = evidence.get("devices", [])
    if not devices:
        pending.append("physical_devices")
    for index, device in enumerate(devices):
        name = f"device[{index}]"
        same_build(device, name)
        if not all(device.get(key) for key in ("model", "android", "tested_at", "evidence_refs")):
            pending.append(name + ":identity-or-proof")
        for check in DEVICE_CHECKS:
            if device.get("checks", {}).get(check) != "PASS":
                pending.append(name + ":" + check)
        if not device.get("measurements"):
            pending.append(name + ":measurements")
    testers = evidence.get("movement_testers", [])
    aliases = {r.get("tester_alias") for r in testers if r.get("tester_alias") and r.get("result") == "PASS" and r.get("evidence_refs")}
    if len(aliases) < 3:
        pending.append("three_external_movement_testers")
    for index, record in enumerate(testers):
        same_build(record, f"tester[{index}]")
    runs = evidence.get("beta_runs", [])
    completed = {r.get("run_id") for r in runs if r.get("run_id") and r.get("complete") is True and r.get("device") and r.get("duration_seconds", 0) > 0 and r.get("evidence_refs")}
    if len(completed) < 20:
        pending.append("twenty_unique_complete_beta_runs")
    for index, record in enumerate(runs):
        same_build(record, f"beta[{index}]")
    if evidence.get("known_blockers") != [] or evidence.get("known_criticals") != []:
        pending.append("zero_known_blocker_critical_bugs")
    if not assets:
        pending.append("asset_inventory_empty")
    for index, asset in enumerate(assets):
        if str(asset.get("release_approved", "")).lower() != "true" or not all(
                asset.get(key) for key in ("asset_path", "source", "license", "proof_location")):
            pending.append(f"asset[{index}]:rights-or-approval")
    for name in REVIEWS:
        review = evidence.get("reviews", {}).get(name, {})
        same_build(review, "review:" + name)
        if review.get("decision") != "APPROVED" or not all(review.get(k) for k in ("reviewer", "date", "evidence_refs")):
            pending.append("review:" + name)
    return {"record_structure": "complete" if not pending else "incomplete",
            "pending": pending, "automatic_gold_go": False,
            "evidence_truth": "not-independently-verified",
            "note": "Checks presence/build consistency only; human evidence, rights and store approval still require review."}


if __name__ == "__main__":
    p = argparse.ArgumentParser()
    p.add_argument("evidence", type=Path)
    p.add_argument("--inventory", type=Path, default=Path("docs/release/acceptance/ASSET_LICENSE_INVENTORY.csv"))
    p.add_argument("--output", type=Path)
    p.add_argument("--report-only", action="store_true")
    a = p.parse_args()
    evidence = json.loads(a.evidence.read_text(encoding="utf-8"))
    with a.inventory.open(encoding="utf-8", newline="") as f:
        assets = [r for r in csv.DictReader(f) if r.get("asset_path")]
    result = inspect(evidence, assets)
    text = json.dumps(result, indent=2, ensure_ascii=False) + "\n"
    if a.output:
        a.output.write_text(text, encoding="utf-8")
    print(text)
    raise SystemExit(0 if a.report_only or not result["pending"] else 1)
