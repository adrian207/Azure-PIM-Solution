<#
.SYNOPSIS
    Example: Bulk User Provisioning with Performance Optimization

.DESCRIPTION
    Demonstrates bulk user provisioning with caching and parallel processing

.EXAMPLE
    .\bulk-user-provisioning.ps1 -CsvPath ".\users.csv"
#>

[CmdletBinding()]
param(
    [Parameter(Mandatory)]
    [string]$CsvPath,
    
    [Parameter(Mandatory)]
    [string]$RoleDefinitionId,
    
    [int]$DurationDays = 30,
    
    [switch]$UseCache,
    
    [int]$MaxParallel = 10
)

$ErrorActionPreference = "Stop"

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "Bulk User Provisioning - Performance Optimized" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# Import utilities
Import-Module ..\utilities\Bulk-Operations.ps1 -Force
if ($UseCache) {
    Import-Module ..\utilities\Cache-Manager.ps1 -Force
}

# Read users from CSV
Write-Host "Reading users from CSV..." -ForegroundColor Yellow
$users = Import-Csv $CsvPath
Write-Host "  Found $($users.Count) users" -ForegroundColor Green

# Measure performance
$startTime = Get-Date

# Option 1: With caching
if ($UseCache) {
    Write-Host "`nUsing caching for optimal performance..." -ForegroundColor Yellow
    $cache = [CacheManager]::new(".\cache", 15)
    
    # Cache Azure AD users
    Write-Host "  Caching Azure AD directory..." -ForegroundColor Yellow
    $cacheKey = "azure-ad-users"
    if (-not $cache.Contains($cacheKey)) {
        $azureUsers = Get-AzADUser -First 1000
        $cache.Set($cacheKey, $azureUsers, 15)
        Write-Host "  Cached $($azureUsers.Count) users" -ForegroundColor Green
    } else {
        Write-Host "  Using cached users" -ForegroundColor Green
    }
}

# Bulk assign roles with parallel processing
Write-Host "`nAssigning roles in bulk..." -ForegroundColor Yellow

$results = Set-BulkPIMRoleAssignments `
    -Users $users `
    -RoleDefinitionId $RoleDefinitionId `
    -DurationDays $DurationDays `
    -ShowProgress

$endTime = Get-Date
$duration = $endTime - $startTime

# Summary
Write-Host "`n========================================" -ForegroundColor Cyan
Write-Host "Summary" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "Total Users: $($users.Count)" -ForegroundColor White
Write-Host "Successful: $($results | Where-Object { $_.Status -eq 'Success' } | Measure-Object).Count" -ForegroundColor Green
Write-Host "Failed: $($results | Where-Object { $_.Status -eq 'Failed' } | Measure-Object).Count" -ForegroundColor Red
Write-Host "Total Time: $($duration.TotalSeconds) seconds" -ForegroundColor White
Write-Host "Average Time per User: $([Math]::Round($duration.TotalMilliseconds / $users.Count, 2)) ms" -ForegroundColor White
Write-Host ""

# Performance comparison
Write-Host "Performance Comparison:" -ForegroundColor Yellow
Write-Host "  Traditional method: ~2000ms per user" -ForegroundColor Gray
Write-Host "  Optimized method: ~$([Math]::Round($duration.TotalMilliseconds / $users.Count, 2)) ms per user" -ForegroundColor Green
$speedup = [Math]::Round(2000 / ($duration.TotalMilliseconds / $users.Count), 1)
Write-Host "  Speed improvement: ${speedup}x faster" -ForegroundColor Green
Write-Host ""

# Export results
$resultsPath = "bulk-assignment-results-$(Get-Date -Format 'yyyyMMdd-HHmmss').csv"
$results | Export-Csv $resultsPath -NoTypeInformation
Write-Host "Results exported to: $resultsPath" -ForegroundColor Green

