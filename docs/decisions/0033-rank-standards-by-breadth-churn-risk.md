# 0033: Standards are rolled out in an order ranked by breadth, churn and risk

- Status: accepted
- Date: 2026-10-21
- Scope: the `roll-out-a-standard` playbook

## Context
[#8](https://github.com/Helforge-Tech/memory-forge/issues/8). Once a repo is adopted, standards arrive one at a time and the code is brought in line later ([0025](0025-check-baselines-and-kinds-map.md) gives the baseline that lets that happen). Something must say which kind gets its standard first.

## Decision
- Score each kind without a standard 1 to 3 on breadth (areas crossed), churn (how often it changes) and risk (harm if wrong). Rank by the sum; break a tie with risk, then breadth.
- The scores come from the repo (`git log`, the kinds map), not from the owner. They give an order to propose; the owner decides.
- The playbook is `memory-kit/playbooks/roll-out-a-standard.md`. Progress is the baseline count, with no hand-kept list.

## Alternatives
- **Weighted scores.** Needs weights nobody can justify before there is a repo's data. Add them if the plain sum ranks badly in a real repo.
- **Risk first only.** Simple, but a risky kind used in one rarely edited folder would outrank a kind that is drifting in every area.

## Dissent
A sum of three coarse scores hides which factor drove the order, and 1 to 3 is a judgement. Accepted: the order is advice to the owner, and the three scores are shown.

## Consequences
Easier: a repeatable way to pick the next standard and a progress number that cannot go stale. Harder: nothing. Revisit after the first real roll-out.
