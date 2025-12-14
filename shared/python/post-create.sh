#!/bin/bash
set -e

echo "================================================"
echo "Python DevContainer: Post Create"
echo "================================================"

cd "/workspaces/${REPO_NAME}"

# Install pip dependencies
if [ -f "requirements.txt" ]; then
    echo "Installing pip dependencies..."
    pip install -r requirements.txt || echo "⚠ pip install failed - check network policy"
elif [ -f "pyproject.toml" ]; then
    echo "Installing poetry dependencies..."
    pip install poetry || echo "⚠ poetry install failed"
    poetry install || echo "⚠ poetry install failed - check network policy"
else
    echo "No requirements.txt or pyproject.toml found, skipping dependency install"
fi

echo "✓ Post-create initialization complete"
echo ""
echo "================================================"
echo "Network Policy: ${NETWORK_PROFILE}"
echo "To change network access, edit .devcontainer/network-policy.json"
echo "Then run: .devcontainer/scripts/update-network-policy.sh"
echo "================================================"
