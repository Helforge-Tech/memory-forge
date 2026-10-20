---
title: Plan a piece of work before building it
status: active
updated: 2026-10-20
---

# Plan a piece of work before building it

## When to use

The work spans several files, areas or sessions, or changes something other code depends on, and the approach is not obvious. A one-file fix with a clear cause needs no plan. When unsure, start the plan: if the research shows the work is small, say so in the plan and stop there.

## Steps

1. **Scope.** Name the issue, what is in scope and what is out. Put the non-goals in the plan in their own section; a plan without them is not ready.
2. **Research the code before asking anything.** Read the code, the standards ([standards INDEX](../standards/INDEX.md)), the playbooks ([INDEX](INDEX.md)) and the decisions that touch the area. Anything the repo can answer is not a question for the owner.
3. **Scan the blast radius.** Search (Grep, not memory) for every caller, consumer, config and doc that mentions what will change, across areas. List what you found and what you checked.
4. **Triage the problems.** For each candidate problem, show it is real (a command, a file, a failing case) and that it matters (who is hurt, how often). Drop the ones that fail either test and say so in the plan; do not plan a fix for something unproven.
5. **Ask and propose in one round-trip.** Send the owner the open questions together with the proposed approach: 2 to 3 options, a recommendation and the strongest objection for each real choice. A decision that is the owner's, and that the repo cannot answer, is the only reason to ask.
6. **Write the plan** from a [template](../templates/INDEX.md) and save it in `docs/plans/` ([0030](../../docs/decisions/0030-plans-live-in-docs-plans.md)): `<issue#>-<short-summary>.md`, or for multi-phase work the summary under that name plus `<issue#>-<short-summary>-phase-<n>.md` per phase. Give it `status` (`draft`, `accepted`, `done` or `dropped`) and `updated` in its header. Every claim is checked against the repo, or marked `(unverified)`. Each step says how to tell it worked.
7. **Record the architecturally significant choices** in `docs/decisions/` from the [decision template](../../docs/decisions/0000-template.md), and link them from the plan.
8. **Review before accepting.** Run the `reviewer` agent in plan mode on the plan file (a subagent cannot start another, so the main session runs it). Fix blocking findings and re-run. Then the owner accepts the plan in conversation and the session sets `status: accepted`; the owner never edits the header.
9. **Ship the plan in its own PR,** before any code, so the plan can be reviewed and merged without code in it (a PR that mixes a plan and code is hard to review).
10. **Build** from the accepted plan, one PR per step or phase through [git-ship-a-change](git-ship-a-change.md). If the code shows the plan is wrong, update the plan and say what changed; do not drift from it silently.

## Standards used

- [agents-model-by-role.md](../standards/agents-model-by-role.md) (the reviewer's model)
- [git-issues.md](../standards/git-issues.md)

## Done when

- The plan exists in `docs/plans/` with a status and a date, from a template.
- It states non-goals, the blast-radius scan and the triage result, and marks every unchecked claim.
- The `reviewer` agent ran on it with no blocking findings left.
- The owner has accepted it, and significant choices have a decision record.

## Reference output

No example yet. The first real plan should be linked here.
