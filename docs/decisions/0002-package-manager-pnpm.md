# 0002: Package manager is pnpm

- Status: accepted
- Date: 2026-10-15
- Scope: all JavaScript/TypeScript in this repo, starting with `apps/desktop`

## Context
A package manager must be chosen and pinned. With npm's hoisted `node_modules`, undeclared imports pass local typechecks and only fail later in isolated builds, which takes a custom check script to catch.

## Decision
pnpm, pinned through the `packageManager` field in `package.json`. The lockfile is committed.

## Alternatives
- npm: already installed everywhere, but hoisting hides undeclared dependencies.
- bun: fastest, but adds a second JavaScript runtime with compatibility rough edges.

## Dissent
It differs from npm, so commands and habits do not carry over one-to-one. It is also one more tool to install and pin, and Node 25+ no longer ships corepack, so pnpm must come from the toolchain (see 0004).

## Consequences
Easier: strict dependency resolution removes the need for an undeclared-import check, and installs are faster. Harder: one extra tool in the toolchain. Revisit if pnpm causes friction with Tauri tooling.
