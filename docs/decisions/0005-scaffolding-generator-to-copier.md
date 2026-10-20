# 0005: Scaffold with a pinned generator, then extract a Copier template

- Status: superseded by 0020
- Date: 2026-10-15
- Scope: `apps/desktop`, and a Copier template in `memory-kit/`

## Context
The plan calls for deterministic scaffolding rather than freehand generation, so that every new app comes out consistent.

## Decision
1. Generate the app once with a pinned `create-tauri-app` (react-ts template).
2. Apply our standards to the result.
3. Extract a Copier template into `memory-kit/`, with no project or personal content.
4. Regenerate `apps/desktop` from the template, to prove it reproduces the app.

## Alternatives
- Generator plus a written playbook only: simplest, but not updatable, and upstream template changes cause drift between runs.
- Copier template written by hand from the start: skips the official generator, so upstream layout knowledge is lost.

## Dissent
A template with exactly one consumer is speculative and strains the memory-kit rule "everything is added by a real task, never in advance". It also adds a Python tool (Copier). Accepted because the regeneration step is the consistency test the plan asks for.

## Consequences
Easier: repeatable new apps, and template updates can be applied to existing apps. Harder: the template must be kept in step with the app. Revisit if the template is never reused by a second app.
