---
title: Bring an existing app up to standard
status: active
updated: 2026-10-21
---

# Bring an existing app up to standard

## When to use

An app already exists, whether built from [desktop-app-setup](desktop-app-setup.md), built by hand, or inherited, and it must conform to the standards that apply to it. Also: after a standard changes and the "applied in" list becomes a migration list. Nothing is rewritten up front; the check decides what is wrong.

## Steps

1. **Scope.** Name the app directory and the standards in scope: every `active` row in `memory-kit/standards/INDEX.md` whose kind matches (for a desktop app, kind `app` and `tooling`; skip any rule marked for a stack the app does not use, and any standard scoped to an app type the app is not, such as `app-auth` for a non-desktop app). Say what is out of scope.
2. **Run every check.** For each in-scope standard, run its check (the `check:` line in its frontmatter), in the dev shell. `task lint` and `task test` cover most. A standard whose check is `reviewer` or `none yet` is read against the code by hand and the findings listed.
3. **Record the baseline.** If checks fail on day one, do not switch them off. Make sure the app is in `checks/kinds` under the kind its conformance check reads (`desktop-app` for `app-conformance.sh`, which covers Tauri apps; another stack needs its own check, which is a gap), then write the violations to the baseline: `memory-kit/checks/app-conformance.sh --list-violations | memory-kit/checks/baseline.sh regenerate app-conformance`. Existing violations are then tolerated and any new one fails ([checks-baseline-and-kinds](../standards/checks-baseline-and-kinds.md)). Commit the baseline in its own commit, with the count in the message.
4. **Rank the violations.** Cheapest and riskiest first. A violation that needs a design change is a gap: stop, give 2 to 3 options with a recommendation and the strongest objection, and let the owner decide (the gap protocol).
5. **Fix in small PRs**, one rule or one area at a time, shipped with [git-ship-a-change](git-ship-a-change.md). Each PR removes its entries from the baseline; the check fails if an entry is left behind, so the count only goes down.
6. **Find what the standards do not cover.** If the app does something with no standard (a variant, a convention nobody wrote down), do not invent one: log it as a gap and add it through the normal route.
7. **Write down what you learned.** Domain facts go into the knowledge notes; rules go into standards; steps that were wrong or missing go into this playbook.

## Standards used

Every active standard in scope, by link from the INDEX. This playbook never restates them.

## Done when

- Every in-scope check passes, or its remaining violations are in the baseline with an issue each.
- No check was loosened or switched off to get here.
- Gaps are recorded, not improvised.
- Standards touched and knowledge added are listed in the PR.

## Reference output

Not run on a real inherited app yet.
