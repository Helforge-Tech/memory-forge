# 0043: Plans and decisions are written accepted; the owner's merge is the acceptance

- Status: accepted
- Date: 2026-11-02
- Scope: plans in `docs/plans/` and decision records in `docs/decisions/`; extends [0018](0018-standards-active-on-merge.md) from `memory-kit/` to them

## Context
[0018](0018-standards-active-on-merge.md) writes anything added to `memory-kit/` as active in its PR, so the owner's merge is the approval. Plans and decisions did not follow that: they were written `draft` or `proposed`, and the session flipped them to `accepted` by hand after the owner agreed in conversation. That is two steps for one approval, the same mismatch 0018 removed for standards.

## Decision
- A plan and a decision record are written `accepted` in the PR that adds them. The owner's merge is the acceptance, as 0018 says for `memory-kit/` items.
- The provisional case keeps its status, as in 0018. A plan made while the owner is unavailable is `draft`, and a decision made then is `proposed` ([0013](0013-provisional-autonomy-rule.md)). The owner confirms either in a later PR that sets it `accepted`, and the handoff flags it.
- A plan ends as `done` or `dropped`.
- An accepted decision is still never edited in place; a change supersedes it.

## Alternatives
- **Keep `draft` until the owner accepts in conversation, then flip by hand.** Two steps for one approval, and the header can disagree with the merge.
- **Flip the status on merge with a CI job.** Keeps the file honest before merge, but adds automation and a write to `main` for a one-word change.

## Dissent
An accepted plan on an open branch can be followed before the owner has read it. Accepted: the branch is reviewed in its PR, and the text reaches other checkouts only on merge, as with 0018.

## Consequences
Easier: one approval step per plan or decision, and the header matches the merge. Harder: the owner reviews the plan in its PR rather than in conversation, so the PR must say what it asks the owner to decide. Revisit if a `draft` or `proposed` from an unmerged branch is relied on elsewhere.
