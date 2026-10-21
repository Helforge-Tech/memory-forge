---
title: Every app has format, lint and test gates from day one
kind: app
scope: portable
status: active
updated: 2026-10-21
decision: ../../docs/decisions/0011-lint-format-test-and-edition.md
check: task lint and task test (run by CI); reviewer for test coverage per layer
---

# Every app has format, lint and test gates from day one

## Rule

1. **Formatting, linting and type checking are enforced by tools, not by review.** Every language in the app has a formatter and a linter, and a typed language is type-checked (for TypeScript, `tsc --noEmit`). Lint warnings are errors (for Rust, `clippy -D warnings`).
2. **One test per layer exists before any feature does.** Every layer the app has gets a test, and a boundary between layers gets a smoke test. For a Tauri desktop app: a unit test in the native layer, a UI test, and an IPC smoke test. The smoke test has two parts: the native test calls the command directly, and the UI test renders with the IPC API mocked. Another stack lists its layers in the repo's own standard.
3. **The gates run with one command each** (`lint`, `test`, `coverage`) so an agent and CI run the same thing ([app-commands](app-commands.md)).
4. **Generated files are formatted by the tool once, then left alone.** If a generated file breaks a lint rule the tool cannot fix, exclude it by path; do not rewrite its code to silence the rule.
5. **A gate is never loosened to make a change pass.** If a rule is wrong, change it through a decision.
6. **The rule is the layers, not the tools.** Today's choices for the Tauri stack ([0011](../../docs/decisions/0011-lint-format-test-and-edition.md)): Biome, `rustfmt`, `clippy`, Vitest with jsdom and Testing Library, the Rust test harness. A better option replaces one through a new decision and a pass over the apps that use it; the standard's layers do not change.

## Why

- A change the agent makes is judged by the same bar every time, without a human re-checking style.
- A mocked UI test is cheap but proves nothing about the real boundary between layers (for Tauri, the IPC bridge); the native half of the smoke test and, later, an end-to-end test cover that.

## Do / Don't

Do: `cargo clippy --all-targets -- -D warnings` (Rust).

Don't: add `#[allow(...)]` or lower a lint level to get a PR green.

## Applied in

Not applied yet in this repo. The first project that applies it lists its paths here.
