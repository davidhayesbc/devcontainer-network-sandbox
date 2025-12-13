# Extracting Shared Components to Separate Repository

This guide explains how to extract the shared devcontainer components into a separate repository for use across multiple projects.

## 📋 Prerequisites

-   Git installed
-   GitHub CLI (`gh`) or web access to create repositories
-   Write access to your organization or personal GitHub account

## 🚀 Step 1: Create Shared Repository

### Option A: Using GitHub CLI

```bash
# Create a new public repository
gh repo create yourorg/devcontainer-network-sandbox --public --description "Network-sandboxed devcontainer templates with Copilot support"

# Or create private
gh repo create yourorg/devcontainer-network-sandbox --private --description "Network-sandboxed devcontainer templates with Copilot support"
```

### Option B: Using GitHub Web

1. Go to https://github.com/new
2. Repository name: `devcontainer-network-sandbox`
3. Description: "Network-sandboxed devcontainer templates with Copilot support"
4. Choose public or private
5. Don't initialize with README (we'll push existing code)
6. Create repository

## 📦 Step 2: Extract and Push Shared Components

```bash
# Navigate to the Game project
cd /path/to/Game/.devcontainer

# Copy shared directory to temporary location
cp -r shared /tmp/devcontainer-network-sandbox
cd /tmp/devcontainer-network-sandbox

# Initialize git repository
git init
git add .
git commit -m "Initial commit: Network-sandboxed devcontainer framework

- Base Dockerfiles for .NET, Node.js, Python
- Squid proxy configuration
- PowerShell management tools (cross-platform)
- Container initialization scripts
- Template-specific setup scripts"

# Add remote and push
git remote add origin https://github.com/yourorg/devcontainer-network-sandbox.git
git push -u origin main
```

## 🔗 Step 3: Use Shared Repo in Game Project

### Option A: Git Submodule (Recommended)

```bash
# Navigate to Game project
cd /path/to/Game/.devcontainer

# Remove existing shared directory
rm -rf shared

# Add as submodule
git submodule add https://github.com/yourorg/devcontainer-network-sandbox.git shared

# Commit the submodule
cd ..
git add .devcontainer/shared .gitmodules
git commit -m "Convert shared devcontainer components to git submodule"
git push
```

### Option B: Keep Direct Copy

If you prefer not to use submodules, just keep the current structure. Update manually when needed:

```bash
# Update shared components
cd /path/to/Game/.devcontainer/shared
git pull origin main
cd ..
git add shared
git commit -m "Update shared devcontainer components"
git push
```

## 🔄 Step 4: Update Other Projects

### For New Projects

```bash
# Navigate to your project
cd /path/to/your-project

# Create .devcontainer if it doesn't exist
mkdir -p .devcontainer
cd .devcontainer

# Add shared components as submodule
git submodule add https://github.com/yourorg/devcontainer-network-sandbox.git shared

# Copy project-specific templates from Game
cp /path/to/Game/.devcontainer/devcontainer.json .
cp /path/to/Game/.devcontainer/docker-compose.yml .
cp /path/to/Game/.devcontainer/network-policy.json .
cp /path/to/Game/.devcontainer/network-policy.schema.json .
mkdir -p proxy
cp /path/to/Game/.devcontainer/proxy/squid.conf proxy/

# Customize for your project
# Edit devcontainer.json, docker-compose.yml, network-policy.json

# Commit
cd ..
git add .devcontainer
git commit -m "Add network-sandboxed devcontainer setup"
git push
```

### For Existing Projects with Shared Components

If you already have the shared components copied:

```bash
cd /path/to/existing-project/.devcontainer

# Remove copied shared directory
rm -rf shared

# Add as submodule instead
git submodule add https://github.com/yourorg/devcontainer-network-sandbox.git shared

# Commit
cd ..
git add .devcontainer
git commit -m "Switch to shared devcontainer components submodule"
git push
```

## 📝 Step 5: Working with Submodules

### Clone Project with Submodules

```bash
# Clone and initialize submodules
git clone --recurse-submodules https://github.com/yourorg/your-project.git

# Or if already cloned without submodules
git clone https://github.com/yourorg/your-project.git
cd your-project
git submodule init
git submodule update
```

### Update Shared Components

```bash
# In your project
cd .devcontainer/shared
git pull origin main
cd ../..
git add .devcontainer/shared
git commit -m "Update shared devcontainer components"
git push
```

### Make Changes to Shared Components

```bash
# Clone the shared repo
git clone https://github.com/yourorg/devcontainer-network-sandbox.git
cd devcontainer-network-sandbox

# Make changes
# Edit files...

# Commit and push
git add .
git commit -m "Describe your changes"
git push origin main

# Update in all projects using it
cd /path/to/project/.devcontainer/shared
git pull origin main
cd ../..
git add .devcontainer/shared
git commit -m "Update shared devcontainer components"
git push
```

## 🏗️ Repository Structure After Setup

### Shared Repository (devcontainer-network-sandbox)

```
devcontainer-network-sandbox/
├── README.md                  # Usage documentation
├── base/
│   ├── dockerfiles/
│   │   ├── Dockerfile.dotnet
│   │   ├── Dockerfile.node
│   │   └── Dockerfile.python
│   ├── proxy/
│   │   └── squid.conf.template
│   └── scripts/
│       ├── on-create.sh
│       └── post-create.sh
├── tools/
│   ├── update-network-policy.ps1
│   ├── switch-profile.ps1
│   ├── add-allowed-domain.ps1
│   ├── remove-allowed-domain.ps1
│   └── view-blocked-requests.ps1
└── templates/
    ├── nodejs/
    │   └── post-create.sh
    └── python/
        └── post-create.sh
```

### Project Repository (e.g., Game)

```
Game/
├── .devcontainer/
│   ├── shared/                    # Git submodule
│   ├── devcontainer.json         # Project-specific
│   ├── docker-compose.yml        # Project-specific
│   ├── network-policy.json       # Project-specific
│   ├── network-policy.schema.json
│   ├── proxy/
│   │   └── squid.conf           # Generated
│   ├── PROJECT-README.md        # Project docs
│   └── MIGRATION.md             # This file
├── Game.Economy/
├── Game.Economy.Tests/
└── ...
```

## ✅ Verification

After setting up, verify:

1. **Shared components are accessible:**

    ```bash
    ls .devcontainer/shared/base/dockerfiles/
    ls .devcontainer/shared/tools/
    ```

2. **Container builds:**

    - Open in VS Code
    - F1 → "Dev Containers: Rebuild Container"
    - Should build successfully

3. **Scripts work:**

    ```powershell
    .devcontainer/shared/tools/view-blocked-requests.ps1
    ```

4. **Submodule status (if using submodule):**
    ```bash
    git submodule status
    # Should show the commit hash and path
    ```

## 🔧 Troubleshooting

### Submodule Not Initialized

```bash
git submodule init
git submodule update
```

### Submodule Points to Wrong Commit

```bash
cd .devcontainer/shared
git checkout main
git pull origin main
cd ../..
git add .devcontainer/shared
git commit -m "Update submodule to latest"
```

### Remove Submodule

```bash
git submodule deinit .devcontainer/shared
git rm .devcontainer/shared
rm -rf .git/modules/.devcontainer/shared
git commit -m "Remove shared components submodule"
```

## 📚 Additional Resources

-   [Git Submodules Documentation](https://git-scm.com/book/en/v2/Git-Tools-Submodules)
-   [VS Code DevContainers](https://code.visualstudio.com/docs/devcontainers/containers)
-   [Shared Components README](shared/README.md)

---

**You're now set up to share devcontainer configurations across all your projects!** 🎉
