#!/usr/bin/env bash
set -euo pipefail

# ROOT="/gpfs1/data/fragana/aggregated_broadclasses"

# Ajusta si necesitas otros años
YEARS=("2030" "2050" "2070")
SCENARIOS=("NaC" "NfN" "NfS")

OUT="/gpfs1/data/fragana/globio_pairs.tsv"

: > "$OUT"   # vacía el archivo

for sc in "${SCENARIOS[@]}"; do
  for yr in "${YEARS[@]}"; do
    echo "$sc $yr" >> "$OUT"
  done
done

echo "Wrote $(wc -l < "$OUT") jobs to $OUT"
echo "First lines:"
head "$OUT"
