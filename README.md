# memory-forge

A template for building things the same way every time (desktop apps, web apps, services, docs, infrastructure), with AI coding sessions that reuse earlier decisions instead of reinventing them.

It holds the process, not a product:

- `memory-kit/`: playbooks, standards and checks that grow out of real tasks
- `.claude/`: the session commands (`/pickup`, `/handoff`, `/standard`) and agents
- `.githooks/`: secret scan, commit message format, no commits or pushes to `main`
- `docs/`: decisions, state (gaps and local handoffs), the memory design and an acceptance test

Projects copy it and grow their own memory. Start with [AGENTS.md](AGENTS.md); the design is in [docs/planning/MEMORY-ARCHITECTURE.md](docs/planning/MEMORY-ARCHITECTURE.md).

## Requirements

[Nix](https://nixos.org) with flakes, and optionally [direnv](https://direnv.net). `nix develop` (or `direnv allow`) gives you `task`, `gh` and `gitleaks`, and turns on the git hooks.

## Licence

[MIT](LICENSE)
