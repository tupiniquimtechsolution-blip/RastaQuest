# Rasta Quest — Art & Animation Pipeline

**Status:** APPROVED framework  
**Purpose:** keep character identity consistent and convert legacy/reference material into production-ready mobile assets.

## 1. Source → review → production flow

```text
reference/source
      ↓
identity review
      ↓
pixel cleanup / frame consistency
      ↓
animation review
      ↓
mobile readability test
      ↓
provenance/license record
      ↓
promotion to game/assets/
```

Nothing in `assets/legacy/` becomes a shipping asset merely because it exists.

## 2. Locked protagonist traits from the raw source

- dark skin;
- thick dreadlocks tied back;
- red/yellow/green headband;
- green pants;
- brown boots;
- compact readable silhouette;
- double-bladed ritual axe;
- pixel-art treatment without blur/anti-aliasing.

Body markings, sacred/religious iconography and culturally specific symbols are **not auto-approved** by the source document; they require intentional reference and review.

## 3. Axe rules

- straight/slightly tapered handle;
- two clear symmetrical blades;
- readable silhouette;
- hand fully grips the handle;
- no weapon/body intersection;
- consistent center of mass and dimensions across frames;
- never drift toward a scythe/sickle silhouette.

## 4. Stable baseline animation names

```text
idle
run
jump
fall
attack_axe
attack_axe_air
hurt
death
lightning_proc
portal_enter
```

These are the integration API for early production.

The raw source later explores extended animation sets (walk, multiple jump phases, combo frames, defense, long-jump). Those are **reference candidates**, not automatic 1.0 engine requirements. Promote them only when a gameplay feature is approved.

## 5. Frame strategy

### MVP

Use the smallest readable frame count that proves gameplay:

- idle: ~4;
- run: ~6;
- jump/fall: minimal distinct poses;
- ground attack: ~4;
- air attack: minimal;
- hurt: ~2;
- death: ~4;
- portal/electric effect: short loops.

### Production

Increase frames only where motion readability and feel improve. Do not force every animation to 10 frames because a generation prompt once specified 10.

## 6. Export conventions

Production files should use deterministic names:

```text
player_idle_01.png
player_idle_02.png
player_run_01.png
...
fx_lightning_proc_01.png
portal_enter_01.png
```

Prefer atlas/sprite-sheet packaging when it improves import and memory behavior, but retain source working files outside shipping folders.

## 7. Visual QA checklist

- same character proportions across frames;
- same pixel density;
- stable baseline/feet alignment;
- weapon anatomy consistent;
- no accidental blur/antialiasing;
- silhouette readable at actual phone scale;
- attack anticipation/impact understandable without VFX;
- electrical VFX does not hide enemy telegraphs;
- transparent backgrounds clean;
- source/provenance known.

## 8. Cultural review gate

Before final marketing assets and 1.0 release:

- review Rastafari representation with appropriate cultural sensitivity;
- review use of Xangô-inspired imagery with knowledgeable cultural/religious consultation;
- avoid reducing either tradition to stereotypes, generic “tribal” decoration or villain imagery;
- document approved iconography/terminology in an art/narrative appendix.

This review is a release-quality requirement, not a gameplay-implementation blocker.
