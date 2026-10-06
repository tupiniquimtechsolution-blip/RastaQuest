# Rasta Quest 1.0 — Gold Candidate Preflight Decision

**Decision:** NO-GO  
**Date:** 2026-10-06  
**Technical RC source commit:** `2c08f6be94e02402511021f4e96500b85a182235`  
**Version under evaluation:** `1.0.0-rc.1`  
**Save schema:** `2`

## Technical evidence available

- RQ-001 through RQ-010 automated engineering/regression gates are present on the technical RC source commit.
- Godot engine is pinned to 4.5.1.
- Android application ID is `com.tupiniquimtechsolution.rastaquest`.
- Android target architecture is arm64-v8a.
- Debug APK evidence exists from Android Technical RC run `37479496762`.
- Debug APK SHA-256:
  `631995b2db3b5940b6a8a03d33949fdd47a146efae0d44f2eb99acf8db4174dc`.
- Debug signing is ephemeral CI-only and is **not** release signing.
- Core gameplay is declared offline; analytics, ads and IAP are disabled.
- No Android permissions are intentionally declared in the RC manifest.

## Gold preflight checks

- [x] candidate source commit frozen for this preflight;
- [x] complete automated RQ-001→RQ-010 regression rerun in Gold Preflight CI;
- [x] candidate debug artifact SHA-256 recorded;
- [x] save schema recorded/frozen at schema 2 for this preflight;
- [x] repository scan rejects tracked keystore/private-key/signing file patterns;
- [x] rollback source commit recorded;
- [x] formal GO/NO-GO decision recorded.

## Blocking acceptance still open

- [ ] RQ-002 Android 60 FPS measurement on reference hardware;
- [ ] RQ-002 two-thumb touch usability;
- [ ] RQ-002 movement feedback from at least 3 external players;
- [ ] RQ-003 combat-feel/readability acceptance;
- [ ] RQ-004 physical-device encounter/performance evidence;
- [ ] RQ-005 Android reward-selection/run-pacing playtest;
- [ ] RQ-006 production-quality vertical-slice acceptance;
- [ ] RQ-008 new-player comprehension/aspect-ratio/licensed-audio/cultural review;
- [ ] RQ-009 20 complete Beta runs + thermal/performance/background-resume evidence;
- [ ] RQ-010 final licensed asset inventory and final store media;
- [ ] RQ-010 external production signing key configured;
- [ ] RQ-010 signed AAB/APK clean-install validation;
- [ ] final release privacy/store declarations reviewed.

## Decision rationale

The technical implementation has progressed far enough for a reproducible preflight, but a Gold Candidate is a release decision rather than a CI label. The open physical-device, human-playtest, cultural/licensing and production-signing criteria are blocking release acceptance.

Creating `v1.0.0`, publishing to a store, or claiming Gold while these items are open would contradict `docs/release/RELEASE_CRITERIA.md`.

## Rollback

If a later candidate regresses, the technical RC source baseline for this preflight is:

`2c08f6be94e02402511021f4e96500b85a182235`

The recorded technical debug APK is test evidence only and must not be promoted to public release.

## Re-evaluation rule

Change this decision to **GO** only when every blocking release criterion is evidenced or explicitly waived in writing with owner, rationale and accepted risk. A GO record must reference the exact final commit and signed release artifact hash.
