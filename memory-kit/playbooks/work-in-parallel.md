---
title: Work an issue in parallel in its own worktree
status: active
updated: 2026-10-20
---

# Work an issue in parallel in its own worktree

## When to use

The owner asks for an issue to be worked "in parallel" (or `/pickup <n>` plus "in parallel"), because another session is already working a different issue. Each issue gets its own top-level session and its own worktree, and the owner starts each session. A session does not start, coordinate or merge another session's work. Several agents helping on one branch is ordinary subagent use and out of scope. Two to four sessions at once is where this pays off; beyond that, review and integration become the bottleneck.

## Steps

1. **Fetch.** `git fetch --prune origin`. The worktree branches from `origin/main`, never from the local checkout, which may hold other work in progress.
2. **Create the worktree on a standard branch name.** `git worktree add .claude/worktrees/<issue#>-<short-kebab-summary> -b <issue#>-<short-kebab-summary> origin/main` ([git-branches-and-prs.md](../standards/git-branches-and-prs.md) rule 12). Then move the session into it (the `EnterWorktree` tool with that path, which is inside `.claude/worktrees/`). Do not use `claude --worktree <name>`: it names the branch `worktree-<name>`.
3. **Initialise the environment there.** A worktree is a fresh checkout: enter the dev shell. Never copy, read or create `.envrc.local`, `.env*` or any other local secret or credential file in a worktree; those files are for the owner only. A worktree session works without the owner's local env and secrets. Work that needs them is done by the owner, or in the owner's main (non-parallel) session. If the owner wants a local file in a worktree, the owner copies it. No `.worktreeinclude` entry for such files. Anything that binds a port or uses a local database needs its own instance; there is no standard for that yet (see `docs/state/gaps.md`).
4. **Work as a normal session:** scope, the work, [git-ship-a-change](git-ship-a-change.md), the `reviewer` agent, `/handoff`. The handoff is written in the worktree's own `docs/state/handoffs/`; `/pickup` reads every worktree.
5. **Stay current.** Before shipping, and after any other PR merges, `git fetch origin && git rebase origin/main`, then re-run the checks. Two changes that git merges cleanly can still disagree (one renames, the other still calls the old name).
   - If `AGENTS.md`, an `INDEX.md` or `gaps.md` conflicts because both branches added rows: keep both sides' rows, in index order, then re-run the checks. Do not use git's `union` merge driver; it can duplicate or scramble lines.
   - Push the rebased branch with `--force-with-lease`, only on this issue's own branch; the go-ahead on the issue covers it ([0027](../../docs/decisions/0027-what-a-go-ahead-covers.md)). Never bare `--force`, and never on a branch the session did not create.
6. **After the PR is merged,** `/pickup` cleans up, run in the main checkout (a worktree session cannot write there): it copies the worktree's handoffs into the main checkout's `docs/state/handoffs/` with `find ... -exec cp -n` (never overwriting; on a name clash it keeps both and says so), removes the worktree with `git worktree remove` only if it has no uncommitted or untracked files (otherwise it leaves it and says why), and reports one line per worktree. Deleting the merged branch waits for the owner's go-ahead. If a handoff was not copied, the issue comment `/handoff` posted still holds the summary ([0026](../../docs/decisions/0026-handoffs-across-worktrees.md)).

## Standards used

- [git-branches-and-prs.md](../standards/git-branches-and-prs.md)
- [git-issues.md](../standards/git-issues.md)

## Done when

- The work was done in `.claude/worktrees/<issue#>-<short-kebab-summary>` on a branch cut from a freshly fetched `origin/main`.
- The branch was rebased and its checks re-run after any other PR merged.
- The PR was shipped and reviewed as in git-ship-a-change.
- After the merge, `/pickup` copied the handoffs to the main checkout and removed the worktree.
- No session copied an env or secret file into the worktree.

## Reference output

No example yet. The first run with two sessions at once should be added here.
