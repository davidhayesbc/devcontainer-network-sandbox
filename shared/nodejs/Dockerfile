# Base image with Node.js 20 LTS
FROM mcr.microsoft.com/devcontainers/javascript-node:1-20-bookworm

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
    && apt-get clean -y \
    && rm -rf /var/lib/apt/lists/*

# Configure git
RUN git config --global credential.helper store

# Configure NPM to use proxy
RUN npm config set proxy http://proxy:3128 \
    && npm config set https-proxy http://proxy:3128 \
    && npm config set strict-ssl false

# Install common global packages (through proxy)
RUN npm install -g \
    typescript \
    eslint \
    prettier \
    nodemon \
    || true

# Set the working directory
WORKDIR /workspaces

# Switch to node user
USER node
