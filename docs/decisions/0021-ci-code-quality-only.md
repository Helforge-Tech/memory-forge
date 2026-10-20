# 0021: CI runs code-quality checks only; the full build is local

- Status: accepted
- Date: 2026-10-15
- Scope: `.github/workflows/`, `task build`

## Context
[0006](0006-ci-ubuntu-plus-macos-build.md) chose Ubuntu checks plus a macOS build on every push, and named cost as its dissent. The repo is private and the Actions budget is $0 with no card on file, so the monthly free quota (2,000 minutes on the Free plan) is a hard cap: when it runs out, runs are blocked until the month resets. The first run took about 4 minutes on Ubuntu and 3 on macOS; macOS minutes count 10 times against the quota, so the build job used most of it.

## Decision
- CI runs code-quality checks only, on Ubuntu: `task lint` and `task test`, on every push.
- The macOS build job is removed. The full build is local: `task build` produces the release binary.
- This supersedes the macOS part of 0006. Its Ubuntu part, and its rule that Rust comes from rustup using `rust-toolchain.toml`, stand.

## Alternatives
- Keep the macOS build but only on pull requests to `main` and on `main`: roughly doubles the headroom, but still spends the scarce macOS minutes on a check the owner can run locally.
- Keep it on every push: the original decision; blocks all CI late in a busy month.

## Dissent
Nothing in CI now proves the app builds on the target platform, so a build break is found when someone runs `task build`, not on the PR. Accepted because the checks that remain (clippy, tests, type-aware lint) compile the same Rust code, and quota is better spent on them.

## Consequences
Easier: CI stays within the free quota, and every push keeps its fast checks. Harder: release builds are a manual step. Revisit if the quota is no longer a constraint (a paid plan, self-hosted runners), or the first build break slips through.
