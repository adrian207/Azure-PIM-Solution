<#
.SYNOPSIS
    Prerequisites Check and Environment Setup for Azure PIM Solution

.DESCRIPTION
    This script checks for required prerequisites and sets up the environment
    for deploying the Azure PIM Solution. It validates Azure connectivity,
    required modules, and permissions.

.PARAMETER ConfigPath
    Path to the environment configuration file (default: ../config/environment-config.json)

.EXAMPLE
    .\01-prerequisites.ps1
    .\01-prerequisites.ps1 -ConfigPath "C:\config\my-config.json"
#>

[CmdletBinding()]
param(
    [string]$ConfigPath = "..\config\environment-config.json"
)

# Error handling
$ErrorActionPreference = "Stop"

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "Azure PIM Solution - Prerequisites Check" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# Load configuration
Write-Host "Loading configuration..." -ForegroundColor Yellow
if (-not (Test-Path $ConfigPath)) {
    Write-Error "Configuration file not found: $ConfigPath"
    exit 1
}

$config = Get-Content $ConfigPath | ConvertFrom-Json
Write-Host "Configuration loaded successfully" -ForegroundColor Green

# Check if running in PowerShell 7+
Write-Host "`nChecking PowerShell version..." -ForegroundColor Yellow
if ($PSVersionTable.PSVersion.Major -lt 7) {
    Write-Warning "PowerShell 7 or higher is recommended. Current version: $($PSVersionTable.PSVersion)"
} else {
    Write-Host "PowerShell version: $($PSVersionTable.PSVersion)" -ForegroundColor Green
}

# Check for required modules
Write-Host "`nChecking required Azure modules..." -ForegroundColor Yellow
$requiredModules = @(
    "Az.Accounts",
    "Az.Resources",
    "Az.Storage",
    "Az.KeyVault",
    "Az.Monitor",
    "Microsoft.Graph.Identity.Governance",
    "Microsoft.Graph.Identity.DirectoryManagement"
)

$missingModules = @()
foreach ($module in $requiredModules) {
    $installed = Get-Module -ListAvailable -Name $module
    if (-not $installed) {
        Write-Warning "Module not found: $module"
        $missingModules += $module
    } else {
        Write-Host "  $module - OK (v$($installed.Version | Sort-Object -Descending | Select-Object -First 1))" -ForegroundColor Green
    }
}

if ($missingModules.Count -gt 0) {
    Write-Host "`nInstalling missing modules..." -ForegroundColor Yellow
    foreach ($module in $missingModules) {
        try {
            Write-Host "  Installing $module..." -ForegroundColor Yellow
            Install-Module -Name $module -Force -AllowClobber -Scope CurrentUser
            Write-Host "  $module installed successfully" -ForegroundColor Green
        } catch {
            Write-Error "Failed to install module: $module - $_"
            exit 1
        }
    }
}

# Check Azure connection
Write-Host "`nChecking Azure connection..." -ForegroundColor Yellow
try {
    $context = Get-AzContext
    if (-not $context) {
        Write-Warning "Not connected to Azure. Please run 'Connect-AzAccount'"
        Write-Host "Attempting to connect to Azure..." -ForegroundColor Yellow
        Connect-AzAccount
    } else {
        Write-Host "Connected to Azure as: $($context.Account.Id)" -ForegroundColor Green
        Write-Host "Subscription: $($context.Subscription.Name)" -ForegroundColor Green
    }
} catch {
    Write-Error "Failed to connect to Azure: $_"
    exit 1
}

# Check Microsoft Graph connection
Write-Host "`nChecking Microsoft Graph connection..." -ForegroundColor Yellow
try {
    $mgContext = Get-MgContext
    if (-not $mgContext) {
        Write-Warning "Not connected to Microsoft Graph. Please run 'Connect-MgGraph'"
        Write-Host "Attempting to connect to Microsoft Graph..." -ForegroundColor Yellow
        Connect-MgGraph -Scopes "Directory.ReadWrite.All", "PrivilegedAccess.ReadWrite.AzureAD"
    } else {
        Write-Host "Connected to Microsoft Graph" -ForegroundColor Green
    }
} catch {
    Write-Warning "Microsoft Graph connection failed: $_"
    Write-Host "Note: You may need to connect with 'Connect-MgGraph'" -ForegroundColor Yellow
}

# Verify subscription
Write-Host "`nVerifying Azure subscription..." -ForegroundColor Yellow
$subscription = Get-AzSubscription | Where-Object { $_.Name -eq $config.azure.subscription.name }
if ($subscription) {
    Write-Host "Subscription found: $($subscription.Name)" -ForegroundColor Green
    Set-AzContext -SubscriptionId $subscription.Id
} else {
    Write-Warning "Subscription not found: $($config.azure.subscription.name)"
    Write-Host "Available subscriptions:" -ForegroundColor Yellow
    Get-AzSubscription | Select-Object Name, Id | Format-Table
}

# Check permissions
Write-Host "`nChecking required permissions..." -ForegroundColor Yellow
$requiredRoles = @(
    "Owner",
    "User Access Administrator",
    "Contributor"
)

try {
    $currentUser = $context.Account.Id
    $subscriptionId = $context.Subscription.Id
    
    foreach ($role in $requiredRoles) {
        $roleAssignments = Get-AzRoleAssignment -Scope "/subscriptions/$subscriptionId" -ObjectId $currentUser -ErrorAction SilentlyContinue
        if ($roleAssignments) {
            Write-Host "  $role - OK" -ForegroundColor Green
        } else {
            Write-Warning "  $role - Not assigned"
        }
    }
} catch {
    Write-Warning "Could not verify all role assignments: $_"
}

# Summary
Write-Host "`n========================================" -ForegroundColor Cyan
Write-Host "Prerequisites Check Complete" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "Next Steps:" -ForegroundColor Yellow
Write-Host "1. Review configuration in: $ConfigPath" -ForegroundColor White
Write-Host "2. Update configuration with your organization details" -ForegroundColor White
Write-Host "3. Run: .\02-create-infrastructure.ps1" -ForegroundColor White
Write-Host ""

