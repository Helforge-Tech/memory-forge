---
title: Roll out a standard incrementally
status: active
updated: 2026-10-21
---

# Roll out a standard incrementally

## When to use

A repo is adopted ([adopt-existing-repo](adopt-existing-repo.md)) and one more kind of thing needs a standard, while the code that already exists is not yet in line with it. The standard arrives first, the code is brought in line over time, and the baseline count says how far along that is. Use [app-bring-to-standard](app-bring-to-standard.md) for the migration issues this playbook files, not for choosing or writing the standard.

## Steps

1. **Rank the kinds, then pick one.** For each kind with no standard (`docs/state/gaps.md`), score three things from 1 (low) to 3 (high):
   - **Breadth:** how many areas (apps, services, packages) the kind crosses. 1 is one area, 2 is a few, 3 is most of the repo.
   - **Churn:** how often the kind changes. Read it from `git log` over the last few months for the paths involved.
   - **Risk:** the harm if it is wrong or inconsistent (data loss, security, a broken release is 3; a style drift is 1).

   Rank by the sum. Break a tie with risk, then breadth. Scores are a starting order for the owner, not a verdict: the owner picks which standard comes first. The scores are derived from the repo, so do not ask the owner to supply them.
2. **Inventory the kind** in the areas in scope: the variants that exist, roughly how often each appears, and one example path each. Output: a short table in the issue or the PR description, not a new file in the repo.
3. **Write the standard from the best existing variant.** The best variant is the reference and the standard's "Applied in" names it; the areas that are not in line are found by the check in step 4. Use `/standard`; it adds the decision when the choice was real. Where two variants are about equal, that is an owner decision (options, a recommendation, the strongest objection).
4. **Add the check in baseline mode.** Write the check to print `rule<TAB>path[<TAB>key]`, find its targets through the kinds map, and write today's violations to its baseline with `baseline.sh regenerate <check>`, in its own commit with the count in the message; the script and its baseline ship in one PR ([checks-baseline-and-kinds](../standards/checks-baseline-and-kinds.md)). New code complies from the day the check merges: a new violation fails the gate.
5. **File the migration as small issues.** The migration list is the distinct `path` values in `checks/baselines/<check>`: one issue per area, scoped to this standard only, each worked with [app-bring-to-standard](app-bring-to-standard.md) or the matching playbook. A feature PR does not fix other areas' violations on the side.
6. **Read progress from the baseline.** The number of lines in `checks/baselines/<check>` is the progress; each migration PR removes its lines. Do not keep a hand-written list. The standard is rolled out when the baseline is empty, and the check then runs without one.

Decision: [0033](../../docs/decisions/0033-rank-standards-by-breadth-churn-risk.md) (the ranking).

## Standards used

- [checks-baseline-and-kinds](../standards/checks-baseline-and-kinds.md)
- [standards-tiers](../standards/standards-tiers.md)
- [git-issues](../standards/git-issues.md)

## Done when

- The kind was ranked, and the ranking shows why it came before the next one.
- The standard exists, with a decision if the choice was real, and its "Applied in" names the reference.
- The check runs in baseline mode and a new violation fails it.
- One issue per area is filed, each scoped to this standard.
- The baseline count is the only progress record.

## Reference output

No example yet. The first standard rolled out in an adopted repo should be added here.
