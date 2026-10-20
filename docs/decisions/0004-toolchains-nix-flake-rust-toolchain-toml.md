# 0004: Toolchains pinned with a nix flake and rust-toolchain.toml

- Status: accepted
- Date: 2026-10-15
- Scope: repo root and `apps/desktop`

## Context
The plan requires pinned Rust, Node and package manager. Rust is not installed on this machine yet. The existing work repo uses a nix flake with direnv, but tracks the latest stable Rust, so the version is not pinned.

## Decision
A nix flake plus direnv provides the dev shell (Node, pnpm, go-task, Rust, gitleaks). Rust is pinned in `rust-toolchain.toml`, and the flake reads that file (`rust-bin.fromRustupToolchainFile`) so there is one source of truth. Node is pinned to a major version. pnpm is pinned via `packageManager`.

## Alternatives
- Nix flake that tracks the latest stable Rust, as in the existing app: simplest, but not reproducible.
- mise + rustup: no nix, simpler for other contributors, but diverges from the existing stack and the tooling already in use here.

## Dissent
Nix is slow in CI without a binary cache. Mitigation: CI installs Rust with rustup from the same `rust-toolchain.toml` rather than entering the flake shell (see 0006).

## Consequences
Easier: reproducible local setup, and CI and local share the Rust version. Harder: nix knowledge is required, and two install paths (nix locally, rustup in CI) must be kept consistent. Revisit if they drift.
