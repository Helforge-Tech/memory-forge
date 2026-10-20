# 0028: Memory has checks, run through the baseline runner

- Status: accepted
- Date: 2026-10-20
- Scope: `memory-kit/checks/memory-check.sh`, `task memory`, the `memory-checks` standard

## Context
Root guidance drifts: the repo map lists folders that no longer exist, links point at removed paths, and guidance names commands the task runner lacks. Agents trust what they read, so stale memory is worse than none. The memory design (§5a) asks for checks on memory itself, and [0025](0025-check-baselines-and-kinds-map.md) gave checks a baseline so they can be switched on in a repo that is already out of standard. Issue #6 asked for the checks.

## Decision
- **One script, many rules.** `memory-kit/checks/memory-check.sh` prints violations in the baseline format; `task memory` pipes it through `baseline.sh run memory`. The rules are listed in the script header and the standard.
- **Links, not prose, are checked.** Only markdown links are resolved; paths written in backticks are not, because they are often examples or future paths. The repo map table is the one place backticked paths are read.
- **Decisions are compared with the merge base** with `origin/main` (override with `MEMORY_CHECK_BASE`), ignoring the `- Status:` line. Where there is no such ref or merge base (a shallow clone), the rule is skipped with a note locally, but is the violation `decision-base-missing` when `CI` or `MEMORY_REQUIRE_BASE` is set: a gate must not pass because it could not look.
- **Task names come from the task runner** (`task --list-all --json`), which knows includes, namespaces and which Taskfile it prefers. Without it, the first `Taskfile.yml` or `Taskfile.yaml` is parsed at whatever indent it uses.
- **A duplicate decision number is a violation** (`decision-number-duplicate`): parallel branches can pick the same next number.
- **"Archival" means a folder holding `ARCHIVED.md`.**
- **The memory map of §5a is not built here.** The checks read the default layout. A repo with a different layout sets that up when it adopts the kit (#7).
- **Not in this first cut:** that each package or service folder of a monorepo is listed in the repo map; that every top-level folder matches a kind or is listed as ignored (needs a decision on how to list ignored folders), and a task-runner check for archived directories beyond links.

## Alternatives
- **One script per rule.** Clearer files, but more entries in `task` and more baselines. One baseline named `memory` keeps the count in one place.
- **Resolve backticked paths too.** Catches more, but fails on every example and every path a playbook says to create.

## Dissent
A single script grows. Accepted for now; split it when a rule needs its own data or runs on its own schedule.

## Consequences
Easier: stale memory fails a check instead of misleading the next session. Harder: a rename now means updating every link in the same PR. Revisit when #7 shows how a repo with a non-default layout maps its sections.
