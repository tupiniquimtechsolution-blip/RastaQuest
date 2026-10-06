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
