---
title: Every repo gates pull requests with one required CI job that calls the repo's own commands
kind: ci
scope: portable
status: active
updated: 2026-10-20
decision: ../../docs/decisions/0028-ci-pr-gate.md
check: reviewer (the workflow and the branch-protection setting)
---

# Every repo gates pull requests with one required CI job that calls the repo's own commands

## Rule

1. **Every PR runs a job named `gate`, and it is the only required check.** It is either the one job that does the work, or an aggregate that `needs` the parallel jobs and fails unless all of them succeeded (`if: always()` and a check of `needs.*.result`), so a skipped or cancelled job cannot read as a pass.
2. **The job runs, in this order:** typecheck, the existing tests, a secret scan of the PR's commits (not the working tree), and lint once the repo has a linter. A repo with no typechecker or linter skips that step; it does not fake one.
3. **The job calls the repo's own commands** (`task test`, `task lint`, `task secrets`, ...), never tool invocations copied into the workflow ([app-commands](app-commands.md)). `secrets` is a repo-level command beside the app commands. A missing command is proposed through the gap route, not invented in YAML.
4. **The secret-scan command reads its base from `GATE_BASE`**, a commit the scan starts after, and scans `$GATE_BASE..HEAD`. CI sets it to the PR's base commit on `pull_request` (`github.event.pull_request.base.sha`) and to the commit before the push on `push` (`github.event.before`). Unset, it defaults to `origin/main`, so a local run covers the same commits as a PR. In CI a scan that covers zero commits, or whose base does not resolve (a new branch's all-zero `before`), fails instead of passing.
5. **A check that fails on today's code runs in baseline mode** ([checks-baseline-and-kinds](checks-baseline-and-kinds.md)), so the gate is on from day one in an existing repo.
6. **The job is required before merge** through branch protection where the plan allows it. Enabling it is a repo setting and waits for the owner's go-ahead. Where the plan does not allow it, record that in `docs/state/gaps.md`.
7. **Cost:** Ubuntu runners only, code-quality checks only ([0021](../../docs/decisions/0021-ci-code-quality-only.md)). The workflow triggers on `pull_request` and on `push` to `main` only, so a push to a PR branch runs the checks once. The gate steps print each check's name and result.
8. **A gate is never loosened to make a PR pass** ([app-quality-gates](app-quality-gates.md) rule 5).

## Why

- A change that breaks or leaks is stopped before merge, not found after.
- One required job means a new check is added to the workflow without a settings change.
- The same commands run locally and in CI, so a result means the same in both.

## Do / Don't

Do:

```yaml
on:
  pull_request:
  push:
    branches: [main]
permissions:
  contents: read
concurrency:
  group: ci-${{ github.ref }}
  cancel-in-progress: true
jobs:
  gate:
    runs-on: ubuntu-latest
    env:
      GATE_BASE: ${{ github.event.pull_request.base.sha || github.event.before }}
    steps:
      - uses: actions/checkout@<40-char commit sha> # v4
        with: { fetch-depth: 0 }
      # install the tools the commands need (the repo's setup step or action)
      - run: task test
      - run: task lint
      - run: task secrets
```

Don't: pin an action by tag only (pin by commit SHA, tag in a comment), drop `permissions` or `concurrency`, `run: gitleaks detect ...` or `run: cargo clippy ...` in the workflow, a required check per tool, or `continue-on-error` on a gate step.

## Applied in

Not applied yet in this repo. The first project that applies it lists its paths here.
