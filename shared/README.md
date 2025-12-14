# DevContainer Network Sandbox - Shared Components

This directory contains reusable devcontainer components for network-sandboxed development with GitHub Copilot support.

## 🎯 Purpose

These files are designed to be shared across multiple projects via:

- **Git submodule** (recommended)
- Direct copy for standalone use
- Reference from a central templates repository

## 📦 Contents

```
shared/
├── base/
│   ├── dockerfiles/
│   │   ├── Dockerfile.dotnet    # .NET development image
│   │   ├── Dockerfile.node      # Node.js development image
│   │   └── Dockerfile.python    # Python development image
│   ├── proxy/
│   │   └── squid.conf.template  # Proxy configuration template
│   └── scripts/
│       └── post-create.sh       # Dependency installation script
├── tools/
│   ├── update-network-policy.ps1      # Regenerate proxy config
│   ├── switch-profile.ps1             # Change network profiles
│   ├── add-allowed-domain.ps1         # Add domain to allowlist
│   ├── remove-allowed-domain.ps1      # Remove domain
│   └── view-blocked-requests.ps1      # View blocked traffic
└── templates/
    ├── nodejs/
    │   └── post-create.sh      # Node.js specific setup
    └── python/
        └── post-create.sh      # Python specific setup
```

## 🔧 Using as a Shared Repository

### Setup (One Time per Organization)

1. **Create the shared repository:**

   ```bash
   # Create a new repo (e.g., devcontainer-network-sandbox)
   gh repo create yourorg/devcontainer-network-sandbox --public

   # Extract this directory
   cd /path/to/Game/.devcontainer
   cp -r shared /tmp/devcontainer-network-sandbox
   cd /tmp/devcontainer-network-sandbox

   # Initialize and push
   git init
   git add .
   git commit -m "Initial commit: Network-sandboxed devcontainer templates"
   git remote add origin https://github.com/yourorg/devcontainer-network-sandbox.git
   git push -u origin main
   ```

### Using in Projects

#### Option 1: Git Submodule (Recommended)

```bash
# In your project repository
cd .devcontainer
git submodule add https://github.com/yourorg/devcontainer-network-sandbox.git shared
git commit -m "Add devcontainer shared components as submodule"
```

**Update shared components:**

```bash
cd .devcontainer/shared
git pull origin main
cd ../..
git add .devcontainer/shared
git commit -m "Update shared devcontainer components"
```

#### Option 2: Direct Copy

```bash
# For standalone projects without git submodule
cd .devcontainer
git clone https://github.com/yourorg/devcontainer-network-sandbox.git shared
rm -rf shared/.git  # Remove git metadata
```

#### Option 3: Download on Container Creation

Add to `devcontainer.json`:

```json
{
  "initializeCommand": "curl -L https://github.com/yourorg/devcontainer-network-sandbox/archive/main.tar.gz | tar xz -C .devcontainer/shared --strip-components=1"
}
```

## 📋 Project-Specific Files

Projects using these shared components should maintain:

```
your-project/
└── .devcontainer/
    ├── shared/                    # Git submodule → this repo
    ├── devcontainer.json         # Project-specific VS Code config
    ├── docker-compose.yml        # References shared/base/dockerfiles
    ├── network-policy.json       # Project-specific network rules
    ├── network-policy.schema.json
    ├── proxy/
    │   └── squid.conf           # Generated from network-policy.json
    └── README.md                # Project-specific quick start
```

### devcontainer.json Template

```json
{
  "name": "Your Project Name",
  "dockerComposeFile": "docker-compose.yml",
  "service": "devcontainer",
  "workspaceFolder": "/workspaces/${localWorkspaceFolderBasename}",

  "postCreateCommand": ".devcontainer/shared/base/scripts/post-create.sh",

  "customizations": {
    "vscode": {
      "extensions": [
        "GitHub.copilot",
        "GitHub.copilot-chat"
        // Add language-specific extensions
      ],
      "settings": {
        "http.proxy": "http://proxy:3128",
        "http.proxyStrictSSL": false
      }
    }
  },

  "remoteUser": "vscode",
  "forwardPorts": [3000, 5000] // Adjust for your project
}
```

### docker-compose.yml Template

```yaml
version: "3.8"

services:
  proxy:
    image: ubuntu/squid:latest
    container_name: yourproject-proxy
    volumes:
      - ./proxy/squid.conf:/etc/squid/squid.conf:ro
      - squid-cache:/var/spool/squid
    ports:
      - "3128:3128"
    networks:
      - devcontainer-network
    restart: unless-stopped
    healthcheck:
      test: ["CMD", "squidclient", "-h", "localhost", "mgr:info"]
      interval: 30s
      timeout: 10s
      retries: 3

  devcontainer:
    build:
      context: ./shared/base/dockerfiles
      dockerfile: Dockerfile.dotnet # or Dockerfile.node, Dockerfile.python
    container_name: yourproject-devcontainer
    volumes:
      - workspace-data:/workspaces
      - ./shared/base/scripts:/tmp/devcontainer-scripts:ro
      - ~/.gitconfig:/home/vscode/.gitconfig:ro
      - ~/.ssh:/home/vscode/.ssh:ro
    environment:
      - REPO_URL=https://github.com/yourorg/yourrepo.git
      - REPO_NAME=yourrepo
      - NETWORK_PROFILE=strict
    networks:
      - devcontainer-network
    depends_on:
      proxy:
        condition: service_healthy
    command: sleep infinity
    cap_drop:
      - NET_RAW
    dns:
      - 8.8.8.8

networks:
  devcontainer-network:
    driver: bridge
    internal: false

volumes:
  workspace-data:
    name: yourproject-workspace
  squid-cache:
    name: yourproject-squid-cache
```

## 🔄 Updating Shared Components

### For Template Maintainers

```bash
# Make changes to shared components
cd shared/
# Edit files...

# Commit and push
git add .
git commit -m "Update: description of changes"
git push origin main
```

### For Project Users

```bash
# Update submodule to latest
cd .devcontainer/shared
git pull origin main
cd ../..
git add .devcontainer/shared
git commit -m "Update shared devcontainer components"
git push
```

## 🛠️ Management Tools

All management scripts in `tools/` are PowerShell and work cross-platform:

```powershell
# Switch network profile
.devcontainer/shared/tools/switch-profile.ps1 development

# Add allowed domain
.devcontainer/shared/tools/add-allowed-domain.ps1 api.example.com

# View blocked requests
.devcontainer/shared/tools/view-blocked-requests.ps1 50

# Update proxy configuration
.devcontainer/shared/tools/update-network-policy.ps1
```

These scripts operate on the project-level `network-policy.json` file.

## 📚 Customization

### Adding a New Language

1. Create `Dockerfile.<language>` in `base/dockerfiles/`
2. Create language-specific setup in `templates/<language>/`
3. Document required network domains
4. Update this README

### Modifying Base Images

Base images are designed to be minimal. Projects can:

- Extend Dockerfiles in their own `.devcontainer/`
- Add project-specific tools in `postCreateCommand`
- Use VS Code features for additional tooling

### Network Policy

Projects control their own network access via `network-policy.json`. The shared components:

- Provide the proxy infrastructure
- Supply management tools
- Include sensible defaults

Each project determines:

- Active profile (strict/development/open)
- Custom allowlists
- Copilot endpoint configuration

## 🔐 Security Benefits

- **Audit trail**: All network changes tracked in git
- **Consistency**: Same security posture across projects
- **Easy updates**: Security improvements propagate to all projects
- **Review process**: Network policy changes visible in PRs

## 📖 Documentation

For detailed usage instructions, see:

- Project-level README.md
- [Network Policy Configuration](../network-policy.json)
- [VS Code DevContainers Docs](https://code.visualstudio.com/docs/devcontainers)

## 🆘 Support

Issues with shared components:

- File issues in the shared repository
- Discuss in your organization's dev channels
- Review project-level logs with `view-blocked-requests.ps1`

---

**This shared repository enables consistent, secure development environments across all your projects!** 🚀
