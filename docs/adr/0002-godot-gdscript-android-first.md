# ADR 0002 — Godot/GDScript Android-first architecture

- **Status:** ACCEPTED
- **Date:** 2026-10-06
- **Supersedes:** ADR 0001 for Rasta Quest 1.0

## Context

The uploaded Rasta Quest source consistently identifies the intended product as a 2D action-platformer/light roguelike using Godot 4.5.1, GDScript and Android landscape. It also defines stable player animation names, a platformer movement model, a double-bladed axe, electrical abilities, portals and light meta progression.

The historical Portal's Edge roadmap used a much heavier portable C++ core and PS3 feasibility gate. That plan preserved useful design concepts but no longer matches the fastest coherent path to the approved Rasta Quest product.

## Decision

For Rasta Quest 1.0:

1. Use Godot 4.5.1.
2. Use typed GDScript without .NET.
3. Ship Android landscape first.
4. Keep gameplay systems modular inside the Godot project rather than building a separate C++ domain core.
5. Treat PC as development/QA and optional later distribution.
6. Treat PS3 homebrew as post-1.0 research only.
7. Use engine-native/data-driven patterns before third-party frameworks.
8. Build mobile performance and touch input into milestones from the start.

## Consequences

### Benefits

- lower implementation and integration overhead;
- direct match to the source project direction;
- faster playable feedback;
- simpler onboarding and CI;
- fewer platform abstractions before product-market/gameplay validation.

### Tradeoffs

- greater engine coupling;
- a later console/engine port may require adaptation rather than a pre-existing portable core;
- PS3 research no longer drives early architecture.

These tradeoffs are accepted for 1.0.

## Revisit conditions

Revisit only after 1.0 or if:

- an approved platform requirement makes GDScript/Godot technically infeasible;
- profiling proves a specific native extension is required;
- a commercial distribution target imposes constraints unavailable in the current stack.
