# 0017: Cheap models do research; heavy models give guidance

- Status: accepted
- Date: 2026-10-15
- Scope: all agents and sub-agents in this repo

## Context
Research was just widened ([0016](0016-borrowing-from-referenced-repos-and-open-source.md)): sessions and research agents look at how comparable apps and open source projects do something. That reads a lot of material. The owner's user-level settings already default sub-agents to the small tier, but that setting is outside the repo and does not cover other machines, and an agent spawned without a model can inherit a heavy one.

## Decision
- Research agents run on a cheap model: the small tier by default, the mid tier only when synthesis across many sources needs it.
- Heavy models (the Opus tier and above) are for guidance: planning, design, review and choosing between options.
- Mechanical agents (git operations and the like) use a cheap model too.
- Agents are spawned with an explicit model.
- The standard is [agents-model-by-role](../../memory-kit/standards/agents-model-by-role.md).

## Alternatives
- Rely on the user-level default sub-agent model: works on this machine, but is invisible to the repo and not portable.
- Let the heavy model do research for quality: simplest, but costs the most and uses plan limits fastest.

## Dissent
A cheap model can miss detail, miscount, or invent a source, and the guidance model may build on that. Mitigation: findings are data to check, the guidance model verifies what it relies on, and a thin result is retried one tier up before going to the heavy tier.

## Consequences
Easier: lower cost and slower limit burn, and research that runs in parallel cheaply. Harder: sessions must set a model on every spawn and check the findings. The `git-ops` agent sets no model yet; whether it should is a separate choice. Revisit if cheap-model research causes wrong decisions.
