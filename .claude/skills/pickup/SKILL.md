---
name: pickup
description: Resume work in this repo. With an issue number (`/pickup 6`) it resumes that thread; with none it lists the open threads and recommends one. Use at the start of a session or whenever you are lost.
disable-model-invocation: true
---

Get oriented. Read only what is listed below; do not explore the repo. Handoffs are local and untracked, named `<issue#>-<topic>.md` (decision 0015), so a fresh clone may have none.

## Always

1. `AGENTS.md` is already loaded.
2. `docs/state/gaps.md`.
3. If `docs/planning/PLAN.md` exists: its Status header (top ~12 lines) and its "Open questions" section. Nothing else in that file.
4. `git status --short`, `git branch --show-current` and `git log --oneline -8`.

## With an issue number (`/pickup <n>`)

6. `gh issue view <n>`, the issue and its last few comments.
7. The newest `docs/state/handoffs/<n>-*.md` by modification time (`ls -t docs/state/handoffs/<n>-*.md | head -1`). Read all of it.
8. The thread's code state: `git branch --list "<n>-*"` and the PRs from that branch (`gh pr list --state all --json number,title,state,headRefName --jq '.[] | select(.headRefName | startswith("<n>-"))'`).
9. Recommend the next step for that thread only.

## With no argument

6. `gh issue list --state open --limit 20` and `gh pr list`.
7. The open threads: the issue-numbered handoffs, newest first by modification time: `ls -t docs/state/handoffs | grep -E '^[0-9]+-' | grep -Ev '^[0-9]{4}-[0-9]{2}-[0-9]{2}-'` (the second filter skips old date-named handoffs). For each, read its header lines (issue, branch, PR, date). Read its "Open" section **only if** it is the newest handoff overall, or its issue is still open (`gh issue view <n> --json state --jq .state`). A handoff for a closed issue that is not the newest is a past snapshot: its Open items may have been resolved since, so do not report them. Do not read the rest.
8. Recommend the earliest open issue in the current milestone, unless an open thread says something is more urgent.

## Verify before reporting

A handoff is a snapshot and can be out of date. Before you report any item from a handoff as waiting, check it against what it points to. Do these checks together, only for items you are about to report (about ten at most):

- **Issue `#N`:** `gh issue view N --json state --jq .state`. If `CLOSED`, drop it.
- **PR `#N`:** `gh pr view N --json state --jq .state`. If `MERGED` or `CLOSED`, drop it.
- **Decision `NNNN`:** read the `- Status:` line of `docs/decisions/NNNN-*.md`. If the item says to confirm or accept it and it is already `accepted` or `superseded`, drop it.
- **Standard or playbook (a path under `memory-kit/`):** read its `status:` line. If the item says to set it `active` and it already is, drop it.
- **A "To promote" gap row:** search `docs/state/gaps.md` for its wording. If it is already there, drop it.
- **Anything with nothing to check:** report it prefixed `(unverified)`.

List what you dropped under **Stale**, with the reason (for example "0013 is accepted").

## Reply

Under 200 words:

- **Where we are:** 3 bullets.
- **Open threads:** one line each (issue, state, what is waiting). Skip this section with an issue number.
- **Waiting on the owner:** open questions and unfinished items.
- **Recommended next step:** one step, with the exact prompt to start it.
- **Stale:** anything in the handoff that no longer matches the repo.

Ignore any struck-through (`~~`) or `RESOLVED` line in a handoff: it is closed.

Do not start any work. With no argument, ask which thread to resume.
