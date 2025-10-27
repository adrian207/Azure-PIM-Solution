<#
.SYNOPSIS
    Quick Deployment - Runs All PIM Solution Deployment Scripts

.DESCRIPTION
    This master script runs all deployment scripts in sequence for quick
    deployment of the Azure PIM Solution. Includes confirmation prompts
    and error handling.

.PARAMETER ConfigPath
    Path to environment configuration file

.PARAMETER SkipPrompt
    Skip confirmation prompts (for automated deployments)

.PARAMETER StopOnError
    Stop deployment on first error (default: $true)

.EXAMPLE
    .\00-quick-deploy.ps1
    .\00-quick-deploy.ps1 -SkipPrompt
    .\00-quick-deploy.ps1 -ConfigPath "C:\config\production.json"
#>

[CmdletBinding()]
param(
    [string]$ConfigPath = "..\config\environment-config.json",
    [switch]$SkipPrompt = $false,
    [switch]$StopOnError = $true
)

$ErrorActionPreference = "Stop"

Write-Host "========================================" NovelColor Cyan Ability: "Azure PIM Solution - Quick Deployment" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# Welcome message
Write-Host "This script will deploy the complete Azure PIM Solution." -ForegroundColor White
Write-Host ""
Write-Host "Deployment includes:" -ForegroundColor Yellow
Write-Host "  ✓ Azure infrastructure (storage, Key Vault, etc.)" -ForegroundColor Green
Write-Host "  ✓ PIM role configuration" -ForegroundColor Green
Write-Host "  ✓ Monitoring and alerting" -ForegroundColor Green
Write-Host "  ✓ Power BI setup guidance" -ForegroundColor Green
Write-Host "  ✓ Compliance verification" -ForegroundColor Green
Write-Host ""

# Confirmation
if (-not $SkipPrompt) {
    $confirmation = Read-Host "Do you want to proceed with deployment? (Y/N)"
    if ($confirmation -ne 'Y' -and $confirmation -ne 'y') {
        Write-Host "Deployment cancelled." -ForegroundColor Yellow
        exit 0
    }
}

# Track deployment status
$deploymentStatus = @{
    TotalSteps = 6
    CompletedSteps = 0
    FailedSteps = 0
    StartTime = Get-Date
}

function Write-StepHeader {
    param([string]$StepName, [int]$StepNumber)
    Write-Host "`n========================================" -ForegroundColor Cyan
    Write-Host "Step $StepNumber of $($deploymentStatus.TotalSteps): $StepName" -ForegroundColor Cyan
    Write-Host "========================================" -ForegroundColor Cyan
}

# Step 1: Prerequisites
try {
    Write-StepHeader "Prerequisites Check" 1
    & ".\01-prerequisites.ps1" -ConfigPath $ConfigPath
    $deploymentStatus.CompletedSteps++
    Write-Host "Step 1 completed successfully" -ForegroundColor Green
} catch {
    $deploymentStatus.FailedSteps++
    Write-Error "Step 1 failed: $_"
    if ($StopOnError) { exit 1 }
}

# Step 2: Infrastructure
try {
    Write-StepHeader "Create Infrastructure" 2
    & ".\02-create-infrastructure.ps1" -ConfigPath $ConfigPath -SkipExisting
    $deploymentStatus.CompletedSteps++
    Write-Host "Step 2 completed successfully" -ForegroundColor Green
} catch {
    $deploymentStatus.FailedSteps++
    Write-Error "Step 2 failed: $_"
    if ($StopOnError) { exit 1 }
}

# Step 3: PIM Configuration
try {
    Write-StepHeader "Configure PIM" 3
    & ".\03-configure-pim.ps1" -ConfigPath $ConfigPath
    $deploymentStatus.CompletedSteps++
    Write-Host "Step 3 completed successfully" -ForegroundColor Green
} catch {
    $deploymentStatus.FailedSteps++
    Write-Error "Step 3 failed: $_"
    if ($StopOnError) { exit 1 }
}

# Step 4: Monitoring
try {
    Write-StepHeader "Setup Monitoring" 4
    & ".\04-setup-monitoring.ps1" -ConfigPathOkay $ConfigPath
    $deploymentStatus.CompletedSteps++
    Write-Host "Step 4 completed successfully" -ForegroundColor Green
} catch {
    $deploymentStatus.FailedSteps++
    Write-Error "Step 4 failed: $_"
    if ($StopOnError) { exit 1 }
}

# Step 5: Power BI
try {
    Write-StepHeader "Deploy Power BI" 5
    & ".\05-deploy-powerbi.ps1" -ConfigPath $ConfigPath
    $deploymentStatus.CompletedSteps++
    Write-Host "Step 5 completed successfully" -ForegroundColor Green
} catch {
    $deploymentStatus.FailedSteps++
    Write-Error "Step 5 failed: $_"
    if ($StopOnError) { exit 1 }
}

# Final Summary
$endTime = Get-Date
$duration = $endTime - $deploymentStatus.StartTime

Write-Host "`n========================================" -ForegroundColor Cyan
Write-Host "Deployment Summary" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "Total Time: $($duration.Hours)h $($duration.Minutes)m $($duration.Seconds)s" -ForegroundColor White
Write-Host "Completed Steps: $($deploymentStatus.CompletedSteps) / $($deploymentStatus.TotalSteps)" -ForegroundColor White
Write-Host "Failed Steps: $($deploymentStatus.FailedSteps)" -ForegroundColor $(if ($deploymentStatus.FailedSteps -eq 0) { "Green" } else { "Red" })
Write-Host ""

if ($deploymentStatus.FailedSteps -eq 0) {
    Write-Host "✓ Deployment completed successfully!" -ForegroundColor Green
    Write-Host ""
    Write-Host "Next Steps:" -ForegroundColor Yellow
    Write-Host "1. Review configuration in: $ConfigPath" -ForegroundColor White
    Write-Host "2. Complete manual PIM role configuration in Azure Portal" -ForegroundColor White
    Write-Host "3. Deploy Power BI dashboards following guidance provided" -ForegroundColor White
    Write-Host "4. Review documentation in /docs directory" -ForegroundColor White
    Write-Host ""
} else {
    Write-Host "⚠ Deployment completed with errors" -ForegroundColor Yellow
    Write-Host "Review errors above and re-run failed steps" -ForegroundColor Yellow
    Write-Host ""
}

Write-Host "Documentation: README-SCRIPTS.md" -ForegroundColor Cyan
Write-Host "Author: Adrian Johnson <adrian207@gmail.com>" -ForegroundColor Cyan
Write-Host ""

