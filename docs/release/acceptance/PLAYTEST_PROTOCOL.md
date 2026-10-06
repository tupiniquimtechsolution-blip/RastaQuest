# External Playtest Protocol

## Movement gate — RQ-002

Minimum: 3 external players.

Ask each tester to complete movement, jump, platform traversal and touch controls without developer intervention.

Record:

- tester ID (non-sensitive alias is enough);
- device;
- whether controls were understood;
- perceived input delay;
- jump readability;
- touch comfort;
- stuck-state occurrence;
- free-text feedback.

## Combat gate — RQ-003

Ask testers to explain, in their own words:

- when an axe hit connects;
- when they receive damage;
- what the electrical proc means;
- whether hit/hurt/death feedback is readable.

Combat is not accepted merely because tests pass; damage timing must be understandable.

## Run gate — RQ-005/RQ-006

Record:

- reward-choice usability;
- portal-flow clarity;
- pacing;
- deaths caused by unreadable stacking;
- whether the hub → run → boss → hub loop is understandable.

## Beta gate — RQ-009

Minimum: 20 complete runs across testers/devices.

Every run record should include build hash, device, outcome, duration, biome reached, upgrade choices, crashes/soft-locks and blocker/critical issue IDs.
