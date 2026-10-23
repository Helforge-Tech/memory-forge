# 0039: A nested area brief is linked from its parent brief's Code section

- Status: accepted
- Date: 2026-10-23
- Scope: the `memory-area-briefs` standard, the memory check (`brief-unlinked`), the `/pickup` skill; extends [0034](0034-area-briefs.md)

## Context

[0034](0034-area-briefs.md) requires the root repo map to link every area brief, and it says an area that needs more than the brief budget should be split. In a monorepo, one area (for example `services/`) can hold many sub-areas, each with its own routes, dependencies and constraints. Kept in one brief, that detail fills the budget, and a session working on one sub-area reads all of it. Splitting it under 0034 means one more root repo-map row per sub-area, and the root is meant to stay a short map of areas.

## Decision

- An area brief may have nested briefs one or more folders below it (`services/api/AGENTS.md` under `services/AGENTS.md`). A nested brief has the same headings and budget as any brief.
- A nested brief is linked either from the root repo map or from the `## Code` section of its nearest parent brief, on the bullet whose path is the nested brief's folder (``- `api/` the public API ([brief](api/AGENTS.md))``). The parent brief then serves as the index, and the root map links only the parent.
- The memory check's `brief-unlinked` accepts either link. A link elsewhere in the parent brief, on another bullet, or inside inline code or a fenced block does not count, so the `## Code` list stays the one index.
- "Scope first" reads the brief of each sub-area in scope, and `/pickup <n>` reads the nested brief when the issue's paths fall in that sub-area.
- A repo whose `checks/split` lists its briefs one by one must also list each nested brief as memory. The split map has no globs.

## Alternatives

- **Root map links every brief.** No check change, but the root grows by one row per sub-area and stops being a map of areas.
- **Move the sub-area detail into `docs/`.** One brief and no rule change, but the detail is no longer next to the code, which 0034 rejected for the same reason, and tools that load a nested `AGENTS.md` miss it.

## Dissent

Nested briefs add a level that a session must follow: the parent brief, then the brief of the sub-area in scope. Many small files also drift more easily than one. Accepted: the parent stays short and links each one, `brief-path-missing` and `ref-missing` cover nested briefs as well, and a session reads only the briefs in scope.

## Consequences

Easier: a session working on one sub-area reads the root map, the parent index and one short brief, and a large area stops pressing on its budget. Harder: adding a sub-area means a brief, a parent `## Code` bullet and, where the split map lists briefs, a `checks/split` row.
