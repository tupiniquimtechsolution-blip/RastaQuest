# Rasta Quest — Master Plan to Playable 1.0 Release

**Status:** APPROVED  
**Plan version:** 1.0  
**Primary target:** Android landscape  
**Engine:** Godot 4.5.1 / GDScript

This roadmap replaces the former PE-000→PE-016 plan as the active 1.0 execution path. The old plan remains archived because it contains useful design/engineering ideas and project history.

## Release definition

“Final playable 1.0” means:

- clean install on supported Android devices;
- complete path from first launch → tutorial/onboarding → run → three biomes → final boss → victory → saved meta state → new run;
- no known blocker/critical bugs;
- stable touch controls;
- production art/audio for all required 1.0 content;
- save/load and upgrade install tested;
- performance within the support matrix;
- store/release package signed and documented;
- accessibility and cultural review gates passed.

## Execution rules

- a wave cannot be accepted while its blocking criteria are red;
- polish cannot substitute for failed core-gameplay validation;
- new systems must be justified against 1.0 scope;
- every wave ends with evidence: commit/PR, automated checks where possible, and human playtest notes where relevant;
- no direct jump to content-heavy waves before the vertical slice.

---

## RQ-000 — Canonicalization & repository governance

**Goal:** establish one product truth and preserve all historical material.

### Deliverables

- canonical product definition;
- approved 1.0 technical architecture;
- archived raw Rasta Quest source;
- archived PE roadmap;
- ADR superseding C++/PS3-first architecture;
- master release plan;
- release criteria;
- repository health CI.

### Definition of Done

- [x] Rasta Quest is the canonical current product name.
- [x] Godot 4.5.1 + GDScript + Android landscape is approved.
- [x] side-scrolling action-platformer perspective is approved.
- [x] portal roguelike loop is defined.
- [x] legacy technical directions are clearly separated.
- [x] final 1.0 plan exists.

---

## RQ-001 — Godot project bootstrap & CI

**Goal:** create the real shipping project skeleton before gameplay implementation.

### Work

1. Create `game/project.godot`.
2. Create canonical scene/script/data/assets directories.
3. Configure InputMap actions.
4. Add minimal main scene.
5. Configure Android project/export prerequisites using free/open tooling where possible.
6. Add headless project import/parse CI.
7. Add debug build/version info.
8. Create a placeholder boot screen proving the project launches.

### DoD

- [ ] project opens without import errors;
- [ ] main scene starts;
- [ ] CI parses/imports project successfully;
- [ ] Android debug export path is documented;
- [ ] no generated editor caches tracked;
- [ ] clean clone can follow README to boot the project.

**Gate:** no gameplay content until the skeleton is reproducible.

---

## RQ-002 — Player feel prototype

**Goal:** prove the platformer controller and animation contract.

### Work

- CharacterBody2D controller;
- left/right movement;
- gravity;
- jump + fall;
- facing;
- stable state machine;
- development keyboard/gamepad mapping;
- Android virtual controls prototype;
- placeholder or validated legacy sprites;
- camera follow;
- death plane/restart test.

### Baseline animation contract

`idle, run, jump, fall`

### Playtest criteria

- controller does not feel delayed;
- jump arc is readable;
- state transitions never fight;
- phone-scale controls are usable with two thumbs.

### DoD

- [ ] 60 FPS target met in empty gameplay scene on reference Android device;
- [ ] no stuck movement/animation states in 100 repeated transitions;
- [ ] input works through InputMap, not hard-coded device keys;
- [ ] at least 3 external playtesters complete the movement test and feedback is recorded.

---

## RQ-003 — Axe combat & Xangô-inspired electricity

**Goal:** make the core combat satisfying before adding enemy variety.

### Work

- ground attack;
- aerial attack;
- hitbox/hurtbox;
- damage and knockback;
- short invulnerability after player damage;
- hurt/death states;
- hit pause/impact feedback;
- electrical proc;
- chain-lightning upgrade prototype;
- on-kill AOE upgrade prototype.

### Animation contract added

`attack_axe, attack_axe_air, hurt, death, lightning_proc`

### DoD

- [ ] damage cannot double-fire unintentionally from one attack window;
- [ ] attack/hurt/death state priorities are deterministic;
- [ ] electrical proc is testable with fixed RNG seed;
- [ ] combat remains readable with VFX reduced/disabled;
- [ ] players can explain when and why damage happened.

**Gate:** if combat is not fun with placeholder art, do not advance by adding content.

---

## RQ-004 — Enemy framework & encounter language

**Goal:** prove one reusable enemy architecture can express the V1 roster.

### Required behaviors

1. Chaser/Knight.
2. Ranged/Archer-Mage.
3. Runner/Charger.
4. Area-controller/Poisoner.
5. Exploder as optional elite/variant.

### Work

- EnemyBase composition;
- stats/data resources;
- health/death;
- detection;
- attack tells;
- simple encounter director/budget;
- spawn points;
- caps for simultaneous high-threat attacks.

### DoD

- [ ] four primary behaviors are distinguishable without labels;
- [ ] enemy stats are data-driven;
- [ ] no unavoidable stacked burst in the baseline encounter suite;
- [ ] 20-minute stress encounter does not leak/spawn without bound;
- [ ] mobile performance budget remains green.

---

## RQ-005 — Roguelike run core

**Goal:** convert combat rooms into a replayable run.

### Work

- RunManager + seed;
- curated room templates;
- encounter selection by depth/biome;
- portal appears after encounter completion;
- portal entry transition;
- one-of-three upgrade reward;
- temporary upgrade application;
- run death/reset;
- debug log for seed + major choices.

### Upgrade target for this wave

- at least 12 functional upgrades;
- at least 3 observable synergies;
- include chain lightning and on-kill AOE.

### DoD

- [ ] a player completes 10+ sequential encounters without manual scene reset;
- [ ] same debug seed reproduces encounter sequence;
- [ ] upgrade selection never offers invalid/null data;
- [ ] death clears temporary run state;
- [ ] no transition soft-locks in 100 automated/manual portal cycles.

---

## RQ-006 — Vertical Slice: Floresta Corrompida

**Goal:** first honest representation of final quality.

### Content

- Refúgio/Santuário basic loop;
- one production-quality forest biome;
- 6–8 curated room templates;
- 4 enemy archetypes;
- 1 elite variant;
- 12–18 upgrades;
- first complete meta-progression save;
- one production-quality mini/final-slice boss encounter;
- HUD, pause, audio mix, touch controls;
- death → hub → new-run flow.

### DoD

- [ ] full hub-to-boss slice playable on Android;
- [ ] no blocker bug in five consecutive full runs;
- [ ] save survives app restart;
- [ ] production art pipeline proven end-to-end;
- [ ] playtest feedback supports “responsive” movement and combat;
- [ ] slice can be shown to an external reviewer without developer explanation.

**Milestone:** VERTICAL SLICE ACCEPTED.

---

## RQ-007 — Alpha: complete 1.0 content spine

**Goal:** make the whole game completable with unfinished polish.

### Biomes

1. Floresta Corrompida.
2. Castelo Fraturado.
3. Cavernas dos Ecos.

### Content target

- 18–24 total room templates across the three biomes;
- 4 core enemy behaviors with biome variants;
- elite modifiers;
- 18–24 upgrades;
- at least 5 synergies;
- final boss implemented;
- complete run progression;
- victory flow;
- hub progression;
- placeholder-complete narrative/lore.

### DoD

- [ ] game is completable from fresh save to final victory;
- [ ] no missing required scene;
- [ ] all upgrade paths have data validation;
- [ ] final boss can be defeated without debug tools;
- [ ] fresh save and progressed save both work.

**Milestone:** FEATURE COMPLETE / ALPHA.

---

## RQ-008 — Narrative, UX, audio & accessibility production

**Goal:** turn feature-complete Alpha into a coherent player-facing game.

### Work

- onboarding/tutorial;
- concise portal-fracture narrative;
- hub NPC/lore delivery;
- final naming/lore for boss;
- full HUD/menu/settings;
- touch-control customization;
- vibration toggle;
- screen-shake setting;
- flash-reduction setting;
- audio sliders;
- final biome ambience/music layers;
- combat/portal/boss SFX;
- first-pass localization structure;
- cultural representation review.

### DoD

- [ ] new player understands controls without developer help;
- [ ] critical UI works on supported aspect ratios;
- [ ] accessibility options actually affect runtime behavior;
- [ ] no unlicensed/temp audio remains in release-content folders;
- [ ] cultural review findings are resolved or explicitly accepted.

---

## RQ-009 — Beta: balance, performance & save hardening

**Goal:** stop adding features and remove release risk.

### Work

- closed playtest;
- difficulty curve;
- upgrade pick/win-rate analysis;
- boss tuning;
- frame-time profiling;
- memory profiling;
- effect/enemy caps;
- battery/thermal observation;
- save schema migration test;
- corrupted-save recovery test;
- clean install/update install test;
- Android lifecycle: pause/background/resume.

### DoD

- [ ] zero known blocker bugs;
- [ ] no repeatable critical save-loss path;
- [ ] target performance met on reference support matrix;
- [ ] no known encounter soft-lock;
- [ ] at least 20 complete beta runs recorded across testers/devices;
- [ ] balance outliers documented and resolved/deferred intentionally.

**Milestone:** BETA ACCEPTED.

---

## RQ-010 — Release Candidate preparation

**Goal:** produce a store-ready candidate without changing core features.

### Work

- application ID/versioning;
- signing workflow;
- final icon/splash/screenshots;
- store description and privacy declarations;
- age/content-rating inputs;
- permission audit;
- credits and third-party licenses;
- final monetization decision (if still none, ship without it);
- release notes;
- support/contact path;
- backup/rollback instructions.

### DoD

- [ ] signed AAB/APK candidate installs cleanly;
- [ ] release key remains outside Git;
- [ ] store assets reflect actual gameplay;
- [ ] permissions are minimal and documented;
- [ ] privacy text matches actual integrations;
- [ ] credits/licenses complete.

---

## RQ-011 — Gold Candidate

**Goal:** freeze the exact build intended for 1.0.

### Rules

- only blocker/critical fixes permitted;
- every fix requires targeted regression;
- content is frozen;
- save schema is frozen unless a blocker demands change.

### Final regression

- fresh install;
- upgrade install;
- first-run tutorial;
- full run through all biomes;
- death/restart;
- final boss/victory;
- settings persistence;
- background/resume;
- offline play;
- low-storage/error behavior where practical.

### DoD

- [ ] zero known blocker/critical defects;
- [ ] all release criteria green;
- [ ] build hash/version recorded;
- [ ] signed artifact reproducible through documented process;
- [ ] rollback artifact preserved;
- [ ] GO decision recorded.

**Milestone:** GOLD / GO.

---

## RQ-012 — 1.0 Release

**Goal:** publish the approved Gold Candidate.

### Work

- create immutable `v1.0.0` tag;
- attach/document release artifact metadata;
- publish to approved Android distribution channel;
- monitor first-day crash/support feedback;
- triage only release-impacting issues;
- publish known issues if any accepted non-critical defect remains.

### DoD

- [ ] released build matches Gold Candidate;
- [ ] store/public version is installable;
- [ ] support path works;
- [ ] release notes published;
- [ ] project status updated to RELEASED;
- [ ] post-release backlog separated from 1.0 scope.

**Milestone:** RASTA QUEST 1.0 PLAYABLE RELEASE.

---

## RQ-013 — Post-release stabilization

Not part of the “build 1.0” gate, but required operational follow-through.

- hotfix branch/process;
- crash/support triage;
- v1.0.x fixes;
- validate retention/feedback only if privacy-approved telemetry exists;
- prioritize post-1.0 content separately.

Candidate future work:

- Ruínas Esquecidas expansion;
- Cidade dos Autômatos;
- Deserto dos Ecos;
- endless mode;
- public PC build;
- PS3 homebrew feasibility research;
- co-op research.

## Critical path

```text
RQ-000
  ↓
RQ-001
  ↓
RQ-002
  ↓
RQ-003
  ↓
RQ-004
  ↓
RQ-005
  ↓
RQ-006  ← vertical slice gate
  ↓
RQ-007  ← feature complete
  ↓
RQ-008
  ↓
RQ-009  ← beta
  ↓
RQ-010  ← RC prep
  ↓
RQ-011  ← gold
  ↓
RQ-012  ← 1.0 release
```

## Principal risks

| Risk | Impact | Control |
|---|---|---|
| inconsistent AI-generated art | high | locked art bible + human cleanup + promotion gate |
| cultural misuse/stereotype | high | documented review before marketing/release |
| mobile performance discovered late | high | physical-device profiling from RQ-002 onward |
| scope growth from legacy ideas | high | 1.0 exclusions + wave gates |
| animation/state bugs | high | stable animation API + priority state machine |
| save loss | critical | versioning, backup, migration tests |
| random unfair encounters | high | encounter budget + curated rooms + seed reproduction |
| boss/content volume delays | medium/high | one final 1.0 boss; expansion content deferred |
| monetization distracts from shipping | medium | separate decision; not 1.0 gameplay blocker |

## Planning note

No calendar dates are committed here because team size, weekly capacity and art throughput have not been verified. The roadmap is **gate-driven**. Once execution capacity is known, each RQ wave can be scheduled without changing scope or Definition of Done.
