# 0025: Checks share one baseline mechanism and a kinds map, kept in a root `checks/` folder

- Status: accepted
- Date: 2026-10-19
- Scope: how checks tolerate existing violations, how they find their targets, where that data lives, how it is classified for the code/memory PR split ([#11](https://github.com/Helforge-Tech/memory-forge/issues/11))

## Context
The design requires every check to support a baseline ([MEMORY-ARCHITECTURE](../planning/MEMORY-ARCHITECTURE.md) section 5a): an existing repo fails almost any new check on day one, and a check that fails on day one gets switched off. One check, `app-conformance.sh`, had its own ad hoc baseline (bare rule ids, one app per path argument). A monorepo also has many instances of each kind of thing, and without a shared map every check hardcodes its own list of paths and the lists drift. (Issue #5.)

## Decision
- **One format, tab-separated.** Fields are separated by single tabs, may contain spaces (paths can), and are never empty. A baseline line is `rule<TAB>path[<TAB>key]`, sorted with `LC_ALL=C`, unique, committed, no comments (it is generated).
- **A runner in bash**, `memory-kit/checks/baseline.sh`. The scripts require **bash 3.2 or newer** (macOS ships 3.2, so no newer bash is assumed). `memory-kit/checks/test-baseline.sh` runs the whole suite under `/bin/bash` and the bash on `PATH`, and prints a note when no 3.2 is present, so a run never claims 3.2 coverage it lacked.
- **A check prints its violations** as `rule<TAB>path[<TAB>key]` lines; the runner compares them to the baseline. A new violation fails; a listed one passes; a listed one that no longer occurs fails until removed, so the count only goes down.
- **Malformed lines fail loudly.** In violations, baselines, exceptions and the kinds map, a line with the wrong number of fields, an empty field, or spaces where tabs belong exits 2 and names the file and line. A baseline that is unsorted or has duplicates, and an exception without a reason, do the same. A missing or malformed kinds map stops the check; it never reads as "no violations".
- **Permanent exceptions** are a separate file with a mandatory reason: the violation's fields plus a final `# reason` field (`rule<TAB>path[<TAB>key]<TAB># reason`). They never count down and are not part of the baseline.
- **Regenerating the baseline** is `baseline.sh regenerate <check>`, used only when a check is introduced. It refuses if the baseline already exists, unless `--force`.
- **A kinds map**, `checks/kinds`: one line per kind, `kind<TAB>glob[<TAB>marker]`. A line starting with `#`, and a blank line, are ignored (no inline comments, since a path may contain `#`). An instance is a directory the glob matches that contains the marker, if one is given. `memory-kit/checks/kinds.sh list <kind>` prints the instances. A check declares one kind and runs once per instance, so a new matching folder is covered automatically.
- **Where it lives.** A visible `checks/` folder at the repo root: `checks/kinds`, `checks/baselines/<check>`, `checks/exceptions/<check>`. The scripts stay in `memory-kit/checks/`.
- **Classification for the PR split (#11): these files are check data and count as code, not memory.** Root `checks/` decides whether code passes CI, changes with code (a new service adds a kinds line, a fix removes a baseline line), and ships in the same PR as the code it describes. `memory-kit/checks/` (the scripts) is memory. #11's path lists must put root `checks/` on the code side.

## Alternatives
- **`.memory/` folder.** Reads as memory, hides the data, and would put baseline fixes in the memory PR, away from the code fix that earns them.
- **YAML kinds map.** Easier to read, but shell needs `yq` in the flake or a fragile parse.
- **Whitespace-separated fields.** Editor-friendly, but rules out paths with spaces. (First proposed in this issue, then replaced by tabs.)
- **Each check keeps its own baseline logic.** Drifts, and gives no single place to see what is tolerated.
- **A binary runner (Python or Rust).** Easier to test, but adds a toolchain to every adopting repo.
- **Requiring a newer bash from the flake.** Simpler code, but breaks bare macOS runs and CI images without the flake.

## Dissent
Tabs are easy to lose in an editor or a code review. Accepted: the runner rejects space-separated lines with the file and line, so a lost tab fails the check and never passes silently. Bash is awkward for edge cases; the cost is limited by the strict validation and the test suite.

## Consequences
- `app-conformance.sh` moves onto the runner and the map; its old `.conformance-baseline` format goes away, and the two playbooks that mention it change.
- Verifying the map against the workspace is the memory-checks issue; writing a repo's first map is the adopt playbook issue.
- Revisit if a check needs structured keys, or if paths with spaces become common.
