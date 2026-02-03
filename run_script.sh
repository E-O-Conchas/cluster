#!/bin/bash
#SBATCH --job-name=globio_bin
#SBATCH --partition=compute
#SBATCH --cpus-per-task=1
#SBATCH --mem=24G
#SBATCH --time=3-00:00:00
#SBATCH --chdir=/gpfs1/work/oceguera/98
#SBATCH --output=logs/%x-%A-%a.out
#SBATCH --error=logs/%x-%A-%a.err
#SBATCH --array=1-9

module purge || true
module load R || true

set -euo pipefail

# Paths
LISTFILE="/gpfs1/data/fragana/globio_pairs.tsv"
SCRIPT="/gpfs1/schlecker/home/oceguera/cluster/generate_binary_entitites.r"

# Ensure logs exists (for safety; ideally create once before sbatch)
mkdir -p logs

JOB_LINE=$(sed -n "${SLURM_ARRAY_TASK_ID}p" "$LISTFILE")
SC=$(echo "$JOB_LINE" | awk '{print $1}')
YR=$(echo "$JOB_LINE" | awk '{print $2}')

echo "[$(date)] Task ${SLURM_ARRAY_TASK_ID}: scenario=$SC year=$YR"
echo "Running: Rscript $SCRIPT $SC $YR"

Rscript "$SCRIPT" "$SC" "$YR"

echo "[$(date)] Done scenario=$SC year=$YR"

# Lee línea del job list
JOB_LINE=$(sed -n "${SLURM_ARRAY_TASK_ID}p" "$LISTFILE")
SC=$(echo "$JOB_LINE" | awk '{print $1}')
YR=$(echo "$JOB_LINE" | awk '{print $2}')

echo "[$(date)] Task ${SLURM_ARRAY_TASK_ID}: scenario=$SC year=$YR"
echo "Running: Rscript $SCRIPT $SC $YR"

Rscript "$SCRIPT" "$SC" "$YR"

echo "[$(date)] Done scenario=$SC year=$YR"
