# Combat and reaction prototype pack — 2026-10-22

13 newly generated body poses: ground attack4, air attack3, hurt2 and death4. This pack uses the approved appearance base, not the rejected native-python-v01 model. Earlier weapon/idle/run/jump/fall prototype approval is recorded in `../OWNER_PROTOTYPE_APPROVAL_2026-10-22.json`; it does not approve these later new poses.

Sources and exact prompts are preserved in PROMPTS.json/CORRECTION_PROMPTS.json. Built-in ImageGen created high-resolution sheets, not native256px sprites. First ground/air attempts extend the arm too far for a full rigid axe; retained as rejected fit studies. Compact corrections were selected. Build applies one declared uniform BOX density per source sheet, the existing32-color mapping/binary alpha, estimated pelvis/grip anchors and explicit floor translation. No per-pose rescaling or native hand-cleanup claim. Editable body/weapon/blade/hand layers, individual frames and atlases are included. Generated source sheets have partial alpha/many colors and must not be mistaken for approved exports.

## Saved-file checks

Run `build_combat.py`, then `verify_combat.py` with Python/Pillow. VERIFICATION.json verifies actual saved hashes,256×256 frames, shared32 visible colors, binary alpha, distinct body exports, floor contacts, non-clipped rigid weapon rotation, fist on opaque body, blade/body clearance, composition and at least some blade overlap with the current active hitbox. It does not prove complete swept hitbox coverage or correct continuous motion. Palette/model and cultural/rights checks are separate. A finite-width raster rotation uses nearest sampling; it is not a redraw or perspective change.

## Timings and integration limits

- Ground attack:4×40ms =160ms. Air attack:50+55+55ms =160ms. No delayed anticipation; current damage starts immediately. Art callbacks must never begin/end damage or lengthen the window. Real controller may interrupt these poses on hurt/death.
- Hurt:2×90ms =180ms, matching current controller lock.
- Death:120+140+160+180ms =600ms proposed presentation; hold final pose. Current game defers return to hub immediately, so death playback is NOT integrated or verified. A separate runtime lifetime change must preserve one-time rewards, damage cancellation and return progression.
- Death keys2–4 are body-only. A dropped independent weapon/world-prop hook is still required; the axe has not been redrawn, shrunk or silently claimed to remain held. Do not use this sequence in shipping until the drop/scene lifetime is resolved.
- GIFs add a700ms final pause for review, outside the game timeline. Contact sheet is a pose review, not a screenshot of gameplay. Review at0.5 scale in the real room and both facings still pending.

## Remaining gates

Manual pixel-edge/anatomy/hair continuity and gait/swing polish; model and palette in room; independent weapon drop and death lifetime; complete body/weapon integration; lightning_proc/portal_enter; Forest/Chaser then other environment/enemy/boss art; device QA, final cultural/version review and rights evidence. Assets remain outside game/assets and are excluded from commercial exports. No new APK, final acceptance or release GREEN is claimed.
