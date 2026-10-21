---
title: An app has size budgets that CI or the build command check
kind: app
scope: portable
status: active
updated: 2026-10-21
decision: none
check: task budget (size-budget.sh); task budget:web in CI; release-profile rule in app-conformance.sh
---

# An app has size budgets that CI or the build command check

## Rule

1. **Every shipped artifact has a size budget in bytes,** recorded in the build config next to the command that checks it (not in prose): at least the frontend bundle (if the app has one) and the release binary or package.
2. **Budgets are set from measurement,** about 20% above what the app measured when they were introduced, so growth shows up before it is large and normal changes do not trip it.
3. **A budget is only raised in a PR that says why.** A budget is a ceiling, so the direction that needs a reason is up.
4. **Anything cheap to build is checked in CI.** An artifact CI does not build is checked by a local command that builds it (`task budget`); the budget file and the command are the same either way.
5. **The release profile keeps the size and speed settings** the generator ships (for Rust: LTO, one codegen unit, `panic = "abort"`, `strip = true`; the conformance check enforces them for Rust apps).
6. **Start-up time and idle memory are not budgeted yet.** They need a running window to measure, and a skeleton app has nothing to measure. Add them when a feature makes them matter, as a measured budget like the others.

## Why

- Size creeps in a dependency at a time. A ceiling makes each addition visible.
- A budget set from a measurement is believable; one guessed in advance is argued over.
- These are production apps, so the cost of bloat is real ([app-no-bloat](app-no-bloat.md)).

## Do / Don't

Do: `BUDGET_WEB_BYTES` in the Taskfile, checked by `size-budget.sh` after the web build.

Don't: raise a budget in the same PR that adds the dependency that broke it, without saying so.

## Applied in

Not applied yet in this repo. The first project that applies it lists its paths here.
