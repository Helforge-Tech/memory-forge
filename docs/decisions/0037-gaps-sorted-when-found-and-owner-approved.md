# 0037: Gaps are sorted when found and recorded only with the owner's approval

- Status: accepted; amended by [0038](0038-gap-standard-renamed-and-settled-gaps-need-no-row.md) (standard renamed to `memory-gap-handling`; gaps settled in the same turn need no row)
- Date: 2026-10-22
- Scope: AGENTS.md session rule 3, the handoff skill, `docs/state/gaps.md`, the kit rules that log or record gaps

## Context

Session rule 3 said: a gap stops the session for options and a human decision, and the outcome is recorded in `docs/decisions/` and `docs/state/gaps.md`. In a project using the kit, gaps were found mid-reply, often after the work they interrupted, and went to three places: the chat, a handoff note (local and untracked), and `gaps.md` (only when promoted). Nothing put the decision in front of the owner when the gap was found, so gaps drifted between sessions, including one-line fixes the owner could have approved on the spot. Several kit rules also told an agent to log or record a gap without asking.

## Decision

Gaps are sorted the moment they are found into researchable, owner-judgement or follow-up work; every reply that finds one ends with a Gaps block; and nothing is written anywhere as a gap or an improvement until the owner agrees. An approved gap gets a `gaps.md` row; follow-up work also gets an issue labelled `gap`, linked from the row. The kit's `improvement` label keeps its meaning: a problem with an existing standard or playbook. The rule is the standard [gap-handling](../../memory-kit/standards/gap-handling.md); session rule 3 summarizes it, the handoff skill asks about unruled gaps before writing its "Gaps found" section, and the kit rules that logged or recorded gaps (git-issues rule 8, app-bring-to-standard step 6, adopt-existing-repo steps 1 and 5, ci-pr-gate rule 6) now ask first.

## Alternatives

- **Keep rule 3 as written.** Rejected: it produced the drift.
- **File every gap as an issue automatically.** Rejected: it floods the tracker with things the owner could approve in one word.
- **Use only `improvement`.** Rejected: missing coverage and a wrong rule are different kinds of work.
- **Issues only, no `gaps.md` row.** Rejected: roll-out-a-standard ranks from `gaps.md`.

## Dissent

More questions arrive mid-task. Mitigated by batching gap questions into one prompt per turn, and by researchable gaps being resolved with one approval instead of becoming issues.

## Consequences

Projects taking this in get the `gap` label the first time a follow-up gap is filed. Revisit if gap questions crowd out the work, or if `gaps.md` and the `gap` issues drift apart.
