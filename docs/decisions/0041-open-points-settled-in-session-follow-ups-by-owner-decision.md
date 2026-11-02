# 0041: Unsettled items are open points settled in the session; only the owner makes something a follow-up

- Status: accepted
- Date: 2026-11-02
- Scope: `memory-kit/standards/memory-open-points.md` (replaces `memory-gap-handling.md`), AGENTS.md session rules 3 and 5, the handoff skill, `docs/state/gaps.md`, the acceptance test, the playbooks that linked the old standard; supersedes the sorting kinds of [0037](0037-gaps-sorted-when-found-and-owner-approved.md) and the `gap`-issue-for-follow-up-work part of [0038](0038-gap-standard-renamed-and-settled-gaps-need-no-row.md)

## Context

[0037](0037-gaps-sorted-when-found-and-owner-approved.md) told a session to sort anything the memory does not cover into three kinds the moment it is found: researchable, needs the owner's judgement, or *follow-up work: propose a GitHub issue*. In a project using the kit, the third kind became the default. A planning session ended its replies with a "Gaps" block proposing five issues "to file once you agree", and had narrowed the owner's chosen scope without asking. The owner reported the same pattern in every conversation: sessions push things off for later instead of raising them so they can be discussed and decided, and the word "gap" makes agreed later work sound like something the plan missed.

Two things were wrong. The rule gave the session a bin for deferral, so it used it. And one word covered three different things: something unsettled that needs talking through, work the owner has decided to do later, and memory that covers nothing.

## Decision

A session never decides that something is for later. Anything unsettled it finds is an **open point**, raised in the reply where it was found and settled there with the owner. The vocabulary is fixed:

- A **discussion point** is raised with what was found and a recommendation.
- A **decision point** needs the owner's choice: 2-3 options, a recommendation, the strongest objection.
- A **follow-up** is work the owner decided, after the discussion, to do but not now. Only then does it become an issue, labelled `follow-up`, filed in the same turn.
- A **gap** keeps its narrow meaning: memory that covers nothing for this (a missing standard, playbook, check or rule). It is raised as an open point like anything else, and recorded (`docs/state/gaps.md` row, a `gap` issue when it is work) only once the owner approves, as 0037 and 0038 already said.

The reply block is **Open points**, not "Gaps". The ask-first rule, the no-row rule for same-turn fixes, and the `gaps.md` list that `roll-out-a-standard` ranks from all stand. The standard is renamed `memory-open-points`, since its subject is no longer gaps, and every link to it uses that name. The handoff skill's "Gaps found" section becomes "Gaps" (true gaps only); unsettled points go under "Open" as questions, and follow-ups appear there by issue number.

**Labels.** `follow-up` joins `gap` and `improvement` as a label a project creates the first time it is needed ([git-issues](../../memory-kit/standards/git-issues.md) rule 4). `gap` is narrowed to missing memory coverage; a project taking this in relabels its work-type `gap` issues `follow-up` and moves agreed-work rows out of `gaps.md` to their issues.

## Alternatives

- **Keep the sorting and only rename the block.** Rejected: the third kind is what steers the session to defer; renaming it leaves the bin.
- **Rename "gap" to "follow-up" everywhere.** Rejected: "gap" is the right word for missing memory, and the ranking playbook needs that list.
- **Drop the end-of-reply block.** Rejected: the block is how points get in front of the owner instead of being mentioned mid-paragraph and lost.
- **One word for everything.** Rejected by the owner who reported the problem: the situations differ and each needs its own word.

## Dissent

More gets discussed per reply, and some replies will end in a list of questions. Accepted: a short list the owner can settle in one message beats work parked across sessions. The owner can always answer "follow-up" to any point, which is the one-word approval 0037 was after.

## Consequences

`memory-gap-handling.md` no longer exists; 0037 and 0038 keep their links to it as history. Projects that took the kit in before this change carry the old rule until they take this in; one such project overrode it by decision in the meantime. Sessions that find a problem outside their scope raise it and ask, rather than noting it for a later issue. Revisit if open-point lists crowd out the work.
