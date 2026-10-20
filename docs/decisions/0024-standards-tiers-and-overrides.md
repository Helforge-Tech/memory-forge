# 0024: Standards have two tiers; a repo overrides a kit standard only by decision

- Status: accepted
- Date: 2026-10-19
- Scope: where standards live, which wins on conflict, `/standard`, the standards indexes

## Context
Kit standards in `memory-kit/standards/` are portable defaults. A real repo has rules of its own, and some contradict a kit standard (a different branch naming scheme, merge commits instead of squash). Nothing said where a repo-only standard lives or which rule wins. [0018](0018-standards-active-on-merge.md) and the `/standard` skill already mention `docs/standards/` without defining it.

## Decision
- Two tiers. Kit standards live in `memory-kit/standards/` and are portable. Repo standards live in `docs/standards/`, with the same file format and an `INDEX.md` of the same shape.
- A repo standard may override a kit standard only if a decision record in `docs/decisions/` names the kit standard it overrides and says why. The kit file is never edited; the repo standard links to the decision, and its index row says which kit standard it overrides.
- With no such decision, the kit standard wins. A repo standard that adds a rule the kit has no standard for needs no override.
- `/standard` asks which tier a new standard belongs to, and defaults to the repo tier when the content is specific to the repo.
- `AGENTS.md` says where each tier lives. The rule, with a sample override, is in the kit standard [standards-tiers](../../memory-kit/standards/standards-tiers.md).

## Alternatives
- **Edit the kit standard in the repo.** Simple, but the copy drifts from upstream and later kit updates conflict.
- **Let a repo standard win silently.** No ceremony, but a session cannot tell a deliberate exception from a mistake.
- **A single tier with per-repo exceptions listed in each standard.** Mixes portable and repo content, which the kit must not do.

## Dissent
Requiring a decision for every override is ceremony when the change is small (a branch prefix). Accepted: the decision is short, and it is what lets a later session and the upstream process tell an exception from drift.

## Consequences
Easier: adopting the kit in a repo with its own conventions. Harder: each exception costs a decision record. Revisit if overrides become so common that the decision records are noise, or when a check can verify the override link ([gaps](../state/gaps.md)).
