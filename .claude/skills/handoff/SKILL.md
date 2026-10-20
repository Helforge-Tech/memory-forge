---
name: handoff
description: Close a session. Writes a local handoff note for the session's issue, holding gap edits and proposed memory changes for review. Use at the end of a work session, before clearing or closing it.
disable-model-invocation: true
---

Write the session handoff. Reconstruct it from this conversation and from `git status`, `git diff` and `git log`; do not ask the owner to summarize.

The handoff is local and untracked (`docs/state/handoffs/` is gitignored; decision 0014). Do not edit any tracked file here. The owner promotes the gap rows in a weekly PR.

1. Find the session's issue. Work always has one (`git-issues`). If it has none, create it first with `gh issue create`. If the session worked on several, write one handoff per issue.
2. Create `docs/state/handoffs/<issue#>-<short-topic>.md` (decision 0015). In a worktree, this is the worktree's own `docs/state/handoffs/`; `/pickup` reads every worktree (decision 0026). If a handoff for that issue exists, write the new one with a different topic. Start it with a header, then these sections, each short:
   - **Header:** `Issue: #<n>`, `Branch: <name or none>`, `PR: #<n> or none`, `Date: <YYYY-MM-DD>`.
   - **Done:** what changed, with paths.
   - **Decided:** decisions made. Link the records in `docs/decisions/`.
   - **Open:** questions and anything waiting on the owner. Anything that will outlive this session must be a GitHub issue (create it with `gh issue create`); list its number here instead of describing it in prose, so it can be closed. Do not repeat items that earlier handoffs listed and this session resolved; say they are resolved.
   - **Next:** one recommended step and the exact prompt to start it, which should begin with `/pickup <n>`.
   - **Gaps found:** kinds of things with no standard or playbook.
   - **Don't redo:** facts verified this session, so the next session doesn't re-check them.
   - **To promote:** the text that belongs in tracked files, ready to paste. Mark it `proposed`.
     - the exact new rows for `docs/state/gaps.md`, one per gap found
     - any proposed standard, playbook or decision record, as a list or diff. Never mark anything `active`
3. Close out earlier notes. If this session resolved an item that an earlier handoff in `docs/state/handoffs/` lists as open or proposed (anywhere in the file, including "To promote"), edit that local note: strike the line through (`~~text~~`) and add `RESOLVED <date> (see <this note>): <how>`. These are untracked files, so no PR is needed.
4. Comment a short summary on the issue: `gh issue comment <n> --body "..."` with what was done, what is left, and that the handoff is local.
5. Do not commit, and do not edit tracked files. Say what is in "To promote".

Rules: no secrets, no pasted transcripts, facts only. Flag anything uncertain.
