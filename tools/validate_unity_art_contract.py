"""Fail-closed structural checks for the illustrated production packet (not art acceptance)."""
import json
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
PACKET = ROOT / "assets/production_drafts/2026-10-24/unity-illustrated-production/PRODUCTION_CONTRACT.json"
REQUIRED_PROTAGONIST = {"idle","run","jump","fall","attack_axe","attack_axe_air","hurt","death","lightning_proc","portal_enter"}
REQUIRED_ENEMIES = {"idle","move","tell","attack","hurt","death"}
REQUIRED_BIOMES = {"forest","castle","caves"}

def validate(packet, root=ROOT):
    errors = []
    def require(ok, why):
        if not ok:
            errors.append(why)
    require(packet.get("schema_version") == 1, "unknown packet version")
    require(packet.get("status") == "SPECIFICATION_ONLY", "art study misclassified as shipping-ready")
    for key in ("commercial_approved","visual_lock","unity_import_verified","device_readability_verified"):
        require(packet.get(key) is False, key + " may not be marked approved by a source-only packet")
    chars = packet.get("characters",[])
    by_id = {obj.get("id"):obj for obj in chars}
    require(len(by_id) == len(chars) and {"protagonist","chaser","ranged"} <= set(by_id), "characters missing/duplicated")
    for character in chars:
        p = root / character.get("reference","")
        require(p.is_file() and "assets/concepts/" in p.as_posix(), "missing concept reference " + character.get("id","?"))
        clips = character.get("clips",[])
        require(len(clips) == len(set(clips)), "duplicate clips " + character.get("id","?"))
        required = REQUIRED_PROTAGONIST if character.get("id") == "protagonist" else REQUIRED_ENEMIES
        require(required <= set(clips), "missing core clips " + character.get("id","?"))
        require(character.get("production_lock") == "PENDING", "unproven character lock")
        require(len(character.get("separate_layers",[])) >= 3, "insufficient layers " + character.get("id","?"))
    env = packet.get("environments",[])
    require(len(env) == len({e.get("id") for e in env}) and REQUIRED_BIOMES <= {e.get("id") for e in env}, "biome contract incomplete")
    for item in env:
        require((root/item.get("reference","")).is_file(), "missing biome concept reference")
        require("gameplay_terrain" in item.get("layers",[]), "missing gameplay layer")
        require(item.get("gameplay_collision_from_art") is False, "art cannot authorize collision geometry")
        require(item.get("production_lock") == "PENDING", "unproven biome lock")
    hud = packet.get("hud",{})
    require(hud.get("status") == "DIRECTION_ONLY", "HUD cannot self-approve")
    require(hud.get("safe_area_required") is True, "safe area missing")
    require(hud.get("contrast_without_color_required") is True, "contrast review missing")
    require({"health_fraction","portrait","pause"} <= set(hud.get("fields",[])), "essential HUD fields missing")
    require(set(hud.get("fields",[])).isdisjoint(hud.get("forbidden_invented_fields",[])), "invented HUD stats")
    pipeline = packet.get("pipeline",{})
    require(pipeline.get("shipping_material_present") is False, "shipping claimed without art evidence")
    require(pipeline.get("runtime","").startswith("unity/Assets/"), "shipping path not isolated")
    gates = packet.get("gates",[])
    require({x.get("id") for x in gates} == {"35-protagonist","36-environment","37-enemies","38-cultural"}, "gate inventory drift")
    require(all(x.get("state")=="PENDING" for x in gates), "source packet may not close human gates")
    return errors

def main():
    data = json.loads(PACKET.read_text(encoding="utf-8"))
    failures = validate(data)
    if failures:
        raise SystemExit("RQ_ART_CONTRACT_FAIL: " + "; ".join(failures))
    print("RQ_ART_CONTRACT_OK — source specification only; zero illustration, licensing or human-acceptance claims")

if __name__ == "__main__":
    main()
