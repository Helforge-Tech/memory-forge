---
title: Every tool a repo needs is declared in its nix flake
kind: tooling
scope: portable
status: active
updated: 2026-10-15
decision: ../../docs/decisions/0008-tools-declared-in-the-nix-flake.md
check: none yet
---

# Every tool a repo needs is declared in its nix flake

## Rule

1. **Any CLI that the repo's scripts, git hooks, task runner, CI, playbooks or agent skills invoke is declared in the dev shell of the repo's `flake.nix`.** This includes `gh`, `gitleaks`, the task runner and the language toolchains.
2. **A missing tool is fixed by adding it to the flake.** Do not install it ad hoc (`brew`, `npm -g`, `curl | sh`) and do not work around it. An agent that finds a tool missing stops and reports "add `<tool>` to `flake.nix`".
3. **The flake provides tools, not credentials.** Auth state (`gh auth login`, tokens, keys) is never in the flake or the repo. The person authenticates once per machine.
4. **Run repo workflows inside the dev shell** (direnv, or `nix develop -c <cmd>`). Error messages and docs name the flake, not a package manager.
5. **Version pins live in the repo** (the flake lock file, plus toolchain files such as `rust-toolchain.toml` where the flake reads them), so every session and machine gets the same versions.

## Why

- A session or CI run gets the same tools as the owner's machine, so "works on my machine" and silent dependence on one laptop's install go away.
- Declaring tools makes the list of what a workflow needs visible and reviewable.
- Keeping credentials out keeps secrets out of the repo.

## Do / Don't

Do:

```nix
devShells.default = pkgs.mkShell {
  buildInputs = with pkgs; [ gh gitleaks go-task ];
};
```

Don't:

```bash
echo "gitleaks is not installed (brew install gitleaks)" >&2   # points to an ad hoc install
```

Do instead: `echo "gitleaks is missing: add it to flake.nix and re-enter the dev shell" >&2`

## Applied in

Not applied yet. No example yet.
