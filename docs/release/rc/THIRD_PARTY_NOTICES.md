# Third-Party / Asset Inventory — RC Working File

## Runtime technology

- Godot Engine 4.5.1 — open-source game engine; verify and include the applicable Godot license text in final credits/distribution materials.
- The in-game Credits panel now exposes notices supplied by the running engine through Engine.get_license_text(), get_copyright_info() and get_license_info(). This implements access to embedded notices; final packaged dependency/asset coverage remains to be audited.
- Android/Gradle exports also include engine Android library dependencies. Preserve the resolved dependency report and review their notices before commercial acceptance; absence of custom addons does not mean absence of third-party runtime components.

## Project dependencies

No third-party Godot addon or native runtime dependency is intentionally required by the current game source.

## Assets

Historical/concept assets under `assets/legacy/` are **not automatically release-approved**.

Before Gold:

- [ ] enumerate every shipped visual asset and provenance;
- [ ] enumerate every shipped music/SFX asset and license;
- [ ] remove/replace temporary or reference-only material;
- [ ] include required attribution/license notices;
- [ ] record approval for AI-assisted/generated assets where applicable.

This file is deliberately incomplete until the final production asset set exists.
