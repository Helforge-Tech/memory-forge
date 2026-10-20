---
title: Checks tolerate existing violations through a baseline and find their targets through a kinds map
kind: checks
scope: portable
status: active
updated: 2026-10-19
decision: ../../docs/decisions/0025-check-baselines-and-kinds-map.md
check: memory-kit/checks/test-baseline.sh, run by task test
---

# Checks tolerate existing violations through a baseline and find their targets through a kinds map

## Rule

1. **Every check supports a baseline.** The check prints one violation per line as `rule<TAB>path[<TAB>key]`; `memory-kit/checks/baseline.sh run <check>` compares them to `checks/baselines/<check>`. A new violation fails. A listed one passes. A listed one that no longer occurs fails until it is removed, so the count only goes down.
2. **Format.** Fields are separated by single tabs, may contain spaces, and are never empty. `rule` is the rule id, `path` is the instance or file, `key` is optional and tells apart several violations of one rule in one path. A baseline is sorted (`LC_ALL=C`), unique, committed and has no comments.
3. **Malformed lines fail loudly.** A wrong field count, an empty field, spaces where tabs belong, an unsorted baseline or an exception with no reason exits 2 and names the file and line, in every file below.
4. **Permanent exceptions** are in `checks/exceptions/<check>`: the violation's fields plus a final `# reason` field. The reason is required. They are never counted down and never go in the baseline.
5. **Regenerate** with `baseline.sh regenerate <check>`, only when introducing a check. It leaves out anything listed in `checks/exceptions/<check>`, and refuses if a baseline exists, unless `--force`. Commit the result in its own commit, with the count in the message.
6. **A kinds map** is `checks/kinds`: one line per kind, `kind<TAB>glob[<TAB>marker]`. Blank lines and lines starting with `#` are ignored; there are no inline comments. An instance is a directory that the glob matches and, if a marker is given, that contains it. `memory-kit/checks/kinds.sh list <kind>` prints the instances. A missing or malformed map, an unknown kind, or a kind with no instances stops the check (exit 2): a lost tab between glob and marker would otherwise match nothing and pass silently. A repo with no instance of a kind simply doesn't run that kind's check.
7. **A check declares one kind** and runs once per instance, with the instance path as the `path` of its violations. A new matching folder is covered with no change to the check.
8. **The scripts need bash 3.2 or newer** (macOS `/bin/bash`), so a check script uses no bash 4 features (`mapfile`, associative arrays, `${var,,}`) and no readline builtins such as `compgen` (the nix dev shell's bash lacks it). `memory-kit/checks/test-baseline.sh` runs under `/bin/bash` and the bash on `PATH`; run it with `task test` and with `nix develop -c task test`.
9. **A check script and its baseline ship together.** A baseline entry exists only because of the script version that produced it, so changing a check's rules and its baseline go in one PR.
10. **Root `checks/` is check data and counts as code, not memory.** It ships in the same PR as the code it describes. The scripts in `memory-kit/checks/` are memory, and a script ships with its baseline in one PR even so ([git-split-code-and-memory](git-split-code-and-memory.md) rule 6; [0025](../../docs/decisions/0025-check-baselines-and-kinds-map.md)).

## Why

- A check that fails on day one gets switched off.
- One format and one runner mean a baseline looks the same for every check, and the count can only go down.
- Per-check lists of paths drift; one map does not.

## Do / Don't

Do, in `checks/kinds` (fields are tabs; shown here as `→`):

```
desktop-app→apps/*→src-tauri
```

in `checks/baselines/app-conformance`:

```
lockfile-rust→apps/legacy
release-profile→apps/legacy
```

and in `checks/exceptions/app-conformance`:

```
cargo-edition→apps/vendor fork→# upstream pins 2021; revisit when it moves
```

Don't: a bare rule id in a baseline, a baseline entry with no path, spaces instead of tabs, a permanent exception without a reason, or a check with its own hardcoded list of app folders.

## Applied in

`memory-kit/checks/app-conformance.sh` (the desktop-app kind). No `checks/` folder exists in this repo yet.
