# Axe / idle progress — issue35, 2026-10-22

Rodrigo approved the appearance/detail target of the PR56 proof as the animation base, explicitly excluding independent weapon, clips and in-game review. The exact SHA256 and direct answer are versioned in assets/production_drafts/2026-10-22/axe-idle-2x/OWNER_APPEARANCE_APPROVAL.json. Historical pending fields are not rewritten as retrospective approval.

New independently layered weapon: head visible64×36; shaft96px; binary alpha/shared32-color set; exact90degree pair from the same PNG. The carried weapon uses nearest-neighbor at102degrees from vertical. Rig anchor sits inside the opaque hand; blade/body alpha overlap is zero in the four draft frames. Actual PNG bounds, transpose equality and layer composition are checked, not merely inferred from the manifest.

Initial generated four-pose idle sheets drifted in stance/weapon and were not promoted. A corrected body-only study supplied a neutral for a **declared layered rig prototype**: one drawn neutral, three rig poses and four200ms timeline keys. The lower body/feet/grip remain fixed and the upper body translates by0/1/2/1source pixel. This is an experimental breathing loop, not accepted final animation or four independently hand-authored drawings. Pixel cleanup, character geometry/envelopes, continuity and human/phone motion review remain open.

Files: prompt/source PNGs, editable PNG layers plus reproducible build script, three rigid weapon orientations, four body/combined frames, atlas, manifest, GIF/weapon review board and verification/tests. All remain under production_drafts. No scene, gameplay, collision, timing, save, app version or production asset was changed.

Validation: six prototype integrity regression tests pass; actual saved exports share32 visible colors and binary alpha at256×256. Full body set is incomplete; the production presenter must continue refusing an idle-only pack. No Godot/Android visual acceptance, rights, cultural final or Gold GO inferred. Repository Health CI applies to this draft-only package; no runtime-export change needs a new APK.

Next: build/clean the remaining body clips with the approved appearance, then review complete state transitions and presentation lifetimes (hurt/death/portal). Forest/Chaser proof follows a consistent actor pack; other environments/enemies/bosses/effects remain on the visual completion tracker. Finishing/audio stays deferred.
