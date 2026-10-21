# 0034: Large repos keep per-area briefs, linked from the root repo map

- Status: accepted
- Date: 2026-10-21
- Scope: the `area-briefs` standard, the memory check, the adopt playbook

## Context
[#10](https://github.com/Helforge-Tech/memory-forge/issues/10). In a large monorepo a session works in one area, and the root `AGENTS.md` should stay a short map (it has a size budget, [0028](0028-memory-checks.md)). Per-area detail needs a home that a session reads only when the area is in scope.

## Decision
- An area brief is a short `AGENTS.md` in the area's folder with fixed headings (what it is, commands, local standards, code, owners).
- The root repo-map row for the area links the brief. The memory check requires the link, a size budget of 4000 bytes per brief and that every path under the brief's `## Code` exists.
- "Scope first" and `/pickup` read the brief of each area in scope, and no other.
- The adopt playbook writes briefs at its root-guidance stage.

## Alternatives
- **Brief found by convention, no link in the map.** Simpler map, but the root no longer shows which areas have briefs, and a missing brief is silent.
- **Briefs under `docs/areas/`.** Keeps area folders free of memory files, but the brief is no longer next to the code, and tools that load a nested `AGENTS.md` lose it.

## Dissent
A link column in the repo map is one more convention for the check to parse, and 4000 bytes is a guess; a big area may want more. Accepted: an area that needs more is the signal to split it, and `MEMORY_BRIEF_BUDGET` sets another budget per repo.

## Consequences
Easier: a session in one area reads the root map plus one short brief. Harder: a brief can drift from its area; the path and link checks catch only part of that. Revisit after the first real monorepo adoption.
