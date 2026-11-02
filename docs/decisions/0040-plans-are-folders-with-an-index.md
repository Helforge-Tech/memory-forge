# 0040: A plan is a folder in `docs/plans/`, and `docs/plans/INDEX.md` lists every plan

- Status: accepted
- Date: 2026-11-02
- Scope: where and how plans are saved; the `plan-a-piece-of-work` playbook; the memory check (`plan-row-missing`); supersedes [0030](0030-plans-live-in-docs-plans.md)

## Context

[0030](0030-plans-live-in-docs-plans.md) saves each plan as flat files named `<issue#>-<short-summary>.md`, plus `-phase-<n>` files for multi-phase work. In a project that used the kit for months, plans grew supporting files (a captured baseline, a verification runbook, sub-plans), some plans had no single issue, and a flat folder of a few dozen files could no longer be scanned. Nothing listed the plans or said which were still live; 0030 had already named the index as the point to revisit.

## Decision

- A plan is a folder, `docs/plans/<slug>/`. A single-issue plan is `plan.md`; multi-phase work is `summary.md` (what, why, scope, non-goals, a few sentences per phase) plus `detail.md` (the spec per phase). Supporting files sit in the same folder.
- The main file keeps the `status` (`draft`, `accepted`, `done`, `dropped`) and `updated` header.
- `docs/plans/INDEX.md` has one row per plan (Plan, What, Issue, Status), linking into its folder.
- The memory check enforces the index: `plan-row-missing` fails a tracked plan folder with no row, and the index is in the `ref-missing` link scan, so a row for a moved or deleted plan fails. Without an index file, the rule does not run.

## Alternatives

- **Keep flat files and add only an index.** Rejected: supporting files still mix into one folder, and plans without an issue have no name under 0030's scheme.
- **An index generated from the plan headers.** Rejected for now: one more script to maintain, and the index also carries a one-line "what" that a header does not.

## Dissent

The issue number is no longer in the file name, so finding a plan by issue means reading the index. Accepted: the index's Issue column answers that, and the slug survives a plan that spans several issues.

## Consequences

Plans are found from one index, with their status. The index and the plan header both hold a status, and nothing checks that they match yet; the next step, if they drift, is an `index-status`-style rule for plans. Projects with flat 0030 plans move each into a folder when they take this in.
