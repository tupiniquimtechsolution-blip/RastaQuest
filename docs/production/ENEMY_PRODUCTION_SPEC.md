# Enemy production specification — issue #37

Updated: 2026-10-22. Status: proposed authoring contract; no final sprites or human acceptance. PR52 connects real timed attacks and provisional telegraph geometry; see HOSTILE_ATTACK_INTEGRATION_2026-10-16.md. Actor source density now follows VISUAL_DENSITY_DECISION_2026-10-22.md.

Reference: assets/concepts/enemies/rq-enemy-roster-v01.png. First end-to-end archetype: Chaser/Knight; biome variants wait for protagonist/Chaser lock.

## Actual runtime contract

EnemyBase.tscn has one34x58 collider/hurtbox and placeholder Polygon2D for every archetype. Feet are local y=29. enemy_base.gd emits attack_tell_started(behavior,duration); duration is tell_seconds multiplied by enemy_brain.gd tell_multiplier. HostileAttack now executes/cancels actual attacks (PR52). Enemy deletion is still immediate on death; final SpriteFrames playback/lifetime is absent. Authoring art alone does not integrate enemy death clips.

| Resource behavior | Source tell seconds | Multiplier | Emitted seconds | Candidate silhouette |
|---|---:|---:|---:|---|
| chaser | 0.25 | 1.0 | 0.25 | broad armored 40x58 |
| ranged | 0.45 | 1.0 | 0.45 | narrow caster 32x64 |
| charger | 0.55 | 1.35 | 0.7425 | low forward 64x40 |
| controller | 0.70 | 1.5 | 1.05 | asymmetrical staff 44x68 |
| exploder | 0.80 | 1.75 | 1.40 | unstable core 56x64 |

Numbers come from game/data/enemies/*.tres and scripts, except silhouette envelopes, which are proposals in world units excluding effect padding. Do not modify shared collision to match these sketches; reconcile readable body/contact alignment in a separate integration review. Source pixel density follows #35 at two pixels/world unit; candidate transparent256x256 frames, origin(128,128), grounded feet y186, render scale0.5. Charger low profile makes collider mismatch a specific review risk.

## Authoring packet

For Chaser first: idle 4 poses, move 6, anticipation 2, attack 3, hurt 2, death 4 (initial budgets). Keep rigid body/weapon proportions, baseline, facing and palette manifest. Each role gets only clips its actual gameplay needs. Distinct shapes must read without labels; remove armor/crystal micro-detail at reduced size. Red/magenta hostile accents vs blue player electricity need grayscale/shape tests. Existing ranged blue and controller green placeholder colors are not a final palette approval.

Telegraph VFX are separate exports with explicit anchors, onset, duration and end/cancel behavior. Use emitted duration rather than fixed animation FPS. Gameplay damage scheduling now exists in HostileAttack and stays authoritative; presentation must follow it. Death animation needs a presentation lifetime decision because current queue_free is immediate. Document these integration prerequisites; do not change gameplay authority in this documentation PR.

## Verification before variants

Capture unlabeled silhouettes for all five at 1280x720 and 640x360; record recognition responses and confusions, not invented pass rates. In a real Android combat-room capture, check actor/effect overlap, red/magenta vs blue differentiation, anticipation readability, cancellation/death behavior and touch UI occlusion. Pair frames with event timestamps to verify tells remain synchronized. Re-run enemy/combat Godot smoke checks after integration; source-only art QA does not replace timing tests.

Next: #35 density/model lock; Chaser authored source and exports; cultural screening of controller motifs (#38); gameplay/presentation integration review; phone QA; provenance/license evidence; explicit promotion. Issue remains open. Every export needs author/tool/date, source hash, rights/terms evidence and reviewer; none is claimed complete here.
