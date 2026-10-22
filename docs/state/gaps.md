# Gaps

Kinds of things with no standard yet, and tasks with no playbook. A session that hits one stops and proposes (see AGENTS.md).

| Gap | Found in | Status |
|---|---|---|
| No playbook yet for setting up CI (the PR gate has a standard, `ci-pr-gate`), or for any app type other than desktop; no standard for IaC, services or web | template | open |
| `main` is protected by the ruleset "Protect Main" (pull request required, no deletion, no force push, no bypass, and the `gate` check required) | #16, #37 | closed: the owner added `gate` as a required check on 2026-10-21 |
| `gh stack` is a preview feature (the flake provides it). Creating, rebasing, syncing and merging a two-layer stack, and the second-PR fallback, were verified (see `git-split-code-and-memory`); not verified: three or more layers, conflicts, required checks or a merge queue, the fallback with merge commits, merging a stacked PR from the GitHub UI | #11, #42 | partly done |
| How notes link to each other: `[[wikilinks]]` vs relative markdown links | opening the repo in Obsidian | closed: relative markdown links, [0036](../decisions/0036-notes-format-linking-and-ownership.md) |
| Checks for branch names and commit scopes (hooks block `main` and check commit type and format) | memory standards (0007) | partly done |
| How to use the Project board: columns, fields, when an issue moves | planning backlog (0009) | open |
| No check that agent definitions set a model and none name a heavy one | memory standards (0017) | open |
| No check that a kit item's status matches its index row | memory standards (0018) | closed by `task memory` (0028) |
| No standard for per-worktree ports and local databases. Becomes real at the first repo whose services or apps run locally from parallel worktrees. Starting point: give each worktree its own port, derived from a hash of the worktree name | parallel sessions (#20) | open |
