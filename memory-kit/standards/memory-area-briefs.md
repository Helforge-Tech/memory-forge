---
title: A large repo keeps a short brief per area, linked from the root repo map
kind: memory
scope: portable
status: active
updated: 2026-10-21
decision: ../../docs/decisions/0034-area-briefs.md
check: memory-check.sh rules brief-unlinked, brief-size, brief-path-missing, tested by test-memory-check.sh in task test; task memory
---

# A large repo keeps a short brief per area, linked from the root repo map

## Rule

1. **Per-area detail goes in an area brief**, not in the root `AGENTS.md`. A brief is `AGENTS.md` in the area's folder. Use one when an area has its own commands, local standards or owners; a small repo needs none.
2. **A brief has these headings, in this order, each short:**
   - `## What it is`: one or two sentences.
   - `## Commands`: the commands for this area, as run from the repo root.
   - `## Local standards`: links to the standards and playbooks that apply here (link, never copy).
   - `## Code`: one bullet per path (a real path, no globs), the path first in backticks and relative to the brief's folder (``- `src/` the UI``).
   - `## Owners`: names or roles, or "none".
3. **The root repo-map row for the area links its brief**, as in the block below. The root stays a short map.

   ```
   | `web/` | The web UI. [brief](web/AGENTS.md) |
   ```
4. **A brief stays under 4000 bytes** (`MEMORY_BRIEF_BUDGET` sets another). A brief that needs more means the area should be split.
5. **A session reads the brief of each area in scope** when it states its scope ("scope first" in `AGENTS.md`), and `/pickup <n>` reads the brief of the issue's area. It does not read the briefs of other areas.
6. **The memory check enforces** `brief-unlinked` (a tracked `<folder>/AGENTS.md` that the repo map does not link), `brief-size` and `brief-path-missing` (a `## Code` path that does not exist), and its link check covers briefs. See [memory-checks](memory-checks.md).

## Why

- A session working in one area should not read guidance for all of them.
- The root's size budget stops being a reason to drop area detail.

## Do / Don't

Do: put `web/`'s test command in `web/AGENTS.md` and link the brief from the root map.

Don't: repeat a standard's text in a brief, or leave a brief unlinked (the check fails it).

## Applied in

No example yet. [adopt-existing-repo](../playbooks/adopt-existing-repo.md) step 3 uses it.
