# Protagonist production specification — issue #35

Updated: 2026-10-22. Status: Rodrigo approved double source resolution at the same world size and the appearance/detail target of the256px proof as the base for animations. Exact anatomy/markers, palette in room, independent weapon/clip acceptance and visual QA remain pending. See VISUAL_DENSITY_DECISION_2026-10-22.md, OWNER_APPROVAL_RECORD_2026-10-08.md and assets/production_drafts/2026-10-22/axe-idle-2x/OWNER_APPEARANCE_APPROVAL.json. No final sprite is supplied by this document.

## Grounded integration contract

Source direction: `assets/concepts/characters/protagonist/rq-protagonist-character-bible-v01.png` and `rq-protagonist-animation-board-v01.png`; see ART_DIRECTION_REVIEW_2026-10-06.md. Miniatures must be rebuilt, never cropped as runtime frames.

`game/scenes/player/Player.tscn` has a28x52 collider, centered on the player origin; feet are local y=26. Visual is Node2D with development polygons and an optional player_sprite_presenter.gd adapter. `player_controller.gd` emits movement_state_changed; player_combat.gd emits attack_state_changed and electrical_proc_triggered. The adapter uses the controller's resolved eight body states and accepts only a complete nonempty256x256 frame set at constant0.5 scale/nearest sampling. No final SpriteFrames resource is assigned: polygons remain visible. Preserve collider and combat geometry during art integration. Electricity/portal presentation and death lifetime are still separate gates.

## Active 2x source contract — approved metrics, visual details pending

Two authored pixels = one world unit at native 1280x720. Transparent 256x256 frame, source origin (128,128), resting feet y=180;104px resting body height, <=64px body width excluding hair/axe. Render the entire visual consistently at0.5, so body remains52 world units and feet remain local y=26. No per-frame scaling. Record airborne feet displacement relative to the same origin rather than aligning jumps to a false floor. The earlier128x128/52px source contract is historical and superseded only for source density; collider28x52, attack geometry and camera scale are unchanged.

Axe source study:96px handle, symmetric64x36px blade head, grip marker and head center recorded in source coordinates; head center is a visual balance marker, not a physics mass claim. These are the original48/32x18 world dimensions at double source density. Keep these rigid dimensions through rotation. Render rotations with cleaned pixel edges. Do not resize the collider or56x42 attack hitbox at x=38 to fit painted effects.

Hair study: six primary readable dreadlock clusters tied behind head, consistent36x40px source resting envelope (18x20 world units); count describes sprite clusters, not the person's total locks. Headband stays above eyes with red/yellow/green segments. No beads, jewelry or body markings added until #38 resolves intentional references.

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

Next: use the approved appearance target while completing exact anatomy and source markers; review the rigid independent axe and layered idle prototype; author the remaining clips, lock palette/model in room and integrate separately; run Godot checks and phone QA. The first idle is explicitly a3-pose breathing rig on one newly generated neutral, not four independent hand-drawn poses or a final clip. Rodrigo approved the presented cultural materials; final versions and marketing still require review under #38. Issue remains open until production evidence satisfies every acceptance item. Provenance and license remain unresolved: record source author/tool/date/terms evidence for each exported asset, never inherit license from reference presence.
