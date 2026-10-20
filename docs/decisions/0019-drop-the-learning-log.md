# 0019: Drop the learning log

- Status: accepted
- Date: 2026-10-15
- Scope: `docs/learning-log.md`, `/handoff`, `/pickup`

## Context
The learning log was meant to record, per session, the context and cost at the end, where the owner stepped in, and what memory was missing. Filling it in meant pasting a status line by hand and rewording each handoff into a table row. That chore left the log empty after a day of sessions, and `/pickup` spent steps tracking which handoffs were not yet promoted into it.

## Decision
- Delete `docs/learning-log.md` and its baseline section.
- `/handoff` no longer writes a learning-log row. Gap rows and proposed memory changes stay in "To promote".
- `/pickup` no longer reads the log or lists unpromoted handoffs.
- If cost or context numbers are wanted later, compute them from the session transcripts rather than by hand.

This supersedes the learning-log parts of [0014](0014-handoffs-are-local-and-promoted-weekly.md) (the row in "To promote") and [0015](0015-handoffs-and-pickup-keyed-by-issue.md) (unpromoted handoffs are those modified since the last log commit). The rest of both stands.

## Alternatives
- Keep the log but record it automatically from transcripts now: the right long-term form, but it is a task of its own and not needed yet.
- Keep the log and fill it in less often: still a chore, and the data would be patchy.

## Dissent
"Where I stepped in" and "what I had to re-explain" are judgements that transcripts do not hold directly, so this signal about missing memory is lost until something replaces it. Mitigation: the handoff's Gaps found section still captures missing standards.

## Consequences
Easier: shorter handoffs and a simpler `/pickup`. Harder: no cost baseline until the transcript tooling exists. Planning notes (`PLAN.md`, `MEMORY-ARCHITECTURE.md`) still mention the log as history; they are not rewritten here.
