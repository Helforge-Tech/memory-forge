# memory-forge

A template for a repeatable way to build things (apps, sites, services, docs, IaC) with AI sessions that reuse earlier decisions. It holds the process, not a product: projects copy it and grow their own memory.

## Repo map

| Path | What | State |
|---|---|---|
| `memory-kit/` | Playbooks, standards, checks, templates. Portable: no project or personal content. Start at `standards/INDEX.md` and `playbooks/INDEX.md` | active; grows from tasks |
| `knowledge/` | Cross-project notes (Obsidian vault); see `knowledge/INDEX.md` | empty skeleton |
| `docs/` | The memory design (`planning/`), decisions (`decisions/`, numbered, superseded never edited), state (handoffs, gaps) and the memory acceptance test (`acceptance/`) | in use |

## Commands

Run inside the nix dev shell (direnv, or `nix develop`). Entering the shell enables the secret-scan hook. The shell carries only what the process needs (`task`, `gh`, `gitleaks`); a project adds its own tools and commands. `task --list` shows them all. Don't invent commands; if one is missing, propose it. Setting a project up is a playbook, not a command.

`task test` tests the kit's check scripts (`memory-kit/checks/test-baseline.sh`). There is no other command yet.

## How a session works

0. **Start from an issue.** Planned work is a GitHub issue in the current milestone. `/pickup` names the next one. One session works one issue; `/handoff` comments on it.
1. **Scope first.** State which areas are in scope and out of scope. Stay inside; ask before crossing.
2. **Check before create.** Before making a new kind of thing (page, API call, config, script), look in `docs/standards/INDEX.md` (this repo's own standards, if it exists), `memory-kit/standards/INDEX.md` and `memory-kit/playbooks/INDEX.md`. A repo standard beats a kit standard only if a decision names the one it overrides ([standard](memory-kit/standards/standards-tiers.md)).
3. **Gaps.** If there is no standard or playbook, stop. Give 2-3 options, a recommendation and the strongest objection. The human decides. Record it in `docs/decisions/` and `docs/state/gaps.md`. To add or change a standard, convention or playbook, use `/standard`.
4. **Review.** After `git-ship` opens or updates a PR, run the `reviewer` agent on it (a subagent cannot start another). Fix blocking findings and re-run before telling the owner the PR is ready.
5. **Close.** Run `/handoff`: it writes a local, untracked note in `docs/state/handoffs/` and edits no tracked file. The note holds only what the session found but did not ship (gap rows, memory candidates); the owner promotes those in a weekly PR. Work shipped in the issue's PR is not held back: it is `active` or `accepted` when merged ([0018](docs/decisions/0018-standards-active-on-merge.md), [0027](docs/decisions/0027-what-a-go-ahead-covers.md)).

## Resuming

New session, or lost? Type `/pickup` to list the open threads and get a recommendation, or `/pickup <issue#>` to resume one thread: its issue, its handoff (`docs/state/handoffs/<issue#>-<topic>.md`), its branch and its PR. It does no work until asked. If a session ended without a handoff, start from `git log`, and make `/handoff` a habit.

## Working with the owner

The owner is whoever owns the repo. A project made from this template names them here, and adds its own preferences (for example which model providers are allowed).

- The owner decides. Give 2-3 options with a recommendation and the strongest objection.
- Guardrails, not bureaucracy. Never ask the owner to fill in, paste or log something you can derive. Only stop for decisions that are theirs. Any new mechanism must be automatic or remove a decision. If it routinely asks for input, it needs a reason, or it goes.
- Do the simple things very well: consistent, standards-following, performant. Don't add structure before a task needs it.
- Verify a mechanism before relying on it, and say what you could not verify.
- **A go-ahead on `/pickup`'s recommended step means finish that issue** ([0027](docs/decisions/0027-what-a-go-ahead-covers.md)): the whole scope, commits, `git-ship`, the reviewer, fixes for blocking findings, pushing the issue's own branch (including `--force-with-lease` after a rebase onto `origin/main`) and opening its PR. Don't add checkpoints, and don't ask about what you can decide; decide and say so. Stop only for the owner's decisions or work outside the issue.
- **Any other "go ahead" or "yes" answers exactly the question asked:** "Should I do X?", "go ahead" means do X, then report back. It never widens the scope. A reply that does not answer the question (a new topic, a new problem) is not a yes; the question is still open.
- Other outward-facing actions (merging, pushing to `main`, creating repos, deleting branches, closing issues or PRs, changing repo settings, anything touching networks or production) wait for their own explicit go-ahead.
- A decision the owner made in conversation is recorded `accepted`. `proposed` is only for choices made while the owner is unavailable (the "When the owner is unavailable" line below).
- When working out how to do something, look at how comparable apps and open source projects do it (research agents too), plus anything the owner points to, and adapt the method in our own words. Never put names, links, paths, accounts, content or code from them in this repo, including what the owner sends you. Copying open source code needs a licence check and the owner's approval first ([0016](docs/decisions/0016-borrowing-from-referenced-repos-and-open-source.md)).
- When the owner is unavailable: reversible things (naming, UI, layout) proceed on a `proposed` standard and are flagged in the handoff's Open section; hard-to-undo things (data formats, external contracts, infrastructure, security) wait ([0013](docs/decisions/0013-provisional-autonomy-rule.md)).

## Rules

- No secrets in files, notes, logs or commit messages. Never read `.env` files.
- Git: follow the `git-*` standards in `memory-kit/standards/` and the `git-ship-a-change` playbook. Branch and PR for every change, never on `main`; branches are `<issue#>-<short-summary>`; a human merges.
- Commits are Conventional Commits, `type(scope): summary`. Scopes: `kit`, `knowledge`, `app`, `ci`, `nix`; omit for repo-wide changes.
- Research agents use a cheap model (Haiku, Sonnet only if needed); heavy models are for guidance. Set the model on every agent you spawn ([standard](memory-kit/standards/agents-model-by-role.md), [0017](docs/decisions/0017-model-by-role.md)).
- Tools that hooks, playbooks or agents need (`gh`, `gitleaks`, ...) are declared in the nix flake. Don't install them ad hoc.
- Links go project -> `knowledge/` only. `memory-kit/` mentions neither.
- Decisions are superseded, never edited in place.

## Where the design lives

`docs/planning/MEMORY-ARCHITECTURE.md`: the memory design (v3): sections, read and write paths, rules. Read it only when a task needs it, not at session start.
