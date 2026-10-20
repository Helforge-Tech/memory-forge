---
name: standard
description: Add or change a standard, convention, playbook, check or template in this repo's memory. Use when the owner says things like "add this to memory", "make this a standard", "we always do X this way", "remember how we do X", or asks for conventions for something (for example GitHub, commits, or PRs).
---

Add or change a piece of memory. Anything in `memory-kit/` (standard, playbook, check, template) becomes `active` when the owner merges the PR that adds it ([0018](../../../docs/decisions/0018-standards-active-on-merge.md)).

1. **Classify it.** A *standard* is a rule outputs must satisfy. A *playbook* is the steps for a recurring task. A *check* is the hook, CI job or script that enforces a standard. A *template* is a reusable starting file. A *decision* is a one-off choice. If it is unclear, ask one question. If the tier is not stated, ask: kit (portable, any repo) or repo (specific to this repo)? Default to the repo tier when the content is specific to the repo. A repo standard that contradicts a kit standard needs a decision naming the kit standard it overrides; never edit the kit file ([standards-tiers](../../../memory-kit/standards/standards-tiers.md)).
2. **Look first.** Read `memory-kit/standards/INDEX.md` and `memory-kit/playbooks/INDEX.md` (checks and templates have no index yet; list them in the standard they enforce or serve). If one exists for this kind of thing, propose changing it (a new decision that supersedes the old one) instead of adding a duplicate. Find an existing example in the repo and point to it; if there is none, write "no example yet".
3. **If the owner has not decided,** give 2-3 options, a recommendation and the strongest objection, and wait. If it was a real choice, write a decision record in `docs/decisions/` from the template (next free number).
4. **Write the file.**
   - Portable standards: `memory-kit/standards/<kind>-<name>.md`. Standards for this repo only: `docs/standards/<kind>-<name>.md` (create `docs/standards/INDEX.md` with the same columns as the kit index if absent; for an override, the row ends "overrides `<kit standard>`"). No project or personal details in `memory-kit/`.
   - Frontmatter: `title`, `kind`, `scope`, `status: active`, `updated`, `decision` (link or `none`), `check` (the command, hook or CI job that enforces it, or `reviewer`, or `none yet`).
   - Sections: Rule, Why, Do / Don't (with a real example), Applied in (paths, or "not applied yet").
   - Playbooks: `memory-kit/playbooks/<name>.md` with When to use, Steps, Standards used (link them, never copy), Done when, Reference output.
   - Link with relative Markdown links.
5. **Add one row** to the `INDEX.md` of the tier you wrote to, with status `active`.
6. **Suggest a check:** the smallest thing that would enforce it (a git hook, a CI step, a lint rule). Offer to add it; do not add it unasked. Never write that a check exists if it does not.
7. **Report:** list the files changed and any existing code the new rule would affect. Do not commit. The owner reviews and merges; that merge is the approval, so do not ask the owner to edit the status. Ship it with a conventional commit (`docs(kit): ...`) through a branch and PR (see `memory-kit/playbooks/git-ship-a-change.md`), and list each kit item the PR activates in the PR description. Use `status: proposed` only for a provisional standard made while the owner is unavailable ([0013](../../../docs/decisions/0013-provisional-autonomy-rule.md)); flag it in the handoff.
