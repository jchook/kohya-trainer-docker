# This Dockerfile requires nvidia-docker
# https://hub.docker.com/r/nvidia/cuda
#
# This should match the CUDA version of your host's driver
# Run the nvidia-smi command to check the version
FROM nvidia/cuda:12.1.1-runtime-ubuntu22.04

# Install
RUN apt-get -y update \
  && apt-get -y install \
    git \
    python3 \
    python3-pip \
    python-is-python3 \
    sudo \
    vim \
    wget \
    zip \
 && apt-get install -y \
  aria2 \
  google-perftools \
  libaria2-0 \
  libc-ares2 \
  libgl1 \
  libglib2.0-0 \
  libgoogle-perftools-dev \
  libgoogle-perftools4 \
  liblz4-tool \
  libtcmalloc-minimal4 \
  libunwind8-dev \
  lz4 \
  nvidia-cuda-toolkit

# Install python dependencies
ENV DEBIAN_FRONTEND=noninteractive
ENV TZ=Europe/London
RUN apt-get update && apt-get install -y python3.10-tk \
  && pip install -U --extra-index-url https://download.pytorch.org/whl/cu118 \
    torch==2.0.1+cu118 \
    torchvision==0.15.2+cu118 \
    xformers==0.0.21 \
  && pip install -U \
    accelerate==0.23.0 \
    aiofiles==23.2.1 \
    albumentations==1.3.0 \
    altair==4.2.2 \
    bitsandbytes==0.41.1 \
    dadaptation==3.1 \
    diffusers[torch]==0.21.4 \
    easygui==0.98.3 \
    einops==0.6.0 \
    fairscale==0.4.13 \
    ftfy==6.1.1 \
    gradio==3.36.1 \
    huggingface-hub==0.15.1 \
    invisible-watermark==0.2.0 \
    lion-pytorch==0.0.6 \
    lycoris_lora==2.0.0 \
    onnx==1.14.1 \
    onnxruntime-gpu==1.16.0 \
    open-clip-torch==2.20.0 \
    opencv-python==4.7.0.68 \
    prodigyopt==1.0 \
    protobuf==3.20.3 \
    pytorch-lightning==1.9.0 \
    rich==13.4.1 \
    safetensors==0.3.1 \
    tensorboard==2.14.1 \
    tensorboard==2.14.1 \
    tensorflow==2.14.0 \
    timm==0.6.12 \
    tk==0.1.0 \
    toml==0.10.2 \
    transformers==4.30.2 \
    voluptuous==0.13.1 \
    wandb==0.15.11 \
  && pip install -U jupyterlab

# Enable this to run Stability-AI scripts
# e.g. image2video via https://github.com/Stability-AI/generative-models
#RUN apt-get update && apt-get install -y ffmpeg python3.10-venv

# Enable this for Dataset Maker
# https://github.com/hollowstrawberry/kohya-colab/tree/main
# https://docs.voxel51.com/getting_started/troubleshooting.html#troubleshooting-linux-imports
#RUN pip install -U fiftyone fiftyone-db==0.4.3
#RUN apt-get update && apt-get install -y libssl-dev

# Enable for YOLO
RUN pip install -U ultralytics

# Hint: set these to your user ID
# See https://stackoverflow.com/questions/56844746/how-to-set-uid-and-gid-in-docker-compose
ARG APP_UID=1000
ARG APP_GID=1000

# Create a non-root user
RUN getent passwd "$APP_UID" || ( \
      groupadd --system --gid $APP_GID app \
      && useradd --uid $APP_UID --gid $APP_GID --system \
        --create-home --home-dir /home/app --shell /bin/bash --groups sudo \
        --password "$(openssl passwd -1 app)" app \
  ) \
  && echo 'app ALL=(ALL) NOPASSWD:ALL' >> /etc/sudoers.d/33-app

# Switch from root
USER $APP_UID:$APP_GID

# Hint: mount these volumes to avoid downloading stuff every time
VOLUME /content
VOLUME /home/app/.cache

# The kohya-trainer ipynb files lean very heavily on hardcoded '/content'
WORKDIR /content

# Load the tcmalloc library
ENV LD_PRELOAD=/usr/lib/x86_64-linux-gnu/libtcmalloc.so.4

# Persist the jupyterlab directory
# ENV JUPYTERLAB_DIR=/content/jupyter/lab

# Copy entrypoint.sh
COPY ./rootfs/ /

# Set the entrypoint
ENTRYPOINT [ "/entrypoint.sh" ]

# Run notebook
EXPOSE 8888
# CMD ["bash"]
# CMD ["kohya_ss/gui.sh", "--listen='0.0.0.0'", "--server_port=8086", "--headless"]
CMD ["jupyter", "lab", "--ip=0.0.0.0", "--port=8888", "--no-browser", "--allow-root"]

