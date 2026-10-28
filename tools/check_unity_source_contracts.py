"""Validate the review-asset bridge and pinned Unity source contracts, not Unity runtime."""
from pathlib import Path, PurePosixPath
import hashlib
import json
import math

ROOT = Path(__file__).resolve().parents[1]
ASSETS = ROOT / "unity/Assets"
REVIEW = ASSETS / "Resources/ReviewArt"

def check(ok, reason):
    if not ok:
        raise AssertionError(reason)

def resource(value):
    check(isinstance(value, str) and value.startswith("ReviewArt/"), f"Invalid resource {value}")
    rel = value[len("ReviewArt/"):]
    p = PurePosixPath(rel)
    check(rel and not p.is_absolute() and ".." not in p.parts and not p.suffix and "\\" not in rel,
          f"Unsafe resource {value}")
    return rel + ".png"

def main():
    manifest = json.loads((REVIEW/"IMPORT_MANIFEST.json").read_text(encoding="utf-8"))
    bridge_bytes = (REVIEW/"bridge.json").read_bytes()
    bridge = json.loads(bridge_bytes)
    check(manifest.get("classification") == "transitional-review-only", "Incorrect asset classification")
    check(manifest.get("commercial_approved") is False and bridge.get("commercialApproved") is False,
          "Review assets are not commercially approved")
    check(manifest.get("pixel_operations") == [], "Copied review assets were modified")
    records = manifest["files"]
    by_name = {item["file"]: item for item in records}
    check(len(by_name) == len(records) and "bridge.json" in by_name, "Duplicate/missing manifest entries")
    check(hashlib.sha256(bridge_bytes).hexdigest() == by_name["bridge.json"]["sha256"], "Bridge hash mismatch")
    names = {n for n in by_name if n.endswith(".png")}
    check(len(names) == 274, f"Expected 274 review PNGs; got {len(names)}")
    actual = {f.relative_to(REVIEW).as_posix() for f in REVIEW.rglob("*.png")}
    check(actual == names, "Manifest/PNG inventory mismatch")
    for n in names:
        p = PurePosixPath(n)
        check(not p.is_absolute() and ".." not in p.parts, f"Unsafe path {n}")
        contents = (REVIEW/n).read_bytes()
        check(len(contents) == by_name[n]["bytes"] and
              hashlib.sha256(contents).hexdigest() == by_name[n]["sha256"], f"PNG drift: {n}")
    used = set()
    actors = bridge["actors"]
    check(len({a["key"] for a in actors}) == len(actors), "Duplicate actors")
    check({"player","chaser","ranged","portal","effect"} <= {a["key"] for a in actors},
          "Required actor absent")
    frames = 0
    for a in actors:
        clips = a["clips"]
        check(len({c["key"] for c in clips}) == len(clips), f"Duplicate clip in {a['key']}")
        for c in clips:
            check(c["frames"], f"Empty clip {a['key']}/{c['key']}")
            for frame in c["frames"]:
                frames += 1
                check(math.isfinite(frame["seconds"]) and frame["seconds"] > 0,
                      f"Invalid frame timing {a['key']}/{c['key']}")
                used.add(resource(frame["file"]))
                equipment = frame.get("equipment", [])
                transforms = frame.get("transforms", [])
                check(len(transforms) == len(equipment)*3 and all(math.isfinite(v) for v in transforms),
                      f"Equipment transform mismatch in {a['key']}/{c['key']}")
                for part in equipment:
                    used.add(resource(part))
    check({"forest","castle","caves"} <= {e["key"] for e in bridge["environments"]},
          "Required review biome absent")
    for e in bridge["environments"]:
        used.add(resource(e["background"]))
        used.add(resource(e["tile"]))
    check(used <= names, f"Missing referenced sprites: {sorted(used-names)[:8]}")
    check("6000.3.27f1" in (ROOT/"unity/ProjectSettings/ProjectVersion.txt").read_text(),
          "Editor version drift")
    packages = json.loads((ROOT/"unity/Packages/manifest.json").read_text())["dependencies"]
    check(packages.get("com.unity.inputsystem") == "1.20.1" and
          packages.get("com.unity.ugui") == "2.0.0", "Package version drift")
    build = (ASSETS/"RastaQuest/Editor/ReviewBuild.cs").read_text()
    settings = (ROOT/"unity/ProjectSettings/ProjectSettings.asset").read_text()
    check("AndroidMinSdkVersion: 25" in settings and "AndroidTargetSdkVersion: 36" in settings,
          "ProjectSettings Android floor/target drift")
    check('Path.Combine(Application.dataPath, "Scenes")' in build and
          "Path.Combine(projectRoot,path)" in build,
          "Editor paths must resolve within Unity project")
    for term in ("com.tupiniquim.rastaquest.unityreview", "AndroidSdkVersions)25", "AndroidSdkVersions)36",
                 "AndroidArchitecture.ARMv7|AndroidArchitecture.ARM64", "BuildOptions.Development"):
        check(term in build, f"Build source contract missing: {term}")
    check(not list(ASSETS.rglob("forest-art-target-v01.png")), "Concept imported into runtime")
    print(f"RQ_UNITY_SOURCE_OK: {len(names)} review PNGs, {frames} frames, {len(used)} references; Unity runtime NOT tested")

if __name__ == "__main__":
    main()
