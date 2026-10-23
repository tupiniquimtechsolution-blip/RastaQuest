# Remaining art v01 — candidate packet

Castle/Caves/Hub; Ranged/Charger/Controller/Exploder; Storm Warden/Rift Sovereign; four new portal poses; shared effects. This is authoring/review material, not shipping art or human/licensing acceptance.

Start with `reviews/` key sheets/source-motion GIFs and `room-review/` actual Godot captures. Detailed scope, checks, risks and next gates: [production report](../../../../docs/production/REMAINING_ART_PROGRESS_2026-10-23.md).

- `sources/`:19 preserved ImageGen source images, including superseded Hub input.
- `PROMPTS.json`, `SUPPLEMENTAL_PROMPTS.json`: generation prompts and references.
- `build_art.py`, `MANIFEST.json`: explicit reconstruction and source/export hashes.
- `INTEGRATION_TRACE.json`: nine actual combat-pattern observations, no device acceptance.
- `room-review/RENDER_REPORT.json`:47 actual engine captures with PNG/input hashes and capture mode.
- `verify_art.py`, `VERIFICATION.json`: automated artifact-integrity gate.
- `AUTHORING_PROVENANCE.csv`: authoring register with rights/cultural/release status pending.

Reproduction from repository root: run the existing Python runtime on `build_art.py`; run Godot on `game/tests/remaining_art_integration.gd` with user argument `--save-art-trace`; capture with desktop Godot script `tools/render_remaining_art_review.gd`; run Python on `verify_art.py`. Headless Godot cannot produce the real desktop screenshots. Preserve source inputs and review each regenerated result; a rebuilt candidate does not inherit approval.

No files are promoted to `game/assets/`. Review fixtures are excluded from Android exports. New portal poses/effects are source galleries; binding and physical GalaxyA13 QA remain pending. Commercial GREEN: **NO-GO**.
