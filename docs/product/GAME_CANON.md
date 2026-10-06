# Rasta Quest — Canonical Game Definition

**Status:** APPROVED  
**Version:** 1.0-preproduction  
**Recorded:** 2026-10-06

## 1. Canonical identity

| Item | Decision |
|---|---|
| Product name | **Rasta Quest** |
| Engine | **Godot 4.5.1** |
| Language | **GDScript, no .NET** |
| Primary platform | **Android** |
| Orientation | **Landscape** |
| Genre | **2D action-platformer + light roguelike** |
| Visual direction | Pixel-art / hand-drawn pixel aesthetic, readable on mobile |
| Protagonist | Rastafarian-inspired medieval warrior |
| Signature weapon | Double-bladed ritual axe inspired by Xangô axe imagery |
| Signature power | Controlled electrical effects |
| Run structure | Portal-linked encounters + one-of-three upgrade choices |
| Meta progression | Light, permanent, non-run-breaking |
| Public multiplayer | Not in 1.0 |

## 2. One-sentence pitch

A Rastafarian-inspired warrior crosses corrupted dimensional portals, fighting with a heavy double-bladed axe and restrained lightning powers while building temporary run synergies and permanent strength to restore balance to a fractured medieval world.

## 3. Design pillars

### 3.1 Movement must feel good before content scales

The player runs, jumps, falls, attacks on the ground and in the air, receives damage, dies and enters portals. Input response and animation-state correctness are more important than content quantity.

### 3.2 Axe combat is the tactile center

The axe must feel heavy without feeling slow to control. Hit confirmation, readable anticipation, hit pause, impact audio, camera feedback and consistent attack windows matter more than long combo lists.

### 3.3 Electricity is identity, not visual noise

The original Rasta Quest source explicitly closes V1 around three electrical ideas:

1. electric damage/proc on axe attacks;
2. chain-lightning as an upgrade;
3. area lightning on kill as an upgrade.

Additional lightning variants require a later balance/content decision.

### 3.4 Portals create the roguelike rhythm

A run is a sequence of combat spaces connected by portals. Completing an encounter unlocks progression, rewards the player and moves the run forward.

### 3.5 Scope remains readable on mobile

UI, controls, effects, enemy tells and level layouts must remain understandable on a phone screen. New systems are rejected when they add complexity without improving the run.

## 4. Integrated world concept

The historical Portal's Edge material contributed a strong world premise: reality has fractured, unstable portals connect corrupted places, and each run reveals more about the collapse.

Rasta Quest reinterprets that premise through its medieval/pixel-art identity.

### Canonical premise

The world has been split by dimensional fractures. Settlements survive in isolated pockets while corrupted portals bleed hostile creatures and unstable energy into familiar places. The protagonist can cross these fractures and is drawn into the task of restoring balance while discovering who or what opened them.

The hub between runs is the **Refúgio/Santuário**: a safe location for permanent progression, lore, loadout decisions and later NPC functions.

### Narrative tone

- mysterious and dark without becoming hopeless;
- stylized rather than realistic;
- room for dry/sarcastic NPC humor inherited from the historical concept;
- lore delivered in short mobile-friendly fragments, not mandatory long dialogue.

## 5. Protagonist canon

The raw Rasta Quest source repeatedly locks these visual traits:

- dark skin;
- thick dreadlocks tied back;
- red/yellow/green headband;
- green pants;
- brown boots;
- strong compact silhouette;
- double-bladed ritual axe.

The source also uses a generic phrase equivalent to “tribal details.” That phrase is **not sufficient as a production specification**. Any body markings, religious symbols, clothing symbolism or direct references to Rastafari/Xangô must be deliberately designed and culturally reviewed before final marketing/release.

The historical protagonist **Axel** is not the 1.0 player identity. Axel remains legacy design material.

## 6. Player gameplay contract

### Baseline animation API

These names are stable integration contracts for the first playable implementation:

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

They may be backed by richer AnimationTree states later, but gameplay code must not casually invent alternate public clip names.

### Movement

- left/right movement;
- jump;
- gravity and fall state;
- responsive acceleration/deceleration;
- coyote time and jump buffering may be added during feel tuning;
- touch controls must map cleanly to the same action layer used by keyboard/gamepad development input.

### Combat

1. ground axe attack;
2. aerial axe attack;
3. damage/hurt with short invulnerability window;
4. death/end-run flow;
5. electrical proc chance;
6. later V1 polish may extend the ground attack into a short 1-2-3 combo without changing the core input contract.

A heavy/charged attack, guard/defense and dash are **not baseline requirements**. They are candidates only after the vertical slice proves the core feel.

## 7. Roguelike loop

```text
Refúgio/Santuário
      ↓
Start run
      ↓
Combat encounter
      ↓
Reward / choose 1 of 3 upgrades
      ↓
Portal
      ↓
Next encounter / escalating difficulty
      ↓
Biome transition
      ↓
Final boss
      ↓
Victory OR death
      ↓
Meta rewards + save
      ↓
Refúgio/Santuário
```

### Run rules

- a run must be finishable offline;
- upgrade choices are temporary unless explicitly marked meta;
- run RNG should be seedable for debugging/reproduction;
- early encounters teach; later encounters combine archetypes;
- healing/recovery opportunities must be predictable enough to avoid purely random failure;
- procedural composition uses curated room templates, not unconstrained random geometry.

## 8. Upgrade model

V1 targets a compact pool rather than hundreds of effects.

### Families

- axe damage/range/impact;
- movement and jump utility;
- survivability;
- cooldown/electrical chance;
- chain lightning;
- on-kill area lightning;
- risk/reward corrupted modifiers after the base pool is stable.

### Target for 1.0

- **18–24** meaningful upgrades;
- at least **5** clear synergies;
- 3-choice reward screen;
- no upgrade that exists only as a cosmetic number change without visible gameplay consequence;
- new upgrades are data-driven where practical.

## 9. Enemy roster model

Historical Rasta Quest and Portal's Edge material are merged by **behavior archetype**, not by forcing every old visual concept into 1.0.

### Required V1 archetypes

1. **Chaser / Knight** — closes distance and attacks in melee.
2. **Ranged / Archer or Mage** — maintains distance and telegraphs projectiles.
3. **Runner / Charger** — commits to a fast lane attack and can be punished after missing.
4. **Area controller / Poisoner or caster** — creates temporary unsafe ground.
5. **Exploder** — optional elite/variant; threatens space on death.

Biomes reskin and tune archetypes instead of requiring a brand-new AI framework for every enemy.

## 10. V1 world structure

The raw Rasta Quest source defines three environment pillars: **forest, castle and cave**. These become the 1.0 content spine.

### Biome 1 — Floresta Corrompida

- onboarding biome;
- layered forest/roots/fog;
- introduces Chaser and Ranged;
- environmental hazards remain simple and readable.

### Biome 2 — Castelo Fraturado

- denser combat spaces;
- knights, mages and chargers;
- traps/doors/verticality;
- narrative evidence of the dimensional collapse.

### Biome 3 — Cavernas dos Ecos

- darker, more dangerous final region;
- area control and elite combinations;
- electrical/portal instability;
- leads to the final boss.

Historical Ruínas Esquecidas, Cidade dos Autômatos and Deserto dos Ecos remain strong **post-1.0 expansion candidates** rather than being discarded.

## 11. Boss

1.0 requires one fully production-ready final boss with:

- clear tells;
- multiple attack patterns;
- at least two combat phases;
- no unavoidable damage;
- mobile-readable VFX;
- death/victory flow tied to run completion.

The historical **O Abominável** is retained as a design seed and may be adapted into the final corrupted guardian. The final visual/lore name is an art/narrative production decision, not an engine blocker.

A boss should not portray Xangô or any living religious figure as an enemy without explicit cultural/narrative review.

## 12. Meta progression

Between runs the player can permanently improve a small set of baseline attributes and unlock options.

Initial allowed categories:

- base health;
- base axe damage;
- initial electrical-proc chance;
- ability cooldown reduction;
- later unlocks that add options rather than only multipliers.

Save data must be versioned and recoverable.

## 13. Art direction

- pixel-art readability before detail;
- consistent pixel density and silhouette;
- transparent character sheets;
- no antialiasing/blur in production sprites;
- weapon anatomy must remain consistent;
- axe must remain readable as a double-bladed ritual axe, not drift into a scythe;
- effects should preserve silhouette readability;
- source/processed/final art must be separated in the asset pipeline.

See `docs/production/ART_PIPELINE.md`.

## 14. Audio direction

Inherited useful themes:

- music grows in intensity during combat;
- biome-specific ambience;
- strong axe impact layers;
- short electrical cue;
- distinct portal-open/portal-enter sound;
- boss layer adds weight rather than simply increasing loudness.

1.0 should use original or properly licensed audio only.

## 15. Accessibility baseline

Required by 1.0 planning:

- touch-control size/position adjustment;
- vibration on/off;
- screen-shake intensity;
- flash/electrical effect reduction;
- readable damage feedback;
- contrast/readability pass;
- pause;
- audio sliders;
- hold/toggle decisions documented for any repeated input.

## 16. Monetization scope

Historical F2P documents proposed rewarded ads, currencies, revives, battle pass and progression acceleration. Those concepts conflict with the current priority of reaching a clean playable 1.0.

**Decision for the approved 1.0 plan:** monetization mechanics are not implementation blockers and are excluded from gameplay scope until a separate product decision is approved.

Absolute rule retained from the historical intent: **no pay-to-win design**.

## 17. Explicit 1.0 exclusions

- online co-op;
- endless mode;
- battle pass;
- revive purchases;
- 20 production portals/biomes;
- PS3 shipping target;
- Unity implementation;
- C++ portable gameplay core;
- full live-service backend;
- procedural geometry generation;
- large narrative branching system.

These can be reconsidered only after 1.0 is stable.

## 18. Legacy integration matrix

| Historical element | 1.0 treatment |
|---|---|
| Rasta warrior + axe | Canonical |
| Xangô-inspired lightning | Canonical, culturally reviewed |
| Godot/GDScript/Android | Canonical |
| Side-scrolling platformer | Canonical |
| Portal runs | Canonical |
| Three-choice upgrades | Canonical |
| Light meta progression | Canonical |
| Forest/castle/cave | Canonical V1 content spine |
| Fractured-dimensional-world premise | Integrated |
| Refuge/hub | Integrated |
| Exploder/Archer/Runner/Poisoner behaviors | Integrated as archetypes |
| O Abominável | Retained as boss design seed |
| Axel | Legacy |
| 360° arena combat | Superseded |
| C++ engine-agnostic core | Superseded for 1.0 |
| PS3 gate | Post-1.0 research |
| Unity/PortalAscendant | Legacy |
| F2P battle pass/revives | Deferred, non-canonical for 1.0 |
| 20 portals | Post-1.0 content library |
| Co-op/endless | Post-1.0 candidates |
