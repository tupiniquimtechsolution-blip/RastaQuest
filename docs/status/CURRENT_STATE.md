# Current State — Rasta Quest

**Date:** 2026-10-24
**Repository:** `tupiniquimtechsolution-blip/RastaQuest`

## 2026-10-24 Unity source hardening (draft PR #82)

[Unity parity matrix](../production/UNITY_PARITY_GATE_2026-10-24.md) tracks touch-center correction, pointer ownership cleanup, source CI and evidence gates. Source checks do not replace Editor build or device acceptance; #80/#81 and Gold remain open.

## New direction — Unity and detailed illustrated 2D

Rodrigo selected detailed illustrated 2D and requested Unity for graphics, movement and polish. [ADR 0003](../adr/0003-unity-illustrated-direction.md) records the migration target; [the technical study](../product/COMBAT_ART_REFERENCE_STUDY_2026-10-24.md) separates verified reference mechanics, image observations and original proposals. `unity/` is a separate review prototype, with the Godot APK retained as functional baseline. Runtime/build verification and final illustrated animation remain gates; Godot CI green is not proof of Unity readiness. See [Unity project status](../../unity/README.md).

## Latest A13 feedback — 2026-10-23

Next polish candidate a13.3 synchronizes attack phases/poses and speed upgrades, cancels buffered inputs on pause/focus/rotation, preserves short stride transitions, improves fractional-health/healing feedback and gives returned shots bounded native-art trails with reduced-effects support. See [polish scope, verification and pending gates](../production/A13_POLISH_2026-10-23.md). Physical/final visual acceptance and commercial approval remain pending.

Second physical feedback round: a13.2 adds circular held defense, 280 ms perfect window, returned ranged shots, upward-stick jump/double jump, raised one-way platforms, hostile contact separation, eight-pose run, three broad axe combo clips and explicit repeatable portal restoration. See [second-round implementation and gates](../production/A13_FLOW_2026-10-23.md). The previous a13.1 feedback is partial; exact a13.2 physical/visual acceptance remains pending and commercial GOLD remains NO-GO.

Rodrigo tested visual.1 on the physical Galaxy A13 and reported good basic movement with concrete visual/control/combat/world corrections. This is partial feedback, not final acceptance. The a13.1 candidate implements analog multitouch controls, PT-BR default + Spanish, both landscape orientations, +15% candidate character art, explicit attack phases, circular warnings, fractional half-damage perfect defense and upgrades, and multi-screen portal-linked biomes. See `docs/production/A13_FEEDBACK_2026-10-23.md` for files, checks, scope and remaining gates. Commercial promotion and GOLD remain **NO-GO** pending exact-version physical review, final visual acceptance, rights/culture and remaining release criteria.

## Executive status

- **Product:** Rasta Quest
- **Phase:** technical release-candidate / Gold preflight
- **Active wave:** RQ-011 acceptance (NO-GO)
- **Playable implementation committed:** Yes — technical full-campaign graybox through final boss; production acceptance incomplete
- **Engine decision:** Godot 4.5.1 / GDScript
- **Primary target:** Android landscape
- **Perspective:** 2D side-scrolling action-platformer
- **Roguelike structure:** portal-linked runs + upgrades + light meta progression

## What changed after the RASTA QUEST source upload

The uploaded raw document materially resolved the previous ambiguity around product direction. After full structural reading of the 4,830-line source document (including its embedded image payloads), the approved canon now favors the recurring explicit Rasta Quest direction:

- Godot 4.5.1;
- GDScript/no .NET;
- Android;
- platformer movement;
- stable baseline animation API;
- axe/Xangô-inspired electrical identity;
- forest/castle/cave content spine;
- portal roguelike loop;
- light meta progression.

The source contains accumulated working material and later expansions, so it is preserved as raw evidence rather than treated line-for-line as a build specification.

## Canonical decisions

- Rasta Quest is the current product name.
- Portal's Edge: Last Stand is design lineage/legacy.
- PortalAscendant is an old Unity prototype codename.
- ADR 0001 is superseded by ADR 0002.
- C++ portable core is not a 1.0 requirement.
- PS3 is not a 1.0 gate.
- monetization/live-service systems are deferred from gameplay implementation.
- three V1 biomes: forest, castle, cave.
- one final production boss for 1.0.
- historical extra dimensions are post-1.0 candidates.

## Repository source classification

### Canonical

- `docs/product/GAME_CANON.md`
- `docs/roadmap/MASTER_RELEASE_PLAN.md`
- `docs/architecture/TECHNICAL_ARCHITECTURE.md`
- `docs/adr/0002-godot-gdscript-android-first.md`
- `docs/release/RELEASE_CRITERIA.md`

### Raw evidence

- `docs/source/RASTA_QUEST_RAW.md`

### Legacy

- DOCX GDD/research files;
- Portal's Edge PE roadmap;
- Unity/PortalAscendant generated metadata;
- old concept/sprite exports under `assets/legacy/`.

## Remaining non-blocking historical recovery

Documento Mestre v3.0 and Planejamento 2.0 referenced by the old PE roadmap are still absent. They are useful for archive completeness but are **no longer implementation blockers** because the owner approved the new integrated canonical plan.

## RQ-001 evidence

- real `game/project.godot` committed;
- canonical project directories materialized;
- InputMap action contract declared;
- minimal main scene and boot controller committed;
- Android Debug export preset and clean-clone instructions documented;
- GitHub Actions run `37460705294` — **Godot Project CI: SUCCESS**;
- engine version verification: PASS;
- headless project import/parse: PASS;
- main-scene smoke boot: PASS;
- tracked Godot-cache rejection: PASS;
- Repository Health: PASS.

## RQ-002 automated evidence

- CharacterBody2D controller implemented;
- left/right acceleration/deceleration, gravity, jump and fall implemented;
- coyote time and jump buffering implemented;
- Idle/Run/Jump/Fall state resolver implemented;
- facing and Camera2D follow implemented;
- death-plane respawn implemented;
- keyboard/gamepad defaults are centralized behind InputMap;
- Android-style touch left/right/jump prototype uses the same InputMap actions;
- graybox player-feel room boots through the normal main scene;
- GitHub Actions run `37461430703` — **Godot Project CI: SUCCESS**;
- 100 full state-transition cycles: PASS.

## RQ-002 remaining acceptance

- [ ] measure 60 FPS target on a reference Android device;
- [ ] verify two-thumb phone-scale controls;
- [ ] record movement feedback from at least 3 external playtesters.

## Next action

Perform the RQ-002 device/playtest acceptance. **RQ-003 combat remains gated** until these criteria are evidenced.


## RQ-003 through RQ-010 technical progression

The repository now contains and has CI evidence for the automated/technical portions of:

- RQ-003 axe combat and electrical effects;
- RQ-004 data-driven enemy framework;
- RQ-005 seedable roguelike run core;
- RQ-006 Corrupted Forest technical vertical slice;
- RQ-007 three-biome technical Alpha campaign spine;
- RQ-008 settings, accessibility, localization and narrative structure;
- RQ-009 save migration/recovery and Beta technical hardening;
- RQ-010 Android technical RC preparation and ephemeral debug APK evidence.

These waves retain open human/device/production acceptance criteria in their GitHub issues and are not falsely marked complete in the master tracker.

## RQ-011 Gold preflight

- PR #33 merged as `a2a92c6`;
- Gold Preflight run `37494134903`: SUCCESS;
- full automated RQ-001→RQ-010 regression: PASS;
- tracked release-key/keystore scan: PASS;
- version under evaluation: `1.0.0-rc.1`;
- save schema: `2`;
- technical debug APK SHA-256: `631995b2db3b5940b6a8a03d33949fdd47a146efae0d44f2eb99acf8db4174dc`;
- rollback technical RC source: `2c08f6be94e02402511021f4e96500b85a182235`;
- formal decision: **NO-GO**.

## Remaining blockers before Gold GO

- physical Android performance, lifecycle and touch acceptance;
- required external playtests and Beta-run evidence;
- combat/run feel acceptance;
- production-quality art/audio and final licensing inventory;
- cultural representation review;
- final store media/privacy/content-rating review;
- external production signing key;
- signed release AAB/APK clean-install validation;
- zero known blocker/critical defects confirmed at final acceptance.

## Next action

Do not create `v1.0.0` or publish RQ-012 while RQ-011 is NO-GO. The correct continuation is to close the remaining device/human/production/signing acceptance evidence, then rerun Gold preflight on the exact final candidate.
