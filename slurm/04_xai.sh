#!/bin/bash
#SBATCH --job-name=gzm_xai
#SBATCH --partition=medium
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=8
#SBATCH --mem=32G
#SBATCH --gres=gpu:1
#SBATCH --time=04:00:00
#SBATCH --output=logs/%x_%j.out
#SBATCH --error=logs/%x_%j.err
#
# Queues after the September 2026 rebuild: short (4 h, the default), medium
# (1 day) and long (7 days). They all reach the same node, cn001, with 224
# cores and eight H100s, and differ only in wall clock; GPUs still come from
# --gres. Override either without editing: sbatch -p <queue> -t <time> ...
# medium (1 day). Four hours is exactly short's limit, which is not a
# margin: a job that reaches the cap is killed, not requeued.

# Grad-CAM for the convnets, attention rollout for the transformers, plus the
# deletion, insertion and background-reliance scores. The deletion and insertion
# curves are 21 forward passes per galaxy per model, which is why this wants a GPU
# even though nothing is being trained.
set -e

source ~/miniconda3/etc/profile.d/conda.sh
conda activate "${ENV_NAME:-galaxy}"
export PYTHONUNBUFFERED=1
# the nodes are shared; this keeps fragmentation from turning a tight
# fit into an out-of-memory error
export PYTORCH_CUDA_ALLOC_CONF=expandable_segments:True
cd "$SLURM_SUBMIT_DIR"

N=${GZM_XAI_N:-200}

echo "GPU asignada: $CUDA_VISIBLE_DEVICES"
echo "node: $(hostname)   start: $(date)"

python -m src.xai --all-checkpoints --n "$N"

echo "end: $(date)"
