# 0027: A go-ahead on an issue covers the whole issue, up to an open PR

- Status: accepted
- Date: 2026-10-20
- Scope: when a session stops for the owner; what "outward-facing actions wait for a go-ahead" covers; the status of work shipped in a PR; rule 9 of `git-branches-and-prs`

## Context
Sessions stopped far more often than the owner wanted. They added checkpoints of their own, asked about choices they could make, wrote decisions and playbooks the owner had already decided as `proposed` and asked the owner to promote them, and asked again before every push and every force push after a rebase. Two texts caused most of it. `AGENTS.md` said of handoff notes that "nothing becomes `active` otherwise", and `/handoff` said "never mark anything `active`"; read without context, both contradict [0018](0018-standards-active-on-merge.md), under which anything added in a PR is written `active` and the merge is the approval. And nothing said what a go-ahead covers, so every push counted as a new outward action. Parallel sessions ([#20](https://github.com/Helforge-Tech/memory-forge/issues/20)) rebase after every merge, which would make the force-push question routine.

## Decision
- **A go-ahead on an issue means: finish it.** Do the whole scope, commit, ship with `git-ship`, run the reviewer, fix blocking findings, push the issue's own branch and open its PR. Do not add checkpoints. Decide what can be decided (commit granularity, wording, file layout) and say what was decided.
- **What it covers outward:** pushing the issue's own branch, including `--force-with-lease` after a rebase onto `origin/main`, and opening or updating its PR. **What it never covers:** merging, pushing to `main`, deleting branches, closing issues or PRs, changing repo settings, or any other outward action. Those keep their own go-ahead.
- **Stop only** for a decision that is the owner's (the gap protocol), for work outside the issue's scope, or for a hard-to-undo step that this list does not cover.
- **Status of shipped work follows 0018:** a standard, playbook or check added in the PR is `active`; a decision the owner made in conversation is `accepted`. `proposed` is only for a choice a session makes while the owner is unavailable ([0013](0013-provisional-autonomy-rule.md)).
- **Handoff notes are separate.** The weekly promotion applies only to what a session found but did not ship (memory candidates and gap rows in its local handoff), not to work in its PR.
- **`/pickup`'s suggested prompt** covers the whole next step and contains no stop points unless an owner decision blocks it.

## Alternatives
- **Keep asking before every push.** Safest, but the push of an issue branch is reversible and the owner merges every PR anyway, so the question protects nothing.
- **Allow merging too.** Fewer steps, but removes the owner's one review point.
- **Leave the wording and correct sessions as they go.** Each new session repeats the same misreading.

## Dissent
A session with a broad go-ahead can push more than the owner expected to see. Accepted: everything stays on the issue's branch and in its PR, which the owner reviews and merges, and a force push uses `--force-with-lease` on the session's own branch only.

## Consequences
Easier: one go-ahead per issue. Harder: sessions must judge what is "outside the issue's scope"; when unsure, they ask. Rule 9 of `git-branches-and-prs` changes to match.
