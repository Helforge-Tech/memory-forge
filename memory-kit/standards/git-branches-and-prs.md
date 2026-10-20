---
title: Branches and pull requests
kind: git
scope: portable
status: active
updated: 2026-10-15
decision: ../../docs/decisions/0007-git-workflow-issue-branches-conventional-commits.md
check: .githooks/pre-commit and .githooks/pre-push block main; reviewer for branch names and PR bodies
---

# Branches and pull requests

## Rule

1. **Never commit or push to the default branch** (`main`). Every change goes on a branch and reaches `main` through a pull request.
2. **Every branch is tied to one issue.** Name it `<issue#>-<short-kebab-summary>`, for example `13-do-thing` for issue 13.
   - Short: a handful of words, lowercase, hyphens only.
   - **No slashes.** Slashes (`feat/`, `user/`) confuse branch-matching automation.
   - The number is the issue this branch actually completes, **never a parent or epic** that tracks other work.
   - If the work has no issue, create one first ([git-issues.md](git-issues.md)).
3. **One branch per unit of work**, cut from the latest `main`. Never branch off another feature branch unless it is a deliberate stacked PR, and the PR says so.
4. **One topic per PR.** The PR title is a conventional commit subject ([git-commits.md](git-commits.md)). The body has **What**, **Why**, **How** (if there are tradeoffs) and **Testing**, and says plainly what was not verified.
5. **Link the issue in the PR body, not in commits:** `Closes #13` on its own line. Use `Refs #N` to link without closing. One `Closes` line per issue the PR resolves.
6. **Default to one issue per PR.** When several issues are in play, help the owner decide whether to bundle or split; do not silently do either.
   - Bundle when the changes are inseparable, or tiny and clearer together (a fix and its test).
   - Split when they can land independently, touch different areas, or the diff is too big to review.
   - A list of unrelated issues is the signal to split.
7. **Merge with merge commits, not squash**, so each commit lands on `main` as written. This is a repo setting, and the owner changes it; do not change it.
8. **Agents open the PR and get it merge-ready** (checks green, every commit clean, fixups folded in). **A human merges in the GitHub UI.** Agents never run `gh pr merge` and never enable auto-merge.
9. **Rewriting pushed history needs the owner's confirmation each time.** Use `--force-with-lease`, never bare `--force`, and only on branches you created.
10. **Ask before** deleting a branch, closing a PR or issue, or changing repo settings.
11. **Delete the branch after merge.**
12. **One checkout per concurrent thread.** When more than one agent or session works at the same time, each gets its own git worktree and branch; never two threads in one folder.
    - Add: `git worktree add ../<repo>-<issue#> -b <issue#>-<short-kebab-summary> origin/main`
    - Remove after the PR is merged: `git worktree remove ../<repo>-<issue#>`
    - Git hooks and config are shared by every worktree. Ignored files (such as local handoffs) are not: they exist only in the worktree that wrote them. Copy any local handoff to the main checkout before removing the worktree.

## Why

- A PR gives CI and a review trail, and keeps `main` releasable and revertable.
- The issue number in the branch ties the work to its tracking issue and lets automation match them. Slashes break that matching.
- Naming a parent issue on a branch can close the parent and everything under it when the branch merges, so a board can report work as built that does not exist.
- Merging is the outward-facing step. Keeping it with a human means an agent's mistake stops at an open PR.
- `--force-with-lease` refuses to overwrite commits you have not seen.
- Two threads in one folder share one working tree and one checked-out branch, so one overwrites the other's uncommitted work. A worktree per thread removes the clash.

## Do / Don't

Do:

```bash
git fetch origin
git switch -c 13-do-thing origin/main
# commit, then
git push -u origin 13-do-thing
gh pr create --base main --title "feat(app): add the thing" --body "...

Closes #13"
```

Don't:

```bash
git switch -c feat/do-thing            # slash, no issue number
git switch -c 7-whole-initiative       # 7 is the parent/epic, not this branch's issue
git commit -m "..."                    # while 'git branch --show-current' prints main
git push --force                       # bare force
gh pr merge 12                         # an agent never merges
```

## Applied in

No example yet. Hooks: `.githooks/pre-commit` (no commits on `main`), `.githooks/pre-push` (no pushes to `main`). The procedure is [git-ship-a-change](../playbooks/git-ship-a-change.md).
