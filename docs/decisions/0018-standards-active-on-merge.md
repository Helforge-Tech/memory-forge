# 0018: Anything in memory-kit becomes active when its PR is merged

- Status: accepted
- Date: 2026-10-15
- Scope: how anything in `memory-kit/` (standards, playbooks, checks, templates) and `docs/standards/` is approved

## Context
`/standard` wrote every new standard or playbook as `status: proposed`; the same applies to any other piece of the kit. The owner then had to review it, edit the status to `active` and commit, so the review and the flip were two steps. The owner's merge of the PR is already the approval, so the flip repeated it, and the index and the file could disagree (the index row for [0017](0017-model-by-role.md)'s standard still said `proposed` after the file was flipped).

## Decision
- Every item added to or changed in `memory-kit/` is written, with its index row, as `status: active` (where it has a status). The PR is the proposal. Agents use the memory in their own checkout, so while a branch is open, sessions on it follow the new or changed item. That lets the owner test it on real work before merging. Merging makes it part of `main`, so every other checkout gets it.
- Nothing is added to `main` without the owner's merge, which keeps "nothing becomes active memory without that commit" ([MEMORY-ARCHITECTURE](../planning/MEMORY-ARCHITECTURE.md) section 4.2).
- `proposed` is kept for one case: a provisional standard that a session created while the owner was unavailable ([0013](0013-provisional-autonomy-rule.md)). Those are marked `proposed` and flagged in the handoff, and the owner confirms them in a PR that sets them `active`.
- Changing an active standard still supersedes the old decision, as in section 4.3 of the architecture.

## Alternatives
- **Keep `proposed` in the PR and flip it by hand after merge.** The current way. Two steps for one approval.
- **Keep `proposed` and flip it automatically on merge (CI job).** Keeps the file honest before merge, but adds automation and a write to `main` for a one-word change.
- **Drop the status field and treat anything on `main` as active.** Simplest, but loses `proposed` for 0013 and `superseded` for changes.

## Dissent
A branch that says `active` before it is approved can leak into work done from that branch, and merging can become a rubber stamp. Accepted: sessions on the branch are meant to use it, and it never reaches other checkouts without the owner's merge. The PR description lists each kit item it activates so the merge is a deliberate act.

## Consequences
- One fewer step per kit item. The `/standard` skill and the INDEX rows change; existing files are unaffected.
- A worktree or checkout of another branch does not see the draft, so a parallel agent must be started from the branch if it should follow it.
- Revisit if reviews of kit items get shallower, or if a draft from an unmerged branch ends up relied on elsewhere.
