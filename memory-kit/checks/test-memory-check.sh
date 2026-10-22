#!/usr/bin/env bash
# Tests memory-check.sh against throwaway git repos: a clean repo passes, and each rule
# fires on the thing it is for.
#
# Usage: test-memory-check.sh
set -uo pipefail
here=$(cd "$(dirname "$0")" && pwd)
fails=0
work=$(mktemp -d); trap 'rm -rf "$work"' EXIT

agents() { # agents <extra repo-map row> <extra body line>
  printf '# x\n\n## Repo map\n\n| Path | What |\n|---|---|\n| `docs/` | d |\n| `memory-kit/` | k |\n%s\n\n## Commands\n\n`task test` runs the tests.\n%s\n' "${1:-}" "${2:-}" > AGENTS.md
}

mk() { # builds a clean repo in $work/r and leaves the shell in it
  rm -rf "$work/r"; mkdir -p "$work/r"; cd "$work/r" || exit 1
  git init -q . && git config user.email t@t && git config user.name t
  mkdir -p docs/decisions memory-kit/standards memory-kit/playbooks
  agents
  printf 'version: "3"\ntasks:\n  test:\n    cmds:\n      - true\n' > Taskfile.yaml
  printf -- '---\nstatus: active\n---\n# s\n' > memory-kit/standards/a.md
  printf '| Kind | Standard | Status |\n|---|---|---|\n| x | [A](a.md) | active |\n' > memory-kit/standards/INDEX.md
  printf '| P | Status |\n|---|---|\n' > memory-kit/playbooks/INDEX.md
  printf '# 1\n\n- Status: accepted\n- Date: d\n\nbody\n' > docs/decisions/0001-x.md
  git add -A && git commit -qm init
  git branch -q base
}
run() { MEMORY_CHECK_BASE=base CHECKS_REPO_ROOT="$work/r" "$here/memory-check.sh" 2>&1; }
want() { # want <name> <violation, tabs written as ~>
  local out line
  out=$(run); line=$(printf '%s' "$2" | tr '~' '\t')
  if printf '%s\n' "$out" | grep -qxF -- "$line"; then echo "ok    $1"; else
    echo "FAIL  $1: lacks '$2'"; printf '%s\n' "$out" | sed 's/^/      /'; fails=$((fails + 1)); fi
}
clean() { # clean <name>
  local out; out=$(run)
  if [ -z "$out" ]; then echo "ok    $1"; else
    echo "FAIL  $1: expected no output"; printf '%s\n' "$out" | sed 's/^/      /'; fails=$((fails + 1)); fi
}

mk; clean "a clean repo has no violations"

mk; agents '| `gone/` | g |'
want "repo map: a listed path that does not exist" "repo-map-missing~AGENTS.md~gone/"

mk; mkdir other; echo x > other/f; git add other
want "repo map: a tracked top-level folder that is not listed" "repo-map-unlisted~other"

mk; agents '' 'See [x](nope.md).'
want "link to a missing path" "ref-missing~AGENTS.md~nope.md"

mk; agents '' 'See [x](docs/old/f.md#top).'; mkdir docs/old; echo x > docs/old/f.md; echo old > docs/old/ARCHIVED.md
want "link into an archived folder" "ref-archived~AGENTS.md~docs/old/f.md#top"

mk; agents '' 'See [x](docs/old/) and [y](docs/old).'; mkdir docs/old; echo old > docs/old/ARCHIVED.md
want "link to an archived folder itself" "ref-archived~AGENTS.md~docs/old/"

mk; agents '' 'See [a](docs/f.md "Title"), [b](docs/my%20dir/f.md), [c](<docs/my dir/f.md>) and `[d](nope.md)`.'
mkdir "docs/my dir"; echo x > docs/f.md; echo x > "docs/my dir/f.md"
clean "titled, encoded and wrapped links resolve; links in inline code are skipped"

mk; echo x > "docs/decisions/0002 y.md"; git add -A; git commit -qm two; git branch -f base
clean "a decision file name with a space is not split"

mk; agents '' "$(printf '```\n[x](nope.md)\n```')"
clean "a link inside a code fence is skipped"

mk; agents '' "$(printf '  ~~~\n  [x](nope.md)\n  ~~~')"
clean "a link inside an indented tilde fence is skipped"

mk; mv Taskfile.yaml Taskfile.yml
clean "a Taskfile.yml is read like Taskfile.yaml"

mk; printf 'version: "3"\ntasks:\n    test:\n        cmds:\n            - true\n' > Taskfile.yaml
clean "a 4-space Taskfile"
out=$(MEMORY_TASK_BIN=none-such MEMORY_CHECK_BASE=base CHECKS_REPO_ROOT="$work/r" "$here/memory-check.sh" 2>&1)
if [ -z "$out" ]; then echo "ok    a 4-space Taskfile, parsed without task"; else
  echo "FAIL  a 4-space Taskfile, parsed without task"; printf '%s\n' "$out" | sed 's/^/      /'; fails=$((fails + 1)); fi

mk; printf 'version: "3"\ntasks:\n  other:\n    cmds:\n      - true\n' > Taskfile.yml
want "both Taskfile names: the .yml one wins, as task itself does" "command-missing~AGENTS.md~task test"

if command -v task >/dev/null 2>&1; then
  mk; agents '' 'Run `task t`.'
  printf 'version: "3"\ntasks:\n  test:\n    aliases: [t]\n    cmds:\n      - true\n' > Taskfile.yaml
  clean "a task alias"

  mk; agents '' 'Run `task docs:build`.'; mkdir docs/sub
  printf 'version: "3"\ntasks:\n  build:\n    cmds:\n      - true\n' > docs/sub/Taskfile.yml
  printf 'version: "3"\nincludes:\n  docs:\n    taskfile: ./docs/sub/Taskfile.yml\ntasks:\n  test:\n    cmds:\n      - true\n' > Taskfile.yaml
  clean "a namespaced task from an include"
else
  echo "NOTE: no task binary; the include case was not tested"
fi

mk; echo x > docs/decisions/0001-y.md
want "two decisions with one number" "decision-number-duplicate~docs/decisions~0001"

mk; git branch -D base -q
out=$(CI=true MEMORY_CHECK_BASE=base CHECKS_REPO_ROOT="$work/r" "$here/memory-check.sh" 2>&1)
if printf '%s\n' "$out" | grep -q '^decision-base-missing'; then echo "ok    missing base fails under CI"; else
  echo "FAIL  missing base fails under CI"; printf '%s\n' "$out" | sed 's/^/      /'; fails=$((fails + 1)); fi
out=$(env -u CI -u MEMORY_REQUIRE_BASE MEMORY_CHECK_BASE=base CHECKS_REPO_ROOT="$work/r" "$here/memory-check.sh" 2>/dev/null)
if [ -z "$out" ]; then echo "ok    missing base skips outside CI"; else
  echo "FAIL  missing base skips outside CI"; fails=$((fails + 1)); fi

mk; agents '' 'Run `task nope`.'
want "command that the task runner lacks" "command-missing~AGENTS.md~task nope"

mk
out=$(MEMORY_ROOT_BUDGET=10 MEMORY_CHECK_BASE=base CHECKS_REPO_ROOT="$work/r" "$here/memory-check.sh" 2>&1)
if printf '%s\n' "$out" | grep -q '^root-size'; then echo "ok    root guidance over its budget"; else
  echo "FAIL  root guidance over its budget"; fails=$((fails + 1)); fi

mk; printf -- '---\nstatus: proposed\n---\n# s\n' > memory-kit/standards/a.md
want "index row status differs from the item" "index-status~memory-kit/standards/INDEX.md~a.md"

mk; printf -- '---\nstatus: active\n---\n' > memory-kit/standards/b.md
want "kit item with no index row" "index-row-missing~memory-kit/standards/INDEX.md~b.md"

mk; mkdir checks; printf 'app\tapps/*\n' > checks/kinds
want "kind with no instance" "kinds-map-invalid~checks/kinds~app"

mk; printf '# 1\n\n- Status: accepted\n- Date: d\n\nchanged\n' > docs/decisions/0001-x.md
want "decision body edited" "decision-edited~docs/decisions/0001-x.md"

mk; rm docs/decisions/0001-x.md
want "decision deleted" "decision-edited~docs/decisions/0001-x.md~deleted"

mk; printf '# 1\n\n- Status: superseded by 0002\n- Date: d\n\nbody\n' > docs/decisions/0001-x.md
clean "a decision's status line may change"

brief() { # brief <folder> <body>: a tracked brief in <folder>
  mkdir -p "$1/src"; printf '# b\n\n## Code\n\n%s\n' "$2" > "$1/AGENTS.md"; git add -A
}

mk; mkdir web; brief web '- `src/` the code'; agents '| `web/` | [brief](web/AGENTS.md) |'
clean "a linked brief with existing paths and a small size"

mk; brief web '- `src/` the code'; agents '| `web/` | w |'
want "brief not linked from the repo map" "brief-unlinked~web/AGENTS.md"

mk; brief web '- `src/` the code
- `gone/` missing'; agents '| `web/` | [brief](web/AGENTS.md) |'
want "brief path that does not exist" "brief-path-missing~web/AGENTS.md~gone/"

mk; brief web '- `src/` the code'; agents '| `web/` | [brief](web/AGENTS.md) |'
out=$(MEMORY_BRIEF_BUDGET=10 MEMORY_CHECK_BASE=base CHECKS_REPO_ROOT="$work/r" "$here/memory-check.sh" 2>&1)
if printf '%s\n' "$out" | grep -qxF "$(printf 'brief-size\tweb/AGENTS.md')"; then echo "ok    brief over its budget"; else
  echo "FAIL  brief over its budget"; fails=$((fails + 1)); fi

mk; brief web '- `src/` the code
See [x](nope.md).'; agents '| `web/` | [brief](web/AGENTS.md) |'
want "link in a brief to a missing path" "ref-missing~web/AGENTS.md~nope.md"

mk; brief "my app" '- `src/` the code
See [x](nope.md).'; agents '| `my app/` | [brief](<my app/AGENTS.md#top>) |'
want "brief in a folder with a space: linked with a wrapped link and an anchor, and its links checked" "ref-missing~my app/AGENTS.md~nope.md"
out=$(run); if printf '%s\n' "$out" | grep -q '^brief-unlinked'; then echo "FAIL  wrapped link with an anchor counts as linked"; fails=$((fails + 1)); else echo "ok    wrapped link with an anchor counts as linked"; fi

mk; brief web '- `src/` the code'; printf '\n## Code owners\n\n- `alice`\n' >> web/AGENTS.md; git add -A; agents '| `web/` | [brief](./web/AGENTS.md) |'
clean "a Code owners heading is not the Code section"

mk; mkdir -p knowledge/domains/a; printf '# n\n\nSee [x](nope.md).\n' > knowledge/domains/a/n.md; git add knowledge
want "link in a note to a missing path" "ref-missing~knowledge/domains/a/n.md~nope.md"

mk; mkdir -p knowledge/domains/a; printf '# n\n\nSee [x](../../../AGENTS.md).\n' > knowledge/domains/a/n.md; git add knowledge
want "link in a note to a project file" "note-link-out~knowledge/domains/a/n.md~../../../AGENTS.md"

mk; mkdir -p knowledge/domains/a; printf '# n\n\nSee [x](m.md).\n' > knowledge/domains/a/n.md; echo m > knowledge/domains/a/m.md; git add knowledge; agents '| `knowledge/` | n |'
clean "a note linking to another note in the vault is clean"

[ "$fails" = 0 ] && echo "all memory-check tests passed" || echo "$fails failed"
exit $((fails > 0))
