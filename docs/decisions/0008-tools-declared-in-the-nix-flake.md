# 0008: Every tool a repo needs is declared in its nix flake

- Status: accepted
- Date: 2026-10-15
- Scope: all repos using the memory kit; this repo first

## Context
Decision [0004](0004-toolchains-nix-flake-rust-toolchain-toml.md) puts the language toolchains in a nix flake. Other tools (`gh`, `gitleaks`, the task runner) are needed by hooks, playbooks and agents, and today come from whatever is installed on the machine. This repo has no `flake.nix` yet.

## Decision
Any CLI that scripts, hooks, the task runner, CI, playbooks or agent skills invoke is declared in the dev shell of the repo's `flake.nix`, including `gh` and `gitleaks`. A missing tool is fixed by adding it to the flake, not by installing it ad hoc. Credentials such as `gh` auth are never in the flake or repo.

## Alternatives
- Install tools by hand with Homebrew: simple, but unreproducible, and an agent can silently depend on a tool that exists on one machine.
- Only the language toolchains in the flake (the scope of 0004): leaves the workflow tools unpinned.

## Dissent
Nix has a learning curve, flake evaluation adds time, and some tools or macOS-specific bits are awkward to package. Accepted because the owner already uses nix, and reproducibility matters most for agent sessions that cannot ask what is installed.

## Consequences
Easier: identical tools for every session, and a reviewable list of what workflows need. Harder: adding a tool is a flake change. This repo needs a `flake.nix` containing at least `gh` and `gitleaks`; the pre-commit hook's install hint still points to Homebrew and should change when the flake exists.
