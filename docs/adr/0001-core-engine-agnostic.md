# ADR 0001 — Portable engine-agnostic gameplay core

- **Status:** SUPERSEDED by ADR 0002
- **Originally recorded:** 2026-10-06
- **Historical source:** former Portal's Edge PE execution roadmap

## Historical decision

The former plan selected a pure C++ gameplay core with Godot and PS3 adapters and treated PS3 feasibility as an early gate.

## Why it was superseded

A later, more product-specific Rasta Quest source defines:

- Godot 4.5.1;
- GDScript without .NET;
- 2D side-scrolling platformer gameplay;
- Android landscape as primary target;
- a compact mobile-first scope.

The approved integrated plan prioritizes shipping that product rather than preserving engine portability that would add substantial implementation complexity before game-feel validation.

No historical evidence is deleted; the old PE roadmap remains archived.

See ADR 0002 for the current decision.
