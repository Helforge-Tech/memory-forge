---
title: Set up a desktop app (Tauri 2, React, TypeScript)
status: active
updated: 2026-10-15
---

# Set up a desktop app (Tauri 2, React, TypeScript)

Version 1. Written from the first run; not yet proven by a fresh-session re-run (that is the consistency test, which fixes this file wherever two runs differ).

## When to use

A new desktop app is needed in a repo that already has the git workflow and a nix dev shell. The result is a minimal app that shows its version, fetched from the Rust side over IPC, with every quality gate and command in place. An agent does this from this file alone: name the issue and the app's directory.

## Decisions already made (do not reopen)

Each links to its record. Change one only through a new decision.

- Frontend: React 19, TypeScript, Vite, single-page, no UI library yet ([0001](../../docs/decisions/0001-frontend-react-vite.md)).
- Package manager: pnpm, pinned with `packageManager`; lockfile committed ([0002](../../docs/decisions/0002-package-manager-pnpm.md)).
- Commands run through go-task ([0003](../../docs/decisions/0003-task-runner-go-task.md)).
- Toolchains pinned by the nix flake and `rust-toolchain.toml` ([0004](../../docs/decisions/0004-toolchains-nix-flake-rust-toolchain-toml.md)).
- Setup is this playbook, run by the agent; there is no setup command or template ([0020](../../docs/decisions/0020-setup-from-memory-copier-deferred.md)).
- Lint, format, tests, Cargo edition 2024 and the IPC smoke test ([0011](../../docs/decisions/0011-lint-format-test-and-edition.md)).
- CI: Ubuntu code-quality checks only, and the build is local; PRs are gated by one required `gate` job ([ci-pr-gate](../standards/ci-pr-gate.md), [0028](../../docs/decisions/0028-ci-pr-gate.md)). [0021](../../docs/decisions/0021-ci-code-quality-only.md) supersedes the macOS part of [0006](../../docs/decisions/0006-ci-ubuntu-plus-macos-build.md); 0006's rustup-from-`rust-toolchain.toml` rule stands).

## Steps

Work on an issue branch and ship with [git-ship-a-change](git-ship-a-change.md). One PR per issue-sized slice (scaffold, IPC slice, quality gates, commands) keeps each reviewable.

1. **Preflight.** Inside the dev shell, `rustc`, `cargo`, `node`, `pnpm` and `task` must resolve. If any is missing, add it to `flake.nix` and stop ([tooling-declared-in-flake](../standards/tooling-declared-in-flake.md)). Nix only sees git-tracked files: `git add -N` new files before `nix develop`. The first `nix develop` downloads a lot and takes many minutes; later ones are instant.
2. **Pin the toolchains** ([app-pins-and-locks](../standards/app-pins-and-locks.md)). If `rust-toolchain.toml` and the flake's Node already exist, keep them; do not bump versions during setup. If not, take the newest Rust the flake's overlay offers (components `rustfmt`, `clippy`, `rust-src`, `llvm-tools`) and the current Node LTS major. Every other version is read, not chosen: the generator from `pnpm view create-tauri-app version`, pnpm and go-task from the dev shell (`pnpm -v`, `task --version`), and dev dependencies at their latest.
3. **Generate once with a pinned generator.** Look up the current `create-tauri-app` version, then run it in a new, empty scratch directory outside the repo (`mktemp -d`), never inside the repo:

   ```bash
   pnpm dlx create-tauri-app@<version> <name> --template react-ts --manager pnpm --identifier <reverse.domain.app> --yes
   ```

   Copy the result into the app directory, keeping its `.gitignore` files and dropping its `README.md` and `.vscode/`. Write the app's own README: what the app is, the generator version and the exact command, and a pointer to `task --list`. Leave the generated `description` and `authors` in `Cargo.toml` as they are.
4. **Pin the package manager and lock** ([app-pins-and-locks](../standards/app-pins-and-locks.md)). `pnpm pkg set packageManager=pnpm@<version>` (the dev shell's version), and `pnpm install`. The Rust lockfile comes at the end of step 5, once the dependencies have settled. The lockfile checks read git, so run `git add -N` on both lockfiles (and any other new file) before `task lint`. The generator already sets the Cargo edition; the check confirms it.
5. **Build the thin slice.** A Rust command returns the app version; the UI shows it.
   - The version has one source ([app-version-single-source](../standards/app-version-single-source.md)): delete `version` from `tauri.conf.json`. Leave the private `package.json` version alone.
   - Replace the generated `greet` command with `get_version` (`env!("CARGO_PKG_VERSION")`) and a unit test that it equals `CARGO_PKG_VERSION`.
   - Delete everything the demo needed ([app-no-bloat](../standards/app-no-bloat.md)): `src/assets/`, `src/App.css` and its import, the images in `public/`, the favicon link in `index.html` (set its `<title>` to the app name), and the Rust dependencies the app does not use: `serde` and `serde_json` (nothing in the skeleton serialises anything) and the opener plugin, which lets the web view open links. The skeleton does not use it; a later feature that opens links adds it back, with its permission (the `tauri-plugin-opener` dependency, its `.plugin(...)` call, the `@tauri-apps/plugin-opener` package and the `opener:default` capability).
   - The UI shows the app version, fetched with `invoke<string>("get_version")`. Its markup and design are not part of this playbook: they change with what the app is for.
   - Last, run `cargo generate-lockfile` in `src-tauri` so `Cargo.lock` matches the final dependencies, and `git add -N` it.
6. **Add the quality gates** ([app-quality-gates](../standards/app-quality-gates.md)):
   - Biome for TypeScript, installed with an exact version (`--save-exact`). Run `pnpm exec biome init`, set `formatter.indentStyle` to `space` to match the generated code, and leave the rest as generated. Then format the generated sources once (`pnpm exec biome check --write .`): formatting a generated file is expected; what [app-quality-gates](../standards/app-quality-gates.md) forbids is editing code to silence a rule.
   - A type check: `tsc --noEmit`.
   - `rustfmt` and `clippy` with warnings denied.
   - The current test stack ([app-quality-gates](../standards/app-quality-gates.md)): Vitest with jsdom and Testing Library, nothing else. The dev dependencies are `vitest`, `jsdom` and `@testing-library/react`. Put the test settings in their own `vitest.config.ts` (`defineConfig` from `vitest/config`, `environment: "jsdom"`, `restoreMocks: true`) and leave the generated `vite.config.ts` alone. Vitest has no globals: import `describe`, `it`, `expect` and `vi` from `vitest`. Do not add jest-dom or `@types/node` (the latter breaks the generated `@ts-expect-error` in `vite.config.ts`).
   - The IPC smoke test has two parts: the Rust unit test above, and `src/App.test.tsx`, which mocks `@tauri-apps/api/core` so `invoke("get_version")` resolves to `"1.2.3"` (and any other command throws), renders `App`, and expects text containing `1.2.3` to appear.
   - Coverage ([app-test-coverage](../standards/app-test-coverage.md)): add `@vitest/coverage-v8`, set `coverage` in `vitest.config.ts` (V8 provider, `src/**` minus tests, `vite-env.d.ts` and `main.tsx`, reporters `text` and `json-summary`) and add `cargo-llvm-cov` to the flake. Measure first, then set the thresholds to what you measured: `thresholds` in `vitest.config.ts`, and `RUST_MIN_LINES` in the Taskfile. The Rust entry point (`main.rs`) is excluded with `--ignore-filename-regex`. Add `coverage` to the app's own `.gitignore` (Biome reads that file, not the root one).
   - Size budgets ([app-performance-budgets](../standards/app-performance-budgets.md)): after the first release build and a Vite build, measure the release binary and the `dist` folder, set `BUDGET_BINARY_BYTES` and `BUDGET_WEB_BYTES` in the Taskfile to about 20% above, and check them with `memory-kit/checks/size-budget.sh`.
   - `package.json` gets two scripts, the ones the Taskfile calls: `check` (`biome check .`) and `test` (`vitest run`).
7. **Add the commands** ([app-commands](../standards/app-commands.md)): `Taskfile.yaml` at the repo root, with `APP` and `RUST` variables for the app and its `src-tauri` folder. go-task has no per-command working directory, so run each command in its folder with `cd <folder> && <command>` inside a task that has no `dir`, or put `dir` on a task whose commands all share it. Tasks, each with a `desc`:
   - `default`: `task --list`.
   - `install` (internal): `pnpm install --frozen-lockfile` in the app, with `sources` `package.json` and `pnpm-lock.yaml` and `generates` `node_modules/.modules.yaml`. Every task that needs dependencies depends on it.
   - `dev`: `pnpm tauri dev`. `build`: `pnpm tauri build --no-bundle`.
   - `test`: `test:web` (`pnpm test`) then `test:rust` (`cargo test` in the `src-tauri` folder).
   - `coverage`: `pnpm exec vitest run --coverage`, then `cargo llvm-cov --ignore-filename-regex 'main\.rs' --fail-under-lines {{.RUST_MIN_LINES}}` in the `src-tauri` folder.
   - `lint`: `pnpm check`, `pnpm exec tsc --noEmit`, `cargo fmt --check`, `cargo clippy --all-targets -- -D warnings`, then `memory-kit/checks/app-conformance.sh`.
   - `secrets`: `gitleaks git --no-banner --redact --log-opts="${GATE_BASE:-origin/main}..HEAD"`; fails in CI when the range is empty ([ci-pr-gate](../standards/ci-pr-gate.md) rule 4). The dev shell has `gitleaks`; CI's setup action installs it.
   - `fmt`: `pnpm exec biome check --write .` and `cargo fmt`.
   - `budget`: `budget:web` (a Vite build, then `size-budget.sh` on `dist`) and `budget:binary` (`task build`, then `size-budget.sh` on the release binary).
   - Add `.task/` (go-task's cache) to the root `.gitignore`. In `AGENTS.md`, list the commands (replacing any "none yet" line) and update the app's row in the repo map. Add the app to `checks/kinds` (`desktop-app  <app>  src-tauri`, or confirm an existing glob matches it); the conformance check finds its apps there. Do not create a baseline: a new app has no violations to tolerate.
8. **Run every check, then run the app.**
   - `task lint`, `task test`, `task coverage`, `task budget` and `task build` pass. The build and the binary budget are run here and not in CI.
   - `task dev` opens a window that shows the version. The window is the one check an agent cannot see; ask the owner to confirm it, once, and say that is what is being asked.
9. **CI** (`.github/workflows/ci.yaml`, decisions 0006, 0021 and 0028). Triggers: `pull_request`, `push` to `main`, and `workflow_dispatch`; `permissions: contents: read`; one concurrency group per ref with `cancel-in-progress`.
   - **Two jobs on Ubuntu, in parallel**, so a failure names the check and a large codebase does not queue lint behind tests: `lint` runs `task lint`; `test` runs `task coverage` (which runs every test, so `task test` is not repeated).
   - **A third job, `gate`, is the only required check** ([ci-pr-gate](../standards/ci-pr-gate.md)). It `needs` `lint` and `test`, runs `if: always()` and fails unless both results are `success`. `GATE_BASE` is set as in the standard, and the `lint` job checks out with `fetch-depth: 0` and runs `task secrets` (step 7).
   - **Shared setup lives in one composite action** (`.github/actions/setup/action.yaml`) that both jobs call after checkout, so they cannot drift. It installs, in order: the Tauri system libraries (`build-essential pkg-config libwebkit2gtk-4.1-dev libxdo-dev libssl-dev libayatana-appindicator3-dev librsvg2-dev`); Rust via `rustup show active-toolchain || rustup toolchain install` (reads `rust-toolchain.toml`); a Rust cache for the `src-tauri` workspace, with a per-job `key` input so the instrumented coverage build and the lint build keep separate caches; pnpm (version read from the app's `package.json` through `package_json_file`); Node 24 with the pnpm cache keyed on the app's lockfile; go-task, pinned to the version in the dev shell (`task --version`).
   - Each job adds only what it alone needs: the `test` job installs `cargo-llvm-cov` through the install action. The `lint` job also runs `task budget:web` after `task lint`.
   - **No build job.** The full build is local (`task build`); CI is kept for code-quality checks, because hosted minutes are limited and macOS minutes count ten times ([0021](../../docs/decisions/0021-ci-code-quality-only.md)).
   - **CI does not use the nix shell** (decision 0004), so the Node major and tool versions appear in the workflow as well as the flake; keep them equal.
   - **Pin every action by commit SHA**, with the tag in a comment. Look up the latest release and resolve its SHA with `gh api repos/<owner>/<repo>/git/ref/tags/<tag>` (follow the tag object if its type is `tag`).
   - The workflow cannot be tested locally: the first run is the PR that adds it. Ship it alone and read the result with `gh pr checks`, and record the job time in the PR.
10. **Hand off.** Ship through the git playbook and report what was not verified.

## Gotchas hit

Domain facts from the first run are written up as knowledge notes (desktop apps, nix). What stays here is specific to this procedure:

- A repo-level `task setup` was built and removed: setup belongs in this playbook, and what it did (install dependencies, enable git hooks) is automatic ([0020](../../docs/decisions/0020-setup-from-memory-copier-deferred.md)).
- The generator names `package.json` and the Cargo package after the name you pass it; leave them equal.
- The conformance check reads git, so new files (lockfiles included) need `git add -N` before `task lint` sees them.

## Standards used

- [app-quality-gates.md](../standards/app-quality-gates.md)
- [app-commands.md](../standards/app-commands.md)
- [app-pins-and-locks.md](../standards/app-pins-and-locks.md)
- [app-version-single-source.md](../standards/app-version-single-source.md)
- [app-no-bloat.md](../standards/app-no-bloat.md)
- [app-test-coverage.md](../standards/app-test-coverage.md)
- [app-performance-budgets.md](../standards/app-performance-budgets.md)
- [tooling-declared-in-flake.md](../standards/tooling-declared-in-flake.md)
- [git-issues.md](../standards/git-issues.md), [git-branches-and-prs.md](../standards/git-branches-and-prs.md), [git-commits.md](../standards/git-commits.md) (through the git playbook)

## Done when

- `task lint`, `task test`, `task coverage`, `task budget` and `task build` pass in the dev shell; CI runs lint, coverage and the frontend bundle budget.
- `task dev` shows the app version, read from the Rust side.
- Every check in the standards above passes; the generator version is recorded in the app's README.
- The commands are listed in `AGENTS.md`.
- Each deviation from this file is written down for the next run.
- Standards touched and knowledge added are listed in the PR.

## Reference output

The first app built from this file, in the directory the repo's `AGENTS.md` repo map names for the desktop app. A fresh-session run is compared against it by diff; every difference is fixed here or in a standard. Two runs are the same when they have the same file set, the same dependencies and settings, and all checks pass. The UI's markup is not compared; its behaviour (it shows the version) is, through the tests. Differences the tools normalise or that carry no behaviour are accepted: comments, test names, README wording, task layout in the Taskfile, and the order of keys.
