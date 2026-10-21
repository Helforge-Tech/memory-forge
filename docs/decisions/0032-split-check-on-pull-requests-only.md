# 0032: The code and memory split is checked on pull requests only, not on a push to main

- Status: accepted
- Date: 2026-10-21
- Scope: the `task split` step of the CI gate; standards `ci-pr-gate` and `git-split-code-and-memory`

## Context
[#54](https://github.com/Helforge-Tech/memory-forge/issues/54). [0031](0031-split-code-and-memory-prs.md) splits a change that needs both code and memory into a stack. Merging a stack with `gh stack merge` lands every layer in one push to `main`. The gate ([0029](0029-ci-pr-gate.md)) takes the base of a push from the commit before it, so the split check saw both layers as one change and failed (run after #49 and #50).

## Decision
- `task split` runs on `pull_request` only. On a push to `main` the gate runs the other checks and skips it.
- Each layer of a stack is still checked as a PR against its own base, which is where the rule applies.

## Alternatives
- **Check a push against its first parent.** Fails the same way for a stack merged as one push, and a squash or merge commit changes what the parent is.
- **Tolerate the red run.** A red `main` hides real failures.

## Dissent
A push to `main` that skipped a PR would not be split-checked. Accepted: `main` requires a pull request, so every change reached it through a PR that was.

## Consequences
Easier: merging a stack no longer turns `main` red. Harder: nothing. The other gate checks still run on a push.
