# DevContainer Network Sandboxing for Game Project

Complete devcontainer setup with network access control, GitHub Copilot support, and automatic repository cloning.

## Features

✅ Full network sandboxing with filtering proxy
✅ Allowlist-based access control (deny-by-default)
✅ Multiple network profiles (strict, development, open)
✅ GitHub Copilot pre-configured and working
✅ Auto-clone repository on container creation
✅ Simple JSON-based configuration
✅ Helper scripts for easy management
✅ Ready-to-use templates for .NET, Node.js, Python
✅ Everything in source control

## Quick Start

```bash
# 1. Open in VS Code
code /path/to/Game

# 2. Reopen in container
# Press F1 -> "Dev Containers: Reopen in Container"

# 3. Wait for initialization
# Repository will be cloned and built automatically
```

## Network Profiles

**Strict** (default): Minimal access - NuGet, GitHub, Copilot only
**Development**: Adds common dev services (npm, docker.io, stackoverflow)
**Open**: Unrestricted (not recommended)

## Managing Network Access

```powershell
# Switch profiles
.devcontainer/shared/tools/switch-profile.ps1 development

# Add individual domains
.devcontainer/shared/tools/add-allowed-domain.ps1 example.com

# View blocked requests
.devcontainer/shared/tools/view-blocked-requests.ps1

# Edit directly
# Edit .devcontainer/network-policy.json, then:
.devcontainer/shared/tools/update-network-policy.ps1
```

## How It Works

```
┌─────────────────┐
│  Dev Container  │
│   (Your Code)   │
└────────┬────────┘
         │ All traffic
         ▼
┌─────────────────┐
│  Squid Proxy    │◄── Enforces allowlist from
│  (Filter)       │    network-policy.json
└────────┬────────┘
         │ Allowed only
         ▼
     Internet
```

1. Dev container routes all traffic through Squid proxy
2. Squid checks domain against allowlist in `network-policy.json`
3. Allowed: Pass through | Blocked: Deny and log
4. Simple JSON config controls what's allowed
5. Helper scripts make changes easy

## Using Templates for Other Projects

### Node.js Project

```bash
# Copy Node.js template
cp -r .devcontainer/shared/shared/nodejs/templates/.devcontainer /path/to/node-project/

# Update repo settings
cd /path/to/node-project/.devcontainer
# Edit docker-compose.yml: REPO_URL and REPO_NAME

# Update network policy for npm
# Already includes: registry.npmjs.org
```

### Python Project

```bash
# Copy Python template
cp -r .devcontainer/shared/shared/python/templates/.devcontainer /path/to/python-project/

# Update repo settings
cd /path/to/python-project/.devcontainer
# Edit docker-compose.yml: REPO_URL and REPO_NAME

# Network policy includes: pypi.org, files.pythonhosted.org
```

## Directory Structure

```
.devcontainer/
├── README.md                   # Full documentation
├── devcontainer.json          # VS Code config
├── docker-compose.yml         # Multi-service setup
├── shared/shared/dotnet/Dockerfile   # .NET image (shared location)
├── network-policy.json        # Access control ⭐
├── proxy/
│   └── squid.conf            # Proxy config (auto-generated)
├── scripts/
│   ├── switch-profile.sh     # Change profiles
│   ├── add-allowed-domain.sh # Add domain
│   └── view-blocked-requests.sh
└── templates/
    ├── nodejs/               # Node.js template
    ├── python/              # Python template
    └── README.md            # Template docs
```

## Configuration Files

### network-policy.json

Controls all network access:

```json
{
    "activeProfile": "strict",
    "profiles": {
        "strict": {
            "allowedDomains": ["github.com", "api.nuget.org", ".githubusercontent.com"]
        }
    },
    "customAllowlist": {
        "domains": []
    }
}
```

### docker-compose.yml

Repository and environment:

```yaml
environment:
    - REPO_URL=https://github.com/davidhayesbc/Game.git
    - REPO_NAME=Game
    - NETWORK_PROFILE=strict
```

## Troubleshooting

### Package restore fails

```powershell
# Check what's being blocked
.devcontainer/shared/tools/view-blocked-requests.ps1

# Add the domain
.devcontainer/shared/tools/add-allowed-domain.ps1 blocked-domain.com
```

### Copilot not working

```powershell
# Verify Copilot domains are in config
Select-String "copilot" .devcontainer/proxy/squid.conf

# Regenerate config if needed
.devcontainer/shared/tools/update-network-policy.ps1
```

### Start over

```bash
# Rebuild container
# F1 -> "Dev Containers: Rebuild Container"
```

## Security Benefits

✅ **Audit outbound access**: All connections logged and controlled
✅ **Review in PRs**: Network policy changes visible in git
✅ **Principle of least privilege**: Start strict, add as needed
✅ **Copilot sandboxed**: Copilot works but can't access arbitrary services
✅ **No data exfiltration**: Code can't phone home without approval
✅ **Team consistency**: Everyone uses same network rules

## Future Enhancements

-   [ ] LiteLLM integration for Copilot logging
-   [ ] Pre-commit hooks to validate network-policy.json
-   [ ] Automated tests for network isolation
-   [ ] More language templates (Go, Rust, Java)
-   [ ] Network usage analytics dashboard

## Documentation

-   [Full README](.devcontainer/README.md) - Complete setup guide
-   [Templates README](.devcontainer/shared/shared/templates/nodejs/README.md) - Node.js template (similar location for Python in the same folder)

## Support

Check logs and blocked requests:

```powershell
.devcontainer/shared/tools/view-blocked-requests.ps1 50
```

Verify proxy is running:

```bash
docker ps | grep proxy
```

Test connectivity:

```bash
docker exec game-economy-devcontainer curl -v http://api.nuget.org
```

---

**This setup is ready to use and fully source controlled!** 🎉
