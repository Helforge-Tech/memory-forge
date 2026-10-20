---
title: Memory has checks that run like code checks
kind: memory
scope: portable
status: active
updated: 2026-10-20
decision: ../../docs/decisions/0028-memory-checks.md
check: memory-kit/checks/test-memory-check.sh, run by task test; task memory runs the checks on a repo
---

# Memory has checks that run like code checks

## Rule

1. **Run `task memory`** in every repo that has the kit. It runs `memory-kit/checks/memory-check.sh` through the baseline runner ([checks-baseline-and-kinds](checks-baseline-and-kinds.md)) under the name `memory`.
2. **These rules hold**, each named as in the violation line:
   - `repo-map-missing`: every path in the `AGENTS.md` repo map exists.
   - `repo-map-unlisted`: every tracked top-level folder (not starting with `.`) is in the repo map.
   - `ref-missing`: every markdown link in `AGENTS.md`, `CLAUDE.md`, the kit README, skills, playbooks and standards points at a path that exists. Links in fenced code blocks (three backticks or `~~~`, even when the fence is indented) and in inline code are examples and are skipped. Not skipped: 4-space indented code blocks. Not checked: reference-style links (`[x]: path`) and paths that contain parentheses.
   - `ref-archived`: no such link points into a folder that holds an `ARCHIVED.md`.
   - `command-missing`: every `` `task <name>` `` in `AGENTS.md` is a task the task runner lists (`task --list-all`, so includes and namespaced tasks count; without `task`, the first `Taskfile.yml` or `Taskfile.yaml` is parsed).
   - `decision-number-duplicate`: no two decisions share a number.
   - `root-size`: `AGENTS.md` stays under 16000 bytes (`MEMORY_ROOT_BUDGET` sets another budget).
   - `index-status` and `index-row-missing`: each kit standard and playbook has a row in its `INDEX.md`, and the row's status matches the item's `status:`.
   - `kinds-map-invalid`: `checks/kinds`, if present, parses and every kind has an instance.
   - `decision-edited`: a decision differs from the merge base with `origin/main` only in its `- Status:` line, and none is deleted. With `CI` or `MEMORY_REQUIRE_BASE` set, a missing base or merge base (a shallow clone) is the violation `decision-base-missing`, not a skip: fetch full history in CI.
3. **Existing violations go in the baseline** (`checks/baselines/memory`) when the check is introduced, and the count only goes down. A permanent exception needs a reason (`checks/exceptions/memory`).
4. **A new rule ships with a test** in `memory-kit/checks/test-memory-check.sh` that makes it fire.

## Why

- Agents trust what they read; a stale repo map or a dead link costs a session.
- The same checks work in a repo that is already out of standard, because of the baseline.

## Do / Don't

Do: change a link and the file it points at in one PR, then run `task memory`.

Don't: write a path in backticks and expect it to be checked (only links and the repo map are), or edit a decision after it merges (supersede it).

## Applied in

This repo: `task memory`. Not wired into CI yet.
