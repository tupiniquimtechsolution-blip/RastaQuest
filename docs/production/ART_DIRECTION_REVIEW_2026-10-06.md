# Rasta Quest — Art Direction Review

**Review date:** 2026-10-06  
**Source commit:** `490f09e7922e6500f39d8b4a6fd2f21ea84620b6`  
**Decision:** approved as canonical visual-development direction; **not approved as shipping/runtime art**.

## Reviewed material

| Canonical asset | Role | Direction decision | Runtime readiness |
|---|---|---|---|
| `assets/concepts/characters/protagonist/rq-protagonist-character-bible-v01.png` | protagonist identity/model sheet | APPROVED-DIRECTION | NOT READY |
| `assets/concepts/characters/protagonist/rq-protagonist-animation-board-v01.png` | motion/animation reference | APPROVED-MOTION-REFERENCE | NOT READY |
| `assets/concepts/environments/rq-world-visual-bible-v01.png` | biome/hub visual bible | APPROVED-DIRECTION | NOT READY |
| `assets/concepts/enemies/rq-enemy-roster-v01.png` | V1 enemy roster language | APPROVED-ROSTER-DIRECTION | NOT READY |

## 1. Protagonist — character bible

### What is working

- the character reads immediately as the Rasta Quest protagonist;
- dark skin, tied-back thick dreadlocks, red/yellow/green headband, green pants and brown boots preserve the locked canon;
- the double-bladed axe has a strong, symmetric silhouette and clearly remains the focal weapon;
- front/side/back/3-quarter views, facial studies, hair breakdown, weapon studies, scale silhouette and palette make the sheet useful as a real production bible;
- the restrained blue electrical treatment separates the protagonist's power language from the red/magenta corruption language used by enemies;
- the design avoids obvious marijuana/reggae-mascot clichés.

### Corrections before production sprites

- the hero is more muscular and visually larger than the canonical "compact readable silhouette"; gameplay scale should be reduced and simplified;
- the axe ornamentation and center medallion are too detailed for phone-scale sprites and must be simplified without losing the two-blade silhouette;
- dreadlock count, bead placement, cloth ornaments and weapon proportions must be locked numerically before frame production;
- jewelry/body adornment must remain intentional and pass cultural review rather than becoming generic decorative shorthand;
- high-resolution illustrated pixel treatment must be translated to one fixed gameplay pixel density.

## 2. Protagonist — animation board

### What is working

- run, jump, ground attack, aerial attack, hurt, death, lightning and portal actions are visually readable;
- axe attack arcs communicate anticipation and impact;
- lightning reads as a special state rather than constant noise;
- portal entry has a clear direction and silhouette transition.

### Corrections before sprite-sheet extraction

The small generated strips are **motion reference**, not final animation frames. Across frames there are normal generative inconsistencies in:

- axe length, blade geometry and angle;
- dreadlock mass/count;
- limb proportions and torso width;
- cloth/accessory placement;
- perspective and ground baseline;
- effect shape and pixel density.

Production must rebuild the baseline API deliberately:

`idle, run, jump, fall, attack_axe, attack_axe_air, hurt, death, lightning_proc, portal_enter`.

Do not crop the generated miniatures and ship them directly.

## 3. World visual bible

### What is working

The sheet is a strong match for the approved 1.0 world spine:

- Floresta Corrompida;
- Castelo Fraturado;
- Cavernas dos Ecos;
- Refúgio/Santuário.

It also provides useful production thinking rather than only key art:

- 1280x720 gameplay mockups;
- entrance/combat/vertical/elite/portal/boss room examples;
- foreground/gameplay/midground/background layer examples;
- palette blocks;
- tile/prop examples;
- protagonist scale reference;
- corruption-language variants.

Biome separation is already clear:
- Forest: ancient vegetation, ruins and turquoise/green atmosphere;
- Castle: fractured masonry, warm fire/sunset and stained-glass language;
- Caves: deep blue/cyan mineral lighting and crystalline forms;
- Hub: warm amber safety contrasted with stabilized blue portals.

### Corrections before environment production

- the mockups are denser than a mobile gameplay layer should be; foreground and midground must be simplified around combat;
- magenta/purple dimensional corruption appears frequently across all hostile biomes. Keep it as a shared fracture motif, but avoid letting it flatten biome identity into "purple corruption everywhere";
- tiles shown in the bible are concept examples, not guaranteed seamless tiles;
- parallax layers must be rebuilt as separate source images;
- collision/platform surfaces must be authored from gameplay metrics, not inferred from painted edges;
- props need deterministic sizes relative to the player and room grid.

## 4. Enemy roster

### What is working

The roster maps very cleanly to the canonical V1 behavior architecture:

- **Chaser/Knight:** broad, armored, heavy silhouette;
- **Ranged/Archer-Mage:** tall/slender caster silhouette;
- **Runner/Charger:** low quadruped/forward-leaning speed silhouette;
- **Area Controller:** tall asymmetrical controller with strong staff/orb telegraph;
- **Exploder Elite:** large unstable core/crystal silhouette.

The silhouette strip is one of the strongest parts of the sheet: the five roles remain distinguishable without labels.

The gameplay-scale and phone-scale rows directly support the mobile readability requirement.

Biome variants preserve archetype identity while changing material language, which matches the data-driven enemy framework already in the game.

### Corrections before production sprites

- reduce micro-detail in armor, crystals, cloth and staff ornament at gameplay scale;
- lock one canonical body/weapon proportion per archetype before producing variants;
- keep enemy corruption primarily red/magenta/controlled-violet so it does not conflict with the player's blue electricity;
- ensure the Area Controller does not borrow sacred/religious visual language that could accidentally associate real traditions with villainy;
- telegraphs must be authored as gameplay VFX with deterministic timing, not extracted from the concept sheet.

## 5. Canonical visual rules established by this review

1. These four sheets are **visual-development references**.
2. They supersede legacy art only as **direction**, not by deleting historical files.
3. Nothing from these sheets enters `game/assets/` until cleaned, normalized, provenance-recorded and tested at phone scale.
4. Production sprites must use fixed proportions, palette, pixel density and baseline alignment.
5. Player electricity = controlled blue/cyan family.
6. Hostile dimensional corruption = primarily red/magenta with biome-specific material treatment.
7. Purple remains secondary; it must not become the universal corruption color.
8. Biome identity must remain readable without UI.
9. Cultural review is mandatory before final protagonist, religiously inspired weapon symbolism, enemy ritual motifs or marketing art are declared release-ready.

## 6. Production order

1. Lock protagonist gameplay model and exact pixel dimensions.
2. Rebuild the ten baseline protagonist clips.
3. Lock enemy silhouettes and gameplay-scale proportions.
4. Produce one clean enemy archetype end-to-end before variants.
5. Build Forest environment kit and parallax layers from the world bible.
6. Validate all three categories together in a 1280x720 phone-scale combat room.
7. Only then scale production to Castle/Caves and the full enemy variant matrix.
