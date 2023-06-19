#!/bin/bash

# ANSI Shadow from https://manytools.org/hacker-tools/ascii-banner/
echo "

██╗  ██╗ ██████╗ ██╗  ██╗██╗   ██╗ █████╗
██║ ██╔╝██╔═══██╗██║  ██║╚██╗ ██╔╝██╔══██╗
█████╔╝ ██║   ██║███████║ ╚████╔╝ ███████║
██╔═██╗ ██║   ██║██╔══██║  ╚██╔╝  ██╔══██║
██║  ██╗╚██████╔╝██║  ██║   ██║   ██║  ██║
╚═╝  ╚═╝ ╚═════╝ ╚═╝  ╚═╝   ╚═╝   ╚═╝  ╚═╝

" >&2

# Check for repos
if [ ! -d kohya-trainer ]; then
  echo "Cloning kohya-trainer..." >&2
  git clone --branch "${KOHYA_TRAINER_BRANCH:-main}" https://github.com/Linaqruf/kohya-trainer.git
fi

# Accelerate config
ACCELERATE_CONFIG=accelerate_config/config.yaml
if [ ! -f "$ACCELERATE_CONFIG" ]; then
  python -c "from accelerate.utils import write_basic_config; write_basic_config(save_location='$ACCELERATE_CONFIG');"
fi

# Environment
CUDA_PATH="/usr/lib/x86_64-linux-gnu"
export LD_LIBRARY_PATH="${LD_LIBRARY_PATH}:${CUDA_PATH}"
export LD_PRELOAD="libtcmalloc.so"
export TF_CPP_MIN_LOG_LEVEL="3"
export SAFETENSORS_FAST_GPU="1"

# Directories
TRAINING_DIR="$(pwd)/LoRA"
CONFIG_DIR="$TRAINING_DIR/config"
PRETRAINED_MODEL_DIR="$(pwd)/pretrained_model"
VAE_DIR="$(pwd)/vae"

# Ensure they exist
for mydir in "$TRAINING_DIR" "$CONFIG_DIR" "$PRETRAINED_MODEL_DIR" "$VAE_DIR"; do
  mkdir -p "$mydir"
done

# Execute whatever
echo "# $*" >&2
exec "$@"
