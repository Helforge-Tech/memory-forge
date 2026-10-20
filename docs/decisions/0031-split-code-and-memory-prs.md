# 0031: A pull request holds code or memory, not both; a change that needs both is a stack

- Status: accepted
- Date: 2026-10-20
- Scope: `git-ship-a-change`, the `git-ship` agent, the CI gate, standard `git-split-code-and-memory`; every repo that uses the kit

## Context
[#11](https://github.com/Helforge-Tech/memory-forge/issues/11). A PR that changes code and memory (standards, playbooks, decisions, docs) together is hard to review: the reviewer reads two kinds of change against two sets of expectations. GitHub now supports stacked pull requests natively (public preview, `gh stack`). Two comments on the issue add constraints. A check script and its baseline must ship in one PR ([0025](0025-check-baselines-and-kinds-map.md)), though the script is memory and the baseline is code. And an existing repo has its own layout, so the paths cannot be written into the check.

## Decision
- **A PR touches memory paths or code paths, not both.** A change that needs both is split into a stack: the code PR first, then a memory PR on top of it (the other way round when the code needs something only the memory layer adds, such as a new check script). The PR on top says it is stacked and names the one below.
- **Stacks use `gh stack` where it is installed and the repo has the feature, and fall back to a second PR whose base is the first PR's branch.** The fallback needs nothing installed and survives a change to the preview. Either way each PR's diff is its own layer only.
- **Which paths are memory is a per-repo setting**, one tracked file `checks/split` (`side<TAB>path` lines, longest match wins, unlisted means code). Without the file, this template's paths are the defaults. Root `checks/` is always code ([0025](0025-check-baselines-and-kinds-map.md)).
- **A check fails a PR that mixes the two.** It reads the PR's own diff (from the base the PR targets, so a stacked PR is judged on its layer) and runs in the CI gate ([0029](0029-ci-pr-gate.md)).
- **One exemption:** a change whose code files are all root `checks/` data and that includes a check script ships as one PR. This is the check-script-plus-baseline rule.
- **`.gitattributes` marks memory paths as generated**, so GitHub collapses them in diffs. It is a backup for a PR that was not split; the check is the control.

## Alternatives
- **Only a rule in the playbook, no check.** Costs nothing, but a forgotten split is found in review, which is what this is meant to avoid.
- **Paths written into the check script.** Simpler, and wrong for an existing repo with its own layout.
- **Require `gh stack`.** It is a preview feature; requiring it would break on a plain machine and on a preview change.
- **Exempt every PR that touches only check data plus memory.** Lets a baseline fix hide in a docs PR. The exemption requires a check script.

## Dissent
Splitting costs a second PR for every change that touches both, and the two halves are often one idea (a rule and the code that follows it). The split also does not help when the memory half is one line. Accepted: the owner's priority is reviewability, a stack is cheap to open, and the exemption covers the one pairing that cannot be separated. Collapsing memory diffs also hides them from a reviewer of the memory PR, who must expand each file.

## Consequences
Easier: each PR has one kind of review. Harder: every change that touches both needs two PRs and the order matters; a lower PR cannot name a command that only the upper one adds. Revisit when `gh stack` leaves preview, or if the check blocks real work often enough that the exemption list should grow.
