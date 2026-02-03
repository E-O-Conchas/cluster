#!/usr/bin/env bash
set -euo pipefail

CLUMP_ROOT="/gpfs1/data/fragana/EUNIS_clumps"
OUT="/gpfs1/data/fragana/pairs.tsv"

# Find all the READY.txt files and derive year, group, and coda from their path
# Explanation:
# - find ... -type f -name READY.txt  -> list all flags
# - while read flag: do....           -> loop over them
# - basename/dirname                  -> peel off path parts
# - print "%s\t%s\t%s\n"              -> emit "YEAR\tGROUP\tCODE"
# - sed 's#^\./##'                    -> remove leading ./
# - sort -u                           -> unique and sorted

cd "$CLUMP_ROOT"

# Build pairs from READY flags (robust to depth)
while IFS= read -r flag; do
  code=$(basename "$(dirname "$flag")")
  group=$(basename "$(dirname "$(dirname "$flag")")")
  year=$(basename "$(dirname "$(dirname "$(dirname "$flag")")")")
  printf "%s\t%s\t%s\n" "$year" "$group" "$code"
done < <(find . -type f -name READY.txt -printf "%p\n") \
| sed 's#^\./##' \
| sort -u > /gpfs1/data/fragana/pairs.tsv

echo "Wrote $(wc -l < "$OUT") lines to $OUT"

# Quick sanity check
head /gpfs1/data/fragana/pairs.tsv
# expected rows like: 2012   N   N1A
