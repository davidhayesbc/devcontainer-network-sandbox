#!/bin/bash
set -e

echo "================================================"
echo "DevContainer Initialization: On Create"
echo "================================================"

# Clone repository if workspace is empty
if [ ! -d "/workspaces/${REPO_NAME}/.git" ]; then
    echo "Cloning repository: ${REPO_URL}"
    cd /workspaces
    git clone "${REPO_URL}" "${REPO_NAME}"
    echo "✓ Repository cloned successfully"
else
    echo "Repository already exists, skipping clone"
fi

# Set workspace as safe directory for git
cd "/workspaces/${REPO_NAME}"
git config --global --add safe.directory "/workspaces/${REPO_NAME}"

echo "✓ On-create initialization complete"
