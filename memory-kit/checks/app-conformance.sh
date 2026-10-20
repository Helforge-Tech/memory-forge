#!/usr/bin/env bash
# Checks every desktop app against the app-pins-and-locks, app-version-single-source and
# app-performance-budgets (release profile) standards.
#
# Usage: app-conformance.sh [--list-violations]
#
# Requires bash 3.2 or newer; tested under 3.2 and a current bash.
#
# The apps are the instances of the `desktop-app` kind in checks/kinds
# (standard checks-baseline-and-kinds). Violations are `rule<TAB>path` lines compared to
# checks/baselines/app-conformance by baseline.sh: a new violation fails, a listed one
# passes, a listed one that now passes fails until removed. A one-line description of
# each violated rule goes to stderr. With --list-violations the violations are printed
# and nothing is compared; pipe them to `baseline.sh regenerate app-conformance` to write
# the first baseline for an existing repo.
set -euo pipefail
export LC_ALL=C

here=$(cd "$(dirname "$0")" && pwd)
list_only=0
if [ "${1:-}" = "--list-violations" ]; then list_only=1; shift; fi
[ $# -eq 0 ] || { echo "usage: app-conformance.sh [--list-violations]" >&2; exit 2; }
root=${CHECKS_REPO_ROOT:-$(git rev-parse --show-toplevel)}
export CHECKS_REPO_ROOT=$root

tracked() { git -C "$root" ls-files --error-unmatch "$1" >/dev/null 2>&1; }
# True when [profile.release] in the given Cargo.toml sets the size and speed options.
release_profile_ok() {
  local section
  section=$(awk '/^\[profile.release\]/{f=1;next} /^\[/{f=0} f' "$1")
  echo "$section" | grep -Eq '^lto *= *true' \
    && echo "$section" | grep -Eq '^codegen-units *= *1' \
    && echo "$section" | grep -Eq '^panic *= *"abort"' \
    && echo "$section" | grep -Eq '^strip *= *true'
}

violations() {
  local app tauri
  while IFS= read -r app; do
    [ -n "$app" ] || continue
    tauri="$app/src-tauri"
    check() { # id, description, command that succeeds when the rule holds
      if ! (eval "$3") >/dev/null 2>&1; then
        printf '%s\t%s\n' "$1" "$app"; echo "violated  $1 ($app): $2" >&2
      fi
    }
    check rust-pinned "rust-toolchain.toml pins an exact version" \
      "grep -Eq '^channel *= *\"[0-9]+\.[0-9]+\.[0-9]+\"' '$root/rust-toolchain.toml'"
    check package-manager-pinned "package.json sets packageManager" \
      "grep -q '\"packageManager\"' '$root/$app/package.json'"
    check lockfile-js "the JavaScript lockfile is committed" \
      "tracked '$app/pnpm-lock.yaml'"
    check lockfile-rust "Cargo.lock is committed" \
      "tracked '$tauri/Cargo.lock'"
    check cargo-edition "Cargo edition is 2024" \
      "grep -Eq '^edition *= *\"2024\"' '$root/$tauri/Cargo.toml'"
    check release-profile "Cargo release profile has lto, one codegen unit, panic abort and strip" \
      "release_profile_ok '$root/$tauri/Cargo.toml'"
    check version-single-source "tauri.conf.json has no version of its own" \
      "! grep -Eq '^  \"version\"' '$root/$tauri/tauri.conf.json'"
  done <<< "$apps"
}

# Read the map before any pipe, so a missing or malformed map stops the check (exit 2)
# instead of looking like "no violations".
apps=$("$here/kinds.sh" list desktop-app) || exit 2

if [ "$list_only" = 1 ]; then
  violations 2>/dev/null
else
  violations | "$here/baseline.sh" run app-conformance
fi
