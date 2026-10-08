# Draft art review — TASK-119 / TASK-120 / TASK-121

Generated 2026-10-08 with built-in ImageGen. Complete prompts and reference roles: PROMPTS.json. Inputs were canonical concept direction, never cropped miniature frames. Outputs are studies, not final sprites or seamless production kit. No license, cultural clearance or human acceptance is asserted. No files promoted into game/assets.

| Output | Purpose | Result / corrections before production |
|---|---|---|
| protagonist-neutral-study-v01.png | model lock candidate | Identity readable and axe ornament simplified. Torso/face remain partly three-quarter rather than clean lateral; hair mass and blade symmetry need measured redraw. Current image is 1376x1143, has partial alpha and >118k visible colors. Not 128x128 limited-palette sprite. |
| forest-layer-study-v01.png | sparse Forest authoring breakup | Four distinct rows, clearer horizontal platforms and red root fractures. Still one opaque board, not independent parallax layers or proven seamless tiles. Moss highlights compete with combat; reduce contrast behind actors. Rebuild modules separately with grid/collision QA. |
| chaser-neutral-study-v01.png | first archetype model candidate | Broad armor/shield silhouette and red cracks readable. Still partly three-quarter with substantial microdetail; redraw for side view, fixed mass/palette. Current image is 1176x1338, partial alpha and >118k visible colors. No final frames or attack executor implied. |

TECHNICAL_GATE.json records exact PNG hashes, dimensions, alpha bounding boxes, palette count and failures. tools/art_asset_gate.py independently rejects the character studies for frame size, palette and partial alpha. Do not downscale/crop these outputs and claim production readiness. tools/test_art_asset_gate.py verifies acceptance of clean synthetic exports and rejection of antialiasing, wrong dimensions, empty/opaque sources. It does not validate animation timing, cultural suitability, silhouette recognition or rights.

Next required model lock: owner/artist confirms candidate metrics in PR #42, corrects neutral models, records grip/head/feet geometry and palette. Only then rebuild ten protagonist clips and six Chaser clip categories; do not generate drifting frame sequences from these unapproved studies. Forest source work depends on the shared density lock. Real Android test/screenshots and separate collision/parallax proof remain pending. This directory stays outside the shipping asset tree.
