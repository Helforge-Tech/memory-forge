# Memory acceptance test

A fresh session, given only the repo and `AGENTS.md` as its starting point, answers these questions correctly while reading little beyond `AGENTS.md`. The key is here and not given to the session under test; a run copies the repo without this folder.

How a run is scored: each answer is **correct** (matches the key), **partial** (right idea, missing a part the key lists as required), or **wrong / not found**. Record the number of files the session opened beyond `AGENTS.md`; a high count is a sign the map is weak even when the answer is right. A miss is fixed in memory (a standard, playbook, decision, or `AGENTS.md`), then the run is repeated.

Questions are about this repo's current state. When the state changes, update the key in the same PR. A project made from this template keeps these questions and adds its own (how to run the tests, where a key piece of code lives, why a stack choice was made).

| # | Question | Key (required parts in bold) |
|---|---|---|
| 1 | I need a new kind of thing, say a settings page. What do I check first, and what if nothing covers it? | **Look in `memory-kit/standards/INDEX.md` and `memory-kit/playbooks/INDEX.md`**; if there is none, **stop** and give 2 to 3 options, a recommendation and the strongest objection; the human decides; record it (decision and gap). |
| 2 | How do I ship a change? | Work from an **issue**; branch `<issue#>-<summary>`; **never commit on `main`**; Conventional Commits; open a **PR** with `Closes #n`; a **human merges**. Playbook `git-ship-a-change`. |
| 3 | Which model should a research subagent use? | A **cheap model (Haiku; Sonnet only if needed)**; heavy models are for guidance; always set the model on spawn (standard `agents-model-by-role`, decision 0017). |
| 4 | How do I set up a brand-new desktop app? | Follow the **`desktop-app-setup` playbook**; there is **no setup command** and no template (decision 0020). |
| 5 | `jq` is missing in the dev shell. What do I do? | **Add it to `flake.nix`**; do not install it ad hoc (`brew`, `npm -g`...) (standard `tooling-declared-in-flake`). |
| 6 | Where do session handoffs go, and are they committed? | **`docs/state/handoffs/<issue#>-<topic>.md`**, **local and untracked**; written by `/handoff` (decisions 0014, 0015). |
| 7 | What is in the repo, and what state is each part in? | `AGENTS.md`'s repo map should match reality: `memory-kit/` has standards and playbooks, `knowledge/` is an empty skeleton, `docs/` holds decisions, state and the memory design. |

## Run log

| Date | Session | Correct | Partial | Wrong / not found | Files beyond `AGENTS.md` | Misses fixed |
|---|---|---|---|---|---|---|

No target is set for the file count yet; set one after a few runs, and watch for it rising as the memory grows.
