# Rasta Quest 1.0 — Release Acceptance Criteria

A build cannot be called final merely because it launches. All blocking sections below must be green.

## 1. Functional completion

- [ ] fresh player can start the game and understand controls;
- [ ] player can complete a full run through all 3 V1 biomes;
- [ ] final boss is reachable and defeatable;
- [ ] death returns to the intended meta loop;
- [ ] meta progression persists;
- [ ] victory persists;
- [ ] pause/settings work;
- [ ] game works offline for core gameplay.

## 2. Controls & game feel

- [ ] touch controls are usable on supported screen sizes;
- [ ] movement, jump, ground attack and air attack are responsive;
- [ ] no reproducible stuck animation/state;
- [ ] hitboxes match visible attack timing;
- [ ] hurt/death/portal states have correct priority.

## 3. Content completeness

- [ ] forest complete;
- [ ] castle complete;
- [ ] cave complete;
- [ ] required enemy archetypes complete;
- [ ] final boss complete;
- [ ] 18–24 upgrade pool complete;
- [ ] at least 5 meaningful synergies;
- [ ] no placeholder asset in release-critical path unless explicitly accepted.

## 4. Performance

- [ ] 60 FPS target validated on reference supported tier;
- [ ] lower-tier support behavior documented;
- [ ] no unbounded enemy/effect spawning;
- [ ] no repeatable severe frame-time spike caused by portal/boss/electrical effects;
- [ ] memory usage remains stable across repeated runs;
- [ ] Android background/resume does not corrupt run/save state.

## 5. Save integrity

- [ ] new save works;
- [ ] existing save reload works;
- [ ] version migration path tested;
- [ ] corrupted save fallback tested;
- [ ] settings survive restart;
- [ ] backup/recovery behavior documented.

## 6. Quality

- [ ] zero known blocker bugs;
- [ ] zero known critical bugs;
- [ ] accepted major bugs have owner/rationale and do not break progression;
- [ ] full regression completed on Gold Candidate;
- [ ] release artifact matches tested artifact.

## 7. Accessibility

- [ ] vibration toggle;
- [ ] screen-shake control;
- [ ] flash/electrical intensity reduction;
- [ ] audio controls;
- [ ] touch-control sizing/positioning or approved equivalent;
- [ ] readability/contrast pass.

## 8. Security & privacy

- [ ] no secrets in repository/build;
- [ ] release signing keys external to Git;
- [ ] Android permissions minimal;
- [ ] privacy declaration matches actual SDKs;
- [ ] third-party addons/services reviewed;
- [ ] no analytics/ads/IAP silently added.

## 9. Art, licensing & culture

- [ ] all release assets have known source/provenance/license;
- [ ] no temp copyrighted reference shipped accidentally;
- [ ] Rastafari representation reviewed;
- [ ] Xangô-inspired symbols/terminology reviewed;
- [ ] marketing screenshots match real final gameplay;
- [ ] credits complete.

## 10. Distribution

- [ ] versionCode/versionName set;
- [ ] application ID final;
- [ ] signed AAB produced;
- [ ] clean install passes;
- [ ] upgrade install passes where applicable;
- [ ] icon/splash/store art ready;
- [ ] release notes ready;
- [ ] support/contact route ready;
- [ ] rollback artifact preserved.

## GO / NO-GO

**GO** requires every blocking item above to be checked or explicitly waived in a written release decision with rationale, owner and risk.

The final GO record should reference the exact commit SHA, version and artifact hash.
