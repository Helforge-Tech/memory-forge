---
title: An app's version is defined in one place
kind: app
scope: portable
status: active
updated: 2026-10-21
decision: none
check: memory-kit/checks/app-conformance.sh (rule version-single-source), run by task lint
---

# An app's version is defined in one place

## Rule

1. **An app's version has one source,** a single file or field, and every other place that needs it reads it from there or is generated from it.
2. **Anything that shows the version reads it from that source,** never from a second copy.

For a Tauri app (the stack of [desktop-app-setup](../playbooks/desktop-app-setup.md)):

3. **The source is the `version` in `Cargo.toml`.** `tauri.conf.json` has no `version`; Tauri then uses Cargo's value.
4. **The UI reads it from the native side** (a command that returns `CARGO_PKG_VERSION`), never from a second copy in the UI.
5. **A private `package.json` version is not a source** and is not displayed. Do not keep it in step by hand.

## Why

- Two copies drift, and the UI then shows a version the build did not ship.
- Reading it over IPC also exercises the UI to native bridge from the first slice.

## Do / Don't

Do: `env!("CARGO_PKG_VERSION")` in the command (Tauri).

Don't: a second `version` key that must be kept equal to the first, for example in `tauri.conf.json` next to `Cargo.toml`.

## Applied in

Not applied yet in this repo. The first project that applies it lists its paths here.
