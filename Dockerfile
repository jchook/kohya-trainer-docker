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

# Apparently the maintainer does not tag releases
ARG KOHYA_TRAINER_BRANCH=main

# Install python dependencies
RUN git clone --branch "${KOHYA_TRAINER_BRANCH}" https://github.com/Linaqruf/kohya-trainer.git \
  && cd kohya-trainer \
  && pip install -r requirements.txt \
  && pip install -U --extra-index-url https://download.pytorch.org/whl/cu118 \
    bitsandbytes==0.39.0 \
    jupyter==1.0.0 \
    torch==2.0.0+cu118 \
    torchvision==0.15.1+cu118 \
    torchaudio==2.0.1+cu118 \
    torchtext==0.15.1 \
    torchdata==0.6.0 \
    triton==2.0.0 \
    xformers==0.0.19

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

# Forward these build-args to the runtime environment
ENV KOHYA_TRAINER_BRANCH=${KOHYA_TRAINER_BRANCH}

# Copy entrypoint.sh
COPY ./rootfs/ /

# Set the entrypoint
ENTRYPOINT [ "/entrypoint.sh" ]

# Run notebook
CMD ["jupyter", "notebook", "--ip='*'", "--port=8888", "--no-browser"]
