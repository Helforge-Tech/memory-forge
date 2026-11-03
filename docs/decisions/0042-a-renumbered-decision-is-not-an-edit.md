# 0042: A renumbered decision is not an edit

- Status: accepted
- Date: 2026-11-02
- Scope: `memory-kit/checks/memory-check.sh` (rule `decision-edited`), `memory-kit/standards/memory-checks.md`

## Context
Two PRs each took decision number 0040 and both merged, so `main` had a duplicate. Fixing it means renaming one file, but the check treated a deleted decision as an edit. An exception for the old name would have lived in root `checks/`, which the split check counts as code, so the fix PR failed as mixed.

## Decision
A decision whose file disappears is not reported when a file with the same slug exists and its text is the same apart from the `- Status:` line and the number in its title. A changed body is still reported. The owner chose this in conversation.

## Alternatives
- A permanent exception for the old file name: blocked by the split check, and every future clash would need another one.
- A two-PR stack (code exception, then memory): each layer fails the gate alone.
- Keep both files: leaves the duplicate.

## Dissent
It loosens a check meant to keep decisions immutable: a renumber with a matching body but with links elsewhere left pointing at the old name is caught only by `ref-missing`. Overruled: the body is the record, and dangling links are caught.

## Consequences
A number clash can be repaired in one memory PR. It does not stop the clash from arising when two PRs take the same number before either merges; the "Protect Main" ruleset's strict status check setting would, and is a separate owner decision.
