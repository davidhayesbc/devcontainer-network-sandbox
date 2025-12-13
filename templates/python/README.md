# Python DevContainer Template

Network-sandboxed development container for Python projects with GitHub Copilot support.

## 🎯 What's Included

-   **Python 3.12** - Latest stable Python version
-   **pip & Poetry** - Package management tools
-   **Black & Flake8** - Code formatting and linting
-   **Pylint** - Static code analysis
-   **pytest** - Testing framework
-   **IPython** - Enhanced interactive shell
-   **Network Sandboxing** - Controlled outbound access via proxy
-   **GitHub Copilot** - Pre-configured and ready to use

## 🚀 Quick Start

### 1. Copy Template to Your Project

```bash
# From the Game repository root
cp -r .devcontainer/templates/python/.devcontainer /path/to/your/python-project/

# Or using PowerShell on Windows
Copy-Item -Recurse .devcontainer/templates/python/.devcontainer /path/to/your/python-project/
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

-   `pypi.org` & `files.pythonhosted.org` - Python packages
-   `github.com` - Git operations
-   GitHub Copilot endpoints

To add more domains, edit `.devcontainer/network-policy.json`:

```json
{
    "customAllowlist": {
        "domains": ["download.pytorch.org", "*.anaconda.org"]
    }
}
```

### 4. Open in DevContainer

```bash
# Open your project in VS Code
code /path/to/your/python-project

# Press F1 and select:
# "Dev Containers: Reopen in Container"
```

## 📦 What Happens on First Run

1. **Container builds** using Python 3.12 base image
2. **Repository clones** into `/workspaces/<yourrepo>`
3. **Dependencies install** from `requirements.txt` or `pyproject.toml`
4. **Copilot activates** and is ready to use
5. **Proxy enforces** network policy

## 🛠️ Customizing for Your Project

### Add System Dependencies

Edit `.devcontainer/Dockerfile.python`:

```dockerfile
RUN apt-get update && export DEBIAN_FRONTEND=noninteractive \
    && apt-get -y install --no-install-recommends \
    postgresql-client \
    libpq-dev \
    redis-tools \
    && apt-get clean -y \
    && rm -rf /var/lib/apt/lists/*
```

### Install Global Python Packages

Edit `.devcontainer/Dockerfile.python`:

```dockerfile
RUN pip install --no-cache-dir \
    black \
    flake8 \
    pylint \
    pytest \
    ipython \
    jupyterlab \
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
                "ms-python.python",
                "ms-python.vscode-pylance",
                "ms-python.black-formatter",
                "ms-python.flake8",
                "GitHub.copilot",
                "ms-toolsai.jupyter"
            ]
        }
    }
}
```

### Adjust Forwarded Ports

For Flask/Django/FastAPI apps, configure ports in `.devcontainer/devcontainer.json`:

```json
{
    "forwardPorts": [5000, 8000, 8080],
    "portsAttributes": {
        "8000": {
            "label": "Django/FastAPI",
            "onAutoForward": "notify"
        }
    }
}
```

## 🌐 Network Policy for Python

### Minimum Required Domains

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

### Common Additional Domains

```json
{
    "customAllowlist": {
        "domains": [
            "download.pytorch.org", // PyTorch models
            "storage.googleapis.com", // TensorFlow/ML resources
            "repo.anaconda.com", // Conda packages
            "*.anaconda.org",
            "huggingface.co", // Hugging Face models
            "cdn-lfs.huggingface.co"
        ]
    }
}
```

## 📋 Common Workflows

### Install New Package

```bash
# In the devcontainer terminal
pip install requests

# Update requirements.txt
pip freeze > requirements.txt
```

If blocked, check logs and add the domain:

```powershell
# From host machine
.devcontainer/shared/tools/view-blocked-requests.ps1
.devcontainer/shared/tools/add-allowed-domain.ps1 blocked-domain.com
```

### Using Poetry

```bash
# Install with poetry (auto-detected in post-create.sh)
poetry add requests

# Or manually
poetry install
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
curl -v https://pypi.org/simple/

# Verify proxy settings (in container)
echo $http_proxy  # Should show: http://proxy:3128
```

## 🔧 Project Type Examples

### Flask API

```python
# app.py
from flask import Flask
app = Flask(__name__)

@app.route('/')
def hello():
    return 'Hello World!'

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000)
```

Forward port 5000 in `devcontainer.json`.

### Django Project

```bash
# Dependencies auto-install
# Run migrations
python manage.py migrate

# Start dev server
python manage.py runserver 0.0.0.0:8000
```

Forward port 8000 in `devcontainer.json`.

### FastAPI Application

```python
# main.py
from fastapi import FastAPI
app = FastAPI()

@app.get("/")
async def root():
    return {"message": "Hello World"}

# Run with: uvicorn main:app --reload --host 0.0.0.0
```

Forward port 8000 in `devcontainer.json`.

### Data Science / Jupyter

```bash
# Jupyter already included in template
jupyter lab --ip=0.0.0.0 --allow-root
```

Forward port 8888 in `devcontainer.json`.

### Machine Learning Project

For PyTorch/TensorFlow, add download domains:

```bash
.devcontainer/shared/tools/add-allowed-domain.sh download.pytorch.org
.devcontainer/shared/tools/add-allowed-domain.sh storage.googleapis.com
```

## 🧪 Testing Setup

### pytest Configuration

Create `pytest.ini`:

```ini
[pytest]
testpaths = tests
python_files = test_*.py
python_classes = Test*
python_functions = test_*
```

### Run Tests in Container

```bash
# Run all tests
pytest

# With coverage
pytest --cov=src

# Specific test file
pytest tests/test_api.py
```

## 🎨 Code Formatting

### Black Configuration

Create `pyproject.toml`:

```toml
[tool.black]
line-length = 88
target-version = ['py312']
include = '\.pyi?$'
```

### Format Code

```bash
# Format all files
black .

# Check without modifying
black --check .
```

### Flake8 Configuration

Create `.flake8`:

```ini
[flake8]
max-line-length = 88
extend-ignore = E203, W503
exclude = .git,__pycache__,venv
```

## 🐛 Troubleshooting

### pip Install Fails

```powershell
# Check blocked requests
.devcontainer/shared/tools/view-blocked-requests.ps1

# Try development profile
.devcontainer/shared/tools/switch-profile.ps1 development
```

### Poetry Issues

```bash
# Check Poetry is installed
poetry --version

# If not, install it
pip install poetry

# Configure to use proxy
poetry config http-basic.pypi http://proxy:3128
```

### Jupyter Not Accessible

Check `.devcontainer/devcontainer.json`:

```json
{
    "forwardPorts": [8888],
    "portsAttributes": {
        "8888": {
            "label": "Jupyter",
            "onAutoForward": "openBrowser"
        }
    }
}
```

### ML Model Downloads Blocked

```powershell
# PyTorch models
.devcontainer/shared/tools/add-allowed-domain.ps1 download.pytorch.org

# TensorFlow models
.devcontainer/shared/tools/add-allowed-domain.ps1 storage.googleapis.com

# Hugging Face models
.devcontainer/shared/tools/add-allowed-domain.ps1 huggingface.co
.devcontainer/shared/tools/add-allowed-domain.ps1 cdn-lfs.huggingface.co
```

### Package from Private PyPI

Add your repository domain:

```powershell
.devcontainer/shared/tools/add-allowed-domain.ps1 pypi.yourcompany.com
```

Or edit `network-policy.json` and pip config:

```bash
pip config set global.index-url https://pypi.yourcompany.com/simple
```

## 🔐 Virtual Environment Best Practices

While the container is isolated, you can still use venv:

```bash
# Create virtual environment
python -m venv venv

# Activate
source venv/bin/activate

# Install dependencies
pip install -r requirements.txt
```

## 📚 Additional Resources

-   [Python in Containers](https://code.visualstudio.com/docs/containers/overview)
-   [pip Proxy Configuration](https://pip.pypa.io/en/stable/topics/configuration/)
-   [Poetry Documentation](https://python-poetry.org/docs/)
-   [DevContainer Python Features](https://github.com/devcontainers/features/tree/main/src/python)

## 🔄 Keeping Template Updated

When Python versions change:

1. Update base image in `Dockerfile.python`:

    ```dockerfile
    FROM mcr.microsoft.com/devcontainers/python:1-3.13-bookworm
    ```

2. Update Python version references in this README

3. Test thoroughly with your projects

## ✅ Checklist for New Projects

-   [ ] Copy template to project directory
-   [ ] Update `REPO_URL` in `docker-compose.yml`
-   [ ] Update `REPO_NAME` in `docker-compose.yml`
-   [ ] Create `requirements.txt` or `pyproject.toml`
-   [ ] Add project-specific domains to `network-policy.json`
-   [ ] Configure forwarded ports for your app
-   [ ] Add project-specific VS Code extensions
-   [ ] Update `post-create.sh` with setup commands
-   [ ] Configure Black/Flake8 settings
-   [ ] Test container build and network access
-   [ ] Commit `.devcontainer/` to version control

---

**Happy Python Development in a Sandboxed Container!** 🐍
