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
3. **Root guidance** (memory PR). Rewrite `AGENTS.md` as a short repo map that `task memory` validates ([memory-checks](../standards/memory-checks.md)): areas, where the standards, playbooks and state live, the session rules. Put per-area detail in short area briefs, not in the root file. Keep the owner's own rules; add, do not drop.
4. **Baseline the checks** (code PR). Make the repo's own commands exist and run the kit's checks against the existing state: add the kinds map, then write each check's current violations to its baseline so today's state passes and any new violation fails ([checks-baseline-and-kinds](../standards/checks-baseline-and-kinds.md); [app-bring-to-standard](app-bring-to-standard.md) step 3 for an app). The baseline commit is its own commit with the count in its message. A check or command the repo lacks is a gap, not something to invent.
5. **Turn on the PR gate** (code PR, then an owner go-ahead for the setting). Apply [ci-pr-gate](../standards/ci-pr-gate.md): one `gate` job that calls the repo's own commands in baseline mode. Marking it required is a repo setting and waits for the owner's explicit go-ahead.
6. **Then ratchet.** From here the repo is adopted. Bringing each area to standard is the normal loop: pick an issue, roll out one standard for one area with [app-bring-to-standard](app-bring-to-standard.md) or the matching playbook, and remove baseline entries as they are fixed.

Each stage ships through [git-ship-a-change](git-ship-a-change.md). Memory and code never share a PR ([git-split-code-and-memory](../standards/git-split-code-and-memory.md)): stages 1 to 3 are memory, stages 4 and 5 are code, and a stage that needs both is a stack. Never read, copy or create `.env*` files or other secret files.

## Standards used

- [agents-model-by-role](../standards/agents-model-by-role.md)
- [standards-tiers](../standards/standards-tiers.md)
- [memory-checks](../standards/memory-checks.md)
- [checks-baseline-and-kinds](../standards/checks-baseline-and-kinds.md)
- [ci-pr-gate](../standards/ci-pr-gate.md)
- [git-split-code-and-memory](../standards/git-split-code-and-memory.md)

## Done when

- Each stage has its own issue and merged PR, and no PR mixes code and memory paths.
- `docs/state/gaps.md` lists the kinds with no standard; every existing skill, guide, ADR and plan has an outcome the owner saw.
- `AGENTS.md` is a short repo map and `task memory` passes.
- Every check passes on the current code through baselines, and a new violation fails.
- The `gate` job runs on PRs; the required-check setting was changed only on the owner's go-ahead, or the gap is recorded.

## Reference output

Not dry-run yet. Run it on a small scratch repo (an `AGENTS.md`, one skill, an ADR folder, a failing lint) and fix this playbook where a step was wrong or missing; that run is what keeps issue #7 open after this playbook merges.
