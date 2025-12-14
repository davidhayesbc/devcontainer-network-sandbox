# Base image with Python 3.12
FROM mcr.microsoft.com/devcontainers/python:1-3.12-bookworm

# Set up proxy environment variables
ENV http_proxy=http://proxy:3128
ENV https_proxy=http://proxy:3128
ENV HTTP_PROXY=http://proxy:3128
ENV HTTPS_PROXY=http://proxy:3128
ENV no_proxy=localhost,127.0.0.1,proxy
ENV NO_PROXY=localhost,127.0.0.1,proxy

# Install additional tools
RUN apt-get update && export DEBIAN_FRONTEND=noninteractive \
    && apt-get -y install --no-install-recommends \
    curl \
    ca-certificates \
    git \
    openssh-client \
    build-essential \
    && apt-get clean -y \
    && rm -rf /var/lib/apt/lists/*

# Configure git
RUN git config --global credential.helper store

# Configure pip to use proxy
RUN pip config set global.proxy http://proxy:3128

# Install common packages
RUN pip install --no-cache-dir \
    black \
    flake8 \
    pylint \
    pytest \
    ipython \
    || true

# Set the working directory
WORKDIR /workspaces

# Switch to vscode user
USER vscode
