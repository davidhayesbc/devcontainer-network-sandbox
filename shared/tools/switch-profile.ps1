#!/usr/bin/env pwsh
# Switch network profile
# Usage: ./switch-profile.ps1 <profile>
# Example: ./switch-profile.ps1 development

param(
    [Parameter(Mandatory = $true, Position = 0)]
    [ValidateSet('strict', 'development', 'open')]
    [string]$Profile
)

$ErrorActionPreference = "Stop"

$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$DevContainerDir = Split-Path -Parent $ScriptDir
$PolicyFile = Join-Path $DevContainerDir "network-policy.json"

# Check if policy file exists
if (-not (Test-Path $PolicyFile)) {
    Write-Error "Error: network-policy.json not found at $PolicyFile"
    exit 1
}

# Read policy file
$policy = Get-Content $PolicyFile -Raw | ConvertFrom-Json

# Validate profile exists
if (-not $policy.profiles.$Profile) {
    Write-Error "Error: Profile '$Profile' not found in network-policy.json"
    Write-Host "Available profiles:"
    $policy.profiles.PSObject.Properties.Name | ForEach-Object { Write-Host "  - $_" }
    exit 1
}

# Update active profile
Write-Host "Switching to profile: $Profile"
$policy.activeProfile = $Profile

# Save updated policy
$policy | ConvertTo-Json -Depth 10 | Set-Content $PolicyFile

Write-Host "✓ Active profile updated"
Write-Host ""
Write-Host "Updating network policy..."

# Call update script
$updateScript = Join-Path $ScriptDir "update-network-policy.ps1"
if (Test-Path $updateScript) {
    & $updateScript
}
else {
    $updateScriptSh = Join-Path $ScriptDir "update-network-policy.sh"
    if (Test-Path $updateScriptSh) {
        bash $updateScriptSh
    }
    else {
        Write-Warning "Could not find update-network-policy script"
    }
}
