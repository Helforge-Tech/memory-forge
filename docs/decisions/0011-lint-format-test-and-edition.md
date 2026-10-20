# 0011: Lint, format, test runner, Cargo edition and the IPC smoke test

- Status: accepted
- Date: 2026-10-15
- Scope: `apps/desktop`

## Context
Task 1a needs formatters, linters, a frontend test runner and an IPC test, and the Cargo edition. They were the remaining open stack gaps and would have interrupted scaffolding. They are decided here in one batch. React and Vite are decided in [0001](0001-frontend-react-vite.md).

## Decision
- **TypeScript lint and format:** Biome.
- **Rust:** `rustfmt` and `clippy` with warnings denied (`-D warnings`).
- **Frontend tests:** Vitest.
- **Cargo edition:** 2024.
- **IPC smoke test:** two parts. A Rust test calls the version command directly. A Vitest test runs the UI with the Tauri API mocked and checks it renders the version.

## Alternatives
- TypeScript: ESLint + Prettier is the most common setup, with more rules and plugins, but two tools and more config. Not chosen.
- Frontend tests: Jest is established but needs more setup with Vite. Not chosen.
- Cargo edition: 2021 is what an existing app uses, and is the safe choice. Not chosen because a new app can start on the current edition.
- IPC smoke test: a full end-to-end test driving the real app (WebDriver) proves more but is slow and platform-fiddly. Left for later.

## Dissent
Deciding before feeling the pain contradicts "structure grows from tasks". Accepted because these choices block scaffolding, and each is cheap to reverse early.

## Consequences
Easier: one tool for TypeScript lint and format, tests that run fast in CI on Ubuntu. Harder: the mocked IPC test does not prove the real bridge works, so a real end-to-end test stays a candidate for Task 1b. Revisit Biome if a needed lint rule is missing.
