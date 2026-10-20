---
name: pickup
description: Resume work in this repo. With an issue number (`/pickup 6`) it resumes that thread; with none it lists the open threads and recommends one. Use at the start of a session or whenever you are lost.
disable-model-invocation: true
---

Get oriented. Read only what is listed below; do not explore the repo. Handoffs are local and untracked, named `<issue#>-<topic>.md` (decision 0015), so a fresh clone may have none. Parallel sessions work in git worktrees, each with its own `docs/state/handoffs/` (decision 0026), so handoffs are looked for in every worktree.

## Always

0. `git fetch --prune origin` first. It updates `origin/*` only: local `main` may still be behind, so use `origin/main`, never local `main`, for commit history. Whether a PR is merged comes from `gh` (below). If the fetch fails (offline), say so at the top of the reply and mark every branch and PR state as possibly stale.
1. `AGENTS.md` is already loaded.
2. `docs/state/gaps.md`.
3. If `docs/planning/PLAN.md` exists: its Status header (top ~12 lines) and its "Open questions" section. Nothing else in that file.
3a. `git worktree list --porcelain`: the path of each worktree. Wherever this skill says `docs/state/handoffs/`, look in that folder of each worktree, and in the current checkout's. If two worktrees hold a note with the same name, use the newer by modification time. Remember which worktree holds it, since that is where the branch is checked out.
4. `git status --short`, `git branch --show-current` and `git log --oneline -8`.
5. The current branch's PR, if it is not `main`: `gh pr list --state all --head "$(git branch --show-current)" --json number,state`. Go by the newest PR. If it is `MERGED`, the report says so in one line ("on `<branch>`, merged in #N; run `git switch main && git pull --ff-only`") and treats nothing on that branch as pending. If there is none (`[]`), the branch's work is unshipped.

5a. **Clean up merged worktrees** (decision 0026, playbook `work-in-parallel`). Only when this session runs in the main checkout (the first path in step 3a); from inside a worktree, skip it and say so. For each other worktree whose branch's newest PR is `MERGED` (`gh pr list --state all --head <branch> --json number,state`; a branch with no PR is unshipped, leave it):
   - Copy its `docs/state/handoffs/*.md` (skip it if the folder is missing: 0 copied; check with `[ -d "<worktree>/docs/state/handoffs" ]` first) into this checkout's `docs/state/handoffs/` without overwriting: `find "<worktree>/docs/state/handoffs" -maxdepth 1 -name '*.md' -exec cp -n -p {} docs/state/handoffs/ \;`. If a name exists in both and the contents differ, copy the incoming one under a renamed file (`<basename without .md>-from-<branch>.md`), keeping the modification time (`cp -p`) with `cp -p "<worktree>/docs/state/handoffs/<name>.md" "docs/state/handoffs/<basename>-from-<branch>.md"`, and say so (`/pickup <n>` takes the newest by modification time, as in step 7).
   - Remove the worktree with `git worktree remove "<worktree>"` only if both hold: `git -C "<worktree>" status --short` is empty (no uncommitted or untracked files), and every `<worktree>/docs/state/handoffs/*.md` has a copy in this checkout with the same contents (`cmp -s`), under its own name or the renamed one. Handoffs are gitignored, so `status` does not show them and `git worktree remove` deletes them silently. Otherwise leave the worktree and say why.
   - Report one line per worktree, for example "Cleaned up worktree `20-...` (PR #24 merged); 1 handoff copied." Do not delete the branch, local or remote; that waits for the owner's go-ahead.

## With an issue number (`/pickup <n>`)

6. `gh issue view <n>`, the issue and its last few comments.
7. The newest `docs/state/handoffs/<n>-*.md` by modification time (`find "<each worktree>/docs/state/handoffs" -maxdepth 1 -name '<n>-*.md' -exec ls -t {} + 2>/dev/null | head -1`; `find` rather than a shell glob, with each path quoted (an unquoted path with a space silently drops that worktree), which fails in zsh when one worktree has no match). Read all of it.
8. The thread's code state: `git branch --list "<n>-*"` and the PRs from that branch (`gh pr list --state all --json number,title,state,headRefName --jq '.[] | select(.headRefName | startswith("<n>-"))'`).
9. Recommend the next step for that thread only. Mention another issue or PR only if it blocks this one, and only after checking its state with `gh`.

## With no argument

6. `gh issue list --state open --limit 200 --json number,title,milestone,labels,updatedAt` and `gh pr list`.
7. The open threads: the issue-numbered handoffs, newest first by modification time: `find "<each worktree>/docs/state/handoffs" -maxdepth 1 -name '[0-9]*-*.md' -exec ls -t {} + 2>/dev/null | grep -Ev '/[0-9]{4}-[0-9]{2}-[0-9]{2}-'` (full paths, so the order is global and each note shows its worktree; the filter skips old date-named handoffs). For each, read its header lines (issue, branch, PR, date). Read its "Open" section **only if** it is the newest handoff overall, or its issue is still open (`gh issue view <n> --json state --jq .state`). A handoff for a closed issue that is not the newest is a past snapshot: its Open items may have been resolved since, so do not report them. Do not read the rest.
8. Recommend the next issue, unless an open thread says something is more urgent. "Current" is not a fixed milestone: several milestones can be open at once and some issues have none. If step 9 ran and returned a pick, take it. Otherwise take the earliest open issue in the lowest-numbered open milestone.
9. **Parallel grouping, only when the owner asks** which tasks can run in parallel (in the `/pickup` message or after it). A plain `/pickup` skips this step: it costs an Opus run. If at least two open issues have no open PR, start the `reviewer` agent in parallel grouping mode: `Agent` with `subagent_type: reviewer` and `model: opus`, prompt `Parallel grouping mode for all open issues without an open PR: #a, #b, ...`. It decides what is current, then returns what can run together, what must wait and why, and the hotspot files. Pass its result on under "Can run in parallel"; it is advice, and the owner opens each session (playbook `work-in-parallel`). Skip this step with one candidate or none, or if the agent cannot be started (say so). On a plain `/pickup` with two or more open issues without an open PR, end the reply with a one-line offer to group them.

## Branch and PR state come from `gh`

Whether a PR or branch is merged, open or closed is read with `gh` (`gh pr view N --json state`, `gh pr list --state all --head <branch>`; without `--state all`, a merged PR lists as nothing), never inferred by comparing local branches or reading `git log` against a local `main`. When the owner says something is merged or done, check it once with `gh` and go with the result; do not repeat the old state.

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

Under 250 words (200 without the parallel section):

- **Where we are:** 3 bullets, plus the cleanup lines from step 5a if any.
- **Open threads:** one line each (issue, state, what is waiting). Skip this section with an issue number.
- **Waiting on the owner:** open questions and unfinished items.
- **Can run in parallel:** only with no argument, two or more candidates, and the owner having asked. The reviewer's groups in 2-4 lines, with the reason for anything that must wait. Omit otherwise. Without it, a one-line offer to group the issues (only with two or more candidates).
- **Recommended next step:** one step, with the exact prompt to start it. The prompt covers the whole step through to an open PR; it contains no stop points unless an owner decision blocks it (0027).
- **Stale:** anything in the handoff that no longer matches the repo.

Ignore any struck-through (`~~`) or `RESOLVED` line in a handoff: it is closed.

Apart from step 5a's cleanup, do not start any work. With no argument, ask which thread to resume.
