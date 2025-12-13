#!/bin/bash
set -e

echo "================================================"
echo "DevContainer Initialization: Post Create"
echo "================================================"

cd "/workspaces/${REPO_NAME}"

# Restore NuGet packages
echo "Restoring NuGet packages..."
dotnet restore || echo "⚠ NuGet restore failed - check network policy"

# Build the solution
echo "Building solution..."
dotnet build --no-restore || echo "⚠ Build failed"

# Install/update CSharpier
echo "Setting up CSharpier..."
dotnet tool restore || dotnet tool install -g csharpier || echo "⚠ CSharpier installation skipped"

echo "✓ Post-create initialization complete"
echo ""
echo "================================================"
echo "Network Policy: ${NETWORK_PROFILE}"
echo "To change network access, edit .devcontainer/network-policy.json"
echo "Then run: .devcontainer/scripts/update-network-policy.sh"
echo "================================================"
