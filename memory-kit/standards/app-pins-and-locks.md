---
title: An app pins its toolchains and commits its lockfiles
kind: app
scope: portable
status: active
updated: 2026-10-15
decision: ../../docs/decisions/0004-toolchains-nix-flake-rust-toolchain-toml.md
check: memory-kit/checks/app-conformance.sh (rules rust-pinned, package-manager-pinned, lockfile-js, lockfile-rust, cargo-edition), run by task lint
---

# An app pins its toolchains and commits its lockfiles

## Rule

1. **Rust is pinned to an exact version** in `rust-toolchain.toml` at the repo root (`channel = "x.y.z"`, never `stable`), and the nix flake reads that file ([0004](../../docs/decisions/0004-toolchains-nix-flake-rust-toolchain-toml.md)).
2. **The package manager is pinned** with the `packageManager` field in `package.json` ([0002](../../docs/decisions/0002-package-manager-pnpm.md)).
3. **Lockfiles are committed**: the JavaScript lockfile and `Cargo.lock`.
4. **The Cargo edition is the current one** (2024 for now; changing it is a decision, [0011](../../docs/decisions/0011-lint-format-test-and-edition.md)).
5. **Node is pinned to a major version in the flake**, not tracked as "latest" ([tooling-declared-in-flake](tooling-declared-in-flake.md)).

## Why

- A fresh session or machine gets the same versions, so a result reproduces.
- A moving toolchain makes a failing check ambiguous: the code or the version?

## Do / Don't

Do: `channel = "1.99.1"`.

Don't: `channel = "stable"`.

## Applied in

Not applied yet in this repo. The first project that applies it lists its paths here.
