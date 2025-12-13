#!/usr/bin/env pwsh
# Update network policy and restart proxy
# Usage: ./update-network-policy.ps1 [profile]
# Example: ./update-network-policy.ps1 development

param(
    [Parameter(Position = 0)]
    [string]$Profile
)

$ErrorActionPreference = "Stop"

$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$DevContainerDir = Split-Path -Parent $ScriptDir
$PolicyFile = Join-Path $DevContainerDir "network-policy.json"
$SquidConf = Join-Path $DevContainerDir "proxy/squid.conf"

# Check if policy file exists
if (-not (Test-Path $PolicyFile)) {
    Write-Error "Error: network-policy.json not found at $PolicyFile"
    exit 1
}

# Read policy file
$policy = Get-Content $PolicyFile -Raw | ConvertFrom-Json

# Determine active profile
if ($Profile) {
    Write-Host "Using profile: $Profile"
    $activeProfile = $Profile
}
else {
    $activeProfile = $policy.activeProfile
    Write-Host "Using active profile from config: $activeProfile"
}

# Validate profile exists
if (-not $policy.profiles.$activeProfile) {
    Write-Error "Error: Profile '$activeProfile' not found in network-policy.json"
    Write-Host "Available profiles:"
    $policy.profiles.PSObject.Properties.Name | ForEach-Object { Write-Host "  - $_" }
    exit 1
}

Write-Host "Generating Squid configuration for profile: $activeProfile"

# Extract allowed domains
$allowedDomains = @($policy.profiles.$activeProfile.allowedDomains)
$customDomains = @($policy.customAllowlist.domains)
$copilotDomains = @($policy.copilotEndpoints.domains)

# Combine and deduplicate
$allDomains = ($allowedDomains + $customDomains + $copilotDomains) |
Where-Object { $_ -and $_ -ne "" } |
Sort-Object -Unique

# Generate Squid configuration
$squidConfig = @"
# Squid proxy configuration for devcontainer network filtering
# Generated from network-policy.json

# Recommended minimum configuration:
acl SSL_ports port 443
acl Safe_ports port 80
acl Safe_ports port 443
acl Safe_ports port 1025-65535
acl CONNECT method CONNECT

# Deny requests to certain unsafe ports
http_access deny !Safe_ports
http_access deny CONNECT !SSL_ports

# Allow localhost
acl localhost src 127.0.0.1/32 ::1
http_access allow localhost

# Allow from devcontainer network
acl devcontainer_network src 172.16.0.0/12
acl devcontainer_network src 192.168.0.0/16
acl devcontainer_network src 10.0.0.0/8

# ALLOWLIST - Allowed domains
"@

# Add ACL entries for each domain
foreach ($domain in $allDomains) {
    if ($domain -and $domain -ne "*") {
        $squidConfig += "`nacl allowed_domains dstdomain $domain"
    }
}

# Complete the configuration
$squidConfig += @"


# SSL/TLS Configuration
http_port 3128

# Access control
http_access allow devcontainer_network allowed_domains
http_access deny all

# Logging
access_log /var/log/squid/access.log squid
cache_log /var/log/squid/cache.log

# Cache settings
cache_dir ufs /var/spool/squid 100 16 256
coredump_dir /var/spool/squid

# Refresh patterns for package caching
refresh_pattern ^ftp: 1440 20% 10080
refresh_pattern ^gopher: 1440 0% 1440
refresh_pattern -i (/cgi-bin/|\?) 0 0% 0
refresh_pattern . 0 20% 4320

# DNS settings
dns_nameservers 8.8.8.8 8.8.4.4
"@

# Write configuration file
Set-Content -Path $SquidConf -Value $squidConfig

Write-Host "✓ Squid configuration generated: $SquidConf"
Write-Host ""
Write-Host "Allowed domains for profile '$activeProfile':"
$allDomains | ForEach-Object { Write-Host "  - $_" }
Write-Host ""

# Restart proxy container if running
try {
    $containerRunning = docker ps --format "{{.Names}}" 2>$null | Select-String "game-economy-proxy"
    if ($containerRunning) {
        Write-Host "Restarting proxy container..."
        docker restart game-economy-proxy | Out-Null
        Write-Host "✓ Proxy restarted with new configuration"
    }
    else {
        Write-Host "⚠ Proxy container not running. Start it with: docker-compose up -d proxy"
    }
}
catch {
    Write-Host "⚠ Could not check/restart proxy container. Docker may not be available."
}

Write-Host ""
Write-Host "Network policy updated successfully!"
