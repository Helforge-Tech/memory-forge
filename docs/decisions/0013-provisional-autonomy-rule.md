# 0013: Provisional autonomy when the owner is unavailable

- Status: accepted (2026-10-15, on the condition that every provisional choice is flagged)
- Date: 2026-10-15
- Scope: all sessions in this repo

## Context
The gap protocol stops a session when there is no standard or playbook. When the owner is unavailable, sessions need to know what may proceed. [MEMORY-ARCHITECTURE.md](../planning/MEMORY-ARCHITECTURE.md) §3 and §9 leave this to confirm.

## Decision
- **Reversible things** (UI, naming, file layout) proceed on a provisional standard marked `proposed`, and the handoff flags it.
- **Hard-to-undo things** (data formats, external contracts, infrastructure, security) wait for the owner.
- **Condition:** every provisional choice is flagged in the "Open" section of the handoff, so the owner can review it. A choice that is not flagged does not count as provisional.
- Outward-facing actions follow the rule in `AGENTS.md`: a branch and PR are allowed, a merge or force push is not.

## Alternatives
- Everything waits: safest, but a session is blocked on small choices.
- Everything proceeds and is flagged: fastest, but makes hard-to-undo mistakes possible.

## Dissent
"Reversible" is a judgement call, and a session can misjudge it. Accepted by the owner on the condition that each provisional choice is flagged in the handoff so it can be reviewed.

## Consequences
Easier: sessions are not blocked on small choices. Harder: the owner reviews provisional standards after the fact. In force from 2026-10-15.
