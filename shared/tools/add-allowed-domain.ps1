#!/usr/bin/env pwsh
# Add a domain to the custom allowlist
# Usage: ./add-allowed-domain.ps1 <domain>
# Example: ./add-allowed-domain.ps1 stackoverflow.com

param(
    [Parameter(Mandatory = $true, Position = 0)]
    [string]$Domain
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

# Check if domain already exists
if ($policy.customAllowlist.domains -contains $Domain) {
    Write-Host "Domain '$Domain' is already in the custom allowlist"
    exit 0
}

# Add domain to custom allowlist
Write-Host "Adding '$Domain' to custom allowlist..."
$policy.customAllowlist.domains += $Domain

# Save updated policy
$policy | ConvertTo-Json -Depth 10 | Set-Content $PolicyFile

Write-Host "✓ Domain added successfully"
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
