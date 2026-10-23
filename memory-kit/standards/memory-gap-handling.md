---
title: Gaps are sorted when found and recorded only with the owner's approval
kind: memory
scope: portable
status: active
updated: 2026-10-22
decision: ../../docs/decisions/0038-gap-standard-renamed-and-settled-gaps-need-no-row.md
check: reviewer
---

# Gaps are sorted when found and recorded only with the owner's approval

## Rule

A **gap** is something nothing in the repo or kit tier covers: a missing standard, playbook, check, command or rule. A problem with an existing standard or playbook is an **improvement** ([git-issues](git-issues.md) rule 8); the same ask-first rule applies to it.

1. **Sort it the moment it is found,** into one of three kinds:
   - *Researchable:* research it now, propose a fix with a recommendation, and ask the owner to approve it in the same turn.
   - *Needs the owner's judgement:* ask now, with 2-3 options, a recommendation and the strongest objection.
   - *Follow-up work:* propose a GitHub issue, and file it once the owner agrees.
2. **Every reply that finds one ends with a Gaps block:** each gap, its kind, and what happened (asked, approved fix, proposed issue). Batch the questions into one prompt per turn.
3. **Nothing is written anywhere as a gap or an improvement** (`docs/state/gaps.md`, a handoff note, an issue) until the owner agrees it should be. Unapproved gaps are dropped, not parked.
4. **A gap settled in the same turn needs no row:** an approved fix that is applied, or the owner's decision recorded in `docs/decisions/`, is its own record. **A gap left open gets a row in `docs/state/gaps.md`** once the owner approves recording it; if it is follow-up work, it also gets an issue labelled `gap`, and the row links it. `gaps.md` stays the list that [roll-out-a-standard](../playbooks/roll-out-a-standard.md) ranks from. An approved improvement gets an issue labelled `improvement`.
5. **Where a playbook says to log or record a gap,** this rule applies: ask first, then record as above. During an adoption survey, the owner approving the survey's rows before its PR merges is the approval.

## Why

- Gaps found mid-reply drift between the chat, untracked handoffs and `gaps.md`, and many are one-word approvals that sit for sessions.
- The owner decides what the memory records.

## Do / Don't

Do: "**Gaps**: no area label for docs-only issues (researchable). Create one? Approve?"

Don't: add a row to `gaps.md` or a gap to a handoff without asking, or mention a gap mid-paragraph and move on.

## Applied in

`AGENTS.md` session rule 3; the handoff skill's "Gaps found" section. See [0037](../../docs/decisions/0037-gaps-sorted-when-found-and-owner-approved.md) and [0038](../../docs/decisions/0038-gap-standard-renamed-and-settled-gaps-need-no-row.md).
