# 0014: Handoffs are local and untracked; their rows are promoted weekly

- Status: accepted
- Date: 2026-10-15
- Scope: `/handoff`, `/pickup` and `docs/state/`

## Context
`/handoff` wrote a handoff note and edited the tracked learning log and gaps file at the end of every session. Sessions often end on `main`, where commits are blocked ([0007](0007-git-workflow-issue-branches-conventional-commits.md)), so each handoff left `main` dirty until someone made an issue, a branch and a PR for it. Handoffs are also per-person state.

## Decision
- `docs/state/handoffs/` is gitignored, like `docs/state/inbox/`. New handoffs are local and untracked.
- `/handoff` edits no tracked file. The note has a "To promote" section with the exact learning-log row, the gap rows and any proposed memory changes.
- The owner promotes those rows in a weekly PR, through the normal issue, branch and PR flow.
- The earlier handoff `2026-10-15-planning-to-task-1.md` stays tracked, since it is already in history.

## Alternatives
- Keep committing handoffs through a PR each session: history is complete, but every session ends with PR overhead and a dirty `main` in between.
- Commit handoffs straight to a long-lived state branch: avoids `main`, but adds a branch to keep in step.

## Dissent
Local handoffs are lost if the machine is lost, and a fresh clone has none, so `/pickup` has less to read. Mitigation: the session's issue gets a summary comment, and the promoted rows land weekly.

## Consequences
Easier: sessions end clean, and `main` stays clean. Harder: learning-log rows and gap rows lag by up to a week, so `/pickup` reads the latest handoff's "To promote" section as current. Revisit if the weekly promotion is skipped or handoffs go missing.
