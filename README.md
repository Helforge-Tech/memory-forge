# memory-forge

A template for building things the same way every time (desktop apps, web apps, services, docs, infrastructure), with AI coding sessions that reuse earlier decisions instead of reinventing them.

It holds the process, not a product:

- `memory-kit/`: playbooks, standards and checks that grow out of real tasks
- `.claude/`: the session commands (`/pickup`, `/handoff`, `/standard`) and agents
- `.githooks/`: secret scan, commit message format, no commits or pushes to `main`
- `docs/`: decisions, state (gaps and local handoffs), the memory design and an acceptance test

Projects copy it and grow their own memory. Start with [AGENTS.md](AGENTS.md); the design is in [docs/planning/MEMORY-ARCHITECTURE.md](docs/planning/MEMORY-ARCHITECTURE.md).

## Install into an existing repo

Paste this in a Claude session inside your repo:

> Install memory-forge into this repo. Clone `https://github.com/Helforge-Tech/memory-forge.git` into a scratch folder outside this repo (read only), then follow `memory-kit/playbooks/install-kit-existing-repo.md` from that copy. Report every clash and wait for my decision before writing anything. Never read or copy `.env*` or other secret files.

## Requirements

[Nix](https://nixos.org) with flakes, and optionally [direnv](https://direnv.net). `nix develop` (or `direnv allow`) gives you `task`, `gh` and `gitleaks`, and turns on the git hooks.

## Licence

[MIT](LICENSE)
