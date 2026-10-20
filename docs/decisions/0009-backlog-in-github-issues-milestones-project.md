# 0009: The backlog lives in GitHub issues, milestones and a Project board

- Status: accepted
- Date: 2026-10-15
- Scope: this repo's planned work

## Context
Planned work was spread over `PLAN.md`, the handoff's Open list, `gaps.md` (which mixed memory gaps with chores) and GitHub issues. Nothing said which one was the backlog, so each session re-derived what to do next.

## Decision
- Planned work is a GitHub issue. Each Task has a milestone and an epic issue.
- A GitHub Project board shows status across issues.
- `docs/state/gaps.md` holds only memory gaps: kinds of things with no standard or playbook. Each is linked to an issue once it is scheduled.
- `docs/planning/PLAN.md` holds direction only.
- One session works one issue. `/handoff` comments a summary on that issue, and `/pickup` reads the open issues in the current milestone.

## Alternatives
- A Markdown backlog in git (`docs/state/backlog.md`): keeps everything in git, but branches already need an issue number, so it would duplicate the issues.
- Issues and milestones without a board: simpler, but no status view across issues.

## Dissent
This moves state out of git, against "memory is Markdown in git", and needs the network and `gh`. Accepted because branches and PRs already depend on issues, and the handoff and gaps files still record decisions in git.

## Consequences
Easier: `/pickup` can name the next issue without reading the plan. Harder: the board and issues must be kept in step by hand, and the `gh` token needs the `project` scope. Revisit if the board is not kept up to date.
