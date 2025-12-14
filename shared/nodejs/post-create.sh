#!/bin/bash
set -e

echo "================================================"
echo "Node.js DevContainer: Post Create"
echo "================================================"

cd "/workspaces/${REPO_NAME}"

# Install NPM dependencies
if [ -f "package.json" ]; then
    echo "Installing NPM dependencies..."
    npm install || echo "⚠ NPM install failed - check network policy"
else
    echo "No package.json found, skipping npm install"
fi

echo "✓ Post-create initialization complete"
echo ""
echo "================================================"
echo "Network Policy: ${NETWORK_PROFILE}"
echo "To change network access, edit .devcontainer/network-policy.json"
echo "Then run: .devcontainer/scripts/update-network-policy.sh"
echo "================================================"
