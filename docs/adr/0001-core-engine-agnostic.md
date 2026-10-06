# ADR 0001 — Portable engine-agnostic gameplay core

- **Status:** Accepted by the current PE execution roadmap; master-source verification pending
- **Recorded:** 2026-10-06
- **Source:** `docs/roadmap/PE_EXECUTION_WAVES.md`

## Context

The available PE roadmap explicitly calls for a gameplay core in pure C++, no Godot or PS3 dependencies inside `core/`, engine/platform integration through adapters, a Godot sandbox, and a separate PS3 feasibility gate.

The repository also contains metadata from an earlier Unity prototype. That historical material conflicts with the newer execution architecture if treated as current guidance.

The roadmap references Documento Mestre v3.0 and Planejamento 2.0, which are not currently committed.

## Decision

Until superseded by an approved ADR:

1. Gameplay/domain logic belongs in a portable C++ core.
2. Engine/platform APIs must not leak into `core/`.
3. Godot integration belongs in `adapters/godot/`.
4. PS3-specific integration belongs in `adapters/ps3/`.
5. Unity project metadata is legacy evidence, not the active architecture.
6. Data-driven gameplay definitions belong in `data/` when their owning PE wave begins.

## Consequences

This reduces engine lock-in and isolates platform experiments, but adds up-front build and adapter complexity.

## Follow-up

Review this ADR when Documento Mestre v3.0 and Planejamento 2.0 are recovered. Contradictions must be handled by a superseding ADR rather than rewriting history.
