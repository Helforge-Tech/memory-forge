---
title: Contribute a framework change upstream
status: active
updated: 2026-10-21
---

# Contribute a framework change upstream

## When to use

A project made from the template changed something in the framework tier: `memory-kit/`, the session skills and agents (`.claude/`), hooks, or the docs structure. `/handoff` and `/standard` ask once whether to submit it; a yes starts this playbook. Repo-tier standards (`docs/standards/`) never prompt. Skip it if `docs/state/kit-source.md` does not exist: this repo is the template and has no upstream.

## Steps

1. **Ask once per change.** "This changes the framework tier. Submit it to the template?" Record the answer in the handoff header (`Upstream: yes / no / later`) so the next session does not ask again.
2. **Read the source line.** `docs/state/kit-source.md` holds `kit: <url> @ <commit>`. Clone `<url>` into a scratch folder outside the repo (`git clone`, not shallow, so the recorded commit is reachable). Never edit this repo from here; never read, copy or create `.env*` or other secret files.
3. **Find the change.** Compare the project's framework-tier files with the template's at the recorded commit (`git diff --no-index`, or the project's own commits since the kit was installed). List only the files that belong to the change.
4. **Branch the clone** from its `origin/main` as `<issue#>-<short-summary>` (the template's issue, filed with `gh issue create -R <url>` if the owner agrees; otherwise ask the owner for the number). Port the change by hand into the clone.
5. **Make it fit any project.** Remove project names, paths, people, accounts, links to the project's decisions and issues, and anything only true here. Replace with placeholders. Keep the change's reason in a decision for the template if it was a real choice (next free number there).
6. **Scan before showing.** In the clone: `gitleaks` on the diff, and a grep of the diff for the project's name, its repo and owner names, its domain terms and its absolute paths. Fix every hit.
7. **Show the owner the diff** and wait for the go-ahead. The owner may drop or reword any part.
8. **Check and open the PR** in the clone, following [git-ship-a-change](git-ship-a-change.md): run the template's `task test` and `task memory`, push, and open the PR against the template. The template's owner reviews and merges; nothing else changes upstream.
9. **Say what is left.** The project's copy now differs from the template until the PR merges and the project takes it in ([take-in-upstream](take-in-upstream.md)). Note the PR link in the handoff.

## Standards used

- [git-branches-and-prs.md](../standards/git-branches-and-prs.md)
- [git-commits.md](../standards/git-commits.md)
- [git-split-code-and-memory.md](../standards/git-split-code-and-memory.md)

## Done when

- The owner answered the question and, on yes, saw the full diff before any PR opened.
- The PR holds only framework-tier files, with no project name, path, person or secret (scan and grep clean).
- The clone's checks passed, or the PR says which did not run.
- The project repo was not edited.

## Reference output

No real contribution yet. Not verified: a contribution whose template has moved on since the recorded commit.
