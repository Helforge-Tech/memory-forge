#!/usr/bin/env bash
# Fails a change that mixes code paths and memory paths (standard git-split-code-and-memory).
# Prints one violation per file as `mixed-pr<TAB>path<TAB>side` and exits 0; run it through
# the baseline runner, like the other checks:
#
#   memory-kit/checks/pr-split.sh | memory-kit/checks/baseline.sh run split
#
# The change is the files that differ between $GATE_BASE (default origin/main) and HEAD,
# from their merge base, so in a stacked PR it is the layer's own files. A base that does
# not resolve, or that shares no history with HEAD (a shallow clone), exits 2.
#
# Which paths are memory is a per-repo setting, <repo>/checks/split: one line per entry,
# `side<TAB>path` with side `memory` or `code`. A path ending in `/` is a folder and
# everything under it; any other path is one file. The longest matching entry wins; a path
# no entry matches is code. Blank lines and lines starting with `#` are ignored. If the file
# exists it replaces the defaults below. The root `checks/` folder is always code
# (decision 0025) and cannot be listed as memory. A malformed line exits 2.
#
# Default memory paths (this template's layout): memory-kit/ docs/ knowledge/ .claude/
# AGENTS.md CLAUDE.md README.md.
#
# Exempt: a change whose code files are all root `checks/` data and that includes a check
# script (memory-kit/checks/): a check script and its baseline ship together
# (standard checks-baseline-and-kinds rule 9).
#
# Requires bash 3.2 or newer (macOS /bin/bash). The repo root is $CHECKS_REPO_ROOT, else
# the git top level.
set -euo pipefail
export LC_ALL=C

die() { echo "pr-split: $*" >&2; exit 2; }

root=${CHECKS_REPO_ROOT:-$(git rev-parse --show-toplevel)}
cd "$root" || die "cannot enter $root"
base=${GATE_BASE:-origin/main}
git rev-parse --verify -q "$base^{commit}" >/dev/null || die "base '$base' does not resolve (fetch it, or set GATE_BASE)"

tab=$(printf '\t')
entries=""   # lines of `side<TAB>path`
if [ -f checks/split ]; then
  n=0
  while IFS= read -r line || [ -n "$line" ]; do
    n=$((n + 1))
    case $line in ''|'#'*) continue ;; esac
    ok=$(printf '%s\n' "$line" | awk -F'\t' '{ print (NF == 2 && $1 != "" && $2 != "") ? 1 : 0 }')
    [ "$ok" = 1 ] || die "checks/split line $n: expected 'side<TAB>path' with no empty field, got: $line"
    side=${line%%"$tab"*}; path=${line#*"$tab"}
    case $side in memory|code) ;; *) die "checks/split line $n: side must be memory or code, got: $side" ;; esac
    case $path in /*|*..*) die "checks/split line $n: path must be relative and have no '..': $path" ;; esac
    if [ "$side" = memory ]; then
      case $path in checks|checks/*) die "checks/split line $n: root checks/ is code (decision 0025) and cannot be memory" ;; esac
    fi
    entries="$entries$line
"
  done < checks/split
else
  for p in memory-kit/ docs/ knowledge/ .claude/ AGENTS.md CLAUDE.md README.md; do
    entries="${entries}memory$tab$p
"
  done
fi

# side_of <path>: prints memory or code.
side_of() {
  local p=$1 best=code bestlen=-1 line side e len
  case $p in checks/*) echo code; return ;; esac
  while IFS= read -r line; do
    [ -n "$line" ] || continue
    side=${line%%"$tab"*}; e=${line#*"$tab"}
    case $e in
      */) case $p in "$e"*) ;; *) continue ;; esac ;;
      *) [ "$p" = "$e" ] || continue ;;
    esac
    len=${#e}
    if [ "$len" -gt "$bestlen" ]; then best=$side; bestlen=$len; fi
  done <<ENTRIES
$entries
ENTRIES
  echo "$best"
}

files=$(git -c core.quotepath=off diff --name-only --no-renames "$base"...HEAD) \
  || die "cannot diff $base...HEAD (a shallow clone has no merge base: fetch full history)"

mem=""; cod=""
while IFS= read -r f; do
  [ -n "$f" ] || continue
  if [ "$(side_of "$f")" = memory ]; then mem="$mem$f
"; else cod="$cod$f
"; fi
done <<FILES
$files
FILES

[ -n "$mem" ] && [ -n "$cod" ] || exit 0

# exemption: the code files are all check data, and a check script is among the memory files
# (case loops, not `grep -q` in a pipe: under pipefail a large list makes printf die of SIGPIPE)
data_only=1; while IFS= read -r f; do
  [ -n "$f" ] || continue
  case $f in checks/*) ;; *) data_only=0; break ;; esac
done <<CODE
$cod
CODE
has_script=0; while IFS= read -r f; do
  case $f in memory-kit/checks/*) has_script=1; break ;; esac
done <<MEM
$mem
MEM
if [ "$data_only" = 1 ] && [ "$has_script" = 1 ]; then exit 0; fi

printf '%s' "$mem" | while IFS= read -r f; do printf 'mixed-pr\t%s\tmemory\n' "$f"; done
printf '%s' "$cod" | while IFS= read -r f; do printf 'mixed-pr\t%s\tcode\n' "$f"; done
