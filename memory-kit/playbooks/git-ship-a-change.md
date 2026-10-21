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
3. **Get on a branch.** `git branch --show-current`. If it is `main`, run `git fetch origin` and `git switch -c <issue#>-<short-kebab-summary>`, for example `13-do-thing`. Uncommitted changes come along. If another thread is active in this folder, use a separate worktree instead and work there ([work-in-parallel](work-in-parallel.md), [git-branches-and-prs.md](../standards/git-branches-and-prs.md) rule 12).
4. **Split by side.** List the changed paths and sort them with [git-split-code-and-memory](../standards/git-split-code-and-memory.md) (`checks/split`, or the defaults). One side only: carry on. Both sides: this is a stack. Code goes on the branch from step 3, memory on a second branch `<issue#>-<short-summary>-memory` cut from the first (named `-code` instead when it is the code on top; if the code calls something only the memory layer adds, such as a new check script, memory goes first). Exempt: a check script (`memory-kit/checks/`) with its root `checks/` data is one PR. Ship it as the stack variant below.
5. **Review what will be committed.** `git status`, `git diff`. Look for secrets, `.env*`, build output and anything outside the stated scope. Stop and report if something looks wrong; do not edit files to make a commit work.
6. **Commit per logical change** as a conventional commit ([git-commits.md](../standards/git-commits.md)). Stage by path. If the hook fails, fix the cause and commit again; never bypass it.
7. **Push.** `git push -u origin <branch>`.
8. **Open the PR.** Title is a conventional commit subject. Body is What, Why, How (if there are tradeoffs), Testing, then `Closes #<issue#>` on its own line. State what was not verified. Use `--draft` for work in progress.

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

9. **Check CI.** `gh pr checks <number>`. Report failures with the reason. Correct earlier commits with `git commit --fixup=<sha>`.
10. **Tidy.** Before hand-off, fold fixups in: `GIT_SEQUENCE_EDITOR=true git rebase -i --autosquash origin/main`. Pushing that needs `git push --force-with-lease` on the issue's own branch, which the go-ahead on the issue covers (0027).
11. **Review.** The main session (a subagent cannot start another) runs the `reviewer` agent on the PR number, right after the PR is opened or updated. Fix blocking findings on the same branch, ship the fix, and re-run the reviewer. Posting findings on the PR waits for the owner's go-ahead.
12. **Hand off.** Report the PR URL, status and the reviewer's last result. Do not merge, and do not call the PR ready while a blocking finding stands. The owner merges with a merge commit in the GitHub UI.
13. **After the merge,** offer to `git switch main && git pull --ff-only` and to delete the branch; ask before deleting. If the work used a worktree, finish it as [work-in-parallel](work-in-parallel.md) step 6 says: copy any local handoff to the main checkout, then remove the worktree.
14. **If a step in this playbook was wrong or missing,** open an `improvement` issue naming the file to fix, then carry on.

### Variant: ship a stack (code PR, then memory PR)

1. Commit the code files on `<issue#>-<short-summary>`. Cut `<issue#>-<short-summary>-memory` from it and commit the memory files there. Neither layer may leave the other's files in its diff, and a layer must not depend on something only the other has (move that thing down, or say the stack passes only as a whole).
2. Create the PRs. With `gh stack` available (the dev shell provides it; check `gh stack --help`): `gh stack init <lower> <upper>` for existing branches, then `gh stack submit`. Otherwise the fallback, which always works: `git push -u origin <lower> <upper>`, `gh pr create --base main --head <lower>`, then `gh pr create --base <lower> --head <upper>`.
3. Bodies: each names the other PR and says "Stacked: merge <lower PR> first". The upper PR has `Closes #<issue#>`; the lower has `Refs #<issue#>`.
4. Locally, `GATE_BASE=<lower branch> task split` checks the upper layer (the default base is `origin/main`, which sees both layers). Run steps 9 to 11 on each PR; the reviewer runs on both, the lower first.
5. After a rebase of the lower branch onto `origin/main`, rebase the upper onto it (`git rebase --onto <lower> <old lower tip> <upper>`, or `gh stack rebase`) and push both with `--force-with-lease`. With `gh stack`, GitHub retargets the upper PR itself when the lower one merges, and `gh stack sync` rebases it (needed after a squash merge); with the plain fallback, merge the lower PR without deleting its branch, retarget the upper to `main` (`gh pr edit <upper> --base main`), rebase it after a squash merge, and only then delete the lower branch: deleting it first closes the upper PR ([standard](../standards/git-split-code-and-memory.md) rule 7).
6. The exemption, one PR: a check script (`memory-kit/checks/`) with the root `checks/` data it changes.

### Variant: update a branch onto the latest `main`

`git fetch origin`, `git rebase origin/main`, resolve conflicts file by file (`git add`, `git rebase --continue`; `git rebase --abort` to back out), then `git push --force-with-lease` on the issue's own branch (covered by the go-ahead on the issue, 0027). Rebase only the issue branch you created, and not mid-review unless asked. If a branch has diverged badly, cut a fresh one from `main` and cherry-pick.

## Standards used

- [git-issues.md](../standards/git-issues.md)
- [git-branches-and-prs.md](../standards/git-branches-and-prs.md)
- [git-commits.md](../standards/git-commits.md)
- [git-split-code-and-memory.md](../standards/git-split-code-and-memory.md)
- [tooling-declared-in-flake.md](../standards/tooling-declared-in-flake.md)

## Done when

- No commit was made on `main`.
- The branch is named `<issue#>-<short-kebab-summary>`, with no slashes.
- No PR mixes code paths and memory paths; a change that touches both is a stack, or the check-script exemption.
- Every commit is a clean, stand-alone conventional commit.
- The branch is pushed and a PR is open with `Closes #<issue#>` (in a stack, the top PR closes it and the lower ones use `Refs`), with checks green or the failures reported.
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
