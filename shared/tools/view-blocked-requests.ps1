#!/usr/bin/env pwsh
# View blocked requests from proxy logs
# Usage: ./view-blocked-requests.ps1 [lines]
# Example: ./view-blocked-requests.ps1 50

param(
    [Parameter(Position = 0)]
    [int]$Lines = 20
)

$ErrorActionPreference = "Stop"

Write-Host "Recent blocked requests (last $Lines):"
Write-Host "========================================"

try {
    $containerRunning = docker ps --format "{{.Names}}" 2>$null | Select-String "game-economy-proxy"

    if ($containerRunning) {
        $logs = docker exec game-economy-proxy tail -n $Lines /var/log/squid/access.log 2>$null
        $blocked = $logs | Select-String "TCP_DENIED"

        if ($blocked) {
            $blocked | ForEach-Object { Write-Host $_ }
        }
        else {
            Write-Host "No blocked requests found"
        }
    }
    else {
        Write-Error "Error: Proxy container is not running"
        exit 1
    }
}
catch {
    Write-Error "Error: Could not access proxy logs. Docker may not be available."
    exit 1
}
