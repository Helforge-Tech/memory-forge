# 0003: Task runner is go-task

- Status: accepted
- Date: 2026-10-15
- Scope: repo root; one `Taskfile.yaml` for setup, dev, build, test, lint and format

## Context
AGENTS.md requires one command each for setup, dev, build, test and lint. A runner is needed that covers both pnpm and cargo. The existing work repo uses go-task.

## Decision
go-task, with a root `Taskfile.yaml`. The commands are listed in AGENTS.md once they exist.

## Alternatives
- just: terser recipes, but a marginal gain and it diverges from the existing stack.
- package.json scripts: no extra tool, but JS-centric, and Rust tasks fit awkwardly.
- mise tasks: one tool for toolchains and tasks, but toolchains are handled by nix (see 0004).

## Dissent
YAML templating gets verbose as a Taskfile grows. Accepted because the skeleton's Taskfile is small, and consistency with the existing stack is worth more than terser syntax.

## Consequences
Easier: the same `task` habits across projects, and `task --list` documents the commands. Harder: long Taskfiles are awkward to read. Revisit if the Taskfile outgrows its usefulness.
