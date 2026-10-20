# Memory Architecture (v3)

> **Status:** In use for standards, decisions, gaps, handoffs, `/pickup`, `/handoff` and `/standard`. Still a draft where nothing has exercised it yet: capture (§4.1), promotion (§4.2), team mode.
> **Version:** v3.

## 1. What this is for

A way of working where doing a task for the tenth time comes out identical to the first time it was done well, by any session, any agent and eventually any teammate, at a fraction of today's cost.

Memory is the carrier. It holds how we do things, what outputs must satisfy, what each system looks like and why, and what the specialists know. Most of it should be **executable** (templates, shared code, checks). Prose is the index that gets a session to the right thing fast. A session that has to read a lot is a sign something is underspecified.

The failure it prevents: many sessions, at different times, each solving the same problem differently because none knew it had already been solved.

## 2. The six sections

| Section | Holds | Portable across projects? |
|---|---|---|
| **Playbooks** | How we do a recurring *task type*: when to use, steps, pieces used, standards it must satisfy, reference output. Build tasks ("set up a desktop app", "add a page") and meta tasks alike ("bring an area up to standard", "vet standards against a lens", "test a plugin", "release") | Yes |
| **Standards** | What outputs must satisfy. First-class, because tasks define, apply, audit and revise them | Yes |
| **Designs** | Per project/area: current architecture, target architecture, plans in progress, contracts between areas | Per project |
| **Decisions** | Why. Alternatives and dissent | Per project, or with the standard they justify |
| **Knowledge** | Domain understanding, independent of any project. What a specialist knows: audio, security, networking, cloud, Tauri… | Partly (personal notes stay with the person) |
| **State** | Handoffs, open gaps, inbox | Per person |

### The links are the point

**A standard knows four things:**

1. **Why** → a decision.
2. **How it's enforced** → a check (lint rule, test, CI policy), or "reviewer" if none exists yet.
3. **Where it applies** → scope: personal, common, a golden path, or one area. Most specific wins; overrides need a decision.
4. **Where it's been applied** → playbooks and code paths. This is what makes revising a standard tractable: the migration list is known before anyone decides.

**A playbook references standards, never copies them,** so a revised standard propagates.

**A design is justified by decisions and constrained by standards.**

**A gap** (a kind of thing with no standard, or a task with no playbook) is a first-class entry in State, so sessions know to stop and propose instead of improvising.

## 3. Read path: how a task uses memory

1. **Orient.** Load the repo map (`CLAUDE.md`). Read the latest handoff if continuing.
2. **Scope.** Declare the areas in scope and out of scope.
3. **Match.** Split the task into task types. For each: is there a playbook? For each kind of thing it will produce: is there a standard?
4. **Follow.** Known types follow the playbook and the standards. Output should be identical to the reference.
5. **Gap protocol.** For anything unknown, stop and work with the human: 2–3 options, a recommendation, the dissent. Human decides. Record the standard and decision. Continue. This is the same whether the task is a new build, a refactor of an old app, an audit, or a test run.
6. **Review.** A reviewer in a fresh context checks the output against the applicable standards and the declared scope, and runs the checks.
7. **Close.** Write the handoff. (Capture of memory candidates is automatic; see §4.)

**Provisional rule when the human is unavailable** (decided, [0013](../decisions/0013-provisional-autonomy-rule.md)): reversible things (UI, naming) proceed with a provisional standard marked `proposed` and flagged in the handoff. Hard-to-undo things (data formats, external contracts, infra) wait.

## 4. Write path: how memory changes

"Automatic" means the harness does it, not that Claude remembers to. Three paths, separated by how much review they need.

### 4.1 Capture: automatic, no review, allowed to be noisy

- A hook at the end of every session runs a cheap extractor over the transcript (`claude -p` on Haiku; later a local model). It looks for a fixed set of signals:
  - corrections the human made
  - decisions taken
  - commands that worked
  - errors and their fixes
  - deviations from a playbook, and why
  - anything the human flagged ("remember: …")
- Each signal becomes a small candidate note in `state/inbox/`, tagged with the session.
- A pre-compaction hook writes a handoff before context is compacted.
- The inbox is **not memory**. Low precision is fine.

**Secrets rules for capture:**

- **Redact before the extractor sees anything.**
  - Run the transcript (and tool-result files) through a secret scanner, plus an exact-value scan against current dev secrets.
  - This happens *before* the extractor model is called, because that call re-sends the transcript to a provider.
  - If the scanner errors, write nothing.
- **Scan the extractor's output too.** If a candidate matches, drop it.
- **`state/inbox/` is gitignored** until promotion. Memory commits run a pre-commit secret scan.
- **A per-session opt-out** (e.g. `MEMORY_CAPTURE=off`) for sessions that handled credentials.
- **Claude Code's built-in auto memory** is disabled, or redirected into the scanned inbox, so the curated pipeline is the only path into memory.

### 4.2 Promote: batched, reviewed by a human, as a diff

- Weekly, or on demand: a memory-keeper pass (a scheduled `claude -p` job, or a skill you trigger) reads the inbox and drafts real entries: a gotcha, a decision, a standard proposal, a playbook edit. It dedupes, and anything that **contradicts** an existing entry is flagged as a conflict rather than added alongside it.
- You review one git diff (in your editor): accept, edit, reject, commit.
- **Nothing becomes active memory without that commit.**

### 4.3 Change: governed

Changing an active standard or playbook is always:

1. a new decision superseding the old one
2. status → `under review`
3. the "applied in" list becomes the migration task list
4. the check is updated so the old way now fails
5. status → `active` (new version); old → `superseded`

| | Solo | Team |
|---|---|---|
| Where memory lives | this repo | a shared kit repo, installed as a plugin |
| Who approves | you, on the diff | `CODEOWNERS` on `standards/` and `playbooks/` |
| Major changes | you | a scheduled review session, batched; the PR carries the decision, the dissent and the migration list |
| Minor changes | you | one async reviewer |
| Capture | your inbox | each person's own inbox; never a shared store agents write to directly |
| Staying in sync | n/a | a session-start hook pulls the latest kit |

**Major vs minor:** a change is major if the entry has a non-empty "applied in" list, or common or golden-path scope. Everything else is minor.

### 4.4 When something is wrong mid-task

- **A playbook gave a wrong result.** Correct the agent as usual. The correction is in the transcript, so capture gets it. The agent also writes "playbook X, step N, wrong because…" into the handoff. Promotion turns it into a playbook edit; the consistency test re-runs.
- **A standard is wrong.** Status → `under review`; it enters §4.3. Or it surfaces from an audit task.
- **New evidence contradicts an entry.** Capture flags a conflict; you resolve it at promotion. Entries never drift silently.

## 5. Layout

A project starts with everything in one repo, kept split-ready:

- `memory-kit/` and `knowledge/` are fixed top-level folders with nothing else inside.
- Links go one way: project → knowledge. The kit references neither and uses placeholder paths.
- Commits are Conventional Commits, `type(scope): summary`, with `kit`, `knowledge` and `app` as scopes (see [decision 0007](../decisions/0007-git-workflow-issue-branches-conventional-commits.md)).
- A later split is `git subtree split --prefix=<folder>`, which keeps history.

```
<repo>/
  CLAUDE.md                  ← repo map: areas, commands, where the indexes are
  .claude/                   ← hooks, skills, subagents (the executable part of the kit, wired in)
  memory-kit/                ← PLAYBOOKS + STANDARDS (+ checks, templates). Portable.
    playbooks/INDEX.md
    standards/INDEX.md
    paths/desktop-tauri/     ← golden path: playbook, standards, checks, budgets, acceptance
  knowledge/                 ← KNOWLEDGE. Personal vault, Obsidian.
  docs/                      ← DESIGNS + DECISIONS + STATE for this project
    designs/ · decisions/ · state/{handoffs,inbox,gaps}
  apps/desktop/              ← an area, with its own CLAUDE.md and docs/
```

Folder detail inside each section is deliberately undefined until a task needs it.

This is the **default** layout for new repos. In existing repos, a memory map points each section at the folders already there (see §5a).

## 5a. Brownfield compatibility (requirements)

The kit must be adoptable in an existing repo that already has its own structure, docs and inconsistent code. Based on a read-only assessment of a real, existing monorepo.

1. **Sections are roles, not fixed folders.** A small **memory map** config file maps each section to existing paths, for example "decisions → `decisions/`", "designs → `planning/`", "root guidance → `AGENTS.md`". The layout in §5 is the *default* for new repos only.
2. **Memory has checks too,** run in CI like code checks:
   - the repo map is generated from the workspace, or validated against it
   - every design and plan has a status and a date
   - decisions are superseded, never edited in place
   - commands listed in the root guidance actually run
   - the root guidance stays under a size budget

   Stale memory that agents trust is worse than no memory.
3. **Every check supports a baseline.** Existing violations are recorded and tolerated, new ones fail, and the count can only go down. A check that fails on day one gets switched off.
4. **Incremental, per area.** The kit is useful with one area brief and one standard. Areas opt in as their first playbook or standard arrives. Installing the kit requires no restructuring.
5. **Language- and tool-agnostic checks.** A check is any command that passes or fails: a linter, a type checker, a manifest validator, a migration dry-run.
6. **One version for everyone.** The kit is versioned and distributed. Local overrides are allowed but visible, so they can't silently split behaviour between people.
7. **Bootstrap playbook.** Day one in an existing repo:
   - existing ADRs are imported as decisions
   - existing plans are imported as designs, each with a status
   - existing skills are wrapped as playbooks
   - an inventory of variants per kind of thing produces the first gap list

   Nothing is rewritten up front.

**When proving the kit:** exercise these deliberately.
- Use `AGENTS.md` as the root file, and put decisions in a non-default path, so the memory map is used.
- Keep the first messy skeleton attempt as a "legacy" area.
- Run the first check in baseline mode.

## 6. The first task and the loop

**The first task:** something small, for example a desktop app that only displays something.

1. Do it with Claude, the way you work today.
2. Capture only what reproduces it: the steps and the decisions you'd make again. That's playbook v1, one file. The agent runs it from memory; where an upstream generator exists, the playbook pins and runs it. Nothing about setup lives in the project ([0020](../decisions/0020-setup-from-memory-copier-deferred.md)).
3. Do it again in a fresh session from playbook v1. **Diff the results.** Every difference is something the playbook underspecified. Fix. Repeat until identical.
4. Only then, Task 2 (add a page). Same loop. What the two playbooks share becomes the first common standard.
5. Structure appears when a task makes its absence hurt: the first shared piece of code and its check, the first index split, the first specialist.

**"Savagely well" test:** a fresh session, with almost no context, reproduces the reference output exactly, and the checks pass, and the budgets are met.

## 7. Mechanisms to verify in your environment

Before relying on the write path, check that these work where you run Claude Code:

- Hooks fire as expected: session start, stop, session end, pre-compaction; and whether session end still fires if the terminal is closed abruptly (if not, trigger capture on stop, deduplicated per session).
- Hook input includes the transcript path and session id.
- User-level deny rules (for example reading `.env`, `printenv`) block, including inside any editor integration you use.
- Subagent `model:` overrides and nested `CLAUDE.md` loading.
- Where Claude Code's auto memory lives, and whether to keep it as scratch or point it elsewhere.
- What your environment loader (for example direnv) exports into the agent process. Keep secrets out of tracked env files.
- The cost of a per-session extraction run, and which model it runs on.
- Whether a `PostToolUse` redaction changes what is stored in the transcript, or only what the model sees.

## 8. What stays undefined on purpose

- Note formats beyond: a title, a status, a date, and the links in §2.
- The list of standards. It starts empty.
- The list of playbooks. It starts with one.
- Which specialists exist. None until a domain is big enough to need one.
- Search indexing, local models, a gateway, agent teams. Add each when a task needs it.

## 9. Open questions

- [x] Provisional rule when you're unavailable: decided in [0013](../decisions/0013-provisional-autonomy-rule.md). Reversible proceeds and is flagged in the handoff; irreversible waits.
- [ ] Team review cadence for major changes: every two weeks, or on demand?
- [ ] Should project `docs/` be opened in the same Obsidian vault as `knowledge/`?
- [x] Backlog: GitHub issues ([0009](../decisions/0009-backlog-in-github-issues-milestones-project.md)).
