---
title: An app's version is defined in one place
kind: app
scope: portable
status: active
updated: 2026-10-15
decision: none
check: memory-kit/checks/app-conformance.sh (rule version-single-source), run by task lint
---

# An app's version is defined in one place

## Rule

1. **The version of a Tauri app is the `version` in `Cargo.toml`.** `tauri.conf.json` has no `version`; Tauri then uses Cargo's value.
2. **Everything that shows the version reads it from the native side** (a command that returns `CARGO_PKG_VERSION`), never from a second copy in the UI.
3. **A private `package.json` version is not a source** and is not displayed. Do not keep it in step by hand.

## Why

- Two copies drift, and the UI then shows a version the build did not ship.
- Reading it over IPC also exercises the UI to native bridge from the first slice.

## Do / Don't

Do: `env!("CARGO_PKG_VERSION")` in the command.

Don't: a `version` key in `tauri.conf.json` that must match `Cargo.toml`.

## Applied in

Not applied yet in this repo. The first project that applies it lists its paths here.
