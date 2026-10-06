# Rasta Quest

> **Canonical product:** Rasta Quest  
> **Phase:** approved pre-production plan → RQ-001 project bootstrap  
> **Engine:** Godot 4.5.1, GDScript, no .NET  
> **Primary release:** Android, landscape  
> **Genre:** 2D action-platformer + light roguelike

Rasta Quest is a mobile-first action-platformer built around a Rastafarian-inspired warrior, a double-bladed ritual axe inspired by Xangô iconography, electrical combat, fractured portals, escalating runs and light permanent progression.

The canonical plan intentionally merges the strongest parts of the newer **Rasta Quest** material with the useful design DNA from the historical **Portal's Edge: Last Stand** documents without allowing old technical choices to override the approved direction.

## Product pillars

1. **Responsive platforming** — readable movement, jump, fall and aerial combat.
2. **Heavy axe combat** — clear impact, reliable hitboxes, short state transitions.
3. **Electric identity** — restrained but meaningful Xangô-inspired lightning effects.
4. **Portal runs** — short replayable chains of encounters with one-of-three upgrade choices.
5. **Progress without bloat** — light meta progression, clean mobile UX, no system added without a gameplay reason.

## Canonical source hierarchy

1. `docs/product/GAME_CANON.md`
2. `docs/roadmap/MASTER_RELEASE_PLAN.md`
3. `docs/architecture/TECHNICAL_ARCHITECTURE.md`
4. `docs/adr/`
5. `docs/status/CURRENT_STATE.md`
6. `docs/source/` — preserved raw source material
7. `docs/legacy/` and `assets/legacy/` — historical material and superseded plans

When sources conflict, the higher item in this list wins unless an approved ADR explicitly supersedes it.

## Repository layout

```text
.
├── .github/
├── .agents/
├── .claude/
├── assets/
│   └── legacy/
├── docs/
│   ├── adr/
│   ├── architecture/
│   ├── legacy/
│   ├── product/
│   ├── production/
│   ├── release/
│   ├── roadmap/
│   ├── source/
│   └── status/
└── game/                    # Godot project created in RQ-001
```

## Current execution point

**RQ-000 — Canonicalization and planning** is complete after merge of the approved plan.

The next implementation gate is **RQ-001 — Godot project bootstrap & CI**. No gameplay feature should jump ahead of the sequence in `docs/roadmap/MASTER_RELEASE_PLAN.md`.

## Historical names

- **Rasta Quest** — canonical current product name.
- **Portal's Edge: Last Stand** — historical design lineage; selected ideas were absorbed into the canon.
- **PortalAscendant** — old Unity prototype codename; archived only.

## Important scope decisions

- Godot/GDScript is the active implementation direction.
- Android landscape is the primary 1.0 release target.
- The older C++ portable-core/PS3-gate roadmap is superseded for 1.0.
- PC builds are development/QA targets first; a public PC release is a separate decision.
- PS3 homebrew is a post-1.0 research/stretch goal only.
- Historical F2P/battle-pass/revive monetization concepts are not part of the 1.0 implementation scope unless separately approved.
- Co-op, endless mode and the 20-portal content catalog are post-1.0 candidates.

## Key documents

- [Game canon](docs/product/GAME_CANON.md)
- [Technical architecture](docs/architecture/TECHNICAL_ARCHITECTURE.md)
- [Master release plan](docs/roadmap/MASTER_RELEASE_PLAN.md)
- [Release criteria](docs/release/RELEASE_CRITERIA.md)
- [Art pipeline](docs/production/ART_PIPELINE.md)
- [Current status](docs/status/CURRENT_STATE.md)

The original 7+ MB Rasta Quest source document is preserved unchanged at `docs/source/RASTA_QUEST_RAW.md`.
