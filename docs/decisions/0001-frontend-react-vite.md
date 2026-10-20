# 0001: Frontend is React 19 + TypeScript + Vite

- Status: accepted
- Date: 2026-10-15
- Scope: `apps/desktop`

## Context
Task 1 needs a frontend framework for the Tauri app. No standard exists. The stack follows a common React, TypeScript and Vite setup; the aim is to deviate only where there is a clear improvement.

## Decision
React 19 + TypeScript + Vite, as a single-page app (no meta-framework). No Tailwind or component library until there is real UI that needs one.

## Alternatives
- Svelte 5 + Vite: smaller runtime and bundle, but models drift to Svelte 4 syntax, and it is a less common stack.
- Vanilla TypeScript + Vite: smallest, but will not scale to the planned UI (auth, notes, A/B comparison).
- React 19 + Tailwind + shadcn from day one: a fuller UI kit, but adds dependencies the skeleton does not use.

## Dissent
React has a larger runtime than Svelte or Solid, which counts against the planned bundle-size and cold-start budgets. Accepted because model fluency and familiarity outweigh the size cost for now.

## Consequences
Easier: reliable model output, a large ecosystem, familiarity. Harder: staying inside bundle budgets. Revisit if the budgets are missed by the framework itself rather than by app code.
