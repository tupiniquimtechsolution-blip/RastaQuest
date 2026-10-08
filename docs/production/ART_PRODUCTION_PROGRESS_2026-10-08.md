# Art production progress — 2026-10-08

## Cleanup completed (#40)

Verified local and remote main at 11175f76a5dab340d3c4e80bfa1d1a63f52077fe, clean working tree, AGENTS.md and repository toolbox skill before editing. Owner explicitly authorized deletion in this task. PR #41 contains exactly four root PNG deletions and merged as 632de6815ab64acab9f83e3ed8776db525b6fee3 after Repository Health run 37764955533 succeeded (all structure steps). Issue #40 closed by merge.

| Deleted root path | Preserved canonical path | Identical Git blob SHA |
|---|---|---|
| Bíblia Visual de Mundos Pixel Art.png | assets/concepts/environments/rq-world-visual-bible-v01.png | 856949b0a7746cffb2a80cdd7a77fcd091d5c9d0 |
| Imagem do ChatGPT 6 de out. de 2026, 17_56_27-1.png | assets/concepts/characters/protagonist/rq-protagonist-character-bible-v01.png | 914c7cd8e69272423d61459986db2fcc7ca09ad3 |
| Imagem do ChatGPT 6 de out. de 2026, 17_56_29-2.png | assets/concepts/characters/protagonist/rq-protagonist-animation-board-v01.png | 94b0ff549d36f6cb12b7bb8193f078807d2193f1 |
| Rasta Quest_ Catálogo de Inimigos em Pixel Art.png | assets/concepts/enemies/rq-enemy-roster-v01.png | 481ba5164ace855ac07bc764e4e9a2d2851c5388 |

Full original filenames are recorded in assets/concepts/README.md and PR. Historical blobs remain recoverable; no other asset was deleted.

## Non-destructive progress (#35–#38)

Added PROTAGONIST_PRODUCTION_SPEC.md, ENVIRONMENT_KIT_SPEC.md, ENEMY_PRODUCTION_SPEC.md and CULTURAL_REVIEW_PACKET.md. Updated ART_PIPELINE.md with links and assets/concepts/README.md to remove the obsolete root-retention statement. This record is the seventh documentation file. No sprite, tile, runtime scene or gameplay script changed.

Verified inputs: Player.tscn, player_controller.gd, player_combat.gd, EnemyBase.tscn, enemy_base.gd, enemy_brain.gd, enemy_data.gd, five enemy .tres resources, RunPrototypeRoom.tscn, project.godot, art pipeline and prior direction review. Proposed numerical art metrics are explicitly distinguished from verified runtime values.

Checks: git diff --check; local equivalent of all Repository Health structure checks (canonical documents, no raw dump/generated project files at root, no tracked engine cache, archived Unity metadata); unchanged game/assets and four canonical PNG blobs. Godot/Android/Gold workflows are path-filtered out for this docs-only scope; no runtime regression or phone visual QA claim is made. No dependency installed. No external research, cultural consultation or license audit performed.

## Remaining risks and next gates

1. Artist/owner must lock candidate protagonist dimensions, axe/hair geometry and exact palette after a neutral model study.
2. Rebuild ten clips; current immediate hitbox and upgrade-dependent cooldown prohibit fabricated windup timing. Portal/effect and death playback require explicit integration decisions.
3. Produce Chaser end-to-end before variants; low Charger silhouette differs from shared collider. Emitted enemy tells are not a finished attack executor.
4. Author Forest layers/tiles and validate seams/collision/parallax in a real 1280x720 room; validate contrast and readability on Android with touch UI.
5. Record authorship/tool/source/export hashes and rights/terms evidence per production asset. Licensing remains unresolved.
6. Obtain knowledgeable human cultural review and owner decisions, including final marketing materials. No acceptance or endorsement is asserted.
7. Only after these gates: explicit promotion to game/assets, integration CI and recorded phone QA. Issues #35–#38 remain open.
