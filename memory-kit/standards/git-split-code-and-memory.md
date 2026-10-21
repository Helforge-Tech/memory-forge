---
title: A pull request holds code or memory, not both; a change that needs both is a stack
kind: git
scope: portable
status: active
updated: 2026-10-21
decision: ../../docs/decisions/0031-split-code-and-memory-prs.md
check: memory-kit/checks/test-pr-split.sh, in task test; pr-split.sh, run by task split in the CI gate
---

# A pull request holds code or memory, not both; a change that needs both is a stack

## Rule

1. **A PR changes memory paths or code paths, not both.** Memory is standards, playbooks, decisions, guidance, notes and docs. Code is everything else.
2. **A change that needs both is a stack:** the code PR first, then a memory PR on top whose base is the code PR's branch. If the code calls something only the memory layer has (a Taskfile that runs a new check script), the memory PR goes first instead; the layer that the other depends on is the lower one. Each PR names the other. Only the top PR carries `Closes #<issue#>`; the lower ones use `Refs #<issue#>`. Branches are `<issue#>-<short-summary>` and `<issue#>-<short-summary>-memory`, or `-code` on the second when memory goes first. A layer must not depend on something only the layer above has; if it cannot be avoided, say in the PR that the stack passes only as a whole.
3. **Which paths are memory is a setting, `checks/split`:** one line per entry, `side<TAB>path`, side `memory` or `code`. A path ending in `/` is a folder and everything under it; other paths are one file. The longest matching entry wins; an unlisted path is code. Blank lines and lines starting with `#` are ignored. If the file exists it replaces the defaults; a malformed line fails the check (exit 2). Root `checks/` is always code ([checks-baseline-and-kinds](checks-baseline-and-kinds.md) rule 10) and cannot be listed as memory.
4. **Defaults, with no `checks/split`:** memory is `memory-kit/`, `docs/`, `knowledge/`, `.claude/`, `AGENTS.md`, `CLAUDE.md`, `README.md`. A repo with another layout writes `checks/split` before it turns the check on.
5. **`task split` runs `memory-kit/checks/pr-split.sh` through the baseline runner** and is a step of the CI gate ([ci-pr-gate](ci-pr-gate.md)), run on pull requests only: a stack merged together is one push to `main` and would read as mixed ([0032](../../docs/decisions/0032-split-check-on-pull-requests-only.md)). It compares the files that differ between `GATE_BASE` and `HEAD`, from their merge base, so a stacked PR is judged on its own layer. It prints `mixed-pr<TAB>path<TAB>side` for each file of a mixed change.
6. **One exemption:** a change whose code files are all root `checks/` data (baselines, exceptions, the kinds map, `checks/split`) and that includes a check script from `memory-kit/checks/` is one PR. A check script and its baseline ship together ([checks-baseline-and-kinds](checks-baseline-and-kinds.md) rule 9). Memory files such as the standard that describes the rule may ride along.
7. **Use `gh stack` where it is installed and the repo has the feature,** to create the stack (`gh stack init`, `gh stack add`, `gh stack submit`; `gh stack link <lower PR> <upper PR>` when the PRs are already open), keep it current (`gh stack rebase` cascades a change in a lower branch; `gh stack sync` fetches, rebases onto the new `main`, pushes and updates the stack on GitHub, and skips a branch whose PR merged) and merge it (`gh stack merge <pr#>` with `--squash` or `--merge`; per its help it merges the stack up to that PR). The human merges ([git-branches-and-prs](git-branches-and-prs.md) rule 8); an agent does not run `gh stack merge`. `gh pr merge` and the plain merge REST endpoint refuse a stacked PR, so use `gh stack merge`; whether the GitHub UI can merge one was not tested. After the lower PR merges, GitHub retargets the upper PR to `main` itself; run `gh stack sync` to rebase it (a squash merge needs that: the PR's file list looks right, but the split check diffs from the merge base and sees the lower layer's files too, so it reads as mixed). The extension is in public preview. This repo's flake provides it in the dev shell (its `gh` forwards `gh stack` to nixpkgs' `gh-stack`); a repo that copies the kit adds the same to its flake ([tooling-declared-in-flake](tooling-declared-in-flake.md)). **The fallback is for a machine without `gh stack`, and always works, in this order:** push the lower branch, open its PR, cut the upper branch from it, and open that PR with `--base <lower branch>`. When the lower PR merges, **keep its branch**, retarget the upper PR (`gh pr edit <upper> --base main`), rebase it after a squash merge (`git rebase --onto origin/main <old lower tip> <upper>`, then `git push --force-with-lease`), and only then delete the lower branch. **Deleting the lower branch before the retarget closed the upper PR** instead of retargeting it. So with the fallback, merge the lower PR without `--delete-branch`; in a repo that deletes branches on merge, prefer `gh stack`, which handled that setting. The stack commands were fine with the setting on. With merge commits ([git-branches-and-prs](git-branches-and-prs.md) rule 7) the upper PR needs no rebase; it is not tested.
8. **`.gitattributes` marks the memory paths `linguist-generated`**, so GitHub collapses them in a diff. It is a backup for a PR that was not split, not a replacement for the check.

## Why

- A reviewer reads code for behaviour and memory for wording and consistency; one PR asking for both gets neither done well.
- A stack lets the pieces be reviewed separately and still land together.
- The paths are a setting so an existing repo with its own layout can adopt the check.

## Do / Don't

Do: `checks/split` for a repo with `playbooks/` at the top level:

```
memory	playbooks/
memory	AGENTS.md
code	playbooks/scripts/
```

Do: open the memory PR with `gh pr create --base 11-do-thing --head 11-do-thing-memory` when the code PR is on `11-do-thing`.

Don't: put the memory edit in the code PR "because it is one line"; list root `checks/` as memory; skip the check by editing a PR so that it only touches one side and then adding the other afterwards.

## Verified

On 2026-10-20 (gh 2.102.0, `gh stack` from the official extension): `gh stack init` on existing branches and `gh stack submit --auto --open` created two PRs with the upper one's base set to the lower branch, and a stack on GitHub.

On 2026-10-21, same versions, in a throwaway private repo with delete-branch-on-merge on:

- `gh pr merge` and the plain merge REST endpoint on a stacked PR are refused; `gh stack merge <pr#> --yes --squash` and `--merge` merged the lower PR alone.
- After either merge, GitHub retargeted the upper PR to `main` and deleted the lower branch. After the squash merge the upper PR's file list was still only its own layer, because the squashed tree matches; `gh stack sync` then fast-forwarded local `main`, skipped the merged branch, rebased the upper one onto `main` and pushed it. After the merge commit, `sync` also rebased and pushed the upper branch (a rewrite, not needed for correctness).
- `gh stack rebase` after a new commit on the lower branch rebased the upper branch onto it; `gh stack push` published both.
- Fallback: with the lower branch deleted at merge (`gh pr merge --delete-branch`), the upper PR (plain, `--base <lower>`) was closed, not retargeted. With the branch kept, `gh pr edit --base main`, a `git rebase --onto` and a force-with-lease push left the upper PR open and showing only its own file.

On 2026-10-21, `gh stack link 49 50` turned two already-open plain PRs (the upper one based on the lower branch) into a GitHub Stack, without creating or editing either PR.

Not verified: a stack of three or more, conflicts during `rebase` or `sync`, a base branch with required checks or a merge queue, and the fallback with merge commits, and whether the GitHub UI merges a stacked PR.

## Applied in

This repo: `memory-kit/checks/pr-split.sh`, `task split`, the `gate` job, `.gitattributes`, and the stack of the PRs that introduced them.
