# 0028: Every repo gates pull requests in CI with one required job that calls the repo's own commands

- Status: accepted
- Date: 2026-10-20
- Scope: `.github/workflows/` of any repo that uses the kit; standard `ci-pr-gate`; the CI row in `docs/state/gaps.md`

## Context
[#16](https://github.com/Helforge-Tech/memory-forge/issues/16). `app-quality-gates` covers one app's format, lint and test gates. Nothing covers a whole repo: in a monorepo CI may only build artifacts, and a broken or leaking change is found after merge. The secret scan exists only as a local hook ([0008](0008-tools-declared-in-the-nix-flake.md)), which a contributor can lack. [0021](0021-ci-code-quality-only.md) limits CI to code-quality checks on Ubuntu to stay inside the free quota.

## Decision
- Every PR runs **one job**, and that job is the **required** check before merge. It runs typecheck, the existing tests, a secret scan of the PR's commits, and lint once a linter exists.
- The job calls the **repo's own commands** (`task ...`, see [app-commands](../../memory-kit/standards/app-commands.md)), not tool invocations copied into the workflow. Where a command is missing, the repo adds it through the gap route.
- A check that fails on today's code runs in **baseline mode** ([0025](0025-check-baselines-and-kinds-map.md)), so the gate can be switched on in an existing repo on day one and the count only goes down.
- It is **required where the plan allows branch protection**. Turning that on is a repo setting and needs the owner's go-ahead ([0027](0027-what-a-go-ahead-covers.md)). Where the plan does not allow it, the gap is recorded in `docs/state/gaps.md`.
- **Triggers:** `pull_request`, and `push` to `main` only, so a push to a PR branch runs the checks once, not twice. This supersedes the "on every push" part of [0021](0021-ci-code-quality-only.md) for repos that adopt the gate; the rest of 0021 stands (Ubuntu only, code-quality only, full build local). 0021's quota reasoning was written for a private repo; this repo is now public, and the standard keeps the checks cheap regardless.

## Alternatives
- **Several required jobs, one per check.** Finer failure reports, but every new check needs a settings change to become required, and the required list drifts from the workflow. One job avoids both.
- **Rely on the local hook for secrets.** Free, but a contributor without the dev shell skips it.
- **Make the gate wait for all checks to be clean.** Cannot be switched on in an existing repo; baselines remove that blocker.

## Dissent
One job hides which check failed until the log is opened, and a slow check delays all of them. Accepted: the job prints each check's name and result, and checks can be split into steps without changing what is required.

## Consequences
Easier: a leaking or broken change is stopped before merge, and an existing repo can adopt the gate on day one. Harder: each repo needs a command for every check the gate runs, including a secret scan over a commit range. The adopt playbook ([#7](https://github.com/Helforge-Tech/memory-forge/issues/7)) is to apply this standard; that link is added there.
