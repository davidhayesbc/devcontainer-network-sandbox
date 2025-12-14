# Base image with .NET 10 SDK
FROM mcr.microsoft.com/devcontainers/dotnet:dev-10.0

# Set up proxy environment variables (will be configured by docker-compose)
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

# Configure git to use credential helper
RUN git config --global credential.helper store

# Deploy a unified NuGet config for root and the vscode user
RUN mkdir -p /root/.nuget/NuGet /home/vscode/.nuget/NuGet
COPY nuget.config /root/.nuget/NuGet/NuGet.Config
RUN cp /root/.nuget/NuGet/NuGet.Config /home/vscode/.nuget/NuGet/NuGet.Config && chown -R vscode:vscode /home/vscode/.nuget

# Install CSharpier globally (through proxy)
RUN dotnet tool install -g csharpier || true

# Add dotnet tools to PATH
ENV PATH="${PATH}:/home/vscode/.dotnet/tools"

# Set the working directory
WORKDIR /workspaces

# Switch to vscode user
USER vscode

# NuGet config for the vscode user is deployed earlier to avoid duplicate copying
