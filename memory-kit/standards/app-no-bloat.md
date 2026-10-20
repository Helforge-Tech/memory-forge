---
title: An app ships no unused code, dependencies, permissions or template leftovers
kind: app
scope: portable
status: active
updated: 2026-10-15
decision: none
check: reviewer (automatic checks suggested below, not added yet)
---

# An app ships no unused code, dependencies, permissions or template leftovers

## Rule

1. **No unused dependencies.** Every package and crate in the manifests is imported or called by the app. Remove one when its last use goes.
2. **No unused plugins or permissions.** A plugin the app does not call is removed together with its initialisation and its capability entries. Capabilities grant only what the app uses.
3. **No template leftovers.** After scaffolding, delete the generator's demo code, demo commands, sample styles, images, placeholder titles and favicon links, and anything else the first feature does not need.
4. **No dead code or commented-out code** in committed files.
5. **Production profile settings from the generator stay** (release optimisation, stripping); do not remove them to save a build minute.

## Why

- These are production apps, not proofs of concept. Every unused dependency adds download size, attack surface and upgrade work, and every unused permission widens what a compromised web view can do.
- A clean first commit gives the next session nothing to wonder about.

## Do / Don't

Do: remove an unused plugin from the Rust dependency list, its builder call, the JavaScript package and the capability entry together.

Don't: leave a plugin "in case we need it later".

## Suggested checks (not added yet)

- An unused-dependency scanner for JavaScript and one for Rust, run in `task lint`, with a baseline for existing apps ([app-bring-to-standard](../playbooks/app-bring-to-standard.md)).
- A script that compares the capability file's permissions with the plugins in use.

## Applied in

Not applied yet in this repo. The first project that applies it lists its paths here.
