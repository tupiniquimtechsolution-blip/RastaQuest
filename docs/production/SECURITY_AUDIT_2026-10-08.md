# TASK-36 / GitHub #1 — initial security audit

Date: 2026-10-08. Audited source baseline: main 632de6815ab64acab9f83e3ed8776db525b6fee3; specification branch e72a2ff4ed27750ad0e8b20c72b1ac5958aede9c. This is an initial offline-game audit, not a pentest or release approval.

| Checklist | Evidence and result |
|---|---|
| Credentials/history | tools/security_audit.py scanned all locally reachable Git refs/history: 327 blobs, 45 binary blobs skipped, zero supported-pattern findings. Values always redacted. Patterns cover private keys and selected provider tokens; no entropy scan, remote secret inventory or unreachable objects; not proof of absence. .gitignore excludes local env/private keys. |
| Auth/authorization | No account login, backend, remote mutation or HTTP/network client found in game/scripts. Server-side auth is N/A for current offline local game. Reassess before adding services. |
| Input/injection | JSON save is the concrete external-input surface. Room/upgrade load paths are constant res:// lists in room_catalog.gd/upgrade_catalog.gd. No command execution, network URLs or user-controlled resource loads found. Malformed save fields reproduced script errors; corrected before typed assignments. |
| Rate limiting | Login/forms/webhooks do not exist here: N/A. Local combat cooldown remains gameplay authority, not security control. |
| CORS/cookies/HTTPS/ports/env | No browser/backend listener or session/cookie surface in runtime: N/A. No new port opened. Android export preset requests no explicit permissions; actual signed APK permissions remain a release inspection gate. |
| Logs/errors | Runtime logs found: fixed boot marker/version, seeded run debug strings and fixed EnemyData error. No input save contents or credentials logged. Regression errors report only field descriptions. Runtime crash/error logs still require device QA. |
| Dependencies/checks | Godot pinned 4.5.1; no runtime package manager dependencies/GDExtensions added. Official Windows ZIP digest matched GitHub release metadata: defccc78669e644861b4247626b01ae362cd9f23975edf19c8bfd2eb1f6a1783. Repository CI pinned engine remains unchanged. No new structural dependency installed; Pillow used from bundled workspace runtime for authoring checks. |
| Backup/rollback | Schema v2 and save paths preserved. New regression demonstrates fallback for malformed/oversized primary to known-good backup. v1 migration, corrupt JSON recovery and existing release suite pass. Non-atomic write and unvalidated backup-copy residual risk recorded in GitHub #43; not claimed resolved. Git/source rollback available; Gold remains NO-GO. |
| Pentest | No public network attack surface found; third-party pentest N/A. No third-party system tested. |

## Fix and regression evidence

save_manager.gd now checks dictionary shape, finite/integer schema and shard count, settings types and nested unlock/flag values before casts; SettingsPolicy normalizes bounded settings; reads reject files above 1 MiB before loading. Invalid primary proceeds to backup recovery. Does not change save schema or mutate existing real save data.

Before fix, save_validation_smoke.gd reproduced Nil/Array/String-to-Dictionary errors and accepted malformed settings. After fix: RQ_SAVE_VALIDATION_OK, including malformed fields, nested values, oversized primary, bounds and backup recovery. Added to Godot CI. Nine existing technical tests plus the new regression and boot marker passed locally under Godot 4.5.1. Local Windows sandbox emitted root-certificate-store warning and initially prevented default AppData writes; successful runs redirected APPDATA/LOCALAPPDATA to workspace test directories. Tests used dedicated fixture saves, not user progression. Editor import succeeded with sandbox warnings; cloud CI supplies the clean environment check.

## Residual risks / scope

GitHub #43: interrupted/truncated writes and copying invalid primary over backup. Physical-device performance/lifecycle, final signed APK/permissions, production art/audio rights, cultural consultation and release signing remain unverified. A completed initial audit is not a vulnerability-free claim. No external research relied on; official engine release/download used only for local tests.
