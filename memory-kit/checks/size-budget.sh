#!/usr/bin/env bash
# Fails when a file or folder is larger than its budget.
#
# Usage: size-budget.sh <label> <path> <max-bytes>
#
# The size of a folder is the total bytes of the files in it. Prints the measured
# size, the budget and the headroom, so a pass still shows how close it is.
set -euo pipefail

label=${1:?usage: size-budget.sh <label> <path> <max-bytes>}
path=${2:?usage: size-budget.sh <label> <path> <max-bytes>}
max=${3:?usage: size-budget.sh <label> <path> <max-bytes>}

if [ ! -e "$path" ]; then
  echo "size-budget: $label: '$path' does not exist; build it first" >&2
  exit 2
fi

if [ -d "$path" ]; then
  size=$(find "$path" -type f -exec cat {} + | wc -c | tr -d ' ')
else
  size=$(wc -c < "$path" | tr -d ' ')
fi

pct=$(( size * 100 / max ))
if [ "$size" -gt "$max" ]; then
  echo "OVER BUDGET  $label: $size bytes, budget $max (${pct}%)" >&2
  exit 1
fi
echo "ok  $label: $size bytes of $max (${pct}%)"
