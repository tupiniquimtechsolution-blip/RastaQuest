# Commercial evidence packet — 2026-10-22

This packet checks record completeness and build consistency, not whether claims are true. It never grants Gold GO, signs builds, publishes, or changes the release decision. All supplied records are blank/pending. Unit test fixtures are synthetic and are never release evidence.

## Collect once a candidate exists

Copy COMMERCIAL_EVIDENCE_TEMPLATE.json to a separately named candidate record. Identify the exact source SHA, artifact SHA-256 and version. Production signing and CI must describe that artifact; a prior green debug build is insufficient. Do not enter private keys or tester personal data; use aliases and references to appropriately protected evidence.

Record physical device identity, installation/launch/offline/touch, performance and thermal measurements, lifecycle/save/boss/death checks. Follow GALAXY_A13_TEST.md and existing device/playtest protocols for measurements and duration. Record three distinct external movement testers and twenty unique completed Beta runs for the same candidate. Unknown bug status stays null, not an invented empty list.

Populate ASSET_LICENSE_INVENTORY.csv from actual delivered assets and dependency records. Record source, applicable license/terms, proof and explicit approval separately. Final visual/cultural/store/content-rating/model/support decisions need reviewer, date, evidence and matching build. Prior study approval does not approve a new production model.

## Run

```sh
python3 -B tools/validate_commercial_evidence.py path/to/candidate.json --output path/to/report.json
```

Incomplete records return exit1. `--report-only` allows an explicitly incomplete planning report without failing the command. COMMERCIAL_EVIDENCE_PENDING.json is the report for the blank template, not an assessment of a released artifact. A complete structure still reports `automatic_gold_go: false` and `evidence_truth: not-independently-verified`. This checks a subset of the 48 release criteria; it does not replace the release checklist, human review, store checks or runtime16KB tests.

## Package separation

Store-format APK/AAB presets exclude `tests/*`. Both actual APK and AAB verifiers reject `tests`, `concepts`, `legacy` path segments under the store contract and always reject `production_drafts`. The internal portable debug profile may include QA scripts. References and studies stay outside game/assets; this protection does not certify the remaining art as final.

No version, collider, gameplay timing, signing identity or store publication changes. Next: verify actual CI exports, then visual production and integration before finishing/audio work, per Rodrigo's22/10 direction. Physical QA, rights, cultural decisions and production signing remain pending.
