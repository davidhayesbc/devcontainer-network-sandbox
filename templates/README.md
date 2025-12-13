# DevContainer Templates

This directory contains reusable devcontainer templates for different project types. Each template provides network sandboxing with GitHub Copilot support.

## Available Templates

### .NET Template

**Location**: `../` (parent directory - the main Game project)

**Use for**:

-   ASP.NET Core applications
-   .NET console applications
-   Blazor applications
-   Class libraries

**Key features**:

-   .NET 10 SDK
-   CSharpier formatting
-   NuGet package management
-   Network sandboxing with strict/development profiles

---

### Node.js Template

**Location**: `templates/nodejs/`

**Use for**:

-   Express.js applications
-   React/Vue/Angular applications
-   Node.js APIs
-   TypeScript projects

**Key features**:

-   Node.js 20 LTS
-   NPM/Yarn support
-   ESLint/Prettier
-   Network sandboxing

---

### Python Template

**Location**: `templates/python/`

**Use for**:

-   Flask/Django applications
-   Data science projects
-   Python scripts
-   Machine learning projects

**Key features**:

-   Python 3.11+
-   pip/poetry support
-   Jupyter notebooks
-   Network sandboxing

---

## Using a Template

> **Quick Start:** See [QUICKSTART.md](QUICKSTART.md) for a step-by-step guide to using these templates.

### Option 1: Copy to New Project

```powershell
# For a new Node.js project
Copy-Item -Recurse .devcontainer/templates/nodejs/.devcontainer /path/to/new/project/

# Edit the configuration
cd /path/to/new/project/.devcontainer
# Update REPO_URL and REPO_NAME in docker-compose.yml
```

### Option 2: Adapt Existing Template

```bash
# Start with .NET template
cp -r .devcontainer /path/to/new/project/

# Swap out the Dockerfile
cp .devcontainer/templates/nodejs/Dockerfile.node /path/to/new/project/.devcontainer/
# Update docker-compose.yml to reference Dockerfile.node
```

### Option 3: Create Template from Scratch

1. Copy the base structure from any template
2. Modify `Dockerfile.*` for your language/framework
3. Update `network-policy.json` with required domains
4. Update `docker-compose.yml` with repository details
5. Test and adjust as needed

## Template Structure

Each template follows this structure:

```
.devcontainer/
├── devcontainer.json          # VS Code configuration
├── docker-compose.yml         # Services (dev container + proxy)
├── Dockerfile.<lang>          # Language-specific image
├── network-policy.json        # Network access rules
├── network-policy.schema.json # JSON schema
├── proxy/
│   ├── squid.conf            # Active proxy config
│   └── squid.conf.template   # Config template
└── scripts/
    ├── on-create.sh          # Clone repository
    ├── post-create.sh        # Install dependencies
    ├── update-network-policy.sh
    ├── switch-profile.sh
    ├── add-allowed-domain.sh
    ├── remove-allowed-domain.sh
    └── view-blocked-requests.sh
```

## Customization Checklist

When adapting a template for a new project:

-   [ ] Update `REPO_URL` in `docker-compose.yml`
-   [ ] Update `REPO_NAME` in `docker-compose.yml`
-   [ ] Update `name` in `devcontainer.json`
-   [ ] Modify `Dockerfile.*` with project-specific tools
-   [ ] Update `network-policy.json` with required domains
-   [ ] Update `post-create.sh` with build/install commands
-   [ ] Update forwarded ports in `devcontainer.json`
-   [ ] Add language-specific VS Code extensions
-   [ ] Test the setup end-to-end

## Network Policy Per Language

### .NET Projects

Minimum required domains:

```json
{
    "allowedDomains": ["api.nuget.org", ".nuget.org", "github.com", "api.github.com", ".githubusercontent.com"]
}
```

### Node.js Projects

Minimum required domains:

```json
{
    "allowedDomains": ["registry.npmjs.org", ".npmjs.org", "github.com", "api.github.com", ".githubusercontent.com"]
}
```

### Python Projects

Minimum required domains:

```json
{
    "allowedDomains": [
        "pypi.org",
        ".pypi.org",
        "files.pythonhosted.org",
        "github.com",
        "api.github.com",
        ".githubusercontent.com"
    ]
}
```

## Contributing Templates

To add a new template:

1. Create directory: `.devcontainer/templates/<language>/`
2. Copy base structure from existing template
3. Create `Dockerfile.<language>` with appropriate base image
4. Update `network-policy.json` with language-specific domains
5. Create language-specific `post-create.sh`
6. Test thoroughly
7. Document in this README

## Best Practices

1. **Keep Templates Minimal**: Include only what's needed for the language/framework
2. **Document Requirements**: List all required domains in comments
3. **Test Strictly**: Verify templates work with `strict` network profile
4. **Version Pin**: Pin major versions of tools/SDKs in Dockerfiles
5. **Share Scripts**: Keep helper scripts identical across templates

## Future Templates

Planned templates:

-   [ ] Go
-   [ ] Rust
-   [ ] Java/Kotlin
-   [ ] Ruby
-   [ ] PHP

## Support

See the main [README.md](../README.md) for:

-   Troubleshooting network issues
-   Managing domains and profiles
-   Advanced configuration options
