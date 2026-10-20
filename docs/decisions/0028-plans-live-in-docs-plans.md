# 0028: Plans for larger work live in `docs/plans/`, one set of files per issue

- Status: accepted
- Date: 2026-10-20
- Scope: where plans are saved; the `plan-a-piece-of-work` playbook

## Context
Issue #9 adds a planning playbook and says plans are designs kept in `docs/`. The folder `docs/planning/` already holds the memory design, so a plan needed a place that is not confused with it.

## Decision
A plan is saved in `docs/plans/`, named `<issue#>-<short-summary>.md`. Multi-phase work uses a summary file with that name plus `<issue#>-<short-summary>-phase-<n>.md` per phase. The owner chose this location in conversation; it needs no gaps row because no standard was missing, only a path to pick.

## Alternatives
- **`docs/planning/`.** Already used for the memory design, so plans and the design would mix.
- **Inside the issue or PR.** Not reviewable against the code later and lost when the PR closes.

## Dissent
`plans/` and `planning/` differ by two letters. Accepted: `docs/INDEX.md` says they are different.

## Consequences
Easier: plans are found by issue number. Harder: finished plans accumulate; mark them `done` or `dropped`. Revisit if the folder grows past what the index can carry.
