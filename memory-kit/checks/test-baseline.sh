#!/usr/bin/env bash
# Tests baseline.sh, kinds.sh and app-conformance.sh against throwaway repos.
#
# Usage: test-baseline.sh
#
# The scripts require bash 3.2 or newer. This runs the whole suite under each of
# /bin/bash (3.2 on macOS) and the bash on PATH, and says so when they are the same or
# when no bash 3.x is present, so a run never claims 3.2 coverage it did not have.
set -uo pipefail
here=$(cd "$(dirname "$0")" && pwd)

if [ -z "${BASH_SUITE_INNER:-}" ]; then
  status=0; seen=""; saw32=0
  for b in /bin/bash "$(command -v bash)"; do
    [ -x "$b" ] || continue
    real=$(cd "$(dirname "$b")" && pwd -P)/$(basename "$b")
    case " $seen " in *" $real "*) continue ;; esac
    seen="$seen $real"
    v=$("$b" -c 'echo "${BASH_VERSION%%(*}"')
    case $v in 3.2*) saw32=1 ;; esac
    echo "== bash $v ($b)"
    PATH="$(dirname "$b"):$PATH" BASH_SUITE_INNER=1 "$b" "$0" || status=1
  done
  [ "$saw32" = 1 ] || echo "NOTE: no bash 3.2 found; the 3.2 minimum was not tested in this run"
  exit $status
fi

work=$(mktemp -d); trap 'rm -rf "$work"' EXIT
export CHECKS_REPO_ROOT=$work
T=$(printf '\t')
fails=0

# expect <name> <expected-exit> <command...>: runs it, compares the exit code.
expect() {
  local name=$1 want=$2; shift 2
  local out got
  out=$("$@" 2>&1 </dev/null); got=$?
  LAST=$out
  if [ "$got" = "$want" ]; then echo "ok    $name"; else
    echo "FAIL  $name: exit $got, wanted $want"; echo "$out" | sed 's/^/      /'; fails=$((fails + 1)); fi
}
contains() { # name needle: LAST output contains needle
  if printf '%s' "$LAST" | grep -qF -- "$2"; then echo "ok    $1"; else
    echo "FAIL  $1: output lacks '$2'"; printf '%s\n' "$LAST" | sed 's/^/      /'; fails=$((fails + 1)); fi
}
# the check's violations are the arguments, one per line, with ~ standing for a tab
feed() { local a; for a in "$@"; do printf '%s\n' "$a" | tr '~' '\t'; done; }
run() { feed "$@" | "$here/baseline.sh" run demo; }
regen() { feed "$@" | "$here/baseline.sh" regenerate ${FORCE:+"$FORCE"} demo; }
put() { local f=$1; shift; mkdir -p "$(dirname "$work/$f")"; feed "$@" > "$work/$f"; }

mkdir -p "$work/checks/baselines" "$work/checks/exceptions"

# --- baseline.sh: comparing
expect "no baseline, no violations passes" 0 run
expect "new violation fails" 1 run "r1~apps/a"
contains "  names the violation" "VIOLATION  r1${T}apps/a"

put checks/baselines/demo "r1~apps/a" "r2~apps/b"
expect "listed violations pass" 0 run "r1~apps/a" "r2~apps/b"
contains "  counts tolerated" "2 tolerated"
expect "new violation beside listed ones fails" 1 run "r1~apps/a" "r2~apps/b" "r3~apps/c"
expect "listed violation that is gone fails" 1 run "r1~apps/a"
contains "  says to remove it" "FIXED      r2${T}apps/b"
expect "key tells violations apart" 1 run "r1~apps/a" "r2~apps/b" "r1~apps/a~k2"

# --- paths with spaces
put checks/baselines/demo "r1~apps/my app"
expect "a path with spaces is one field" 0 run "r1~apps/my app"
expect "  and differs from its prefix" 1 run "r1~apps/my"

# --- malformed lines fail loudly (exit 2), naming file and line
expect "one field in violations" 2 run "r1"
contains "  names the source" "violations line 1"
expect "four fields in violations" 2 run "r1~apps/a~k~extra"
expect "empty field in violations" 2 run "r1~~k"
expect "blank line in violations" 2 run "r1~apps/a" ""
expect "space-separated line in violations" 2 run "r1 apps/a"
put checks/baselines/demo "r1~apps/a" "r2 apps/b"
expect "space-separated line in baseline" 2 run "r1~apps/a"
contains "  names file and line" "checks/baselines/demo line 2"
put checks/baselines/demo "# comment" "r1~apps/a"
expect "comment in baseline" 2 run "r1~apps/a"
put checks/baselines/demo "r2~apps/b" "r1~apps/a"
expect "unsorted baseline" 2 run "r1~apps/a" "r2~apps/b"
put checks/baselines/demo "r1~apps/a" "r1~apps/a"
expect "duplicate baseline lines" 2 run "r1~apps/a"
put checks/baselines/demo "r1~apps/a"

# --- exceptions
put checks/exceptions/demo "r9~apps/z~# upstream pins an old edition"
expect "exception with reason passes" 0 run "r1~apps/a" "r9~apps/z"
contains "  counts excepted" "1 excepted"
expect "exception that no longer occurs does not fail" 0 run "r1~apps/a"
put checks/exceptions/demo "r9~apps/z~k~# keyed exception"
expect "keyed exception matches only its key" 1 run "r1~apps/a" "r9~apps/z"
expect "  and passes with the key" 0 run "r1~apps/a" "r9~apps/z~k"
put checks/exceptions/demo "r9~apps/z"
expect "exception without reason field" 2 run "r1~apps/a"
put checks/exceptions/demo "r9~apps/z~reason"
expect "exception whose last field is not a # reason" 2 run "r1~apps/a"
put checks/exceptions/demo "r9~apps/z~#   "
expect "exception with empty reason" 2 run "r1~apps/a"
contains "  names file and line" "checks/exceptions/demo line 1"
put checks/exceptions/demo "r9~apps/z~# ok" "bad line"
expect "malformed second exception line" 2 run "r1~apps/a"
rm "$work/checks/exceptions/demo"
expect "a violation is not excepted by default" 1 run "r1~apps/a" "r9~apps/z"

# --- regenerate
rm "$work/checks/baselines/demo"
expect "regenerate writes the baseline" 0 regen "r2~apps/b" "r1~apps/a" "r1~apps/a"
expect "  sorted and unique" 0 test "$(cat "$work/checks/baselines/demo")" = "$(printf 'r1\tapps/a\nr2\tapps/b')"
expect "  and run now passes" 0 run "r1~apps/a" "r2~apps/b"
expect "regenerate refuses to overwrite" 2 regen "r1~apps/a"
FORCE=--force expect "regenerate --force overwrites" 0 regen "r1~apps/a"
expect "regenerate rejects malformed input" 2 regen "r1"
expect "unknown mode" 2 "$here/baseline.sh" bogus demo
expect "missing check name" 2 "$here/baseline.sh" run
expect "check name with a slash" 2 "$here/baseline.sh" run a/b

# --- kinds.sh
mkdir -p "$work/apps/a/src-tauri" "$work/apps/b" "$work/apps/my app/src-tauri" "$work/services/x" "$work/services/y"
touch "$work/apps/file"
printf '# the kinds map\n\ndesktop-app\tapps/*\tsrc-tauri\nservice\tservices/*\nspaced\tapps/my app*\n' > "$work/checks/kinds"
expect "marker confirms an instance" 0 "$here/kinds.sh" list desktop-app
contains "  lists the folder with the marker" "apps/a"
contains "  and a folder whose name has a space" "apps/my app"
expect "  not the one without a marker" 1 sh -c "'$here/kinds.sh' list desktop-app | grep -q apps/b"
expect "files are not instances" 1 sh -c "'$here/kinds.sh' list desktop-app | grep -q apps/file"
expect "no marker: every folder matches" 0 test "$("$here/kinds.sh" list service | wc -l | tr -d ' ')" = 2
expect "a glob with a space" 0 test "$("$here/kinds.sh" list spaced)" = "apps/my app"
mkdir "$work/services/z"
expect "a new folder is picked up" 0 test "$("$here/kinds.sh" list service | wc -l | tr -d ' ')" = 3
expect "a kind that matches nothing prints nothing" 0 test -z "$(printf 'empty\tnope/*\n' >> "$work/checks/kinds"; "$here/kinds.sh" list empty)"
expect "unknown kind" 2 "$here/kinds.sh" list nope
for bad in "broken" "kind  apps/*" "kind${T}${T}x" "kind${T}a${T}b${T}c" "${T}apps/*"; do
  printf '%s\n' "$bad" > "$work/checks/kinds"
  expect "malformed kinds line: $(printf '%s' "$bad" | tr '\t' '~')" 2 "$here/kinds.sh" list kind
done
contains "  names file and line" "checks/kinds line 1"
rm "$work/checks/kinds"
expect "missing map" 2 "$here/kinds.sh" list service

# --- app-conformance.sh through the map
rm -rf "$work"; mkdir -p "$work/checks" "$work/apps/a/src-tauri" "$work/apps/my app/src-tauri"
( cd "$work" && git init -q )
printf 'desktop-app\tapps/*\tsrc-tauri\n' > "$work/checks/kinds"
for app in a "my app"; do
  echo '{}' > "$work/apps/$app/package.json"
  printf '[package]\nedition = "2021"\n' > "$work/apps/$app/src-tauri/Cargo.toml"
  echo '{}' > "$work/apps/$app/src-tauri/tauri.conf.json"
done
expect "app-conformance fails on a new app's violations" 1 "$here/app-conformance.sh"
contains "  names the app with a space" "cargo-edition${T}apps/my app"
expect "--list-violations feeds regenerate" 0 sh -c "'$here/app-conformance.sh' --list-violations | '$here/baseline.sh' regenerate app-conformance"
expect "  then the check passes" 0 "$here/app-conformance.sh"
mkdir -p "$work/apps/c/src-tauri"; echo '{}' > "$work/apps/c/package.json"
expect "a new app is covered with no change to the check" 1 "$here/app-conformance.sh"
contains "  and it is the new app" "apps/c"
rm -rf "$work/checks/kinds"
expect "app-conformance fails loudly with no map" 2 "$here/app-conformance.sh"

echo
if [ "$fails" = 0 ]; then echo "all tests passed"; else echo "$fails failed"; exit 1; fi
