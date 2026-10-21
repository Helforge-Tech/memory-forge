#!/usr/bin/env bash
# Checks the repo's memory for drift (standard memory-checks). Prints one violation per
# line as `rule<TAB>path[<TAB>key]` and exits 0; run it through the baseline runner:
#
#   memory-kit/checks/memory-check.sh | memory-kit/checks/baseline.sh run memory
#
# Rules:
#   repo-map-missing     AGENTS.md repo map lists a path that does not exist (key: the path)
#   repo-map-unlisted    a tracked top-level folder is not in the repo map
#   ref-missing          a markdown link in root guidance, a skill, a playbook or a standard
#                        points at a path that does not exist (key: the link)
#   ref-archived         such a link points into a folder that holds ARCHIVED.md
#   command-missing      AGENTS.md names `task <name>` and the task runner has no such task
#                        (`task --list-all`; $MEMORY_TASK_BIN names another binary; without
#                        one, the first Taskfile.yml or Taskfile.yaml is parsed)
#   root-size            AGENTS.md is over its budget ($MEMORY_ROOT_BUDGET bytes, default 16000)
#   brief-unlinked       a tracked area brief (<folder>/AGENTS.md) is not linked from the repo map
#   brief-size           an area brief is over its budget ($MEMORY_BRIEF_BUDGET bytes, default 4000)
#   brief-path-missing   a path in a brief's `## Code` section does not exist (key: the path)
#   index-status         a kit index row's status differs from the item's `status:` (key: the file)
#   index-row-missing    a kit item has no row in its INDEX.md (key: the file)
#   kinds-map-invalid    checks/kinds is malformed or has a kind with no instance (key: the kind)
#   decision-base-missing  no base ref or merge base, and $CI or $MEMORY_REQUIRE_BASE is set
#                        (otherwise the decisions check is skipped with a note)
#   decision-number-duplicate  two files in docs/decisions share a number (key: the number)
#   decision-edited      a decision differs from the merge base with $MEMORY_CHECK_BASE
#                        (default origin/main) in any line but `- Status:`; also when deleted
#
# Requires bash 3.2 or newer (macOS /bin/bash). The repo root is $CHECKS_REPO_ROOT, else
# the git top level.
set -euo pipefail
export LC_ALL=C

here=$(cd "$(dirname "$0")" && pwd)
root=${CHECKS_REPO_ROOT:-$(git rev-parse --show-toplevel)}
cd "$root"
T=$(printf '\t')

emit() { # rule path [key]
  if [ -n "${3:-}" ]; then printf '%s\t%s\t%s\n' "$1" "$2" "$3"; else printf '%s\t%s\n' "$1" "$2"; fi
}

# --- repo map -----------------------------------------------------------------------
if [ -f AGENTS.md ]; then
  listed=$(awk '/^## Repo map/{on=1;next} /^## /{on=0} on' AGENTS.md \
    | sed -n 's/^| *`\([^`]*\)`.*/\1/p')
  while IFS= read -r p; do
    [ -n "$p" ] || continue
    [ -e "${p%/}" ] || emit repo-map-missing AGENTS.md "$p"
  done <<EOF
$listed
EOF
  tops=$(git ls-files | awk -F/ 'NF > 1 && $1 !~ /^\./ { print $1 }' | sort -u)
  while IFS= read -r d; do
    [ -n "$d" ] || continue
    printf '%s\n' "$listed" | grep -q "^${d}/*\$\|^${d}/" || emit repo-map-unlisted "$d"
  done <<EOF
$tops
EOF

  # --- commands named in root guidance exist in the task runner ----------------------
  # Ask the task runner itself (it knows includes, namespaces and which Taskfile it
  # prefers). Without it, read the first Taskfile's own tasks at whatever indent it uses.
  tasks=""
  if json=$("${MEMORY_TASK_BIN:-task}" --list-all --json 2>/dev/null); then
    tasks=$(printf '%s' "$json" | grep -o '"name": *"[^"]*"' | sed 's/"name": *"\(.*\)"/\1/' || true)
    # aliases are valid names too: "aliases": ["t", "tt"]
    aliases=$(printf '%s' "$json" | tr '\n' ' ' | grep -o '"aliases": *\[[^]]*\]' | grep -o '"[^"]*"' | grep -v '^"aliases"$' | tr -d '"' || true)
    tasks=$(printf '%s\n%s\n' "$tasks" "$aliases")
  else
    for tf in Taskfile.yml Taskfile.yaml; do
      [ -f "$tf" ] || continue
      tasks=$(awk '/^tasks:/{on=1;next} /^[^ #]/{on=0}
        on && /^[ ]+[A-Za-z0-9:_-]+:/ { n = match($0, /[^ ]/) - 1; if (!ind) ind = n
          if (n == ind) { s = $0; sub(/^[ ]+/, "", s); sub(/:.*/, "", s); print s } }' "$tf")
      break
    done
  fi
  names=$(grep -o '`task [a-z][A-Za-z0-9:_-]*`' AGENTS.md | sed 's/`task \(.*\)`/\1/' | sort -u || true)
  while IFS= read -r n; do
    [ -n "$n" ] || continue
    printf '%s\n' "$tasks" | grep -qx -- "$n" || emit command-missing AGENTS.md "task $n"
  done <<EOF
$names
EOF

  # --- size budget ---------------------------------------------------------------------
  "$here/size-budget.sh" AGENTS.md AGENTS.md "${MEMORY_ROOT_BUDGET:-16000}" >/dev/null 2>&1 \
    || emit root-size AGENTS.md
fi

# --- area briefs (standard memory-area-briefs) ----------------------------------------------------
# A brief is a tracked AGENTS.md below the root, outside dot-folders.
briefs=$(git ls-files | grep '/AGENTS\.md$' | grep -v '^\.' || true)
if [ -n "$briefs" ] && [ -f AGENTS.md ]; then
  # link targets in the repo map, normalised like the link check below (<wrapped>, title, %20, anchor, ./)
  mapped=$(awk '/^## Repo map/{on=1;next} /^## /{on=0} on' AGENTS.md | grep -o '\]([^)]*)' | sed 's/^](//; s/)$//' \
    | sed -e 's/^<\(.*\)>.*$/\1/' -e 's/[[:space:]][[:space:]]*["'"'"'(].*$//' -e 's/#.*$//' -e 's/%20/ /g' -e 's|^\./||' || true)
  while IFS= read -r b; do
    [ -n "$b" ] || continue
    printf '%s\n' "$mapped" | grep -qxF -- "$b" || emit brief-unlinked "$b"
    "$here/size-budget.sh" "$b" "$b" "${MEMORY_BRIEF_BUDGET:-4000}" >/dev/null 2>&1 \
      || emit brief-size "$b"
    bdir=$(dirname "$b")
    # `## Code` lists one path per bullet, first in backticks, relative to the brief's folder
    paths=$(awk '/^## Code[ \t\r]*$/{on=1;next} /^## /{on=0} on' "$b" | sed -n 's/^[-*] *`\([^`]*\)`.*/\1/p')
    while IFS= read -r p; do
      [ -n "$p" ] || continue
      [ -e "$bdir/${p%/}" ] || emit brief-path-missing "$b" "$p"
    done <<EOF
$paths
EOF
  done <<EOF
$briefs
EOF
fi

# --- links ----------------------------------------------------------------------------
# Links inside fenced code blocks are examples and are skipped.
# one file per line, so a folder name with a space survives
files="AGENTS.md
CLAUDE.md
memory-kit/README.md
$briefs"
for f in .claude/skills/*/SKILL.md memory-kit/playbooks/*.md memory-kit/standards/*.md; do
  files="$files
$f"
done
while IFS= read -r f; do
  [ -f "$f" ] || continue
  dir=$(dirname "$f")
  # Fenced blocks and inline code are examples. A link may be <wrapped>, carry a "title"
  # and use %20 for a space; the key keeps the link as written.
  links=$(awk '/^[ \t]*(```|~~~)/{f=!f;next} !f' "$f" | sed 's/`[^`]*`//g' | grep -o '\]([^)]*)' | sed 's/^](//; s/)$//' | sort -u || true)
  while IFS= read -r l; do
    [ -n "$l" ] || continue
    case $l in http*|mailto:*|'#'*|/*) continue ;; esac
    t=$l
    case $t in
      '<'*'>'*) t=${t#<}; t=${t%%>*} ;;
      *) t=$(printf '%s' "$t" | sed 's/[[:space:]][[:space:]]*["'"'"'(].*$//') ;;
    esac
    t=$(printf '%s' "${t%%#*}" | sed 's/%20/ /g')
    [ -n "$t" ] || continue
    if [ ! -e "$dir/$t" ]; then emit ref-missing "$f" "$l"; continue; fi
    # walk up from the target (itself, if a folder) to the repo root for an ARCHIVED.md marker
    if [ -d "$dir/$t" ]; then abs=$(cd "$dir/$t" && pwd -P); else abs=$(cd "$(dirname "$dir/$t")" && pwd -P); fi
    while [ "$abs" != "$(pwd -P)" ] && [ "$abs" != / ]; do
      if [ -e "$abs/ARCHIVED.md" ]; then emit ref-archived "$f" "$l"; break; fi
      abs=$(dirname "$abs")
    done
  done <<EOF
$links
EOF
done <<EOF
$files
EOF

# --- kit indexes ------------------------------------------------------------------------
for idx in memory-kit/standards/INDEX.md memory-kit/playbooks/INDEX.md; do
  [ -f "$idx" ] || continue
  d=$(dirname "$idx")
  rows=$(grep '^|.*](' "$idx" || true)
  for item in "$d"/*.md; do
    [ "$(basename "$item")" != INDEX.md ] || continue
    b=$(basename "$item")
    row=$(printf '%s\n' "$rows" | grep -F "($b)" | head -1 || true)
    if [ -z "$row" ]; then emit index-row-missing "$idx" "$b"; continue; fi
    have=$(awk 'NR==1 && $0!="---"{exit} NR>1 && $0=="---"{exit} /^status:/{sub(/^status:[ ]*/,""); print; exit}' "$item")
    want=$(printf '%s\n' "$row" | sed 's/|[[:space:]]*$//; s/.*|//' | awk '{print $1}')
    [ "$have" = "$want" ] || emit index-status "$idx" "$b"
  done
done

# --- kinds map --------------------------------------------------------------------------
if [ -f checks/kinds ]; then
  kinds=$(awk -F'\t' '!/^#/ && NF > 0 { print $1 }' checks/kinds | sort -u)
  while IFS= read -r k; do
    [ -n "$k" ] || continue
    "$here/kinds.sh" list "$k" >/dev/null 2>&1 || emit kinds-map-invalid checks/kinds "$k"
  done <<EOF
$kinds
EOF
fi

# --- decisions are not edited after merge ---------------------------------------------------
dups=$(ls docs/decisions 2>/dev/null | sed -n 's/^\([0-9]\{4\}\)-.*/\1/p' | sort | uniq -d || true)
while IFS= read -r n; do
  [ -n "$n" ] || continue
  emit decision-number-duplicate docs/decisions "$n"
done <<EOF
$dups
EOF

base=${MEMORY_CHECK_BASE:-origin/main}
mb=""
if git rev-parse --verify -q "$base^{commit}" >/dev/null 2>&1; then
  mb=$(git merge-base HEAD "$base" 2>/dev/null || true)
fi
if [ -n "$mb" ]; then
  git ls-tree -r --name-only "$mb" -- docs/decisions | while IFS= read -r f; do
    if [ ! -f "$f" ]; then emit decision-edited "$f" deleted; continue; fi
    if ! diff <(git show "$mb:$f" | grep -v '^- Status:') <(grep -v '^- Status:' "$f") >/dev/null; then
      emit decision-edited "$f"
    fi
  done
elif [ -n "${CI:-}" ] || [ -n "${MEMORY_REQUIRE_BASE:-}" ]; then
  # a gate must not pass because it could not look (a shallow clone has no merge base)
  emit decision-base-missing docs/decisions "$base"
else
  echo "memory-check: no merge base with '$base'; skipped the decisions check" >&2
fi
exit 0
