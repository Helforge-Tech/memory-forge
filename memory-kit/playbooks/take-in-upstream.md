---
title: Take template changes in
status: active
updated: 2026-10-21
---

# Take template changes in

## When to use

The owner asks to bring the template's newer changes into a project made from it. On request only; nothing prompts it. Needs `docs/state/kit-source.md` (written by [install-kit-existing-repo](install-kit-existing-repo.md)); for a project copied without it, see the first paragraph of [contribute-upstream](contribute-upstream.md) for how to write it.

## Steps

1. **Read the source line.** `docs/state/kit-source.md` holds `kit: <url> @ <commit>`. Clone `<url>` into a scratch folder outside the repo, read only. Never read, copy or create `.env*` or other secret files.
2. **List what is new.** `git log --oneline <commit>..origin/main` in the clone. If `<commit>` is not reachable, say so and stop; the owner decides how to re-baseline.
3. **Walk through it with the owner.** For each commit or group of commits, one line: what changed, which of the project's files it touches, and whether the project changed the same file (`git diff --no-index` against the template's version). Give a recommendation per item (take, skip, take with changes). The owner picks. Code-path changes (hooks, flake, Taskfile, CI) are offered as a second PR, not mixed in ([git-split-code-and-memory](../standards/git-split-code-and-memory.md)).
4. **Apply the chosen ones** on a branch cut from `origin/main` (`<issue#>-take-in-kit`). Where the project changed the same file, merge by hand and keep the project's local content; never overwrite silently. Copy the decisions that taken kit files link to, under their own numbers (see the missing-link rule in step 4 of the install playbook).
5. **Move the source line.** Set `docs/state/kit-source.md` to the template commit walked through up to, even when some items were skipped; list the skipped ones in the PR description so they are not asked again by accident.
6. **Check, then open a memory-only PR** after the owner's go-ahead, following [git-ship-a-change](git-ship-a-change.md). Run `task memory` and `task test` where they exist.

## Standards used

- [git-split-code-and-memory.md](../standards/git-split-code-and-memory.md)
- [git-branches-and-prs.md](../standards/git-branches-and-prs.md)

## Done when

- The owner picked each item; skipped items are listed in the PR.
- The PR touches memory paths only and `docs/state/kit-source.md` names the new commit.
- No project-local change was overwritten without the owner choosing it.

## Reference output

No real take-in yet. Not verified: a template history that was rebased since the recorded commit.
