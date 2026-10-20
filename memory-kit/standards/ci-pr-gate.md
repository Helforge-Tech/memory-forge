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

1. **Every PR runs one job**, named `gate`, and it is the only required check.
2. **The job runs, in this order:** typecheck, the existing tests, a secret scan of the PR's commits (not the working tree), and lint once the repo has a linter. A repo with no typechecker or linter skips that step; it does not fake one.
3. **The job calls the repo's own commands** (`task test`, `task lint`, `task secrets`, ...), never tool invocations copied into the workflow ([app-commands](app-commands.md)). A missing command is proposed through the gap route, not invented in YAML.
4. **The secret-scan command takes the PR's base from the environment** (default `origin/main`) and scans only `base..HEAD`, so a local run and CI agree.
5. **A check that fails on today's code runs in baseline mode** ([checks-baseline-and-kinds](checks-baseline-and-kinds.md)), so the gate is on from day one in an existing repo.
6. **The job is required before merge** through branch protection where the plan allows it. Enabling it is a repo setting and waits for the owner's go-ahead. Where the plan does not allow it, record that in `docs/state/gaps.md`.
7. **Cost:** Ubuntu runners only, code-quality checks only ([0021](../../docs/decisions/0021-ci-code-quality-only.md)). The gate steps print each check's name and result.
8. **A gate is never loosened to make a PR pass** ([app-quality-gates](app-quality-gates.md) rule 5).

## Why

- A change that breaks or leaks is stopped before merge, not found after.
- One required job means a new check is added to the workflow without a settings change.
- The same commands run locally and in CI, so a result means the same in both.

## Do / Don't

Do:

```yaml
jobs:
  gate:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
        with: { fetch-depth: 0 }
      - run: nix develop -c task test
      - run: nix develop -c task secrets
```

Don't: `run: gitleaks detect ...` or `run: cargo clippy ...` in the workflow, a required check per tool, or `continue-on-error` on a gate step.

## Applied in

Not applied yet in this repo. The first project that applies it lists its paths here.
