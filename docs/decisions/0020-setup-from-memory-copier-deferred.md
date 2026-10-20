# 0020: Setup is done by the agent from memory; a Copier template is deferred

- Status: accepted
- Date: 2026-10-15
- Scope: how a new project of any kind (desktop, web, service, docs, IaC) is set up; `memory-kit/`; the root `Taskfile.yaml`

## Context
The plan asked for "one command each for setup, dev, build, test, lint and format", and [0005](0005-scaffolding-generator-to-copier.md) chose to extract a Copier template from the first app and regenerate the app from it. Following the first literally produced a `task setup` in the root Taskfile that ran `pnpm install`, `cargo fetch` and a git config. The owner pointed out the misread: the memory system exists so that an agent session can set up anything from memory, with good standards. A setup command in one project only fits that project's stack and says nothing about a service or IaC. A Copier template per stack has the same shape one level up: the agent's job shrinks to running a script we also have to maintain, and the knowledge of how to set up lives in the template rather than in the playbook and standards.

The owner's framing on accepting: tooling around code quality, standards and testing guardrails for agents doing the work matters far more than a tool that produces boilerplate. We are building processes, not boilerplates.

Meanwhile the memory design already describes the memory-driven path: write playbook v1, re-run it in a fresh session, diff, fix the playbook or a standard, repeat until identical.

## Decision
- Setting up a project is a **playbook the agent follows**, never a command in the project. The playbook names the decisions already made, pins and runs an upstream generator where one exists (for Tauri, `create-tauri-app` at a recorded version), applies our standards, and runs the checks.
- A project's own commands (`task dev`, `task build`, `task test`, `task lint`, `task fmt`) are part of the **output** the standards require. `task setup` is removed. Things it did become automatic: tasks install their dependencies when missing, and entering the nix dev shell enables the git hooks.
- Repeatability is **proven by the consistency test**, not by a template we own. Every difference between fresh-session runs is fixed in the playbook or a standard.
- The **Copier template is deferred**. It becomes the fallback if, after the playbook has been fixed, fresh-session runs still differ in ways the playbook cannot pin down.
- This supersedes [0005](0005-scaffolding-generator-to-copier.md). Steps 1 and 2 of 0005 (generate once with a pinned generator, apply our standards) stand; steps 3 and 4 (extract Copier, regenerate) are deferred.

## Alternatives
- Keep 0005 and build the Copier template now: deterministic by construction, and templates can update existing apps. Not chosen because it moves setup knowledge out of memory into a per-stack script, and the kit would need one template per kind of output before any was proven necessary.
- Keep `task setup` but make it generic per project type: still a command inside the output, and still one implementation per stack.

## Dissent
The plan's own argument against freehand generation stands: boilerplate written from a prose playbook can drift between runs in ways a template never would. If the diff test keeps finding differences, the fix is a template, and this decision has only delayed it. Accepted because the diff test gives a measurable trigger rather than an assumption.

## Consequences
Easier: one approach for every kind of output, and the kit stays prose plus checks, which anyone can read. The playbook is the artefact that improves. Harder: the first re-run will likely show drift, and fixing it in prose takes iterations. Revisit when the re-run has happened twice: if the second run still differs, revive 0005's Copier step.
