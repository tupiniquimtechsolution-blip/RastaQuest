# Current State — Rasta Quest

**Date:** 2026-10-06  
**Repository:** `tupiniquimtechsolution-blip/RastaQuest`

## Executive status

- **Product:** Rasta Quest
- **Phase:** player-feel prototype validation
- **Active wave:** RQ-002
- **Playable implementation committed:** Yes — graybox movement prototype; combat not started
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
