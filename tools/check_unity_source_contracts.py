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
    check("m_EditorVersion: 6000.6.10f1" in (ROOT/"unity/ProjectSettings/ProjectVersion.txt").read_text(),
          "Editor version drift")
    packages = json.loads((ROOT/"unity/Packages/manifest.json").read_text())["dependencies"]
    check(packages.get("com.unity.inputsystem") == "1.20.1" and
          packages.get("com.unity.ugui") == "2.0.0", "Package version drift")
    # Unity 6.6 no longer resolves this legacy built-in module by package ID.
    check("com.unity.modules.textrendering" not in packages,
          "Obsolete text rendering package breaks Unity 6.6 import")
    player = (ASSETS/"RastaQuest/Runtime/SlicePlayer.cs").read_text()
    enemy = (ASSETS/"RastaQuest/Runtime/SliceEnemy.cs").read_text()
    bootstrap = (ASSETS/"RastaQuest/Runtime/SliceBootstrap.cs").read_text()
    check("GetInstanceID()" not in player and "Rules.ClaimTarget(foe.HitTargetId)" in player,
          "Unity 6.6 combat must not use obsolete InstanceID or integer EntityId hashes")
    check("System.Threading.Interlocked.Increment(ref nextHitTargetId)" in enemy and
          "public int HitTargetId" in enemy, "Hit-target IDs must be unique and gameplay-scoped")
    check("WhiteSprite=UnityEngine.Sprite.Create(" in bootstrap,
          "Sprite factory must be qualified to avoid collision with helper method")
    hud = (ASSETS/"RastaQuest/Runtime/SliceHud.cs").read_text()
    editor = (ASSETS/"RastaQuest/Editor/ReviewBuild.cs").read_text()
    repair = (ASSETS/"RastaQuest/Editor/ReviewSpriteRepair.cs").read_text()
    check("VerifyReviewSprites();" in editor and
          "LoadAssetAtPath<Texture2D>" in editor and
          "Resources.Load<Texture2D>" in editor and
          "RQ_UNITY_REVIEW_ASSETS_OK" in editor,
          "Unity 6.6 review bridge must accept Texture2D imports with runtime fallback")
    art_code = (ASSETS/"RastaQuest/Runtime/ReviewArt.cs").read_text()
    check("Resources.Load<Sprite>(file)" in art_code and
          "Resources.Load<Texture2D>(file)" in art_code and
          "UnityEngine.Sprite.Create(texture," in art_code and
          "fallbackSprites[file] = cached" in art_code,
          "ReviewArt must cache runtime sprites without touching PNGs or GUIDs")
    check("ReviewSpriteRepair.Repair();" not in editor,
          "Scene preparation must not force known-failing metadata repair")
    check("AssetDatabase.ForceReserializeAssets(" in repair and
          "ForceReserializeAssetsOptions.ReserializeMetadata" in repair and
          "TextureImporterType.Sprite" in repair and "SaveAndReimport()" in repair and
          "AssetDatabase.LoadAssetAtPath<Sprite>" in repair,
          "ReviewArt repair must persist upgraded importer settings and validate each Sprite")
    check("File.Delete" not in repair and "DeleteAsset(" not in repair,
          "ReviewArt repair must preserve GUIDs and image files")
    check("LoadAssetAtPath<Sprite>" in editor and
          "LoadAssetAtPath<Texture2D>" in editor,
          "Unity 6.6 scene must validate Sprite or Texture2D before HUD")
    check("if(!initialized || Player==null) return;" in hud and
          "ReviewArt player idle is not imported as Sprite" in hud,
          "HUD must report missing sprite once and avoid per-frame exceptions")
    check("if(!initialized||Player==null||Flow.Paused)return;" in bootstrap,
          "Bootstrap cannot update portal before room initialization")
    check("o.AddComponent<CanvasRenderer>()" in hud and
          "typeof(Graphic).IsAssignableFrom(typeof(T))" in hud and
          "portraitFrame.raycastTarget=false" in hud and
          "barFrame.raycastTarget=false" in hud,
          "Unity 6.6 HUD graphics must have CanvasRenderer and noninteractive frames cannot block clicks")
    check("RQ_UNITY_RESTART_BUTTON_CLICK" in hud and
          "Keyboard.current.rKey.wasPressedThisFrame" in hud and
          "slice.RestartRun();" in hud,
          "Defeat must expose working button diagnostics and a keyboard retry fallback")
    check("Tecla R ou botão" in (ASSETS/"RastaQuest/Core/ReviewText.cs").read_text(encoding="utf-8"),
          "Defeat modal must tell players how to restart")
    enemy_code = (ASSETS/"RastaQuest/Runtime/SliceEnemy.cs").read_text()
    check("art.AuthoredFacing = -1;" in enemy_code and
          "RenderScale*facing*AuthoredFacing" in art_code,
          "Enemy facing must account for left-facing source sprites and preserve equipment mirroring")
    probe_code = (ASSETS/"RastaQuest/Runtime/NativeReviewProbe.cs").read_text()
    check("HUD Graphic missing CanvasRenderer" in probe_code and
          "restart button center blocked" in probe_code and
          "InputSystem.QueueStateEvent(mouse" in probe_code and
          "new KeyboardState(Key.R)" in probe_code,
          "Native probe must check HUD renderers and restart button input reachability")

    build = (ASSETS/"RastaQuest/Editor/ReviewBuild.cs").read_text()
    settings = (ROOT/"unity/ProjectSettings/ProjectSettings.asset").read_text()
    check("AndroidMinSdkVersion: 26" in settings and "AndroidTargetSdkVersion: 36" in settings,
          "ProjectSettings Android floor/target drift")
    check('Path.Combine(Application.dataPath, "Scenes")' in build and
          "Path.Combine(projectRoot,path)" in build,
          "Editor paths must resolve within Unity project")
    for term in ("com.tupiniquim.rastaquest.unityreview", "AndroidSdkVersions.AndroidApiLevel26", "AndroidSdkVersions)36",
                 "AndroidArchitecture.ARMv7|AndroidArchitecture.ARM64", "BuildOptions.Development"):
        check(term in build, f"Build source contract missing: {term}")
    check(not list(ASSETS.rglob("forest-art-target-v01.png")), "Concept imported into runtime")
    print(f"RQ_UNITY_SOURCE_OK: {len(names)} review PNGs, {frames} frames, {len(used)} references; Unity runtime NOT tested")

if __name__ == "__main__":
    main()
