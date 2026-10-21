---
title: Every repo gates pull requests with one required CI job that calls the repo's own commands
kind: ci
scope: portable
status: active
updated: 2026-10-21
decision: ../../docs/decisions/0029-ci-pr-gate.md
check: reviewer (the workflow and the branch-protection setting)
---

# Every repo gates pull requests with one required CI job that calls the repo's own commands

## Rule

1. **Every PR runs a job named `gate`, and it is the only required check.** It is either the one job that does the work, or an aggregate that `needs` the parallel jobs and fails unless all of them succeeded (`if: always()` and a check of `needs.*.result`), so a skipped or cancelled job cannot read as a pass.
2. **The gate runs:** typecheck and lint (often one command), the existing tests, `task memory` ([memory-checks](memory-checks.md)) and `task split` ([git-split-code-and-memory](git-split-code-and-memory.md)) in a repo that has the kit, and a secret scan of the PR's commits (not the working tree). A repo with no typechecker or linter skips that step; it does not fake one.
3. **The job calls the repo's own commands** (`task test`, `task lint`, `task secrets`, ...), never tool invocations copied into the workflow ([app-commands](app-commands.md)). `secrets` is a repo-level command beside the app commands. A missing command is proposed through the gap route, not invented in YAML.
4. **The secret-scan command reads its base from `GATE_BASE`**, a commit the scan starts after, and scans `$GATE_BASE..HEAD`. CI sets it once, at workflow level so every job has it, to the PR's base commit on `pull_request` (`github.event.pull_request.base.sha`) and to the commit before the push on `push` (`github.event.before`). Unset, it defaults to `origin/main`, so a local run covers the same commits as a PR. A base that does not resolve (a new branch's all-zero `before`) always fails. A range with no commits fails when the `CI` environment variable is set (GitHub Actions sets it) and only warns locally.
5. **A check that fails on today's code runs in baseline mode** ([checks-baseline-and-kinds](checks-baseline-and-kinds.md)), so the gate is on from day one in an existing repo.
6. **The job is required before merge** through branch protection where the plan allows it. Enabling it is a repo setting and waits for the owner's go-ahead. Where the plan does not allow it, record that in `docs/state/gaps.md`.
7. **Cost:** Ubuntu runners only, code-quality checks only ([0021](../../docs/decisions/0021-ci-code-quality-only.md)). The workflow triggers on `pull_request` and on `push` to `main` only, so a push to a PR branch runs the checks once. There is no `workflow_dispatch`: it has no base commit, so the scan would cover nothing; re-run a PR's jobs from its checks tab. Cancel superseded runs only off `main`, so a cancelled run never leaves commits on `main` unscanned. The gate steps print each check's name and result.
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
env:
  GATE_BASE: ${{ github.event.pull_request.base.sha || github.event.before }}
concurrency:
  group: ci-${{ github.ref }}
  cancel-in-progress: ${{ github.ref != 'refs/heads/main' }}
jobs:
  gate:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@<40-char commit sha> # v4
        with: { fetch-depth: 0 }
      # install the tools the commands need (the repo's setup step or action)
      - run: task lint
      - run: task test
      - run: task memory   # only in a repo that has the kit
      - run: task split    # only in a repo that has the kit
      - run: task secrets
```

Don't: pin an action by tag only (pin by commit SHA, tag in a comment), drop `permissions` or `concurrency`, `run: gitleaks detect ...` or `run: cargo clippy ...` in the workflow, a required check per tool, or `continue-on-error` on a gate step.

## Applied in

This repo: `.github/workflows/gate.yml` runs `task test`, `task memory`, `task split` and `task secrets`. `task secrets` is a few lines of shell in the `Taskfile.yaml` (a new top-level folder for one script would need an `AGENTS.md` repo-map row, which a code-only PR cannot carry) that call `gitleaks git --log-opts="$GATE_BASE..HEAD"`.

## Verified

On 2026-10-21: locally, an unresolved base exits 2, an empty range warns, and with `CI` set it fails, and a commit with a fake key in a scratch clone fails the scan. In CI on a PR (#49), `github.event.pull_request.base.sha` resolved after `fetch-depth: 0` and the scan covered the PR's commits.

Not verified: `github.event.before` on a push to `main` (checkable on the first push after #49 and its memory PR merge), and the required-check setting.
