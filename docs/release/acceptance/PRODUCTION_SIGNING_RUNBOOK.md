# Android Production Signing Runbook

Production signing material must remain outside Git and outside release documentation.

## Preconditions

- RQ-011 blocking acceptance is otherwise green;
- final application ID/version confirmed;
- final AAB export path tested;
- release keystore and credentials stored in an approved secret manager;
- repository scan shows no signing material tracked.

## CI principles

- inject keystore as an encrypted secret/file only for the signing job;
- inject alias/password through secret variables;
- never echo secrets;
- upload only the signed artifact and checksum;
- retain release artifact according to release policy;
- delete temporary keystore material from the runner after use.

## Verification

After export:

1. calculate SHA-256;
2. verify package/application ID;
3. install on clean physical device;
4. launch offline;
5. verify save/settings;
6. verify upgrade install when applicable;
7. record exact commit, versionCode, versionName and artifact hash.

Do not promote an ephemeral debug-signed APK as the production release.
