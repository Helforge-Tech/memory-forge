---
title: Ship a change to a branch and open a PR
status: active
updated: 2026-10-20
---

# Ship a change to a branch and open a PR

## When to use

Finished work is in the working tree (or on a branch) and needs to be committed, pushed and put up for review. Also: bringing a branch up to date with `main`, or filing the issue the work belongs to. An agent can do this on request: tell it to follow this playbook, name the files, the issue (or the summary to file one with), and a one-line description of the change.

## Steps

1. **Preflight.** Inside the dev shell, check `command -v gh`, `gh auth status`, and that the repo's git hooks are enabled. If a tool is missing, stop and say which tool to add to `flake.nix`. If `gh` is unauthenticated, stop and ask the owner to run `gh auth login`.
2. **Find or create the issue.** Search for it. If none exists, create one ([git-issues.md](../standards/git-issues.md)). Note its number, for example 13. Use the issue the work completes, not a parent or epic.
3. **Get on a branch.** `git branch --show-current`. If it is `main`, run `git fetch origin` and `git switch -c <issue#>-<short-kebab-summary>`, for example `13-do-thing`. Uncommitted changes come along. If another thread is active in this folder, use a separate worktree instead: `git worktree add ../<repo>-<issue#> -b <issue#>-<short-kebab-summary> origin/main`, and work there ([git-branches-and-prs.md](../standards/git-branches-and-prs.md) rule 12).
4. **Review what will be committed.** `git status`, `git diff`. Look for secrets, `.env*`, build output and anything outside the stated scope. Stop and report if something looks wrong; do not edit files to make a commit work.
5. **Commit per logical change** as a conventional commit ([git-commits.md](../standards/git-commits.md)). Stage by path. If the hook fails, fix the cause and commit again; never bypass it.
6. **Push.** `git push -u origin <branch>`.
7. **Open the PR.** Title is a conventional commit subject. Body is What, Why, How (if there are tradeoffs), Testing, then `Closes #<issue#>` on its own line. State what was not verified. Use `--draft` for work in progress.

   ```bash
   gh pr create --base main --title "feat(app): add the thing" --body "$(cat <<'EOF'
   ## What
   ...
   ## Why
   ...
   ## Testing
   ...

   Closes #13
   EOF
   )"
   ```

8. **Check CI.** `gh pr checks <number>`. Report failures with the reason. Correct earlier commits with `git commit --fixup=<sha>`.
9. **Tidy.** Before hand-off, fold fixups in: `GIT_SEQUENCE_EDITOR=true git rebase -i --autosquash origin/main`. Pushing that needs `git push --force-with-lease` on the issue's own branch, which the go-ahead on the issue covers (0027).
10. **Review.** The main session (a subagent cannot start another) runs the `reviewer` agent on the PR number, right after the PR is opened or updated. Fix blocking findings on the same branch, ship the fix, and re-run the reviewer. Posting findings on the PR waits for the owner's go-ahead.
11. **Hand off.** Report the PR URL, status and the reviewer's last result. Do not merge, and do not call the PR ready while a blocking finding stands. The owner merges with a merge commit in the GitHub UI.
12. **After the merge,** offer to `git switch main && git pull --ff-only` and to delete the branch; ask before deleting. If the work used a worktree, copy any local handoff to the main checkout, then `git worktree remove` it.
13. **If a step in this playbook was wrong or missing,** open an `improvement` issue naming the file to fix, then carry on.

### Variant: update a branch onto the latest `main`

`git fetch origin`, `git rebase origin/main`, resolve conflicts file by file (`git add`, `git rebase --continue`; `git rebase --abort` to back out), then `git push --force-with-lease` on the issue's own branch (covered by the go-ahead on the issue, 0027). Rebase only the issue branch you created, and not mid-review unless asked. If a branch has diverged badly, cut a fresh one from `main` and cherry-pick.

## Standards used

- [git-issues.md](../standards/git-issues.md)
- [git-branches-and-prs.md](../standards/git-branches-and-prs.md)
- [git-commits.md](../standards/git-commits.md)
- [tooling-declared-in-flake.md](../standards/tooling-declared-in-flake.md)

## Done when

- No commit was made on `main`.
- The branch is named `<issue#>-<short-kebab-summary>`, with no slashes.
- Every commit is a clean, stand-alone conventional commit.
- The branch is pushed and a PR is open with `Closes #<issue#>`, with checks green or the failures reported.
- The `reviewer` agent has run on the final state of the PR with no blocking finding standing.
- The PR URL is reported and the merge is left to the owner.
- If the change added or changed a playbook or standard, the PR lists the standards touched and the knowledge added.

## Reference output

No example yet. The first run should be added here as the reference.

An agent's report looks like:

```
Issue: #13
Branch: 13-do-thing
Commits: 3f2a1c9 feat(app): add the thing
PR: https://github.com/<org>/<repo>/pull/14 (checks: pending)
Not verified: CI has not finished.
Needs you: merge in the GitHub UI.
Next: the main session runs the `reviewer` agent before telling the owner the PR is ready.
```
