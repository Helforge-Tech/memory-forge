# 0015: Handoffs and /pickup are keyed by issue number

- Status: accepted
- Date: 2026-10-15
- Scope: `/handoff`, `/pickup` and `docs/state/handoffs/`

## Context
`/pickup` read only the newest handoff and recommended the earliest open issue. Handoffs were named by date and topic, so notes written on the same day tied, and an older thread of work could not be resumed. Several threads, or several agents working at different times, are expected ([0009](0009-backlog-in-github-issues-milestones-project.md): one session works one issue). Handoffs are local and untracked ([0014](0014-handoffs-are-local-and-promoted-weekly.md)).

## Decision
- A handoff is named `docs/state/handoffs/<issue#>-<short-topic>.md` and starts with a header: issue, branch, PR, date.
- `/handoff` writes one note per issue worked, creating the issue first if there is none.
- `/pickup <issue#>` reads that issue, its newest handoff, its branch and its PR, and recommends the next step for that thread.
- `/pickup` with no argument lists the open threads, one line each, shows the unpromoted handoff rows, recommends the earliest open issue in the current milestone, and asks which to resume.
- Unpromoted handoffs are those modified since the last commit to `docs/learning-log.md`.
- Older, pre-issue handoffs keep their date names.

## Alternatives
- Name handoffs by topic and let `/pickup` match words: no issue is needed, but fuzzy matching will sometimes pick the wrong note.
- Keep only the newest handoff, with an index file listing threads: simple to read, but one more file to keep in step, and concurrent agents would edit it at the same time.

## Dissent
Every thread needs an issue. That is already the rule ([git-issues](../../memory-kit/standards/git-issues.md)), but it breaks for throwaway experiments, which now need an issue or no handoff.

## Consequences
Easier: resuming any thread by number, and an overview of what is open. Harder: the note's header must be kept accurate for the no-argument list to be useful. Revisit if issues become too heavy for small threads. Concurrent agents in one checkout still need separate git worktrees; that is not decided here.
