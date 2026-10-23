# 0038: The gap standard is named memory-gap-handling, and gaps settled in the same turn need no row

- Status: accepted
- Date: 2026-10-22
- Scope: `memory-kit/standards/memory-gap-handling.md`, AGENTS.md session rule 3, the acceptance test

## Context

[0037](0037-gaps-sorted-when-found-and-owner-approved.md) added the gap standard as `memory-kit/standards/gap-handling.md`. The `/standard` skill names portable standards `<kind>-<name>.md`, and its kind is `memory`, so the name broke the convention every other `memory` standard follows. 0037 also said every approved gap gets a `docs/state/gaps.md` row, while the handoff skill lists a researchable gap by the fix the owner approved, so it was unclear whether a gap fixed in the same turn also needs a row. The acceptance test still expected the old "record it" answer.

## Decision

The standard is `memory-kit/standards/memory-gap-handling.md`, and every link to it uses that name. A gap settled in the same turn, by an applied fix or by the owner's decision recorded in `docs/decisions/`, needs no row: the fix or the decision record is its record. A gap left open gets a `gaps.md` row once the owner approves recording it, and follow-up work also gets an issue labelled `gap`. The acceptance test's first question expects nothing to be recorded as a gap without the owner's agreement.

## Alternatives

- **Keep the name.** Rejected: one standard outside the naming convention makes the index harder to scan and the `/standard` skill's rule untrue.
- **A row for every approved gap.** Rejected: rows for gaps already fixed are noise in the list roll-out-a-standard ranks from.

## Dissent

A same-turn fix leaves no entry in `gaps.md`, so the list no longer shows every gap ever found. The fix's commit and PR are its record.

## Consequences

0037's link to the old file name is historical; its Status line points here. Revisit if same-turn fixes turn out to need tracking.
