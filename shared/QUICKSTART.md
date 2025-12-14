# DevContainer Templates Quick Start

Get up and running with network-sandboxed development containers in minutes.

## 🎯 What Are These Templates?

Pre-configured development environments that:

-   ✅ **Clone your code** from GitHub into an isolated container
-   ✅ **Sandbox network access** - only allowed domains can be reached
-   ✅ **Enable GitHub Copilot** with proper API access
-   ✅ **Include language tools** - SDKs, formatters, linters ready to go
-   ✅ **Work cross-platform** - Windows, Mac, Linux with Docker

## 📦 Available Templates

| Template                     | Use For                    | Base Image  | Package Manager |
| ---------------------------- | -------------------------- | ----------- | --------------- |
| [.NET](../Dockerfile.dotnet) | ASP.NET, Blazor, C#        | .NET 10 SDK | NuGet           |
| [Node.js](nodejs/)           | Express, React, Next.js    | Node 20 LTS | NPM/Yarn        |
| [Python](python/)            | Flask, Django, FastAPI, ML | Python 3.12 | pip/Poetry      |

## ⚡ Quick Start (3 Steps)

### Step 1: Copy Template

Choose your language and copy the template:

**For .NET (from Game project root):**

```powershell
# The .NET template is already configured in this project
# Just use it as-is or copy to another .NET project
Copy-Item -Recurse .devcontainer /path/to/other-dotnet-project/
```

**For Node.js:**

```powershell
Copy-Item -Recurse .devcontainer/templates/nodejs/.devcontainer /path/to/your/node-project/
```

**For Python:**

```powershell
Copy-Item -Recurse .devcontainer/templates/python/.devcontainer /path/to/your/python-project/
```

### Step 2: Configure Your Repository

Edit `.devcontainer/docker-compose.yml` in your project:

```yaml
environment:
    - REPO_URL=https://github.com/yourorg/yourrepo.git
    - REPO_NAME=yourrepo # Must match repo name exactly
    - NETWORK_PROFILE=strict
```

### Step 3: Open in Container

```bash
# Open your project in VS Code
code /path/to/your/project

# Press F1 and type/select:
"Dev Containers: Reopen in Container"

# Wait for initialization (first time takes 2-5 minutes)
```

That's it! Your code is now running in a sandboxed container with Copilot.

## 🌐 Network Profiles Explained

Each template includes 3 profiles:

### Strict (Default) ✅ Recommended

**What's allowed:**

-   GitHub (for git operations and Copilot)
-   Language package manager (NuGet, NPM, PyPI)
-   Nothing else

**Use when:** You want maximum security

### Development

**What's allowed:**

-   Everything in Strict, plus:
-   Docker Hub
-   Stack Overflow
-   Microsoft sites
-   Common CDNs

**Use when:** You need common development resources

### Open ⚠️ Not Recommended

**What's allowed:**

-   Everything (no restrictions)

**Use when:** Debugging network issues only

## 🔧 Common Customizations

### Change Network Profile

```powershell
.devcontainer/shared/tools/switch-profile.ps1 development
```

### Add Single Domain

```powershell
.devcontainer/shared/tools/add-allowed-domain.ps1 api.example.com
```

### Add Multiple Domains

Edit `.devcontainer/network-policy.json`:

```json
{
    "customAllowlist": {
        "domains": ["api.example.com", "cdn.example.com", ".yourdomain.com"]
    }
}
```

Then update the proxy config:

```powershell
.devcontainer/shared/tools/update-network-policy.ps1
```

### See What's Blocked

```powershell
.devcontainer/shared/tools/view-blocked-requests.ps1 50
```

## 🎨 Template-Specific Setup

### .NET Projects

**Ports to forward (in devcontainer.json):**

```json
{
    "forwardPorts": [5000, 5001] // HTTP, HTTPS
}
```

**Common additional domains:**

-   `mcr.microsoft.com` - Microsoft container registry
-   `*.visualstudio.com` - Visual Studio services

**See:** Main `.devcontainer/README.md`

### Node.js Projects

**Ports to forward (in devcontainer.json):**

```json
{
    "forwardPorts": [3000, 3001] // Next.js, React, Express
}
```

**Common additional domains:**

-   `registry.yarnpkg.com` - Yarn packages
-   `cdn.jsdelivr.net` - CDN
-   `unpkg.com` - Package CDN

**See:** [Node.js Template README](nodejs/README.md)

### Python Projects

**Ports to forward (in devcontainer.json):**

```json
{
    "forwardPorts": [8000, 8888] // Django/FastAPI, Jupyter
}
```

**Common additional domains:**

-   `download.pytorch.org` - PyTorch models
-   `storage.googleapis.com` - TensorFlow
-   `huggingface.co` - ML models

**See:** [Python Template README](python/README.md)

## 📝 File Structure After Setup

```
your-project/
├── .devcontainer/
│   ├── devcontainer.json          # VS Code config
│   ├── docker-compose.yml         # Services (edit REPO_URL here)
│   ├── Dockerfile.{lang}          # Language-specific image
│   ├── network-policy.json        # Network rules (edit to allow domains)
│   ├── proxy/
│   │   └── squid.conf            # Auto-generated proxy config
│   └── scripts/
│       ├── *.sh                  # Bash scripts (run in container)
│       └── *.ps1                 # PowerShell scripts (run anywhere)
├── src/                           # Your code (auto-cloned)
├── package.json                   # Node.js
├── requirements.txt              # Python
└── YourProject.csproj            # .NET
```

## 🔍 Troubleshooting

### Container Won't Start

```bash
# Check Docker is running
docker ps

# Rebuild from scratch
# F1 -> "Dev Containers: Rebuild Container"
```

### Package Install Fails

```powershell
# Check what's being blocked
.devcontainer/shared/tools/view-blocked-requests.ps1

# Add the blocked domain
.devcontainer/shared/tools/add-allowed-domain.ps1 blocked-domain.com
```

### Copilot Not Working

```powershell
# Verify Copilot domains are allowed
Select-String "copilot|github" .devcontainer/proxy/squid.conf

# Should see:
# acl allowed_domains dstdomain github.com
# acl allowed_domains dstdomain api.github.com
# acl allowed_domains dstdomain .githubusercontent.com
# acl allowed_domains dstdomain copilot-proxy.githubusercontent.com
```

### Can't Clone Repository

Check `docker-compose.yml`:

-   `REPO_URL` is correct and accessible
-   `REPO_NAME` matches the repository name exactly
-   You have git credentials set up (see below)

### Git Authentication

The container uses your host machine's git credentials:

```bash
# On host, ensure credentials are configured
git config --global user.name "Your Name"
git config --global user.email "your@email.com"

# For HTTPS repos, you may need a credential helper
git config --global credential.helper store

# Or use SSH keys (keys are mounted into container)
```

## 🚀 Advanced Usage

### Multiple Profiles for Different Environments

Create custom profiles in `network-policy.json`:

```json
{
    "profiles": {
        "strict": {
            /* ... */
        },
        "development": {
            /* ... */
        },
        "production-debug": {
            "description": "Production debugging with specific APIs",
            "allowedDomains": [
                "github.com",
                "api.github.com",
                ".githubusercontent.com",
                "api.production.com",
                "monitoring.production.com"
            ],
            "blockAll": true
        }
    }
}
```

### Share Templates Across Organization

1. Create a dedicated "devcontainer-templates" repository
2. Copy each template to its own directory
3. Developers clone and copy to their projects:

```bash
git clone https://github.com/yourorg/devcontainer-templates
cp -r devcontainer-templates/nodejs/.devcontainer ./my-project/
```

### CI/CD Integration

The devcontainer can be used in CI:

```yaml
# GitHub Actions example
- name: Run tests in devcontainer
  uses: devcontainers/ci@v0.3
  with:
      runCmd: npm test
```

## 📚 Learn More

-   **Main Documentation:** [../.devcontainer/README.md](../README.md)
-   **Template List:** [README.md](README.md)
-   **Node.js Template:** [nodejs/README.md](nodejs/README.md)
-   **Python Template:** [python/README.md](python/README.md)
-   **VS Code DevContainers:** [code.visualstudio.com/docs/devcontainers](https://code.visualstudio.com/docs/devcontainers/containers)

## ✅ Success Checklist

After setting up your devcontainer:

-   [ ] Container builds successfully
-   [ ] Repository clones automatically
-   [ ] Dependencies install (packages restore)
-   [ ] GitHub Copilot works
-   [ ] Your app/tests run
-   [ ] Network policy is appropriate (strict by default)
-   [ ] `.devcontainer/` committed to git
-   [ ] Team can use same setup

## 🆘 Getting Help

1. **Check logs:** `.devcontainer/shared/tools/view-blocked-requests.ps1`
2. **Verify proxy:** `docker ps | grep proxy`
3. **Test network:** `curl -v https://github.com` (in container)
4. **Rebuild:** F1 → "Dev Containers: Rebuild Container"
5. **Review docs:** Check template-specific README

---

**You're ready to develop in a secure, sandboxed environment!** 🎉
