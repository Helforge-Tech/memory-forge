---
title: Adopt the framework into an existing repo
status: active
updated: 2026-10-21
---

# Adopt the framework into an existing repo

## When to use

The kit is installed in an existing repo ([install-kit-existing-repo](install-kit-existing-repo.md) has merged) and the repo must now be brought under it. The repo may be far from standard and may already hold its own skills, ADRs, "best practices" docs and plans in other shapes. Nothing is rewritten at once: each stage below is its own issue and its own PR, and the owner decides which stage is next.

## Steps

1. **Shallow survey** (one issue, one memory PR). Scope: list, do not judge.
   - One cheap agent per area, model set on each ([agents-model-by-role](../standards/agents-model-by-role.md)). Each returns: the area's folders, its existing skills, commands and docs, and the kinds of things it makes (endpoints, config, logging, errors, tests, infra modules, CI jobs).
   - Output: one row per kind with no standard or playbook in `docs/state/gaps.md`, and the repo's first kinds map as `checks/kinds` (format in [checks-baseline-and-kinds](../standards/checks-baseline-and-kinds.md); `checks/` is a code path, so it goes in the code PR of step 4, and the survey PR holds the proposed map in the PR description).
   - Not in this stage: the per-area inventory of variants. That happens later, just in time, when a standard for that area is rolled out.
2. **Sort existing memory** (one PR per batch). List every existing skill, guideline doc, ADR and plan, and give each one outcome: a standard (plus a check if the rule is mechanical), a playbook, an agent, a knowledge note, a decision, a thin skill that calls a playbook, or retired. Stale material is retired, not carried over. Give the owner the list with a recommendation per item; the owner decides the contested ones. Existing ADRs are kept as history and are not renumbered; a kit decision number that clashes was settled at install. New standards go through `/standard` and [standards-tiers](../standards/standards-tiers.md) (a repo standard that contradicts a kit one needs a decision).
3. **Root guidance** (memory PR). Rewrite `AGENTS.md` as a short repo map that the memory check validates (run `memory-kit/checks/memory-check.sh` directly until step 4 adds `task memory`: it always exits 0, so it passes when it prints nothing, and until step 4 `AGENTS.md` names no `task` command; [memory-checks](../standards/memory-checks.md)): areas, where the standards, playbooks and state live, the session rules. The repo map is a table whose first column is the path in backticks (``| `src/` | ... |``): the check reads nothing else, so a bullet list lists nothing. It lists every tracked top-level folder, and it finds unlisted folders only among tracked files, so `git add` new files before running it. Put per-area detail in short area briefs, not in the root file: one `AGENTS.md` per area folder, linked from that area's repo-map row ([memory-area-briefs](../standards/memory-area-briefs.md)); the check fails an unlinked, oversized or stale-path brief. Keep the owner's own rules; add, do not drop.
4. **Baseline the checks** (code PR). Wrap the repo's existing tools in the standard `task` commands (`task memory`, `task split`, `task test`, `task lint`, ...) and run the kit's checks against the existing state: add the kinds map, then write each check's current violations to its baseline so today's state passes and any new violation fails ([checks-baseline-and-kinds](../standards/checks-baseline-and-kinds.md); [app-bring-to-standard](app-bring-to-standard.md) step 3 for an app). A repo tool that does not print `rule<TAB>path[<TAB>key]` (a linter, say) gets a small adapter script that runs it once per instance from `kinds.sh list <kind>` and rewrites its output; use text that survives edits as the key (the rule's own message), not a line number. Put the adapter in `checks/`, which is always code, so the step adds no other top-level folder. `checks/` itself must be in the `AGENTS.md` repo map, and `AGENTS.md` is memory, so the step is a stack ([git-split-code-and-memory](../standards/git-split-code-and-memory.md) rule 2): the code PR first, then a memory PR on top with that one row. Until the memory PR merges, the memory check reports `repo-map-unlisted checks`; the gate is not on yet, so that is expected. The baseline commit is its own commit with the count in its message. A new kind of check the kit does not have, or a tool the repo does not use, is a gap, not something to invent.
5. **Turn on the PR gate** (code PR, then an owner go-ahead for the setting). Apply [ci-pr-gate](../standards/ci-pr-gate.md): one `gate` job that calls the repo's own commands in baseline mode. The job runs in the dev shell, so the repo needs a `flake.nix` declaring the tools its commands use ([tooling-declared-in-flake](../standards/tooling-declared-in-flake.md): `go-task`, `gitleaks`, the language runtime); add it in this PR if the repo has none. The kit has no secret-scan script, so `task secrets` (scan `$GATE_BASE..HEAD`, rule 4 of the standard) is written by the repo and recorded as a gap in `docs/state/gaps.md`. Marking the `gate` job required is a repo setting and waits for the owner's explicit go-ahead.
6. **Then ratchet.** From here the repo is adopted. Bringing each area to standard is the normal loop: pick an issue, roll out a new standard with [roll-out-a-standard](roll-out-a-standard.md), and bring one area up with [app-bring-to-standard](app-bring-to-standard.md) or the matching playbook, and remove baseline entries as they are fixed.

Each stage ships through [git-ship-a-change](git-ship-a-change.md). Memory and code never share a PR ([git-split-code-and-memory](../standards/git-split-code-and-memory.md)): stages 1 to 3 are memory, stages 4 and 5 are code, and a stage that needs both is a stack. Never read, copy or create `.env*` files or other secret files.

## Standards used

- [agents-model-by-role](../standards/agents-model-by-role.md)
- [standards-tiers](../standards/standards-tiers.md)
- [memory-checks](../standards/memory-checks.md)
- [memory-area-briefs](../standards/memory-area-briefs.md)
- [checks-baseline-and-kinds](../standards/checks-baseline-and-kinds.md)
- [ci-pr-gate](../standards/ci-pr-gate.md)
- [tooling-declared-in-flake](../standards/tooling-declared-in-flake.md)
- [git-split-code-and-memory](../standards/git-split-code-and-memory.md)

## Done when

- Each stage has its own issue and merged PR, and no PR mixes code and memory paths.
- `docs/state/gaps.md` lists the kinds with no standard; every existing skill, guide, ADR and plan has an outcome the owner saw.
- `AGENTS.md` is a short repo map and the memory check prints no violation (or `task memory` passes, once step 4 has added it).
- Every check passes on the current code through baselines, and a new violation fails.
- The `gate` job runs on PRs; the required-check setting was changed only on the owner's go-ahead, or the gap is recorded.

## Reference output

Dry run on a scratch repo with its own `AGENTS.md`, one skill, a `docs/adr/` folder and a failing lint rule (one violation), kit installed by [install-kit-existing-repo](install-kit-existing-repo.md) (copying the decisions that `memory-check.sh | grep ref-missing` named left the check clean). Stages 1 to 3 passed the memory check, and with the adapter, `task lint`, `task memory`, `task split` and `task secrets` passed on the baselined state (one tolerated lint violation) while a new `var` failed `task lint`. Changes it caused: the repo map must be a table and only sees tracked files; the `checks/` repo-map row makes step 4 a stack; a lint tool needs an adapter; the gate needs a flake and a repo-written `task secrets`. Step 4 was then run as a real stack in the scratch repo with `gh stack init --base <trunk> <code> <memory>` and `gh stack submit` (code PR on the trunk, memory PR on top): on the code layer `task memory` reported only `repo-map-unlisted checks`, on the memory layer it was clean, and `task split` and `task lint` passed on both. Not run: the gate workflow on GitHub, the required-check setting, and an area brief.
