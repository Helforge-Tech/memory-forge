# 0006: CI runs on Ubuntu, with a macOS build job

- Status: accepted
- Date: 2026-10-15
- Scope: GitHub Actions for `apps/desktop`

## Context
The plan requires CI on at least one OS. The development and target platform is macOS.

## Decision
- Ubuntu: formatting, linting and tests on every push.
- macOS: a job that builds the app.
Windows is not built for now. Rust comes from rustup using `rust-toolchain.toml` (see 0004).

## Alternatives
- Ubuntu only: cheapest, and meets the minimum.
- macOS only: the target platform, but every run costs macOS minutes.
- Full matrix of macOS, Ubuntu and Windows: more coverage than a skeleton needs.

## Dissent
macOS minutes cost about ten times Linux minutes on private repositories, and a skeleton barely needs them. Ubuntu-only already meets the definition of done.

## Consequences
Easier: catches macOS-only build failures early, on the real target. Harder: higher cost. Revisit if the cost is noticeable, or when Windows becomes a target.
