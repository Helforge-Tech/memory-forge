# 0035: Changes flow to and from the template by playbook, with one recorded source line

- Status: accepted
- Date: 2026-10-21
- Scope: the `contribute-upstream` and `take-in-upstream` playbooks, the `/handoff` and `/standard` skills

## Context
[#12](https://github.com/Helforge-Tech/memory-forge/issues/12). A project made from the template improves the framework in place, and the template improves too. Both directions must work with no git remote and no automatic sync, and nothing project-specific may leak into the template.

## Decision
- Two playbooks: `contribute-upstream` (project to template) and `take-in-upstream` (template to project).
- The link between the two is `docs/state/kit-source.md`, one tracked line written at install ([install-kit-existing-repo](../../memory-kit/playbooks/install-kit-existing-repo.md)) and moved forward by every take-in. A repo without that file is the template itself; it has no upstream and nothing prompts.
- Contributing is offered, never automatic. `/handoff` and `/standard` ask once per framework-tier change (`memory-kit/`, session skills and agents, hooks, docs structure). Repo-tier standards never prompt. A yes starts the playbook; the PR opens only after the owner has seen the diff.
- Taking in happens on request only. The session walks the template's commits since the recorded one, the owner picks, and the result is a memory-only PR.

## Alternatives
- **Git remote or subtree for the kit.** Automatic, but couples histories and carries project content both ways; rejected by the issue.
- **Copy the whole kit on each update.** Simple, but overwrites local changes without the owner choosing.

## Dissent
Rewriting a change to fit any project is judgement; a grep for project names catches only the obvious leaks. Accepted: the owner sees the full diff before the PR opens, and the reviewer runs on it.

## Consequences
Easier: improvements travel both ways with the owner deciding each one. Harder: a project that never takes in drifts from the template; the recorded commit makes the drift measurable (`git log <commit>..origin/main`). Not verified: a take-in over a rebased or force-pushed template history.
