---
title: Commits follow Conventional Commits
kind: git
scope: portable
status: active
updated: 2026-10-15
decision: ../../docs/decisions/0007-git-workflow-issue-branches-conventional-commits.md
check: .githooks/commit-msg (type, format, length, period); reviewer for the rest
---

# Commits follow Conventional Commits

## Rule

1. **Every commit follows [Conventional Commits](https://www.conventionalcommits.org/):** `type(scope): summary`.
   - Imperative mood ("add", not "added"), no trailing period, 72 characters or fewer.
   - The scope is optional. Omit it for repo-wide changes.
2. **Types:**

   | Type | Use for |
   |---|---|
   | `feat` | a new feature or capability |
   | `fix` | a bug fix |
   | `docs` | documentation only |
   | `refactor` | neither a fix nor a feature |
   | `perf` | a performance improvement |
   | `test` | adding or fixing tests |
   | `build` | build system and dependencies |
   | `ci` | CI/CD config |
   | `chore` | maintenance with no source or test change |
   | `revert` | reverting a previous commit |
   | `style` | formatting only |

3. **Scopes are the repo's areas** and are listed in its root guidance file (for example `AGENTS.md`). Use the most specific one. A scope not on the list is wrong; if none are defined, that is a gap.
4. **Body (optional):** why the change was made, not what (the diff shows that). Blank line after the subject, wrapped near 72 characters.
5. **Breaking change:** add a `BREAKING CHANGE:` footer describing it.
6. **One logical change per commit.** Stage by path or with `git add -p`, never blind `git add -A`.
7. **Every commit stands alone.** We merge with merge commits, so each commit lands on `main` as written. No "wip", "address review" or "fix typo" commits.
8. **Correct an earlier commit on the branch with a fixup:** `git commit --fixup=<sha>`, then `GIT_SEQUENCE_EDITOR=true git rebase -i --autosquash origin/main` before hand-off. Pushing the result is a force push ([git-branches-and-prs.md](git-branches-and-prs.md)). Push fixups during review so threads stay intact; autosquash just before merge.
9. **Issue links:** `Refs #N` in a commit body is allowed. Put `Closes #N` in the PR body, not in commits, so it fires once, on merge.
10. **Agent-authored commits** end with the attribution trailer the session specifies, after a blank line.
11. **No secrets, and never bypass hooks** (`--no-verify`). If a hook fails, fix the cause and make a new commit. A secret that was committed needs rotating, not just deleting.
12. **Non-interactive git only** for agents: no `git add -i`, no plain `git rebase -i`.

## Why

- Consistent history makes `git log` and changelog tooling useful and shows a reviewer the intent of each step.
- Because every commit lands on `main`, small stand-alone commits can be reverted or cherry-picked cleanly.
- Fixups keep review threads intact and keep correction noise out of `main`.

## Do / Don't

Do:

```
feat(app): show the app version from the Rust side

The version comes over IPC so the UI and core agree on one source.

Refs #13
```

```
docs: record the stack decisions
```

Don't:

```
Updated stuff.
wip
app: Fixed typo.            # "app" is a scope, not a type
```

## Applied in

Hook: `.githooks/commit-msg`. It does not check scopes against the repo list. No example yet. Existing history uses `docs:` and `chore:` subjects, which are valid types; the scoped forms are new.
