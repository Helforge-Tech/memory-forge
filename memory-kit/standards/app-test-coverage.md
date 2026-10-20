---
title: Every app enforces test coverage thresholds that only go up
kind: app
scope: portable
status: active
updated: 2026-10-15
decision: none
check: task coverage (run by CI); reviewer for lowered thresholds
---

# Every app enforces test coverage thresholds that only go up

## Rule

1. **Every test layer is measured with coverage** and gated by a threshold: the native layer and the UI layer separately, with the tools each stack uses.
2. **Thresholds are set from measurement when coverage is introduced,** never guessed, and are recorded in the config the tool reads (not in prose).
3. **A threshold is never lowered.** It rises as tests are added. Lowering one needs a decision that says why.
4. **Entry points that only launch or mount the app are excluded by path,** and the exclusion is commented where it is configured. Nothing else is excluded to improve a number.
5. **New feature code arrives with tests.** The threshold is the floor; reviewers hold the line above it.
6. **CI runs the coverage command on every pull request and every push to `main`** ([app-commands](app-commands.md), [ci-pr-gate](ci-pr-gate.md)).

## Why

- A gate added at the start costs nothing; added later it needs a migration and an argument about the number.
- Thresholds that only go up turn "test what you add" from advice into a check.
- A low native number is honest about code that cannot be unit tested, such as the function that starts the app. That is a fact to keep visible, not hide.

## Do / Don't

Do: set the threshold to the measured value, then raise it in the same PR that adds tests.

Don't: exclude a file to make the number pass, or lower a threshold to merge.

## Applied in

Not applied yet in this repo. The first project that applies it lists its paths here.
