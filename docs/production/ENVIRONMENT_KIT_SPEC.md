# Forest environment kit specification — issue #36

Date: 2026-10-08. Status: proposed kit contract; no tiles/layers or visual acceptance yet.

Reference: assets/concepts/environments/rq-world-visual-bible-v01.png. Rebuild separate images; concept tile examples are not proven seamless exports.

## Verified baseline and candidate metrics

Viewport in game/project.godot: 1280x720. RunPrototypeRoom.tscn uses polygon backdrop and a 1400x80 ground collider centered (640,680), with top y=640. It has no finished TileSet/parallax kit. Preserve collision geometry and spawn/portal locations during first proof; grid must not silently move platforms.

Candidate density: one source pixel per world unit, matching protagonist proposal. Candidate tile: 32x32; ground top y=640 aligns to row 20. Player collider height 52 is 1.625 tiles; this is collision scale, not approved art height. Candidate props: small debris <=32x32, trunk 64x128, ruin column 64x96. Decorative overhangs have no collision; traversable props require explicit collision polygons. Lock scale only after shared room QA.

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

Next gates: protagonist density lock (#35), layered Forest authoring, seamless/collision QA, integration PR with Godot CI, phone readability review, provenance/license record and explicit promotion. Castle/Caves variants follow only after Forest proof. License/author/tool/terms evidence is pending for each production export; canonical reference status is not licensing permission.
