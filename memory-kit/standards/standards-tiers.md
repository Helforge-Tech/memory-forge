---
title: Standards have two tiers; a repo overrides a kit standard only by decision
kind: standards
scope: portable
status: active
updated: 2026-10-19
decision: ../../docs/decisions/0024-standards-tiers-and-overrides.md
check: reviewer
---

# Standards have two tiers; a repo overrides a kit standard only by decision

## Rule

1. **Kit tier:** portable standards live in `memory-kit/standards/`, indexed in its `INDEX.md`.
2. **Repo tier:** standards specific to this repo live in `docs/standards/`, with the same file format and an `INDEX.md` of the same shape. `/standard` asks which tier a new standard belongs to and defaults to the repo tier when the content is specific to the repo.
3. **The kit wins by default.** A repo standard overrides a kit standard only if a decision in `docs/decisions/` names the kit standard it overrides and says why.
4. **Never edit the kit file** to make an exception. The repo standard says what applies instead; its `decision` frontmatter links the override decision; its index row says "overrides `<kit standard>`".
5. **A repo standard that adds a rule the kit lacks needs no override.** It is only a new standard.
6. **Look in both indexes** before making a new kind of thing, repo tier first.

## Why

- Repos have their own conventions, and the kit must not be edited to fit one.
- A named decision lets a session tell a deliberate exception from drift.
- Keeping the kit file untouched keeps taking in upstream changes clean.

## Do / Don't

Sample (not applied to this repo). The kit says branches are `<issue#>-<short-summary>`; a repo's tracker uses keys like `PAY-123`.

Do: write decision `NNNN-branch-names-use-tracker-keys.md` naming `git-branches-and-prs.md` as the standard it overrides, then add `docs/standards/git-branch-names.md`:

```markdown
---
title: Branches are named <TRACKER-KEY>-<short-summary>
kind: git
scope: repo
status: active
updated: YYYY-MM-DD
decision: ../decisions/NNNN-branch-names-use-tracker-keys.md
check: reviewer
---
```

and an index row in `docs/standards/INDEX.md` ending "overrides git-branches-and-prs (branch names)".

Don't: edit `git-branches-and-prs.md`, or add the repo standard with no decision.

## Applied in

Not applied yet. No example yet.
