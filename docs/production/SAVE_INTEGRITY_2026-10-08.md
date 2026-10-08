# Save integrity — issue #43

The primary is no longer opened in WRITE mode for a replacement. Prepare a same-directory .tmp file, reject oversized/invalid data, flush/close, read back exact serialized content and validate schema before renaming. Reject malformed in-memory candidates instead of replacing progression with defaults. Schema v2 and primary/backup paths remain unchanged.

Backup rotation validates the existing primary through migration and stages a complete backup before replacing it. An invalid primary cannot overwrite a known-good backup. If backup staging/commit fails, abort primary replacement. skip_backup preserves an existing valid backup, but creates one when a valid primary would otherwise lack recovery. Migration writes its original v1 backup before replacing primary; interrupted staging files are ignored during load.

Godot 4.5 Unix rename uses native same-filesystem rename. Godot 4.5 Windows rename removes an existing destination then moves the source: do not claim atomic replacement on Windows. Previous-good backup remains recoverable across that gap. A failed primary commit returns false and retains staged bytes; normal load recovers backup when primary is absent/invalid. Single writer expected, as in the existing main-thread save manager. Flush is not a guarantee against hardware power loss; no directory fsync or multi-process locking added.

Regression covers successful replacement, skip_backup protection, truncated staging, rejected backup rename, rejected primary rename, simulated Windows delete/move interruption, recovery, invalid-primary backup preservation and invalid in-memory data. Tests use rq_atomic_smoke fixtures only; real user progression untouched. CI and Gold Preflight execute the regression. Gold NO-GO remains unchanged.

Sources consulted: https://docs.godotengine.org/en/4.5/classes/class_fileaccess.html ; https://raw.githubusercontent.com/godotengine/godot/4.5/drivers/unix/dir_access_unix.cpp ; https://raw.githubusercontent.com/godotengine/godot/4.5/drivers/windows/dir_access_windows.cpp . No external source code copied or new dependencies installed.

Validation: Godot 4.5.1 Windows staged-save regression passes with marker RQ_SAVE_ATOMIC_OK. Local root-certificate-store warning is the known sandbox limitation. Cloud checks must pass before merge. Final issue closure requires successful combined CI and integration; physical Android kill/restart testing and sudden power-loss durability are not asserted.
