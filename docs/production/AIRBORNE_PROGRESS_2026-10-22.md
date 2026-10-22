# Airborne prototype progress — issue35

After merged PR57 (67a4dd621a52983441de35f19f1d5dd373d68c40; Repository Health39773301496 SUCCESS), two new unarmed pose sources were authored for jump/fall using the approved appearance target. This draft-only iteration changes no gameplay, engine scene or production import.

Two256×256 composed exports share the same source normalization scale24/140,32-color working palette, binary alpha and rigid carried axe from the previous package. Pelvis/grip source markers are estimated and declared. Origin128,128 and intended runtime0.5 remain constant; feet have different recorded local offsets rather than being snapped to a false floor. Saved source/export hashes, layer composition, unchanged weapon, opaque grip and zero blade/body pixel overlap are verified.

These are **two new single-pose prototypes**, not final approved sprites or proof of motion/state-transition quality. Character proportions, head/hair mass, limb lengths and continuity between poses/idle still need native artist review. Poses are not imported into game/assets or the real Player SpriteFrames; the current adapter correctly requires the full eight-body-clip set.

Files: assets/production_drafts/2026-10-22/airborne-2x/ (prompt/source PNGs, explicit build method, body/weapon/fist layers, combined exports, manifest/report and AIRBORNE_REVIEW.png). Source1254px outputs remain studies; no native-generation claim. No license, cultural final, in-room/device acceptance or commercial GO inferred.

Next pending body work: run, attack_axe, attack_axe_air, hurt, death; final idle cleanup/motion review; lightning/portal presentation and lifetime hooks. Then consistent actor/Forest/Chaser proof and remaining visual kit before finishing/audio.
