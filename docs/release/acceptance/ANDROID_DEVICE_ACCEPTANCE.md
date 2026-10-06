# Android Device Acceptance Protocol

Use this protocol for the blocking physical-device evidence in RQ-002, RQ-004, RQ-006 and RQ-009.

## Required record per device

- date/time;
- tester;
- manufacturer/model;
- Android version;
- chipset/GPU if known;
- RAM;
- display resolution/aspect ratio;
- build version and exact commit;
- APK/AAB SHA-256;
- install type: clean or upgrade.

## Test sequence

1. Clean install and first launch.
2. Complete onboarding.
3. Validate two-thumb movement/jump/attack/reward selection.
4. Run at least 15 minutes with combat, portals and electrical effects.
5. Complete background → resume cycles during hub and active run.
6. Complete death → hub → new run.
7. Reach at least one boss encounter.
8. Record frame-rate observation and any severe frame-time spikes.
9. Record thermal/battery observation.
10. Verify save survives app restart.

## Acceptance fields

- target 60 FPS on reference tier: PASS / FAIL;
- touch controls usable with two thumbs: PASS / FAIL;
- no repeatable lifecycle/save corruption: PASS / FAIL;
- no severe portal/boss/electrical performance regression: PASS / FAIL;
- blocker/critical defects found: list issue IDs.

Do not mark a device gate complete without build hash and device identity.
