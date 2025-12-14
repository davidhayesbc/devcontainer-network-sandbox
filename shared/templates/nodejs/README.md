# Node.js DevContainer Template

Network-sandboxed development container for Node.js projects with GitHub Copilot support.

## 🎯 What's Included

-   **Node.js 20 LTS** - Latest long-term support version
-   **NPM & Yarn** - Package managers pre-configured
-   **TypeScript** - Global TypeScript installation
-   **ESLint & Prettier** - Code quality tools
-   **Nodemon** - Auto-reload during development
-   **Network Sandboxing** - Controlled outbound access via proxy
-   **GitHub Copilot** - Pre-configured and ready to use

## 🚀 Quick Start

### 1. Copy Template to Your Project

```bash
# From the Game repository root
cp -r .devcontainer/shared/shared/nodejs/templates/.devcontainer /path/to/your/node-project/

# Or using PowerShell on Windows
Copy-Item -Recurse .devcontainer/shared/shared/nodejs/templates/.devcontainer /path/to/your/node-project/
```

### 2. Configure Repository Settings

Edit `.devcontainer/docker-compose.yml`:

```yaml
environment:
    - REPO_URL=https://github.com/yourorg/yourrepo.git
    - REPO_NAME=yourrepo # Must match the repo name
    - NETWORK_PROFILE=strict
```

### 3. Customize Network Policy (Optional)

The template comes with a `strict` profile that includes:

-   `registry.npmjs.org` - NPM packages
-   `github.com` - Git operations
-   GitHub Copilot endpoints

To add more domains, edit `.devcontainer/network-policy.json`:

```json
{
    "customAllowlist": {
        "domains": ["cdn.example.com", ".yourapi.com"]
    }
}
```

### 4. Open in DevContainer

```bash
# Open your project in VS Code
code /path/to/your/node-project

# Press F1 and select:
# "Dev Containers: Reopen in Container"
```

## 📦 What Happens on First Run

1. **Container builds** using Node.js 20 base image
2. **Repository clones** into `/workspaces/<yourrepo>`
3. **NPM install runs** (if `package.json` exists)
4. **Copilot activates** and is ready to use
5. **Proxy enforces** network policy

## 🛠️ Customizing for Your Project

### Add NPM Global Packages

Edit `.devcontainer/shared/shared/nodejs/Dockerfile`:

```dockerfile
RUN npm install -g \
    typescript \
    eslint \
    prettier \
    nodemon \
    your-package-here \
    || true
```

### Configure VS Code Extensions

Edit `.devcontainer/devcontainer.json`:

```json
{
    "customizations": {
        "vscode": {
            "extensions": [
                "dbaeumer.vscode-eslint",
                "esbenp.prettier-vscode",
                "ms-vscode.vscode-typescript-next",
                "GitHub.copilot",
                "your-extension-here"
            ]
        }
    }
}
```

### Adjust Forwarded Ports

For Express/React/Next.js apps, configure ports in `.devcontainer/devcontainer.json`:

```json
{
    "forwardPorts": [3000, 3001, 5000],
    "portsAttributes": {
        "3000": {
            "label": "App",
            "onAutoForward": "notify"
        }
    }
}
```

### Add Build Scripts

Edit `.devcontainer/shared/shared/nodejs/templates/post-create.sh`:

```bash
# Build TypeScript
npm run build

# Run tests
npm test

# Start development server in background
# npm run dev &
```

## 🌐 Network Policy for Node.js

### Minimum Required Domains

```json
{
    "allowedDomains": ["registry.npmjs.org", ".npmjs.org", "github.com", "api.github.com", ".githubusercontent.com"]
}
```

### Common Additional Domains

```json
{
    "customAllowlist": {
        "domains": [
            ".yarnpkg.com", // If using Yarn
            "registry.yarnpkg.com",
            "cdn.jsdelivr.net", // CDN resources
            "unpkg.com", // Package CDN
            "fonts.googleapis.com", // Google Fonts
            "fonts.gstatic.com"
        ]
    }
}
```

## 📋 Common Workflows

### Install New Package

```bash
# In the devcontainer terminal
npm install express
```

If blocked, check logs and add the domain:

```powershell
# From host machine
.devcontainer/shared/tools/view-blocked-requests.ps1
.devcontainer/shared/tools/add-allowed-domain.ps1 blocked-domain.com
```

### Switch to Development Profile

```powershell
# Allows more services (docker.io, stackoverflow, etc.)
.devcontainer/shared/tools/switch-profile.ps1 development
```

### Debug Network Issues

```powershell
# Check what's being blocked (from host)
.devcontainer/shared/tools/view-blocked-requests.ps1 50
```

```bash
# Test connectivity (in container terminal)
curl -v https://registry.npmjs.org

# Verify proxy settings (in container)
echo $http_proxy  # Should show: http://proxy:3128
```

## 🔧 Project Type Examples

### Express.js API

```javascript
// package.json
{
  "scripts": {
    "dev": "nodemon src/index.js",
    "start": "node src/index.js"
  }
}
```

Forward port 3000 in `devcontainer.json`.

### React App (Create React App)

```bash
# NPM dependencies auto-install
# Start dev server
npm start
```

Forward port 3000 in `devcontainer.json`.

### Next.js Application

```bash
# Install dependencies (auto-runs)
# Development
npm run dev
```

Forward ports 3000 and 3001 in `devcontainer.json`.

### TypeScript Project

The template includes TypeScript globally. For project-specific config:

```json
// tsconfig.json
{
    "compilerOptions": {
        "target": "ES2020",
        "module": "commonjs",
        "outDir": "./dist"
    }
}
```

## 🐛 Troubleshooting

### NPM Install Fails

```powershell
# Check blocked requests
.devcontainer/shared/tools/view-blocked-requests.ps1

# Try development profile
.devcontainer/shared/tools/switch-profile.ps1 development
```

### Yarn Not Working

```powershell
# Add Yarn registry
.devcontainer/shared/tools/add-allowed-domain.ps1 registry.yarnpkg.com
.devcontainer/shared/tools/add-allowed-domain.ps1 .yarnpkg.com
```

### Port Not Forwarding

Check `.devcontainer/devcontainer.json`:

```json
{
    "forwardPorts": [3000],
    "portsAttributes": {
        "3000": {
            "label": "App",
            "onAutoForward": "notify"
        }
    }
}
```

### Package from Private Registry

Add your registry domain:

```powershell
.devcontainer/shared/tools/add-allowed-domain.ps1 registry.yourcompany.com
```

Or edit `network-policy.json` directly.

## 📚 Additional Resources

-   [Node.js in Containers](https://code.visualstudio.com/docs/containers/overview)
-   [NPM Proxy Configuration](https://docs.npmjs.com/cli/v9/using-npm/config#proxy)
-   [DevContainer Node Features](https://github.com/devcontainers/features/tree/main/src/node)

## 🔄 Keeping Template Updated

When Node.js LTS versions change:

1. Update base image in `nodejs/Dockerfile`:

    ```dockerfile
    FROM mcr.microsoft.com/devcontainers/javascript-node:1-22-bookworm
    ```

2. Test thoroughly with your projects

3. Update this README with new version number

## ✅ Checklist for New Projects

-   [ ] Copy template to project directory
-   [ ] Update `REPO_URL` in `docker-compose.yml`
-   [ ] Update `REPO_NAME` in `docker-compose.yml`
-   [ ] Add project-specific domains to `network-policy.json`
-   [ ] Configure forwarded ports for your app
-   [ ] Add project-specific VS Code extensions
-   [ ] Update `post-create.sh` with build commands
-   [ ] Test container build and network access
-   [ ] Commit `.devcontainer/` to version control

---

**Happy Node.js Development in a Sandboxed Container!** 🚀
