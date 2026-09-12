#!/bin/bash
#SBATCH --job-name=gzm_train
#SBATCH --partition=medium
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=8
#SBATCH --mem=32G
#SBATCH --gres=gpu:1
#SBATCH --time=08:00:00
#SBATCH --output=logs/%x_%A_%a.out
#SBATCH --error=logs/%x_%A_%a.err
#
# Queues after the September 2026 rebuild: short (4 h, the default), medium
# (1 day) and long (7 days). They all reach the same node, cn001, with 224
# cores and eight H100s, and differ only in wall clock; GPUs still come from
# --gres. Override either without editing: sbatch -p <queue> -t <time> ...
# medium (1 day). One task is one training run and the longest take six
# hours, so short's four-hour ceiling would kill the slow architectures.

# One array task trains one configuration on one GPU; nothing here can use more
# than a single card.
#
#   python -m src.build_jobs            # writes jobs.csv and prints the range
#   sbatch --array=0-N%4 slurm/02_train_array.sh
#
# The throttle after the % is how many tasks run at once. It used to be 2, which was
# the per-user GPU limit on the old gpu-small queue; the rebuilt cluster states no
# such limit and cn001 carries eight cards, so 4 is a reasonable share to take when
# the machine is otherwise quiet. Check `squeue` first and lower it if it is not. A
# task whose run is already finished exits immediately, so resubmitting the whole
# range after a timeout is cheap and safe.
set -e

source ~/miniconda3/etc/profile.d/conda.sh
conda activate "${ENV_NAME:-galaxy}"
export PYTHONUNBUFFERED=1
# the nodes are shared; this keeps fragmentation from turning a tight
# fit into an out-of-memory error
export PYTORCH_CUDA_ALLOC_CONF=expandable_segments:True
cd "$SLURM_SUBMIT_DIR"

export GZM_WORKERS=${SLURM_CPUS_PER_TASK:-8}
JOBS=${GZM_JOBS:-${GZM_WORK:-$HOME/galaxy-morphology/work}/jobs/jobs.csv}

echo "GPU asignada: $CUDA_VISIBLE_DEVICES"
echo "node: $(hostname)   task: $SLURM_ARRAY_TASK_ID   start: $(date)"

python -m src.train --jobs-csv "$JOBS" --task-id "$SLURM_ARRAY_TASK_ID"

echo "end: $(date)"
