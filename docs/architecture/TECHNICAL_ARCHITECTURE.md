# Rasta Quest — Technical Architecture

**Status:** APPROVED for 1.0  
**Engine:** Godot 4.5.1  
**Language:** typed GDScript, no .NET  
**Primary runtime:** Android landscape

## 1. Architecture principles

1. Keep gameplay code engine-native and simple.
2. Separate state, combat, presentation and data so scenes do not become monoliths.
3. Prefer composition over deep inheritance.
4. Use deterministic/seedable run randomness for debugging.
5. Keep all input behind Godot InputMap actions.
6. Avoid premature native C++ extensions.
7. Build for mobile constraints from the first playable, not at the end.
8. Every system must have a testable acceptance condition.

ADR 0002 supersedes the former C++ portable-core decision for 1.0.

## 2. Target project layout

```text
game/
├── project.godot
├── export_presets.cfg
├── scenes/
│   ├── main/
│   ├── player/
│   ├── enemies/
│   ├── boss/
│   ├── portals/
│   ├── world/
│   ├── hub/
│   └── ui/
├── scripts/
│   ├── core/
│   ├── player/
│   ├── combat/
│   ├── enemies/
│   ├── roguelike/
│   ├── progression/
│   ├── save/
│   └── ui/
├── data/
│   ├── upgrades/
│   ├── enemies/
│   ├── encounters/
│   └── biomes/
├── assets/
│   ├── characters/
│   ├── enemies/
│   ├── bosses/
│   ├── environments/
│   ├── effects/
│   ├── ui/
│   └── audio/
└── tests/
```

`assets/legacy/` at repository root stays outside the shipping Godot project until an asset is reviewed, normalized, licensed/provenanced and promoted into `game/assets/`.

## 3. Core runtime services

Recommended autoloads are intentionally few:

- `GameManager` — global application state and scene transitions;
- `RunManager` — run seed, progression, encounter depth, temporary upgrades;
- `SaveManager` — versioned local persistence and backup/recovery;
- `AudioManager` — music/SFX buses and transition control.

Avoid turning every subsystem into an autoload.

## 4. Player composition

`Player.tscn` should own:

- `CharacterBody2D`;
- visual/animation node;
- collision;
- attack/hurt areas;
- state machine/controller;
- stats/health;
- optional effect anchors.

Responsibilities remain split:

- movement/controller: velocity, gravity, jump, facing;
- state machine: legal transitions/priorities;
- combat: attack timing, hitbox enable windows, cooldowns;
- stats/health: damage, invulnerability, death;
- animation presenter: maps stable gameplay states to clips;
- lightning effect: separate proc/effect path, not embedded in animation-state ownership.

## 5. State priority

Minimum safe priority:

```text
Death
  > Hurt
  > PortalEnter
  > Attack
  > Air movement
  > Ground movement
```

This prevents lower-priority movement animation from interrupting death, hurt, portal entry or attack.

## 6. Input abstraction

Define actions, not hard-coded keys:

```text
move_left
move_right
jump
attack
pause
interact
```

Keyboard/gamepad exist for development. Android virtual controls invoke the same actions or controller methods, keeping gameplay logic device-independent.

## 7. Combat contract

- damage events carry source, amount and damage type;
- hitboxes are active only during explicit attack windows;
- hurtboxes own receive-damage behavior;
- invulnerability is time/state based;
- electrical proc is an effect attached to a successful eligible hit;
- chain/AOE upgrades subscribe to combat events rather than rewriting the base attack code.

This allows later upgrade composition without duplicating player attack logic.

## 8. Data-driven content

Use Godot `Resource` types (`.tres`) for authored game data where editor support is valuable:

- UpgradeData;
- EnemyData;
- EncounterData;
- BiomeData.

Keep runtime scripts generic. Content values should not be scattered across scene scripts.

## 9. Run generation

1. RunManager creates/stores seed.
2. Curated room/encounter templates are selected by depth and biome.
3. Encounter director respects budget/rules.
4. Reward screen samples valid upgrades.
5. Portal transition advances depth/biome.
6. Seed and important choices are logged in debug builds for reproduction.

The game does **not** procedurally generate arbitrary platform geometry for 1.0.

## 10. Save architecture

Save data must include:

- `schema_version`;
- meta currency/progression;
- unlocks/settings;
- accessibility settings;
- basic completion flags.

Requirements:

- atomic write where practical;
- previous-good backup;
- migration function for schema changes;
- corrupted-save fallback that preserves settings when possible;
- no secrets in save files.

## 11. Mobile performance budget

Performance work begins at RQ-001.

Rules:

- target 60 FPS on the supported reference tier;
- avoid unbounded particles;
- pool frequently spawned projectiles/effects if profiling proves allocation pressure;
- cap simultaneous enemies/effects;
- use texture atlases where beneficial;
- keep overdraw and full-screen transparent effects controlled;
- profile on physical Android devices before each major release gate.

A lower-end fallback may target 30 FPS only if explicitly documented in the support matrix; the design must remain deterministic and fair.

## 12. Testing strategy

### Every pull request

- repository structural checks;
- Godot project import/parse once the project exists;
- headless smoke scene load when possible;
- deterministic unit-like checks for pure logic;
- save schema validation.

### Gameplay gates

- controller state transitions;
- attack/hurt/death priority;
- portal transition;
- one-of-three upgrade selection;
- run seed reproducibility;
- save/load/migration;
- final-boss completion path.

### Human playtests

Automated tests cannot prove game feel. Each milestone from vertical slice onward requires recorded playtest findings.

## 13. CI evolution

- **RQ-000:** documentation/repository health only.
- **RQ-001:** Godot headless import + project boot smoke test.
- **RQ-002:** player-state smoke tests.
- **RQ-006:** Android debug export artifact.
- **RQ-009:** release export + automated package checks.
- **RQ-011:** release-candidate artifact and immutable tag candidate.

## 14. Security/privacy

1. no credentials in project/repository;
2. no unnecessary permissions in Android manifest;
3. offline-first core gameplay;
4. analytics/ads/IAP require a separate privacy/security review before integration;
5. signed release keys never belong in Git;
6. dependencies/plugins must have provenance and license recorded.

## 15. Dependency policy

Default to engine-native solutions. Third-party addons require:

- real need;
- active maintenance check;
- compatible license;
- Android compatibility;
- explicit entry in dependency documentation.

Paid plugins/services require separate approval.
