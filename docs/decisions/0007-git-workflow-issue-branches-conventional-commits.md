# 0007: Git workflow: issue-linked branches, conventional commits, PR only, human merges

- Status: accepted
- Date: 2026-10-15
- Scope: all repos using the memory kit; this repo first

## Context
Sessions were committing straight to `main`. The owner already uses a working git and GitHub workflow in another repo and asked for this one to follow it, adapted for the pieces that repo does not need. This repo had its own commit prefixes (`kit:`, `app:`, ...), which are not valid conventional commit types.

## Decision
- Work reaches `main` only through a pull request from a branch. Never commit or push to `main`.
- Branches are named `<issue#>-<short-kebab-summary>` (for example `13-do-thing`), short, with no slashes, using the issue the branch completes and never a parent or epic.
- Every commit is a conventional commit, `type(scope): summary`. Scopes are the repo's areas, listed in its root guidance file.
- The PR body carries `Closes #N`. Commits do not.
- Merge with merge commits, not squash. Agents get the PR merge-ready; a human merges.
- Agents run this workflow through the playbook `git-ship-a-change`, and may be given it as a task.

## Alternatives
- Keep this repo's own prefixes (`kit:`, `app:`, ...): shorter, but not conventional commits, so no changelog tooling and a different rule from the owner's other repo.
- Type-prefixed branch names (`feat/do-thing`): readable, but the slash confuses automation and there is no issue link.
- Squash merges: a clean `main` with one commit per PR, but loses the individual commits and makes the fixup discipline pointless.
- Let agents merge when checks pass: faster, but merging is outward-facing, and the repo's rule is that those wait for an explicit go-ahead.

## Dissent
For a one-person repo, issue, branch, PR and human merge are ceremony that slows small changes. Accepted because it keeps one workflow across repos, gives CI and a review trail, and lets agents do the mechanics safely.

## Consequences
Easier: consistent history, automation that can match issues to branches, an agent that can run the whole flow. Harder: every change needs an issue first. The commit prefix line in `AGENTS.md` is replaced by conventional commits with scopes. The repo's merge settings (squash and rebase merges allowed, branches not deleted on merge) do not yet match this and need changing by the owner. Revisit if the issue-per-change overhead outweighs its value.
