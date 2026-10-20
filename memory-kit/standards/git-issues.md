---
title: Issues are the unit of tracked work
kind: git
scope: portable
status: active
updated: 2026-10-15
decision: ../../docs/decisions/0007-git-workflow-issue-branches-conventional-commits.md
check: none yet
---

# Issues are the unit of tracked work

## Rule

1. **Every branch and PR traces to an issue** ([git-branches-and-prs.md](git-branches-and-prs.md)). Search first (`gh issue list --search "<words>"`); do not duplicate.
2. **Title:** concise, imperative, no type prefix (issue titles are not commits).
3. **Body:** `## Context` (what and why, with links), `## Acceptance criteria` as a checklist of specific, verifiable outcomes, and optional `## Notes`.
4. **Labels** mirror commit types (`type:feat`, `type:bug`, `type:docs`, `type:chore`) and the repo's commit scopes (`area:<scope>`), plus initiative tags such as `epic`. Create a label the first time it is needed, not in advance.
5. **Close through the PR** (`Closes #N`), not by hand, so the closing commit is recorded. Reopen with `gh issue reopen <N>` if a fix regresses.
6. **Group related work under an epic.** Create the epic, create each child with a shared label and `Part of #<epic>`, then edit the epic into a task list (`- [ ] #124 Phase 0 ...`). The checklist ticks as children close.
7. **Formal sub-issues sparingly,** for large planned initiatives only. They need the child's internal id, not its number:

   ```bash
   CHILD_ID=$(gh api repos/{owner}/{repo}/issues/<child#> --jq '.id')
   gh api --method POST repos/{owner}/{repo}/issues/<parent#>/sub_issues -F sub_issue_id=$CHILD_ID
   ```

   A parent issue's number never names a branch.
8. **Log problems with these standards or playbooks as issues** (label `improvement`) before moving on: what went wrong, what the correct behaviour is, and which file needs changing. Do not wait for a perfect fix.

## Why

- An issue gives a branch and a PR something to point at, and the acceptance criteria say when the work is done.
- Search-first and epics keep the backlog from filling with duplicates and loose ends.
- Logging gaps as they are found is how the memory improves.

## Do / Don't

Do:

```bash
gh issue create --title "Show the app version from the Rust side" \
  --label "type:feat,area:app" \
  --body "$(cat <<'EOF'
## Context
The UI should read the version over IPC. See the Task 1 plan.

## Acceptance criteria
- [ ] A Rust command returns the version
- [ ] The UI renders it
- [ ] An IPC smoke test covers it
EOF
)"
```

Don't: title it `feat(app): ...`, hand-close an issue a PR will close, or open a second issue for something already filed.

## Applied in

Not applied yet. No example yet.
