---
title: An app exposes one command each for dev, build, test, coverage, lint, fmt and budget
kind: app
scope: portable
status: active
updated: 2026-10-15
decision: ../../docs/decisions/0003-task-runner-go-task.md
check: reviewer (`task --list` shows every command; AGENTS.md lists them)
---

# An app exposes one command each for dev, build, test, coverage, lint, fmt and budget

## Rule

1. **The task runner has exactly one command each for `dev`, `build`, `test`, `coverage`, `lint`, `fmt` and `budget`.** `budget` checks every size budget, building what it needs ([app-performance-budgets](app-performance-budgets.md)); its cheap half is also a separate task for CI. `coverage` runs every test with coverage and enforces the thresholds ([app-test-coverage](app-test-coverage.md)); it is a superset of `test`. They are listed in the repo's `AGENTS.md` and appear in `task --list` with a description.
2. **There is no `setup` command.** Setting a project up is a playbook the agent follows. What setup used to do is automatic: tasks install their dependencies when the lockfile changes, and entering the dev shell enables the git hooks ([0020](../../docs/decisions/0020-setup-from-memory-copier-deferred.md)).
3. **Commands run inside the dev shell** ([tooling-declared-in-flake](tooling-declared-in-flake.md)).
4. **A missing command is proposed, not invented.** Add it through the usual gap route.

## Why

- Agents and CI call the same commands, so a result means the same thing in both.
- A per-project setup command only fits one stack and hides knowledge that belongs in memory.

## Do / Don't

Do: `install` as an internal task with `sources` and `generates`, depended on by the others.

Don't: a public `task setup` that a human or agent must remember to run first.

## Applied in

Not applied yet in this repo. The first project that applies it lists its paths here.
