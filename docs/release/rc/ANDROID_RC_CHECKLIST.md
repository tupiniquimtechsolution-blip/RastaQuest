# Android RC Checklist

## Technical configuration

- [x] Godot 4.5.1 pinned
- [x] GDScript / no .NET
- [x] package ID: `com.tupiniquimtechsolution.rastaquest`
- [x] versionName: `1.0.0-rc.1`
- [x] versionCode: `1000001`
- [x] arm64-v8a enabled
- [x] release keys excluded from Git
- [x] debug CI export uses ephemeral credentials only
- [x] debug APK generated and verified by `apksigner`
- [x] debug APK SHA-256 recorded: `631995b2db3b5940b6a8a03d33949fdd47a146efae0d44f2eb99acf8db4174dc`
- [x] GitHub Actions evidence: run `37479496762`, artifact `11420956791`

## Still required for accepted RC

- [ ] signed release AAB/APK
- [ ] release key configured only in approved secret storage
- [ ] clean install on supported physical Android device
- [ ] upgrade install/migration on device
- [ ] background/resume on device
- [ ] performance/thermal support matrix
- [ ] final icon/splash/screenshots
- [ ] final permissions inspection from packaged artifact
- [ ] final privacy/store declarations
- [ ] complete third-party asset/license inventory
- [ ] cultural review
