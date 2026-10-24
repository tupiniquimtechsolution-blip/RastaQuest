"""Plan-only validator. PASS evidence completeness never proves truth or grants Gold GO."""
import json
import re
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
PLAN = ROOT/"docs/release/acceptance/UNITY_MIGRATION_EVIDENCE_PENDING.json"
REQUIRED = {
    "unity-editor-install","unity-package-import","unity-csharp-compile","unity-playmode-smoke",
    "unity-hud-controls","unity-android-debug-apk","unity-native-16kb",
    "galaxy-a13-physical","art-protagonist-final","art-environment-final",
    "art-enemy-final","cultural-consultation","save-compatibility",
    "localization-audio-accessibility"
}
HUMAN = {"galaxy-a13-physical","art-protagonist-final","art-environment-final",
         "art-enemy-final","cultural-consultation","localization-audio-accessibility"}

def validate(packet):
    errors=[]
    def require(ok, message):
        if not ok:
            errors.append(message)
    require(packet.get("schema_version")==1, "unknown evidence schema")
    require(packet.get("purpose")=="UNITY_MIGRATION_PREPRODUCTION_EVIDENCE", "wrong evidence purpose")
    require(packet.get("classification")=="PLANNING_ONLY", "do not reclassify as release evidence")
    require(packet.get("release_decision")=="NO-GO", "a source-only packet cannot be Gold GO")
    for flag in ("commercial_go","editor_import_verified","android_apk_verified","physical_device_verified"):
        require(packet.get(flag) is False, "invalid approval claim: "+flag)
    require(packet.get("unity_candidate_commit") is None, "no binary evidence for candidate commit")
    require(packet.get("unity_editor_expected") == "6000.3.27f1", "Editor pin changed")
    require(packet.get("android_min_sdk")==25 and packet.get("android_target_sdk")==36, "Android SDK drift")
    require(set(packet.get("android_abis",[]))=={"armeabi-v7a","arm64-v8a"}, "ABI drift")
    checks=packet.get("checks",[])
    ids=[c.get("id") for c in checks]
    require(set(ids)==REQUIRED and len(ids)==len(REQUIRED), "missing or duplicated evidence gate")
    require(all(c.get("state") in ("PENDING","BLOCKED","PASS","FAIL") for c in checks),
            "unrecognized evidence state")
    for item in checks:
        state=item.get("state")
        require(isinstance(item.get("issue"),int) and item["issue"]>0, "missing issue reference")
        urls=item.get("evidence",[])
        require(isinstance(urls,list), "malformed evidence list")
        if state=="PASS":
            require(bool(urls) and all(isinstance(u,str) and u.startswith("https://") for u in urls),
                    "PASS without referenced evidence: "+item.get("id",""))
            sha=item.get("artifact_sha256")
            require(isinstance(sha,str) and re.fullmatch(r"[0-9a-f]{64}",sha) is not None,
                    "PASS without 64-hex artifact hash: "+item.get("id",""))
            if item.get("id") in HUMAN:
                require(isinstance(item.get("reviewer"),str) and bool(item["reviewer"].strip()),
                        "PASS without accountable reviewer: "+item.get("id",""))
        elif state in ("PENDING","BLOCKED"):
            require(urls==[] and item.get("artifact_sha256") is None and item.get("reviewer") is None,
                    "pending gate contains premature acceptance data: "+item.get("id",""))
    return errors

if __name__=="__main__":
    current=json.loads(PLAN.read_text(encoding="utf-8"))
    errors=validate(current)
    if errors:
        raise SystemExit("RQ_UNITY_QA_PLAN_FAIL: "+"; ".join(errors))
    print("RQ_UNITY_QA_PLAN_OK — planning record only; commercial decision remains NO-GO")
