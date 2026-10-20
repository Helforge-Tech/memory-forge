#!/usr/bin/env bash
# Checks a desktop app against the app-pins-and-locks, app-version-single-source and
# app-performance-budgets (release profile) standards.
#
# Usage: app-conformance.sh <app-dir> [baseline-file]
#
# Prints one line per rule: ok, violation, tolerated or fixed. Exits 1 if there is a
# violation that is not in the baseline, or a baseline entry that no longer violates
# (remove it, so the count only goes down). A baseline file lists rule ids, one per line;
# `#` starts a comment. Run with --list-violations to print current violating ids, which
# is how a baseline is first written for an existing app.
set -euo pipefail

list_only=0
if [ "${1:-}" = "--list-violations" ]; then list_only=1; shift; fi
app=${1:?usage: app-conformance.sh [--list-violations] <app-dir> [baseline-file]}
baseline=${2:-}
root=$(git -C "$app" rev-parse --show-toplevel)
app=$(cd "$app" && pwd)
tauri="$app/src-tauri"

violations=()
check() { # id, description, command that succeeds when the rule holds
  if ! (eval "$3") >/dev/null 2>&1; then violations+=("$1"); fi
  rules+=("$1|$2")
}
# True when [profile.release] in the given Cargo.toml sets the size and speed options.
release_profile_ok() {
  local section
  section=$(awk '/^\[profile.release\]/{f=1;next} /^\[/{f=0} f' "$1")
  echo "$section" | grep -Eq '^lto *= *true' \
    && echo "$section" | grep -Eq '^codegen-units *= *1' \
    && echo "$section" | grep -Eq '^panic *= *"abort"' \
    && echo "$section" | grep -Eq '^strip *= *true'
}
tracked() { git -C "$root" ls-files --error-unmatch "$1" >/dev/null 2>&1; }

rules=()
check rust-pinned "rust-toolchain.toml pins an exact version" \
  "grep -Eq '^channel *= *\"[0-9]+\.[0-9]+\.[0-9]+\"' '$root/rust-toolchain.toml'"
check package-manager-pinned "package.json sets packageManager" \
  "grep -q '\"packageManager\"' '$app/package.json'"
check lockfile-js "the JavaScript lockfile is committed" \
  "tracked '${app#"$root"/}/pnpm-lock.yaml'"
check lockfile-rust "Cargo.lock is committed" \
  "tracked '${tauri#"$root"/}/Cargo.lock'"
check cargo-edition "Cargo edition is 2024" \
  "grep -Eq '^edition *= *\"2024\"' '$tauri/Cargo.toml'"
check release-profile "Cargo release profile has lto, one codegen unit, panic abort and strip" \
  "release_profile_ok '$tauri/Cargo.toml'"
check version-single-source "tauri.conf.json has no version of its own" \
  "! grep -Eq '^  \"version\"' '$tauri/tauri.conf.json'"

if [ "$list_only" = 1 ]; then
  printf '%s\n' "${violations[@]:-}" | sed '/^$/d'
  exit 0
fi

tolerated=()
if [ -n "$baseline" ] && [ -f "$baseline" ]; then
  while IFS= read -r line; do
    line=${line%%#*}; line=$(echo "$line" | tr -d '[:space:]')
    [ -n "$line" ] && tolerated+=("$line")
  done < "$baseline"
fi

in_list() { local x=$1; shift; for y in "$@"; do [ "$x" = "$y" ] && return 0; done; return 1; }

status=0
for r in "${rules[@]}"; do
  id=${r%%|*}; desc=${r#*|}
  if in_list "$id" "${violations[@]:-}"; then
    if in_list "$id" "${tolerated[@]:-}"; then
      echo "tolerated  $id: $desc"
    else
      echo "VIOLATION  $id: $desc"; status=1
    fi
  else
    if in_list "$id" "${tolerated[@]:-}"; then
      echo "FIXED      $id: now passes, remove it from the baseline"; status=1
    else
      echo "ok         $id"
    fi
  fi
done
exit $status
