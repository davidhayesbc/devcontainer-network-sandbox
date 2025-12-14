# DevContainer with Network Sandboxing

This directory contains a complete devcontainer setup with network access control for secure development with GitHub Copilot.

Note: Templates and shared components are provided by the `devcontainer-network-sandbox` repository and exposed as a submodule at `.devcontainer/shared`. The top-level `.devcontainer/templates` is a symlink pointing to `.devcontainer/shared/templates` for backward compatibility and convenience.

## 🔒 Key Features

- **Network Sandboxing**: All outbound traffic goes through a filtering proxy
- **Allowlist-Based**: Default deny with explicit domain allowlisting
- **Multiple Profiles**: Switch between strict, development, and open modes
- **Simple Management**: JSON-based configuration with helper scripts
- **Git Integration**: Auto-clones repository into container on creation
- **Copilot Ready**: Pre-configured with required endpoints for GitHub Copilot

## 🚀 Quick Start

### Prerequisites

- Docker and Docker Compose installed
- VS Code with Remote - Containers extension
- Git credentials configured on host machine

### First Time Setup

1. **Open in devcontainer**:

   ```bash
   # In VS Code, press F1 and select:
   # "Dev Containers: Reopen in Container"
   ```

2. **Wait for initialization**:

   - Repository will be cloned into `/workspaces/Game`
   - NuGet packages will be restored
   - Container will use the `strict` network profile by default

3. **Verify Copilot is working**:
   - Open any C# file
   - Start typing - Copilot suggestions should appear

## 📁 Directory Structure

```
.devcontainer/
├── devcontainer.json          # Main devcontainer configuration
├── docker-compose.yml         # Multi-service setup
├── shared/shared/dotnet/Dockerfile   # .NET development container image (shared location)
├── network-policy.json        # Network access control configuration
├── network-policy.schema.json # JSON schema for validation
├── proxy/
│   ├── squid.conf            # Active Squid proxy configuration
│   └── squid.conf.template   # Template for generating configs
└── scripts/
    ├── post-create.sh                # Restore packages and build
    ├── update-network-policy.sh      # Regenerate proxy config
    ├── switch-profile.sh             # Switch network profiles
    ├── add-allowed-domain.sh         # Add domain to allowlist
    ├── remove-allowed-domain.sh      # Remove domain from allowlist
    └── view-blocked-requests.sh      # View blocked traffic logs
```

## 🌐 Network Profiles

### Strict (Default)

Minimal access for .NET development with Copilot:

- `github.com` and `*.githubusercontent.com`
- `api.nuget.org` and `*.nuget.org`
- GitHub Copilot API endpoints

### Development

Adds common development services:

- All strict profile domains
- `registry.npmjs.org` (NPM)
- `*.docker.io` (Docker Hub)
- `*.microsoft.com`
- `stackoverflow.com`

### Open

**Not recommended** - Allows all outbound traffic

## 🛠️ Managing Network Access

> **Cross-Platform:** All management scripts are PowerShell (`.ps1`) and work on Windows, Mac, and Linux. Run them from your host machine.

### Switch Profiles

```powershell
# Switch to development profile
.devcontainer/shared/tools/switch-profile.ps1 development

# Switch back to strict
.devcontainer/shared/tools/switch-profile.ps1 strict
```

### Add Individual Domains

```powershell
# Add a single domain
.devcontainer/shared/tools/add-allowed-domain.ps1 example.com

# Add with wildcard for subdomains
.devcontainer/shared/tools/add-allowed-domain.ps1 .example.com
```

### Remove Domains

```powershell
.devcontainer/shared/tools/remove-allowed-domain.ps1 example.com
```

### Edit Directly

Edit `.devcontainer/network-policy.json`:

```json
{
  "activeProfile": "strict",
  "customAllowlist": {
    "domains": ["myapi.com", ".cdn.example.com"]
  }
}
```

Then apply changes:

```powershell
.devcontainer/shared/tools/update-network-policy.ps1
```

### View Blocked Requests

```powershell
# See last 20 blocked requests
.devcontainer/shared/tools/view-blocked-requests.ps1

# See last 50 blocked requests
.devcontainer/shared/tools/view-blocked-requests.ps1 50
```

## 📝 Editing network-policy.json

The configuration file supports:

```json
{
  "activeProfile": "strict|development|open",

  "profiles": {
    "strict": {
      "description": "Profile description",
      "allowedDomains": ["domain1.com", ".wildcard.com"],
      "allowedIPs": [],
      "blockAll": true
    }
  },

  "customAllowlist": {
    "description": "Always allowed regardless of profile",
    "domains": ["custom.com"],
    "ips": []
  }
}
```

### Domain Matching Rules

- `example.com` - Matches exactly `example.com`
- `.example.com` - Matches `example.com` and all subdomains (`api.example.com`, `cdn.example.com`, etc.)
- `*.example.com` - Matches only subdomains (NOT the root domain)

## 🔍 Troubleshooting

### NuGet Restore Fails

Check if NuGet domains are allowed:

```bash
# View blocked requests
.devcontainer/shared/tools/view-blocked-requests.sh | grep nuget

# Ensure you're using strict or development profile
cat .devcontainer/network-policy.json | grep activeProfile
```

### Copilot Not Working

Verify Copilot endpoints are accessible:

```bash
# Check squid configuration includes Copilot domains
grep copilot .devcontainer/proxy/squid.conf

# Check for blocked Copilot requests
.devcontainer/shared/tools/view-blocked-requests.sh | grep -E "copilot|github"
```

### Need to Access New Service

1. Try the request and note the blocked domain from logs
2. Add the domain to allowlist
3. Update and restart proxy

```bash
.devcontainer/shared/tools/view-blocked-requests.sh
.devcontainer/shared/tools/add-allowed-domain.sh newservice.com
```

### Rebuild Container

```bash
# From VS Code command palette (F1):
# "Dev Containers: Rebuild Container"

# Or from host terminal:
cd .devcontainer
docker-compose down
docker-compose up --build -d
```

## 🔧 Advanced Configuration

### Customize for Different Projects

The setup is designed to be templated. Key files to modify:

1. **Repository URL**: Edit `docker-compose.yml`

   ```yaml
   environment:
     - REPO_URL=https://github.com/yourorg/yourrepo.git
     - REPO_NAME=yourrepo
   ```

2. **Different Language Stack**: Create new Dockerfile

   ```bash
   # Copy and modify for Node.js
   cp dotnet/Dockerfile nodejs/Dockerfile
   # Edit shared/shared/nodejs/Dockerfile to use node base image
   # Update docker-compose.yml to use new Dockerfile
   ```

3. **Add Custom Tools**: Edit `dotnet/Dockerfile`
   ```dockerfile
   RUN apt-get install -y your-tool
   ```

### Monitor All Traffic

Enable logging of allowed requests in `network-policy.json`:

```json
{
  "logging": {
    "enabled": true,
    "logAllowed": true,
    "logBlocked": true
  }
}
```

Then regenerate config:

```bash
.devcontainer/shared/tools/update-network-policy.sh
```

View all traffic:

```bash
docker exec game-economy-proxy tail -f /var/log/squid/access.log
```

### Use with LiteLLM (Future)

To add LiteLLM proxy for logging Copilot API calls:

1. Add LiteLLM service to `docker-compose.yml`
2. Configure to proxy between Copilot and container
3. Update allowlist to include LiteLLM endpoints
4. Configure VS Code to use LiteLLM proxy

## 📋 Version Control

All configuration is in version control:

- `network-policy.json` - Track allowed domains per project
- `docker-compose.yml` - Service configuration
- `Dockerfile.*` - Development environment dependencies
- `scripts/` - Automation and management tools

Changes to network policy can be reviewed in PRs just like code.

## 🎯 Best Practices

1. **Start Strict**: Begin with `strict` profile and add domains as needed
2. **Document Additions**: Add comments in `network-policy.json` explaining why domains are needed
3. **Review Logs Regularly**: Check blocked requests to ensure no needed services are blocked
4. **Use Wildcards Carefully**: `.example.com` is safer than `*` when you control the domain
5. **Test Profile Changes**: Verify builds/tests work after changing profiles
6. **Commit Policy Changes**: Keep `network-policy.json` in git to track security posture

## 🚢 Deploying to Team

To share this setup with your team:

1. **Commit all `.devcontainer/` files** to your repository
2. **Document required credentials**: Git, any tokens needed
3. **Team members run**:
   ```bash
   git pull
   # Open in VS Code
   # F1 -> "Dev Containers: Reopen in Container"
   ```

Everyone gets identical sandboxed environments!

## 📚 Additional Resources

- [VS Code Dev Containers](https://code.visualstudio.com/docs/devcontainers/containers)
- [Squid Proxy Documentation](http://www.squid-cache.org/Doc/)
- [GitHub Copilot in Containers](https://docs.github.com/en/copilot)

## 🆘 Support

If you encounter issues:

1. Check logs: `.devcontainer/shared/tools/view-blocked-requests.sh`
2. Verify proxy is running: `docker ps | grep proxy`
3. Test connectivity: `docker exec game-economy-devcontainer curl -v http://github.com`
4. Rebuild container: "Dev Containers: Rebuild Container" in VS Code
