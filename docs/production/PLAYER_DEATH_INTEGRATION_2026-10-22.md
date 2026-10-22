# Player presentation lifetime and cancellation

The PR60 art package exposed two runtime gaps: PlayerCombat checked only cooldown/active attack, allowing damage to remain active after hurt/death; RunRoom returned to the hub immediately, leaving no time for a death clip. This change prepares safe presentation without assigning prototype art to shipping scenes.

## Runtime changes

- Player controller gates new attacks by health/dead/hurt state; damage/death cancel active damage immediately. Respawn clears attack and cooldown state. Attack damage still begins immediately and retains its0.16s window and existing geometry.
- Hitbox and portal update their logical gates immediately, then defer physics monitoring changes. This supports damage/death fired inside Area2D query flushing.
- Presenter rejects zero-speed clips and looping one-shots. A complete assigned pack exposes the sum of actual death frame durations, bounded at1.5s. No assigned art returns0 and retains the existing immediate fallback.
- Room closes reward/portal progression and pays/end-runs once. It waits the bounded gameplay timer for assigned art before returning to the hub. Animation completion never authorizes damage, rewards or scene progression. The timer pauses with the scene, consistent with sprite playback.

## Evidence

`game/tests/player_death_presentation_integration.gd` loads actual PNG studies for all eight body states only inside the test scene, at0.5 scale. It exercises real grounded attack, run/jump input, fall/air attack, hurt cancellation, respawn reset, fatal contact through a real Area2D callback, a late overlap that must not damage a target, one-time rewards, blocked portal/upgrade progression,0.6s assigned-clip return,1.5s cap and immediate no-art fallback. It also rejects looping and zero-speed death resources. This is a technical headless scene test, not a visual screenshot/device approval. Test files and drafts are excluded from shipping exports.

Local: this integration, player_sprite_integration and hostile_attack_integration passed on Godot4.5.1 without runtime errors. Editor initialization printed an environment Safe-save warning/error and unavailable local Android build-tools; no clean editor import or local APK build is claimed. Applicable CI must independently import, regress and export.

Sources: repository code and PR57–60 studies; no external implementation/library introduced. Redacted credential-pattern scan and diff checks run on the committed branch; CI run IDs/merge are tracked in the PR and Agenor.

Remaining: independent dropped axe world prop during collapse; actual visual review/motion cleanup and palette/model lock; lightning/portal state hooks/effects; native frame promotion only after documented gates; Forest/Chaser and remaining environment/enemy/boss kits; device, rights and final cultural reviews. Shipping scenes still have unassigned production SpriteFrames and keep development art. This does not complete Issue35 or commercial GREEN.
