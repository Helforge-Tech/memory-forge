# 0026: Handoffs stay in the repo and are read across worktrees

- Status: accepted
- Date: 2026-10-20
- Scope: `/handoff`, `/pickup` and `docs/state/handoffs/` when work runs in several worktrees

## Context
Parallel work is one session per issue, each in its own git worktree ([#20](https://github.com/Helforge-Tech/memory-forge/issues/20)). Handoffs are local and untracked ([0014](0014-handoffs-are-local-and-promoted-weekly.md)) and keyed by issue number ([0015](0015-handoffs-and-pickup-keyed-by-issue.md)). A handoff written in one worktree is invisible to `/pickup` in another checkout, and is deleted with a temporary worktree. An isolated worktree session cannot edit files in the main checkout, so it cannot write its handoff there.

## Decision
This refines 0015 for worktrees; it does not supersede it.
- **Writing is unchanged.** A session writes its handoff to its own checkout's `docs/state/handoffs/`, including when that checkout is a worktree.
- **`/pickup` reads every worktree.** It lists the repo's worktrees (`git worktree list --porcelain`) and reads `<path>/docs/state/handoffs/` for each, plus its own. Newest-first and the verify rules are as today.
- **Cleanup copies first.** Before a worktree is removed, its handoffs are copied into the main checkout's `docs/state/handoffs/`, run from the main checkout. This is a step of the cleanup, not something to remember. If it is skipped, the issue comment that `/handoff` posts still holds the summary.
- Nothing is written outside the repo or into `.git`.

## Alternatives
- A folder outside the repo, keyed by repo: one place for every checkout, but a template used by a team would create files in other people's home directories.
- The shared git directory: one place for every worktree, but it hides notes inside `.git` and is easy to lose on a re-clone.
- The issue comment as the source of truth, with the local file as a cache: survives everything, but `/pickup` then depends on the network and every note is public to the repo's readers.

## Dissent
`/pickup` reads files from other worktrees, so a handoff is stale or unseen if its worktree was deleted without the copy step. Mitigation: the copy is part of cleanup, and the issue comment holds the summary.

## Consequences
Easier: `/pickup` from any checkout sees all parallel threads; no new location to learn. Harder: `/pickup` and the cleanup step each gain a worktree-aware step, and a worktree removed by hand loses its notes. Revisit if hand-removed worktrees lose notes in practice.
