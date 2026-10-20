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

mk; agents '' "$(printf '```\n[x](nope.md)\n```')"
clean "a link inside a code fence is skipped"

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

[ "$fails" = 0 ] && echo "all memory-check tests passed" || echo "$fails failed"
exit $((fails > 0))
