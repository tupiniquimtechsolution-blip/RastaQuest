# Protagonist production specification — issue #35

Date: 2026-10-08; visual direction updated 2026-10-10. Status: frame/body metrics and protagonist v03 visual direction approved by Rodrigo; native model, exact palette and in-game visual QA pending. Approval evidence: OWNER_APPROVAL_RECORD_2026-10-08.md and assets/production_drafts/2026-10-10/model-v03/OWNER_VISUAL_APPROVAL.md. No final sprite is supplied by this document.

## Grounded integration contract

Source direction: `assets/concepts/characters/protagonist/rq-protagonist-character-bible-v01.png` and `rq-protagonist-animation-board-v01.png`; see ART_DIRECTION_REVIEW_2026-10-06.md. Miniatures must be rebuilt, never cropped as runtime frames.

Selected visual reference: `assets/production_drafts/2026-10-10/model-v03/protagonist-neutral-study-v03.png`, SHA-256 `152940d341a63fa65b64c8043675b4c63bfd5a19021e4f109c12fc0352279edd`, approved by Rodrigo with “Gostei do visual, está aprovado” after PR #47 was presented. Preserve its face/body volume, clothing, hair mass and axe silhouette in the native model. The reference itself fails native export requirements; approval does not establish exact palette, geometry, cultural/rights clearance or device QA.

`game/scenes/player/Player.tscn` currently has a 28x52 collider, centered on the player origin; feet are local y=26. Visual is Node2D with placeholder polygons. `player_controller.gd` emits movement_state_changed; player_combat.gd emits attack_state_changed and electrical_proc_triggered. There is no final sprite player here. Preserve collider and combat geometry during first art integration.

## Model v0.1 — approved metrics, visual details pending

One authored pixel = one world unit at native 1280x720. Transparent 128x128 frame, centered origin (64,64), resting feet y=90; 52px resting body height, <=32px body width excluding hair/axe. No per-frame scaling. Record airborne feet displacement relative to the same origin rather than aligning jumps to a false floor.

Axe study: 48px handle, symmetric 32x18px blade head, grip marker and head center recorded in source coordinates; head center is a visual balance marker, not a physics mass claim. Keep these rigid dimensions through rotation. Render rotations with cleaned pixel edges. Do not resize the collider or 56x42 attack hitbox at x=38 to fit painted effects.

Hair study: six primary readable dreadlock clusters tied behind head, consistent 18x20px resting envelope; count describes sprite clusters, not the person's total locks. Headband stays above eyes with red/yellow/green segments. No beads, jewelry or body markings added until #38 resolves intentional references.

Candidate palette, authored proposal rather than colors sampled from the sheet: skin #24150F/#4B2C20/#754631; hair #151310/#302A22; band #C8392B/#E8BD42/#39854B; pants #21432D/#397044; boots/handle #35251C/#795237; blade #455660/#9BAEB6; electricity #298FCE/#74DCEF. Transparent alpha=0; visible pixels alpha=255. No blur or automatic palette extraction. Palette lock requires actual in-room comparison.

## Clip delivery matrix

| Clip | Initial authored poses | Playback/integration gate |
|---|---:|---|
| idle | 4 | loop, stable feet |
| run | 6 | loop, contact poses and hair mass consistent |
| jump | 1 | movement signal; ascending pose |
| fall | 1 | movement signal; descending pose |
| attack_axe | 4 | attack signal; gameplay window drives active art |
| attack_axe_air | 3 | same combat authority; airborne pivot |
| hurt | 2 | controller hurt lock currently 0.18s |
| death | 4 | hold final pose; verify scene transition lifetime |
| lightning_proc | 3 | separate effect from body; electrical proc signal |
| portal_enter | 4 | integration hook/lifetime must be designed before use |

Counts are starting budgets, not accepted final clips. Ground/air attack window is currently 0.16s and cooldown 0.30s; upgrades reduce cooldown down to 0.12s. Current hitbox begins immediately on try_attack, so drawing a pre-hit anticipation would misrepresent gameplay. Any real windup requires a separate approved gameplay change. Do not let animation completion authorize damage or extend windows.

## Export and gates

Use ART_PIPELINE naming and keep layered editable sources outside game/assets. Record frame bounds, origin, feet/contact markers, grip, blade centers and duration per frame in an accompanying manifest. Verify all ten exact clip names, transparent edges, rigid proportions, both facings and no weapon/body intersection. Test at native 1280x720 and reduced 640x360 with nearest-neighbor plus actual Android display evidence, including touch UI and overlapping enemies. Screenshots, device, scale and reviewer/date required; no test performed yet.

Next: artist builds one corrected neutral model and axe study at approved frame/body metrics; owner locks palette and visual proportions; rebuild clips; integrate separately; run Godot checks and phone QA. Rodrigo approved the presented cultural materials; final versions and marketing still require review under #38. Issue remains open until production evidence satisfies every acceptance item. Provenance and license remain unresolved: record source author/tool/date/terms evidence for each exported asset, never inherit license from reference presence.
