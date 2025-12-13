# Game Economy DevContainer Setup

Network-sandboxed development environment for the Game Economy simulation project.

## 🚀 Quick Start

This project uses a **shared devcontainer framework** for network-sandboxed development with GitHub Copilot.

### First Time Setup

1. **Open in VS Code:**

    ```bash
    code /path/to/Game
    ```

2. **Reopen in Container:**

    - Press `F1`
    - Select "Dev Containers: Reopen in Container"
    - Wait for initialization (first time: 2-5 minutes)

3. **Start Coding:**
    - Repository is cloned automatically
    - NuGet packages are restored
    - Copilot is ready to use

## 📂 Project Structure

```
.devcontainer/
├── shared/                        # Shared components (can be git submodule)
│   ├── base/
│   │   ├── dockerfiles/          # Language-specific dev images
│   │   ├── proxy/                # Proxy configuration templates
│   │   └── scripts/              # Init scripts
│   ├── tools/                    # Management scripts (PowerShell)
│   └── templates/                # Template-specific setup
├── devcontainer.json             # Project-specific VS Code config
├── docker-compose.yml            # Project-specific services config
├── network-policy.json           # Project network access rules
├── proxy/
│   └── squid.conf               # Generated proxy config (do not edit)
└── README.md                    # This file
```

## 🔒 Network Sandboxing

All outbound traffic goes through a filtering proxy controlled by `network-policy.json`.

### Current Profile: Strict

**Allowed:**

-   `github.com` - Git operations and Copilot
-   `api.nuget.org` - NuGet packages
-   `*.githubusercontent.com` - GitHub resources

**Everything else is blocked by default.**

### Change Network Access

```powershell
# Switch to development profile (more permissive)
.devcontainer/shared/tools/switch-profile.ps1 development

# Add a specific domain
.devcontainer/shared/tools/add-allowed-domain.ps1 stackoverflow.com

# View what's being blocked
.devcontainer/shared/tools/view-blocked-requests.ps1
```

## 🛠️ Management Scripts

All management scripts are in `shared/tools/` and work cross-platform:

| Script                      | Purpose                                           |
| --------------------------- | ------------------------------------------------- |
| `switch-profile.ps1`        | Change network profiles (strict/development/open) |
| `add-allowed-domain.ps1`    | Add domain to custom allowlist                    |
| `remove-allowed-domain.ps1` | Remove domain from allowlist                      |
| `update-network-policy.ps1` | Regenerate proxy config from JSON                 |
| `view-blocked-requests.ps1` | View blocked traffic logs                         |

## 📝 Configuration Files

### network-policy.json

**Project-specific** - Controls network access for this project:

```json
{
    "activeProfile": "strict",
    "customAllowlist": {
        "domains": [
            // Add project-specific domains here
        ]
    }
}
```

After editing, run:

```powershell
.devcontainer/shared/tools/update-network-policy.ps1
```

### devcontainer.json

**Project-specific** - VS Code settings and extensions:

```json
{
    "name": "Game Economy - .NET Dev Container",
    "customizations": {
        "vscode": {
            "extensions": ["ms-dotnettools.csdevkit", "GitHub.copilot"]
        }
    },
    "forwardPorts": [5000, 5001] // Blazor app ports
}
```

### docker-compose.yml

**Project-specific** - Container configuration:

```yaml
environment:
    - REPO_URL=https://github.com/davidhayesbc/Game.git
    - REPO_NAME=Game
    - NETWORK_PROFILE=strict
```

## 🔄 Shared Components

The `shared/` directory contains reusable devcontainer components that can be:

1. **Used directly** (current setup)
2. **Converted to git submodule** for easy updates:

    ```bash
    # Extract shared to separate repo
    cd .devcontainer
    # (create repo from shared/ directory)

    # Then use as submodule
    rm -rf shared
    git submodule add https://github.com/yourorg/devcontainer-network-sandbox.git shared
    ```

See [shared/README.md](shared/README.md) for details on using these components across projects.

## 🐛 Troubleshooting

### NuGet Restore Fails

```powershell
# Check what's blocked
.devcontainer/shared/tools/view-blocked-requests.ps1

# Add the blocked domain
.devcontainer/shared/tools/add-allowed-domain.ps1 blocked-domain.com
```

### Copilot Not Working

Verify Copilot domains are in the proxy config:

```powershell
Select-String "copilot|github" .devcontainer/proxy/squid.conf
```

### Rebuild Container

Press `F1` → "Dev Containers: Rebuild Container"

### Check Logs

```bash
# Inside container
docker logs game-economy-proxy
docker logs game-economy-devcontainer
```

## 📚 Learn More

-   [Shared Components README](shared/README.md) - Using across projects
-   [Full DevContainer Docs](https://code.visualstudio.com/docs/devcontainers)
-   [Network Policy Schema](network-policy.schema.json)

## ✅ What's Working

-   ✅ GitHub Copilot with network sandboxing
-   ✅ NuGet package restoration
-   ✅ Code cloned from GitHub into container
-   ✅ .NET 10 SDK with CSharpier
-   ✅ Blazor Harness app (ports 5000/5001)
-   ✅ Cross-platform management scripts

## 🎯 Project-Specific Notes

This is a **.NET 10** game economy simulation:

-   **Blazor Harness** runs on ports 5000/5001
-   **CSharpier** for code formatting
-   **xUnit** for testing
-   **Strict network policy** by default

---

**Happy Development!** 🎮
