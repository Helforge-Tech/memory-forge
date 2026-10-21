---
title: Install the kit into an existing repo
status: active
updated: 2026-10-21
---

# Install the kit into an existing repo

## When to use

The owner of an existing repo wants "this repo built out from memory-forge" and pasted the README prompt in a Claude session inside that repo. This playbook only installs: it looks for clashes, copies the kit in and opens a PR. Surveying the repo and bringing it up to standard are later steps, not this one.

## Steps

1. **Copy the source, read only.** Clone `https://github.com/Helforge-Tech/memory-forge.git` into a scratch folder outside the repo (`git clone --depth 1`), and note its commit (`git rev-parse HEAD`). Never edit the clone. Never copy, read or create `.env*`, `.envrc.local` or any other secret file, in either repo.
2. **Take a quick look for clashes, before copying anything.** Only what the kit would add or collide with. It answers "will installing break or duplicate something?", nothing more. Look for:
   - skills or agents named `pickup`, `handoff`, `standard`, `git-ship` or `reviewer` (`.claude/skills/`, `.claude/agents/`);
   - an `AGENTS.md` or `CLAUDE.md`;
   - a `docs/decisions/`, `docs/state/` or `memory-kit/` folder, or decision numbers the kit's decisions would reuse;
   - a `core.hooksPath` setting or a pre-commit hook in use (a `.githooks/` folder, which is the kit's name too; `.husky/`, `.pre-commit-config.yaml`, `.git/hooks`);
   - skills or docs that do a kit job under another name (an ADR folder, a "best practices" or "conventions" doc, a handoff-style skill, a contributing guide that fixes commit or branch rules);
   - a `Taskfile`, `flake.nix` or `.github/workflows/` the kit's checks would have to join (note them; the kit does not edit them in this step).
3. **Report each clash with a recommendation before writing anything:** keep both, rename the kit's copy, or leave it for the later adoption stage to replace. Give the owner 2-3 options for any clash that is not obvious, with a recommendation and the strongest objection. The owner decides. Nothing is overwritten silently, and nothing outside the kit's own paths changes except what the owner chose.
4. **Copy in the memory layer** on a branch cut from `origin/main` (`<issue#>-install-memory-kit`, or `install-memory-kit` if the repo tracks no issues; ask for an issue only if the repo's own rules require one):
   - `memory-kit/` (playbooks, standards, checks, templates and their indexes);
   - `.claude/skills/{pickup,handoff,standard}` and `.claude/agents/{git-ship,reviewer}`, minus any the owner chose to keep as they are;
   - the decisions that copied kit files link to (`docs/decisions/`, with the template), under their own numbers; find them with `memory-kit/checks/memory-check.sh | grep ref-missing`. Copy no other decision, plan or handoff: they are this repo's history. A decision number the repo already uses is a clash for step 3: the options are to skip the kit's copy of that decision and note the resulting missing link for the code PR of step 6 to put in the check's baseline (`checks/baselines/` is a code path), or to leave out the kit items that link to it. Decisions about the kit's own app stack (the `app-*` standards, `desktop-app-setup`) are only needed if those items are copied, and the owner may leave them out in step 3. `memory-check` does not scan `docs/decisions/`, so links between decisions may dangle; do not rewrite decisions to fix them;
   - a pointer to the kit in `AGENTS.md` (create a short one if none exists; if one exists, add only the session rules the owner approved in step 3), with `memory-kit/` and `docs/` in its repo map;
   - an empty `docs/state/handoffs/` with a `.gitkeep`, and an empty `docs/state/gaps.md` (the table header only), which the skills and playbooks point at. The `.gitignore` lines for handoffs are a code path, so they go in step 6's PR; until then add them to `.git/info/exclude`, which no PR carries;
   - the kit-source line (step 5).
5. **Record where the kit came from in one tracked line:** `docs/state/kit-source.md` with a single line `kit: https://github.com/Helforge-Tech/memory-forge.git @ <commit>`, and nothing else. The playbook for taking changes in reads this line.
6. **Hooks and tooling are code, so they are a second PR.** The secret-scan and commit hooks (`.githooks/`, with `git config core.hooksPath .githooks`) and the tools they need (`gitleaks`, `gh`, `task`, declared in the repo's flake or equivalent per [tooling-declared-in-flake](../standards/tooling-declared-in-flake.md)) change code paths, and [git-split-code-and-memory](../standards/git-split-code-and-memory.md) keeps them out of the memory PR. Offer that PR to the owner; do not open it unasked. Before the check runs in CI, write the repo's `checks/split` if its layout differs from the defaults.
7. **Check, then open the memory PR** after the owner's go-ahead, following [git-ship-a-change](git-ship-a-change.md). The PR touches memory paths only. If the repo has a `task memory`, run it; if not, say the kit's checks are not wired yet.

## Standards used

- [git-split-code-and-memory.md](../standards/git-split-code-and-memory.md)
- [tooling-declared-in-flake.md](../standards/tooling-declared-in-flake.md)
- [git-branches-and-prs.md](../standards/git-branches-and-prs.md)

## Done when

- Every clash found in step 2 was reported with a recommendation and decided by the owner before any file was written.
- The memory PR holds the kit, `docs/state/gaps.md`, the session skills and agents, the `AGENTS.md` pointer and the kit-source line, and no code path.
- No existing doc, skill or decision changed beyond what the owner chose.
- No secret or env file was read, copied or created.
- The hooks and tooling PR was offered, not assumed.

## Reference output

Dry run on a scratch repo that had its own `handoff` skill, an `AGENTS.md`, a `.githooks/pre-commit` with `core.hooksPath` set, a `docs/adr/` folder and a tracked `.env`: step 2 found the first four (the `.env` was never opened). Copying in then showed over 20 broken links from kit files to decisions that were not copied and a repo map missing `memory-kit/` and `docs/`; steps 4 and 2 were changed to cover both.
