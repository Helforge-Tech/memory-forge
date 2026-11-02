---
title: Unsettled items are open points, raised and settled in the session; only the owner makes one a follow-up
kind: memory
scope: portable
status: active
updated: 2026-11-02
decision: ../../docs/decisions/0040-open-points-settled-in-session-follow-ups-by-owner-decision.md
check: reviewer
---

# Unsettled items are open points, raised and settled in the session; only the owner makes one a follow-up

## Rule

1. **Four words, four meanings.**

   | Word | Means | What the session does |
   |---|---|---|
   | **Discussion point** | Something unsettled that turned up while working: an inconsistency, a problem outside the stated scope, a choice the session made that was really the owner's | Raise it with what was found and a recommendation |
   | **Decision point** | A discussion point that needs the owner's choice between real options | 2-3 options, a recommendation, the strongest objection; wait |
   | **Follow-up** | Work the owner decided, after the discussion, should be done but not now | An issue labelled `follow-up`, filed in the same turn |
   | **Gap** | Memory that covers nothing for this: a missing standard, playbook, check or rule | Raise it as an open point; record it only once the owner approves (rules 6-8) |

   A problem with an existing standard or playbook is an **improvement** ([git-issues](git-issues.md) rule 8); the same ask-first rule applies to it.
2. **Raise it where it was found.** Every reply that finds one ends with an **Open points** block: each point, its word, and what is needed from the owner. Batch them into one block per reply. A point is never mentioned mid-paragraph and left.
3. **The session never decides something is for later.** "Follow-up" is the owner's verdict on a point that was raised. The session does not sort a point into follow-up on its own, and does not propose an issue as the way to settle it. "Propose an issue" is not a kind of open point.
4. **Scope is the owner's.** Narrowing or widening what the owner asked for is a decision point, not something the session does and reports.
5. **A researchable point is researched now.** When the answer can be found (in the repo, the docs, comparable projects), the session finds it and proposes the fix with a recommendation in the same turn, rather than asking the owner to decide blind.
6. **Nothing is written anywhere as a follow-up or a gap until the owner agrees:** no issue, no `docs/state/gaps.md` row, no handoff line. A point the owner rules "not now, not ever" is dropped, not parked.
7. **A gap settled in the same turn needs no row:** an approved fix that is applied, or the owner's decision recorded in `docs/decisions/`, is its own record. **A gap left open gets a row in `docs/state/gaps.md`** once the owner approves recording it; if the gap is itself work (writing the missing standard, playbook or check), it also gets an issue labelled `gap`, and the row links it; work the owner decided to do later is a follow-up and gets `follow-up`, never `gap`. `gaps.md` stays the list that [roll-out-a-standard](../playbooks/roll-out-a-standard.md) ranks from. An approved improvement gets an issue labelled `improvement`.
8. **Where a playbook says to log or record a gap,** this rule applies: ask first, then record as above. During an adoption survey, the owner approving the survey's rows before its PR merges is the approval.
9. **At session close,** points still unsettled go in the handoff's **Open** section as questions; follow-ups appear by issue number; the **Gaps** section lists only gaps the owner agreed to record.

## Why

- The earlier rule sorted anything unsettled into three kinds, and the third, "follow-up work: propose an issue", became the default. Sessions pushed things off instead of raising them, in every kind of conversation, not only planning.
- "Gap" said *something the plan missed* about work the owner had chosen to do later. Separate words stop the two from being confused.
- A short list the owner settles in one message beats work parked across sessions and handoffs, and keeps the owner deciding what the memory records.

## Do / Don't

Do:

```
**Open points**
1. Phase 1 writes two of the four standards you chose; I cut it for size without asking. Decision point: write all four now (recommended: memory only, nothing to break) or keep two.
2. Seven other read handlers turn an outage into empty content, so a save during an outage overwrites real data. Discussion point: I'd add a phase for it right after the storage fix. The objection: the editor may then need to show the failure.
```

Don't:

```
**Gaps** (proposed; nothing is filed until you agree):
- Follow-up `gap` issues: give the other seven read handlers the 404/502 rule; move the older pages onto the shared renderer; ...
```

Don't: add a row to `gaps.md` or a gap to a handoff without asking, or mention a point mid-paragraph and move on.

## Applied in

`AGENTS.md` session rule 3; the handoff skill's **Open** and **Gaps** sections; `docs/state/gaps.md`. Replaces `memory-gap-handling` ([0037](../../docs/decisions/0037-gaps-sorted-when-found-and-owner-approved.md), [0038](../../docs/decisions/0038-gap-standard-renamed-and-settled-gaps-need-no-row.md)); see [0040](../../docs/decisions/0040-open-points-settled-in-session-follow-ups-by-owner-decision.md).
