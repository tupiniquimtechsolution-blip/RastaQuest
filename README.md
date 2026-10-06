# RastaQuest

> **Status:** pre-production / PE-000 repository normalization  
> **Playable build committed:** no  
> **Current implementation source committed:** no

RastaQuest consolidates the historical **Portal's Edge: Last Stand** design material, a newer PE execution roadmap, concept art, and metadata from an earlier Unity prototype named **PortalAscendant**.

The repository is organized so an executive, producer, designer or engineer can distinguish **current decisions** from **legacy evidence** without losing project history.

## Executive snapshot

- Historical GDD: action roguelite centered on portals, melee combat, upgrades and meta progression.
- Current execution roadmap: portable **C++ core**, engine/platform adapters, **Godot** gameplay sandbox, and a gated **PS3 homebrew feasibility proof**.
- Earlier Unity metadata is preserved in `docs/legacy/unity/`; it is not the current implementation baseline.
- The repository currently contains no complete gameplay source tree or executable build.
- Naming remains unresolved: repository **RastaQuest**, historical title **Portal's Edge: Last Stand**, old Unity solution **PortalAscendant**.

## Source-of-truth hierarchy

1. `AGENTS.md` — operating contract.
2. `docs/roadmap/PE_EXECUTION_WAVES.md` — most structured current execution plan available.
3. `docs/adr/` — approved architecture decisions.
4. `docs/status/CURRENT_STATE.md` — evidence-backed project status.
5. `docs/legacy/` and `assets/legacy/` — preserved historical inputs, not automatically current requirements.

> The PE roadmap references **Documento Mestre v3.0** and **Planejamento 2.0**. Those sources are not currently present, so requirements that depend exclusively on them remain unverified.

## Structure

```text
.
├── .github/        # CI and review templates
├── .agents/        # Tupiniquim agent skill
├── .claude/        # Claude adapter
├── adapters/       # Engine/platform integration
├── assets/legacy/  # Historical visual material
├── core/           # Portable gameplay core (PE-001+)
├── data/           # Data-driven definitions (future waves)
├── docs/
│   ├── adr/
│   ├── legacy/
│   ├── roadmap/
│   └── status/
├── tests/
└── tools/
```

## Current blockers

1. Recover or upload Documento Mestre v3.0 and Planejamento 2.0, or formally declare them obsolete.
2. Confirm the complete intended source upload. The old Unity metadata references `Assets/Scripts/PlayerMovement.CS`, which is absent.
3. Reconcile RastaQuest / Portal's Edge / PortalAscendant naming.
4. Confirm platform priority and architecture before PE-001.
5. Select a license before external distribution or third-party contribution.

See `docs/status/CURRENT_STATE.md` for audit evidence.

## Working rules

- Do not treat legacy documents as current requirements without an explicit decision.
- Do not commit generated engine/editor caches.
- Never commit secrets, tokens, credentials or signing material.
- Architecture/scope changes require an ADR or an explicit superseding decision.
- Prefer pull requests for structural and implementation changes.
