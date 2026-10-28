# Rasta Quest — Unity/Godot parity and evidence gates
Date: 2026-10-24. Scope: draft PR #82; reference Godot a13.3 on main `dd12bb3`. Status **Unity runtime UNKNOWN, commercial NO-GO**.

## Boundary
Godot automated tests and prior Galaxy A13 feedback are reference data, not proof of Unity readiness. Pure C# assertions, review-art hash checks and source CI do not establish Editor import, Unity compilation, correct controls, rendered HUD, Android binary, frame-time, cultural clearance or player acceptance. The 274 copied PNGs are transitional, not a commercially accepted illustrated art set. No concept painting is a native screenshot or game-ready background.

## First migration parity matrix

| Feature | Unity draft evidence | Required acceptance |
|---|---|---|
| Side camera, movement and double jump | Source/controller + independent JumpRules tests | Real Play Mode trajectories, collision, phone FPS |
| Axe combo, air attack, target dedupe | CombatRules + runtime adapter source | Exact three-hit timing, one hit per target, no phantom hurt |
| Circular guard, parry, projectile reflection | Source and pure C# rules | Blocking and reflecting against enemies/walls; no loop/double damage |
| Chaser and Ranged | Scripted room source | Readable tells, damage and interruptions, mobile encounter |
| Charger, controller, exploder, boss | **Not migrated** | Dedicated gameplay and performance tests |
| Portal, three-choice reward, heal | Room logic source | One portal; heal only by selection; other picks preserve current HP |
| Touch stick and multi-touch | TouchBinding/SliceInput source | Left, right, neutral, up jump; 2–3 fingers, hold+rotate |
| Pause/focus/resize | Source cancellation with pointer-owner reset | Repeat with held fingers; no orphaned pointer IDs after resume |
| HUD, vignette and safe area | Source-generated portrait and long health bar | Captures on real screen, fractional damage and accessibility |
| Forest/Castle/Caves | Transitional background switch | Production parallax/layers, complete traversable campaign |
| Saves, full upgrades, localization, music | **Not migrated** | Compatibility strategy and regression before engine replacement |
| Android release | Development build method only | Unity 6.3 minimum API25, target API36, ARMv7/ARM64, 16 KB packaging, signed tests |
| New illustrated art | One non-runtime concept scene | Character animation/rig, separated scenery, enemies, provenance, review |

## Source corrections prepared for validation

1. **Joystick center**: `TouchBinding.OnDrag` subtracts `RectTransform.rect.center` before normalizing, because UI controls have a top-left pivot; previously the origin was not at the visible stick center.
2. **Lost pointer-up**: `SliceInput.Cancel` notifies each bound `TouchBinding` to release its pointer ID when pause, reward, focus loss or screen resize interrupts touch. `SliceHud.Resize` delegates cancellation to this one path.
3. **Source contract CI**: `tools/check_unity_source_contracts.py` checks review image inventory/hashes, bridge references, durations, equipment transform lengths, required actors/biomes, explicit noncommercial status, Unity version, packages, Android source metadata and concept separation. Run with `python -B tools/sync_unity_review.py --check`. Neither command compiles Unity.

## Gate #80: real Editor and build
- [ ] Install Unity Hub Editor **6000.3.27f1** with Android Build Support, SDK/NDK/JDK (administrator confirmation still required).
- [ ] Owner handles account and license through Unity UI; never commit credentials.
- [ ] Open `unity/`; save exact Editor/package import logs and generated package lock.
- [ ] Run **Rasta Quest → Preparar sala Unity**, inspect Console, verify sprites/camera/HUD.
- [ ] Execute Windows and Android development builds in the real Editor; save hashes and relevant logs.
- [ ] Keep PR #82 in draft until compiled and reviewed.

## Gate #81: Unity Galaxy A13 acceptance
- [ ] Test stick left/right/neutral, upward jump, attack and defense simultaneously; test long press.
- [ ] Pause/resume with finger held; reward screen, app background/foreground, landscape rotation both ways, resize.
- [ ] Prove Chaser/Ranged, one-hit attack, parry, shot-wall response and no duplicated hits.
- [ ] Show 4.5/5 fractional health, healing only on choosing heal and one portal after clear.
- [ ] Capture true native frames and video/log hashes; monitor sustained FPS, memory and temperature.
- [ ] Verify target SDK/ABIs and native 16 KB alignment from generated APK/AAB (related #50).
- [ ] Record owner feedback on exact build; do not infer it from source checks.

## Art and release boundaries
#35 protagonist: lock anatomy, dreadlock silhouette, clothing, axe grip, poses, pivots, proportions and animation; #36 Forest: separate collision-safe foreground, gameplay, midground and background; #37 Chaser/Ranged: unique attacks and telegraphs; #38 cultural review: Rastafari/Xangô-inspired references and enemy motifs. Preserve approved identity but do not copy other games. Record licenses and human acceptance. No store submission, version 1.0 tag or Godot replacement until #80/#81, art and #50 release gate are explicitly passed.

References: [draft PR #82](https://github.com/tupiniquimtechsolution-blip/RastaQuest/pull/82), [Unity setup #80](https://github.com/tupiniquimtechsolution-blip/RastaQuest/issues/80), [A13 parity #81](https://github.com/tupiniquimtechsolution-blip/RastaQuest/issues/81), [art #35](https://github.com/tupiniquimtechsolution-blip/RastaQuest/issues/35), [Android #50](https://github.com/tupiniquimtechsolution-blip/RastaQuest/issues/50).

## Policy and platform cross-check (24/10/2026)

- Unity 6.3 minimum runtime Android 7.1 / API 25. Source review build now uses minSdk 25 rather than unsupported API 24; the previous Godot baseline and historical Android support must not be rewritten. Source: [Unity 6.3 system requirements](https://docs.unity.com/en-us/engine/6000.3/manual/get-started/install-and-upgrade/getting-started-installing-unity/system-requirements).
- Google Play normal mobile new-app/update submissions since 31 August 2026 must target Android 16 / API 36 or higher, subject to official exceptions/extensions; Play Console account eligibility has not been reviewed. Source: [Play API-level requirements](https://support.google.com/googleplay/android-developer/answer/11926878?hl=pt-br).
- Apps with native 64-bit libraries require correct 16 KB page support, including ELF LOAD and APK/AAB ZIP alignment; declaring an SDK target or using a supported Unity version does not prove the actual generated binary. Source: [Android 16 KB page sizes](https://developer.android.com/guide/practices/page-sizes?hl=pt-br).
- Validate the exact Unity build toolchain, Android ABI split and 16 KB compatibility using the real editor, generated artifacts, Play diagnostics and 16 KB environment. No such binary was produced in this source audit.
