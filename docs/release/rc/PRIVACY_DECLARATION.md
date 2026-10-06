# Rasta Quest — RC Privacy Declaration

**Status:** technical RC preparation; must be re-audited before store submission.

## Current repository/runtime declaration

The current 1.0 codebase does not intentionally integrate analytics, advertising, in-app purchases, account login, cloud save, remote tracking, or a network backend.

Core gameplay is designed to work offline. Player progression and settings are stored locally through the versioned Godot save system.

## Android permissions

The canonical export preset does not intentionally request gameplay-specific dangerous permissions. The final generated Android manifest must still be inspected from the actual signed release artifact before store submission because engine/tooling defaults can affect the packaged manifest.

## Data handling

Current local data categories:

- local settings/accessibility preferences;
- meta-progression currency and unlocks;
- completion flags;
- save schema version.

No user secrets or privileged credentials belong in save data.

## Release blocker

Any future SDK for analytics, crash reporting, ads, IAP, authentication, social features or network services requires this declaration and the store privacy disclosures to be updated before release.
