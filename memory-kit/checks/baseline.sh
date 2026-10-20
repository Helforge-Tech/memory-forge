#!/usr/bin/env bash
# Compares a check's violations to its baseline, so existing violations are tolerated
# and the count can only go down (standard checks-baseline-and-kinds).
#
# Usage:
#   <check> | baseline.sh run <check-name>
#   <check> | baseline.sh regenerate [--force] <check-name>
#
# Requires bash 3.2 or newer (macOS /bin/bash); tested under 3.2 and a current bash.
#
# A check prints one violation per line: `rule<TAB>path[<TAB>key]`. Fields are separated
# by single tabs, may contain spaces, and are never empty. Data lives in
# <repo>/checks/baselines/<check-name> (same format, sorted, no comments) and
# <repo>/checks/exceptions/<check-name> (a violation's fields plus a final `# reason`
# field; the reason is required). Any malformed line in any of these exits 2 and names
# the file and line. `run` exits 1 on a violation that is in neither file, or on a
# baseline entry that no longer occurs. `regenerate` writes the baseline from stdin and
# refuses if one exists, unless --force. The repo root is $CHECKS_REPO_ROOT, else the
# git top level.
set -euo pipefail
export LC_ALL=C

die() { echo "baseline: $*" >&2; exit 2; }

mode=${1:-}; [ -n "$mode" ] || die "usage: baseline.sh run|regenerate [--force] <check-name>"
shift
force=0
if [ "${1:-}" = "--force" ]; then force=1; shift; fi
name=${1:-}; [ -n "$name" ] || die "usage: baseline.sh run|regenerate [--force] <check-name>"
case $name in */*) die "check name '$name' must not contain '/'" ;; esac
[ "$mode" = run ] || [ "$mode" = regenerate ] || die "unknown mode '$mode' (run or regenerate)"

root=${CHECKS_REPO_ROOT:-$(git rev-parse --show-toplevel)}
baseline="$root/checks/baselines/$name"
exceptions="$root/checks/exceptions/$name"

tmp=$(mktemp -d); trap 'rm -rf "$tmp"' EXIT

# validate <label> <kind>: reads stdin and copies it to stdout, or exits 2 at the first
# malformed line. kind is `violation` (2-3 non-empty tab-separated fields) or `exception`
# (3-4 fields, the last being `# reason` with a non-empty reason).
validate() {
  awk -F'\t' -v label="$1" -v kind="$2" '
    function fail(why) {
      printf "baseline: %s line %d: %s: %s\n", label, NR, why, $0 > "/dev/stderr"; bad = 1; exit
    }
    {
      min = (kind == "exception") ? 3 : 2; max = min + 1
      if (NF < min || NF > max) fail("expected " min "-" max " tab-separated fields")
      for (i = 1; i <= NF; i++) if ($i == "") fail("empty field")
      if (kind == "exception") {
        reason = $NF; sub(/^#[ ]*/, "", reason)
        if (substr($NF, 1, 1) != "#" || reason == "") fail("the last field must be \"# reason\" with a reason")
      }
      print
    }
    END { exit bad }'
}

validate "violations" violation > "$tmp/current.raw" || exit 2
sort -u "$tmp/current.raw" > "$tmp/current"

if [ "$mode" = regenerate ]; then
  if [ -e "$baseline" ] && [ "$force" = 0 ]; then
    die "${baseline#"$root"/} exists; regenerate is for introducing a check (use --force to overwrite)"
  fi
  mkdir -p "$(dirname "$baseline")"
  cp "$tmp/current" "$baseline"
  echo "baseline: wrote $(wc -l < "$baseline" | tr -d ' ') entries to ${baseline#"$root"/}"
  exit 0
fi

: > "$tmp/baseline"; : > "$tmp/exceptions"
if [ -f "$baseline" ]; then
  validate "${baseline#"$root"/}" violation < "$baseline" > "$tmp/baseline.raw" || exit 2
  sort -u "$tmp/baseline.raw" > "$tmp/baseline"
  cmp -s "$tmp/baseline.raw" "$tmp/baseline" \
    || die "${baseline#"$root"/} is not sorted and unique (LC_ALL=C sort -u)"
fi
if [ -f "$exceptions" ]; then
  validate "${exceptions#"$root"/}" exception < "$exceptions" > "$tmp/exceptions.raw" || exit 2
  # the id of an exception is its line without the final reason field
  sed 's/	[^	]*$//' "$tmp/exceptions.raw" | sort -u > "$tmp/exceptions"
fi

comm -23 "$tmp/current" "$tmp/exceptions" > "$tmp/live"       # not a permanent exception
comm -23 "$tmp/live" "$tmp/baseline" > "$tmp/new"             # new violations
comm -12 "$tmp/live" "$tmp/baseline" > "$tmp/tolerated"
comm -23 "$tmp/baseline" "$tmp/current" > "$tmp/fixed"        # baseline entries that now pass
comm -12 "$tmp/current" "$tmp/exceptions" > "$tmp/excepted"

sed 's/^/VIOLATION  /' "$tmp/new"
sed 's/^/FIXED      /; s/$/  (now passes: remove it from the baseline)/' "$tmp/fixed"
echo "$name: $(wc -l < "$tmp/new" | tr -d ' ') new, $(wc -l < "$tmp/tolerated" | tr -d ' ') tolerated, $(wc -l < "$tmp/excepted" | tr -d ' ') excepted, $(wc -l < "$tmp/fixed" | tr -d ' ') to remove"
[ ! -s "$tmp/new" ] && [ ! -s "$tmp/fixed" ]
