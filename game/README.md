# Rasta Quest — Godot Project

This directory is the canonical shipping project created by **RQ-001**.

- Engine: Godot 4.5.1 Standard (no .NET)
- Language: typed GDScript
- Primary release: Android landscape
- Development/QA: desktop keyboard/gamepad support is introduced in later waves

## Open locally

Install Godot 4.5.1 Standard, then from the repository root:

```bash
godot --path game --editor
```

A clean headless import/parse check is:

```bash
godot --headless --path game --editor --quit
```

The RQ-001 boot smoke test is:

```bash
godot --headless --path game -- --smoke-test
```

Successful boot prints:

```text
RASTA_QUEST_BOOT_OK wave=RQ-001 version=0.1.0-dev
```

## InputMap contract

RQ-001 creates the canonical actions without gameplay bindings yet:

- `move_left`
- `move_right`
- `jump`
- `attack`
- `pause`
- `interact`

Physical keyboard/gamepad and Android virtual-control bindings belong to RQ-002 so device input stays behind the same action layer.

## Android debug export path

The tracked preset is **Android Debug** and writes to:

```text
build/android/rasta-quest-debug.apk
```

For a local Android export, install the Godot 4.5.1 export templates and configure an Android SDK. Godot 4.5 documentation recommends JDK 17 for Android export.

After the local SDK/editor configuration is valid:

```bash
godot --headless --path game --export-debug "Android Debug" ../build/android/rasta-quest-debug.apk
```

RQ-001 CI intentionally validates project import and boot only. A reproducible Android artifact build becomes a release gate after SDK/export-template automation is added; signing keys must never be committed.

## Asset promotion rule

Do not copy files from repository-root `assets/legacy/` directly into the shipping project. Assets enter `game/assets/` only after review for consistency, provenance/license and production readiness.

## RQ-001 CI evidence

GitHub Actions run `37460705294` validated the pinned Godot 4.5.1 engine, clean headless import/parse and main-scene smoke boot on the RQ-001 branch.
