"""Read-only draft content and source save contract validation; no Unity runtime integration."""
import json
import re
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
PACK = ROOT / "docs/production/content_drafts/unity_content_v01.json"

def validate(data, root=ROOT):
    failures = []
    def check(ok, message):
        if not ok:
            failures.append(message)
    check(data.get("schema_version") == 1 and data.get("status") == "DRAFT_NOT_IN_RUNTIME", "draft status required")
    for field in ("commercial_approved", "unity_integrated", "narrative_approved"):
        check(data.get(field) is False, "false approval: " + field)
    for path in data.get("reference_sources", []):
        check((root / path).is_file(), "source missing: " + path)
    check(data.get("biome_sequence") == ["forest","castle","caves"], "biome sequence drift")
    locales = data.get("locales", {})
    check(set(locales) == {"pt_BR","es","en"}, "locale inventory drift")
    canonical = locales.get("pt_BR",{})
    for name, messages in locales.items():
        check(set(messages) == set(canonical), "locale keys mismatch: "+name)
        for key, value in messages.items():
            check(isinstance(value,str) and len(value.strip()) > 0, "blank text: "+name+"/"+key)
            expected = set(re.findall(r"\{([a-z_]+)\}", canonical.get(key,"")))
            actual = set(re.findall(r"\{([a-z_]+)\}", value))
            check(expected == actual, "placeholder mismatch: "+name+"/"+key)
    choices = data.get("choices",[])
    check(len(choices) == 3 and len({x["id"] for x in choices}) == 3, "reward trio drift")
    for item in choices:
        name = item.get("upgrade","")
        path = root/"game/data/upgrades"/(name+".tres")
        check(path.is_file(), "missing upgrade: "+name)
        if path.is_file():
            source = path.read_text(encoding="utf-8")
            check(('id = &"'+name+'"') in source, "upgrade name mismatch: "+name)
            check(('effect_key = &"'+item.get("effect","")+'"') in source, "upgrade effect mismatch: "+name)
        check(item.get("label") in canonical, "missing choice label")
    heal = [x for x in choices if x.get("id") == "heal"]
    check(len(heal) == 1 and heal[0].get("apply") == "ONLY_WHEN_SELECTED", "healing must be opt-in")
    cues = data.get("audio",[])
    check(len({x.get("id") for x in cues}) == len(cues), "duplicate audio cue")
    check(all(x.get("asset") is None and x.get("bus") in ("SFX","Music") for x in cues),
          "unlicensed audio or invalid bus")
    save = data.get("save",{})
    check(save.get("source_schema") == 2 and save.get("source_max_bytes") == 1048576,
          "save schema drift")
    check(set(save.get("keys",[])) == {"schema_version","meta_shards","unlocks","settings","completion_flags"},
          "save fields drift")
    check(save.get("migration") == "NO_AUTOMATIC_MIGRATION" and
          save.get("target_write_enabled") is False and save.get("preserve_godot_save") is True,
          "unsafe save migration claim")
    source = (root/"game/scripts/save/save_manager.gd").read_text(encoding="utf-8")
    check("CURRENT_SCHEMA_VERSION: int = 2" in source and
          "MAX_SAVE_BYTES: int = 1048576" in source, "Godot save source changed")
    for key in save.get("keys",[]):
        check(('"'+key+'"') in source, "Godot save field missing: "+key)
    return failures

if __name__ == "__main__":
    errors = validate(json.loads(PACK.read_text(encoding="utf-8")))
    if errors:
        raise SystemExit("RQ_CONTENT_FAIL " + "; ".join(errors))
    print("RQ_CONTENT_OK — drafts aligned with current Godot source; no Unity runtime/save migration claim")
