#!/usr/bin/env bash
# Prints the instances of a kind from the repo's kinds map (standard checks-baseline-and-kinds).
#
# Usage: kinds.sh list <kind>
#
# Requires bash 3.2 or newer (macOS /bin/bash); tested under 3.2 and a current bash.
#
# <repo>/checks/kinds has one line per kind: `kind<TAB>glob[<TAB>marker]`. Fields are
# separated by single tabs, may contain spaces, and are never empty. A line that starts
# with `#`, and a blank line, are ignored. An instance is a directory matched by the glob
# that contains the marker, if one is given. Prints paths relative to the repo root, one
# per line, sorted. Exits 2 on a malformed line (naming the line), an unknown kind, a kind with no
# instances (a lost tab between glob and marker would otherwise pass silently), or any
# error while listing. The
# repo root is $CHECKS_REPO_ROOT, else the git top level.
set -euo pipefail
export LC_ALL=C

die() { echo "kinds: $*" >&2; exit 2; }

[ "${1:-}" = list ] || die "usage: kinds.sh list <kind>"
kind=${2:-}; [ -n "$kind" ] || die "usage: kinds.sh list <kind>"
root=${CHECKS_REPO_ROOT:-$(git rev-parse --show-toplevel)}
map="$root/checks/kinds"
[ -f "$map" ] || die "no kinds map at ${map#"$root"/}"

tab=$(printf '\t')
# Globs are expanded by the shell itself (no compgen: it is missing from some bashes, such
# as the nix dev shell's). nullglob makes an unmatched glob expand to nothing; IFS= keeps
# a glob with spaces in one word.
cd "$root" || die "cannot enter $root"
shopt -s nullglob
n=0; found=0
tmp=$(mktemp) || die "cannot create a temporary file"; trap 'rm -f "$tmp"' EXIT
while IFS= read -r line || [ -n "$line" ]; do
  n=$((n + 1))
  case $line in ''|'#'*) continue ;; esac
  # 2 or 3 non-empty fields, separated by single tabs
  fields=$(printf '%s\n' "$line" | awk -F'\t' '{ ok = (NF == 2 || NF == 3); for (i = 1; i <= NF; i++) if ($i == "") ok = 0; print ok }') \
    || die "cannot parse ${map#"$root"/} line $n"
  [ "$fields" = 1 ] || die "${map#"$root"/} line $n: expected 'kind<TAB>glob[<TAB>marker]' with no empty field, got: $line"
  k=${line%%"$tab"*}
  [ "$k" = "$kind" ] || continue
  found=1
  rest=${line#*"$tab"}
  glob=${rest%%"$tab"*}
  marker=""
  case $rest in *"$tab"*) marker=${rest#*"$tab"} ;; esac
  IFS=
  for d in $glob; do
    [ -d "$d" ] || continue
    [ -z "$marker" ] || [ -e "$d/$marker" ] || continue
    printf '%s\n' "${d%/}" >> "$tmp" || die "cannot write a temporary file"
  done
  unset IFS
done < "$map"

[ "$found" = 1 ] || die "kind '$kind' is not in the kinds map"
[ -s "$tmp" ] || die "kind '$kind' has no instances (check its glob and marker in ${map#"$root"/}; fields must be separated by tabs)"
sort -u "$tmp"
