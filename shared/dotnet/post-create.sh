#!/bin/bash
set -e

echo "================================================"
echo "Dotnet DevContainer: Post Create"
echo "================================================"

cd "/workspaces/${REPO_NAME}"

# Restore NuGet and build the solution
if [ -f "Game.sln" ]; then
    echo "Restoring NuGet packages..."
    dotnet restore || echo "⚠ dotnet restore failed - check network policy"
    echo "Building solution..."
    dotnet build --no-restore || echo "⚠ dotnet build failed"
else
    echo "No Game.sln found, skipping restore/build"
fi

echo "✓ Post-create initialization complete"
