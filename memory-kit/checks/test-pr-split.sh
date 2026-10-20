#!/usr/bin/env bash
# Tests pr-split.sh against throwaway git repos: a one-sided change passes, a mixed one
# fails, and the exemption, the per-repo setting and the error cases behave as written.
#
# Usage: test-pr-split.sh
set -uo pipefail
here=$(cd "$(dirname "$0")" && pwd)
fails=0
work=$(mktemp -d); trap 'rm -rf "$work"' EXIT

mk() { # builds a repo in $work/r with a base branch, and leaves the shell on a change branch
  rm -rf "$work/r"; mkdir -p "$work/r"; cd "$work/r" || exit 1
  git init -q . && git config user.email t@t && git config user.name t
  mkdir -p memory-kit/checks docs checks src
  echo a > memory-kit/checks/c.sh; echo a > docs/d.md; echo a > src/s.rs; echo a > AGENTS.md
  git add -A && git commit -qm init
  git branch -q base
  git switch -q -c change
}
commit() { git add -A && git commit -qm change; }
run() { GATE_BASE=base CHECKS_REPO_ROOT="$work/r" "$here/pr-split.sh" 2>&1; echo "exit=$?"; }
want() { # want <name> <expected output, tabs written as ~, lines joined by |>
  local out exp
  out=$(run | tr '\t' '~' | paste -sd'|' -); exp=$2
  if [ "$out" = "$exp" ]; then echo "ok    $1"; else
    echo "FAIL  $1"; echo "      want: $exp"; echo "      got:  $out"; fails=$((fails + 1)); fi
}

mk; echo b > src/s.rs; commit
want "code only passes" "exit=0"

mk; echo b > docs/d.md; echo b > AGENTS.md; commit
want "memory only passes" "exit=0"

mk; echo b > src/s.rs; echo b > docs/d.md; commit
want "a mixed change fails, one line per file" "mixed-pr~docs/d.md~memory|mixed-pr~src/s.rs~code|exit=0"

mk; echo b > memory-kit/checks/c.sh; echo b > checks/baseline; commit
want "a check script with root checks/ data is exempt" "exit=0"

mk; echo b > memory-kit/checks/c.sh; echo b > checks/baseline; echo b > src/s.rs; commit
want "the exemption does not cover other code" "mixed-pr~memory-kit/checks/c.sh~memory|mixed-pr~checks/baseline~code|mixed-pr~src/s.rs~code|exit=0"

mk; echo b > memory-kit/checks/c.sh; mkdir src/many; i=0; while [ $i -lt 3000 ]; do echo $i > src/many/f$i; i=$((i + 1)); done; commit
out=$(run | grep -c '^mixed-pr')
if [ "$out" = 3001 ]; then echo "ok    a large change is not exempted by a closed pipe"; else echo "FAIL  large change: $out violations, want 3001"; fails=$((fails + 1)); fi

mk; echo b > docs/d.md; echo b > checks/baseline; commit
want "root checks/ data with a non-script memory file is mixed" "mixed-pr~docs/d.md~memory|mixed-pr~checks/baseline~code|exit=0"

mk; git rm -q docs/d.md; echo b > src/s.rs; commit
want "a deleted memory file counts" "mixed-pr~docs/d.md~memory|mixed-pr~src/s.rs~code|exit=0"

mk; mkdir "docs/my dir"; echo b > "docs/my dir/f.md"; echo b > src/s.rs; commit
want "a path with a space" "mixed-pr~docs/my dir/f.md~memory|mixed-pr~src/s.rs~code|exit=0"

mk; printf 'memory\tsrc/\ncode\tsrc/gen/\n' > checks/split; git add -A; git commit -qm setting; git branch -qf base
mkdir -p src/gen; echo b > src/s.rs; echo b > src/gen/g.rs; commit
want "a repo setting replaces the defaults; the longest entry wins" "mixed-pr~src/s.rs~memory|mixed-pr~src/gen/g.rs~code|exit=0"

mk; printf 'memory\tsrc/\n' > checks/split; git add -A; git commit -qm setting; git branch -qf base
echo b > docs/d.md; commit
want "with a setting, a default memory path is code unless listed" "exit=0"

mk; printf 'memory\tchecks/\n' > checks/split; commit
want "root checks/ cannot be memory" "pr-split: checks/split line 1: root checks/ is code (decision 0025) and cannot be memory|exit=2"

mk; printf 'memory src/\n' > checks/split; commit
want "spaces instead of a tab" "pr-split: checks/split line 1: expected 'side<TAB>path' with no empty field, got: memory src/|exit=2"

mk; printf 'both\tsrc/\n' > checks/split; commit
want "an unknown side" "pr-split: checks/split line 1: side must be memory or code, got: both|exit=2"

mk; echo b > src/s.rs; commit
out=$(GATE_BASE=nope CHECKS_REPO_ROOT="$work/r" "$here/pr-split.sh" 2>&1; echo "exit=$?")
case $out in *"does not resolve"*"exit=2") echo "ok    a base that does not resolve" ;; *) echo "FAIL  unresolved base: $out"; fails=$((fails + 1)) ;; esac

[ "$fails" = 0 ] && echo "all pr-split tests passed" || echo "$fails failed"
exit $((fails > 0))
