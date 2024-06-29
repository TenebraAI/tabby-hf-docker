ARG BUILDKIT_SBOM_SCAN_CONTEXT=true
ARG BUILDKIT_SBOM_SCAN_STAGE=true

# Use an official CUDA runtime with Ubuntu as a parent image
ARG BASE_IMAGE
FROM docker.io/nvidia/cuda:$BASE_IMAGE as build-000

ARG GIT_REPO=https://github.com/theroyallab/tabbyAPI
ARG DO_PULL=true
ENV DO_PULL $DO_PULL

# Set the working directory in the container
WORKDIR /app

# Install system dependencies
RUN apt-get update && apt-get install -y --no-install-recommends \
    build-essential \
    curl \
    ca-certificates \
    python3.11 \
    python3-pip \
    git \
    ssh \
    7zip \
    iputils-ping \
    git-lfs \
    less \
    nano \
    neovim \
    net-tools \
    nvi \
    nvtop \
    rsync \
    tldr \
    tmux \
    unzip \
    vim \
    wget \
    zip \
    zsh \
    && rm -rf /etc/ssh/ssh_host_*

# Set locale
RUN apt-get install -y locales && \
    localedef -i en_US -c -f UTF-8 -A /usr/share/locale/locale.alias en_US.UTF-8
ENV LANG en_US.utf8

# Upgrade
RUN apt-get upgrade -y

# Change global Python
RUN update-alternatives --install /usr/bin/python3 python3 /usr/bin/python3.11 1 \
    && apt-get install -y --no-install-recommends python-is-python3 \
    && rm -rf /var/lib/apt/lists/* 

# Upgrade pip
RUN pip install --no-cache-dir --upgrade pip

# Set up git to support LFS, and to cache credentials; useful for Huggingface Hub
RUN git config --global credential.helper cache && \
    git lfs install

# Update repo
RUN if [ ${DO_PULL} ]; then \
    git init && \
    git remote add origin $GIT_REPO && \
    git fetch origin && \
    git pull origin main && \
    echo "Pull finished"; fi

# Install packages specified in pyproject.toml cu121
RUN pip install --no-cache-dir .[cu121]

# Make port 5000 and 22 available to the world outside this container
EXPOSE 80

# Install Huggingface tools
RUN pip install --no-cache-dir hf_transfer huggingface-hub[cli]

ADD tabby.yaml config/tabby.yaml
ADD entrypoint.sh entrypoint.sh
ADD model_downloader.py model_downloader.py

# Run when the container launches
ENTRYPOINT ["./entrypoint.sh"]
