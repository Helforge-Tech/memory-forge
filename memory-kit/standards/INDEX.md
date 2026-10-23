# Standards

What outputs must satisfy. Standards are added the first time a task introduces a new kind of thing. These are the kit tier; a repo's own standards live in `docs/standards/` and override a kit standard only by decision ([standards-tiers](standards-tiers.md)).

| Kind | Standard | Check | Scope | Status |
|---|---|---|---|---|
| git | [Branches and pull requests](git-branches-and-prs.md) | none yet | portable | active |
| git | [Commits follow Conventional Commits](git-commits.md) | none yet | portable | active |
| git | [Issues are the unit of tracked work](git-issues.md) | none yet | portable | active |
| git | [A pull request holds code or memory, not both; a change that needs both is a stack](git-split-code-and-memory.md) | `test-pr-split.sh`, in `task test`; `pr-split.sh` in the CI gate | portable | active |
| agents | [Cheap models do research; heavy models give guidance](agents-model-by-role.md) | none yet | portable | active |
| tooling | [Every tool a repo needs is declared in its nix flake](tooling-declared-in-flake.md) | none yet | portable | active |
| app | [Every app has format, lint and test gates from day one](app-quality-gates.md) | `task lint`, `task test` | portable | active |
| app | [An app exposes one command each for dev, build, test, coverage, lint, fmt and budget](app-commands.md) | reviewer | portable | active |
| app | [An app pins its toolchains and commits its lockfiles](app-pins-and-locks.md) | `app-conformance.sh`, in `task lint` | portable | active |
| app | [An app's version is defined in one place](app-version-single-source.md) | `app-conformance.sh`, in `task lint` | portable | active |
| app | [Every app enforces test coverage thresholds that only go up](app-test-coverage.md) | `task coverage`, run by CI | portable | active |
| app | [An app has size budgets that CI or the build command check](app-performance-budgets.md) | `task budget`; `task budget:web` in CI | portable | active |
| app | [An app ships no unused code, dependencies, permissions or template leftovers](app-no-bloat.md) | reviewer | portable | active |
| app | [A desktop app signs users in through the system browser, keeps tokens out of the webview, and fails closed](app-auth.md) | reviewer | portable | active |
| standards | [Standards have two tiers; a repo overrides a kit standard only by decision](standards-tiers.md) | reviewer | portable | active |
| checks | [Checks tolerate existing violations through a baseline and find their targets through a kinds map](checks-baseline-and-kinds.md) | `test-baseline.sh`, in `task test` | portable | active |
| memory | [Memory has checks that run like code checks](memory-checks.md) | `test-memory-check.sh`, in `task test`; `task memory` | portable | active |
| memory | [A large repo keeps a short brief per area, linked from the root repo map](memory-area-briefs.md) | `memory-check.sh` rules `brief-*`, in `task test` and `task memory` | portable | active |
| memory | [Gaps are sorted when found and recorded only with the owner's approval](memory-gap-handling.md) | reviewer | portable | active |
| memory | [Notes have a small fixed format, link with relative markdown links, and live by who owns them](memory-notes.md) | `memory-check.sh` rules `ref-missing`, `note-link-out`, in `task test` and `task memory` | portable | active |
| ci | [Every repo gates pull requests with one required CI job that calls the repo's own commands](ci-pr-gate.md) | reviewer | portable | active |
