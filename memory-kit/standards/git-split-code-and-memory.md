---
title: A pull request holds code or memory, not both; a change that needs both is a stack
kind: git
scope: portable
status: active
updated: 2026-10-20
decision: ../../docs/decisions/0031-split-code-and-memory-prs.md
check: memory-kit/checks/test-pr-split.sh, in task test; pr-split.sh, run by task split in the CI gate
---

# A pull request holds code or memory, not both; a change that needs both is a stack

## Rule

1. **A PR changes memory paths or code paths, not both.** Memory is standards, playbooks, decisions, guidance, notes and docs. Code is everything else.
2. **A change that needs both is a stack:** the code PR first, then a memory PR on top whose base is the code PR's branch. If the code calls something only the memory layer has (a Taskfile that runs a new check script), the memory PR goes first instead; the layer that the other depends on is the lower one. Each PR names the other. Only the top PR carries `Closes #<issue#>`; the lower ones use `Refs #<issue#>`. Branches are `<issue#>-<short-summary>` and `<issue#>-<short-summary>-memory`, or `-code` on the second when memory goes first. A layer must not depend on something only the layer above has; if it cannot be avoided, say in the PR that the stack passes only as a whole.
3. **Which paths are memory is a setting, `checks/split`:** one line per entry, `side<TAB>path`, side `memory` or `code`. A path ending in `/` is a folder and everything under it; other paths are one file. The longest matching entry wins; an unlisted path is code. Blank lines and lines starting with `#` are ignored. If the file exists it replaces the defaults; a malformed line fails the check (exit 2). Root `checks/` is always code ([checks-baseline-and-kinds](checks-baseline-and-kinds.md) rule 10) and cannot be listed as memory.
4. **Defaults, with no `checks/split`:** memory is `memory-kit/`, `docs/`, `knowledge/`, `.claude/`, `AGENTS.md`, `CLAUDE.md`, `README.md`. A repo with another layout writes `checks/split` before it turns the check on.
5. **`task split` runs `memory-kit/checks/pr-split.sh` through the baseline runner** and is a step of the CI gate ([ci-pr-gate](ci-pr-gate.md)). It compares the files that differ between `GATE_BASE` and `HEAD`, from their merge base, so a stacked PR is judged on its own layer. It prints `mixed-pr<TAB>path<TAB>side` for each file of a mixed change.
6. **One exemption:** a change whose code files are all root `checks/` data (baselines, exceptions, the kinds map, `checks/split`) and that includes a check script from `memory-kit/checks/` is one PR. A check script and its baseline ship together ([checks-baseline-and-kinds](checks-baseline-and-kinds.md) rule 9). Memory files such as the standard that describes the rule may ride along.
7. **Use `gh stack` where it is installed and the repo has the feature,** to create the stack (`gh stack init`, `gh stack add`, `gh stack submit`). The extension is in public preview. This repo's flake provides it in the dev shell (its `gh` forwards `gh stack` to nixpkgs' `gh-stack`); a repo that copies the kit adds the same to its flake ([tooling-declared-in-flake](tooling-declared-in-flake.md)). **The fallback always works:** push the lower branch, open its PR, cut the upper branch from it, and open that PR with `--base <lower branch>`. When the lower PR merges, retarget the upper one to `main` (GitHub does this when the base branch is deleted after merge). With merge commits ([git-branches-and-prs](git-branches-and-prs.md) rule 7) the upper PR needs no rebase. After a squash merge it does (`git rebase --onto origin/main <old lower tip> <upper>`), or its check sees the lower layer's files too and reads as mixed.
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

On 2026-10-20 (gh 2.102.0, `gh stack` from the official extension): `gh stack init` on existing branches and `gh stack submit --auto --open` created two PRs with the upper one's base set to the lower branch, and a stack on GitHub. Not verified: merging a stack, `gh stack rebase`, `gh stack sync`, and the fallback on GitHub (it is plain `gh pr create --base`).

## Applied in

This repo: `memory-kit/checks/pr-split.sh`, `task split`, the `gate` job, `.gitattributes`, and the stack of the PRs that introduced them.
