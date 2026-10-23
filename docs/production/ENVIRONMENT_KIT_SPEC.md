# Forest environment kit specification — issue #36

Date: 2026-10-08. Status: 32x32 tile metric approved by Rodrigo; remaining kit contract proposed. No final tiles/layers or visual QA yet. See OWNER_APPROVAL_RECORD_2026-10-08.md.

Reference: assets/concepts/environments/rq-world-visual-bible-v01.png. Rebuild separate images; concept tile examples are not proven seamless exports.

## Verified baseline and candidate metrics

Viewport in game/project.godot: 1280x720. RunPrototypeRoom.tscn uses polygon backdrop and a 1400x80 ground collider centered (640,680), with top y=640. It has no finished TileSet/parallax kit. Preserve collision geometry and spawn/portal locations during first proof; grid must not silently move platforms.

Authoring density: one source pixel per world unit. Approved tile: 32x32; ground top y=640 aligns to row 20. Player collider height 52 is 1.625 tiles; approved resting art body height is also 52px. Candidate props: small debris <=32x32, trunk 64x128, ruin column 64x96. Decorative overhangs have no collision; traversable props require explicit collision polygons. Validate the approved metrics in shared room QA.

## First kit inventory

| Deliverable | Initial budget | Evidence |
|---|---|---|
| Gameplay terrain | top/left/right corners, interior, bottom, isolated platform | repeat 3x3; no gaps; readable top boundary |
| Foreground | two edge clusters | no cover over player/enemy/telegraph combat corridor |
| Midground | tree and ruin modules | reduced contrast behind actors |
| Background | distant canopy and sky layers | repeat and camera-boundary inspection |
| Props | debris, trunk, column | size manifest vs player; no false walkable ledge |

Candidate parallax factors: background 0.15, midground 0.45, gameplay 1.0, foreground 1.10. These are design proposals; wrap size, camera bounds and memory must be tested, not claimed implemented. Keep contact surfaces the clearest environment edge. Dense ornament belongs outside active combat and touch-control zones.

Forest corruption uses damaged roots/vegetation/ruins; Castle fractures masonry/fire/stained glass; Caves fractures mineral/crystal forms; Hub uses warm amber and stabilized blue portals. Shared magenta fractures are accents, not universal full-biome tint. Blue/cyan cave ambience must remain distinguishable from player electricity by shape, motion and contrast, not hue alone.

## Proof protocol

Build a separate 1280x720 Godot art proof room after source assets exist. Demonstrate contiguous floor, two platform edges, repeated terrain, all layers, props, protagonist, one Chaser, portal and touch UI. Capture native/reduced scale plus Android evidence. Move camera across wrap boundaries; inspect collision top/side overlays, landing edges, silhouette/telegraph visibility, texture sampling and texture memory. Record engine version, device, source/export hashes and screenshots. Current document does not satisfy the playable-room acceptance item.

## Execution update — 2026-10-23

Forest proof and v02 polish now exist as separate review fixtures, including 16 terrain exports, true camera-relative layers and traversal evidence. `remaining-art-v01` adds Castle, Caves and Hub candidate kits: 48 native32x32 terrain exports, 15 props and three1280x720 backgrounds. These reuse the approved tile metric; actor density separately follows256px/body104 rendered0.5. The paragraph above describing52px art is a world-size baseline, not a requirement to reduce the approved actor source density.

Review factors are now0.25/0.65/1/1.08. Alternating mirrored background panels cover tested camera checkpoints but retain visible reflection/periodicity; natural seamless repetition is not claimed. Automated tile joins and twelve actual platform-edge landings across the three kits pass in the review fixture. The Hub proof uses RunPrototypeRoom and is not integration into the shipping Hub. Production camera, collisions and scene art assignments remain unchanged.

See [remaining-art progress](REMAINING_ART_PROGRESS_2026-10-23.md). Remaining gates: natural repetition/art polish, actual Hub and biome scene integration, native/reduced combat contrast review, Android readability/performance, provenance/rights evidence and explicit promotion of identified versions. Canonical reference status is not licensing permission.
