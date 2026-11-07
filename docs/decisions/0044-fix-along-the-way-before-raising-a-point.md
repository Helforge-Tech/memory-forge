# 0044: An inconsistency with one sensible fix is fixed along the way, not raised as an open point

- Status: accepted
- Date: 2026-11-06
- Scope: [memory-open-points](../../memory-kit/standards/memory-open-points.md) rules 1 and 4, `AGENTS.md` session rule 3; amends [0041](0041-open-points-settled-in-session-follow-ups-by-owner-decision.md), which stands otherwise

## Context
0041 made every unsettled item an open point for the owner, to stop sessions deferring work. Its rule 1 lists "an inconsistency" as a discussion point, and its rule 4 makes scope the owner's. Together they turned every stale line into a question. In a project using the kit, the owner was asked whether to correct a script header and a standard that the change itself had made wrong, and whether to add a file that a standard already said exists. The owner's verdict: these are the session's to fix.

## Decision
- **A fix along the way is checked first.** An inconsistency the current change caused or sits next to, with one sensible fix and no real cost, is fixed in the same PR (on its side of the split) and listed in one line under **Fixed along the way**. It is not an open point.
- **Making nearby text true is not a change of scope** (memory-open-points rule 4).
- **Open points are kept for what is the owner's:** a real choice between options with a cost, work outside the change, or a gap. 0041's rules for those stand.

## Alternatives
- Keep 0041 and rely on judgement: rejected, the rule as written is what produced the questions.
- A size limit (fix anything under N lines): rejected, size is not the test; one sensible fix with no cost is.

## Dissent
A session can now change memory the owner did not ask about, and a "sensible" fix may still be the owner's call. Limit: the listing under **Fixed along the way** keeps every such fix visible in the reply and the PR, and the reviewer checks it.

## Consequences
- Replies carry fewer open points; each fix along the way is one line.
- Delegated agents (a shipping agent, a reviewer) still report what they find; the main session sorts each finding into a fix along the way or an open point before telling the owner.
