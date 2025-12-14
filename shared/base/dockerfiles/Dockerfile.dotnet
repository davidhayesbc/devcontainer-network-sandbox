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

# Install CSharpier globally (through proxy)
RUN dotnet tool install -g csharpier || true

# Add dotnet tools to PATH
ENV PATH="${PATH}:/home/vscode/.dotnet/tools"

# Set the working directory
WORKDIR /workspaces

# Switch to vscode user
USER vscode

# Configure NuGet to use proxy
RUN mkdir -p ~/.nuget/NuGet && \
    echo '<?xml version="1.0" encoding="utf-8"?>\n\
    <configuration>\n\
    <config>\n\
    <add key="http_proxy" value="http://proxy:3128" />\n\
    </config>\n\
    </configuration>' > ~/.nuget/NuGet/NuGet.Config
