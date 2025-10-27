<#
.SYNOPSIS
    Configure Azure AD PIM Role Settings

.DESCRIPTION
    Configures PIM role settings including activation duration, approval
    requirements, and MFA requirements based on configuration file.

.PARAMETER ConfigPath
    Path to environment configuration file
#>

[CmdletBinding()]
param(
    [string]$ConfigPath = "..\config\environment-config.json"
)

$ErrorActionPreference = "Stop"

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "Azure PIM Solution - PIM Configuration" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# Load configuration
Write-Host "Loading configuration..." -ForegroundColor Yellow
$config = Get-Content $ConfigPath | ConvertFrom-Json

# Check Microsoft Graph connection
$mgContext = Get-MgContext
if (-not $mgContext) {
    Write-Host "Connecting to Microsoft Graph..." -ForegroundColor Yellow
    Connect-MgGraph -Scopes "Directory.ReadWrite.All", "PrivilegedAccess.ReadWrite.AzureAD"
}

Write-Host "`nConfiguring PIM role settings..." -ForegroundColor Yellow
Write-Host "Note: This script provides configuration guidance." -ForegroundColor Yellow
Write-Host "Azure AD PIM role configuration is done through Azure Portal or Graph API." -ForegroundColor Yellow
Write-Host ""

# Display configuration summary
Write-Host "Role Configuration Summary:" -ForegroundColor Cyan
Write-Host "===========================" -ForegroundColor Cyan

foreach ($roleName in $config.pim.roles.PSObject.Properties.Name) {
    $role = $config.pim.roles.$roleName
    Write-Host "`nRole: $($role.name)" -ForegroundColor Green
    Write-Host "  Description: $($role.description)" -ForegroundColor White
    Write-Host "  Max Duration: $($role.maxDurationHours) hours" -ForegroundColor White
    Write-Host "  Approval Required: $($role.approvalRequired)" -ForegroundColor White
    if ($role.approvalRequired) {
        Write-Host "  Approvers: $($role.approvers -join ', ')" -ForegroundColor White
    }
    Write-Host "  MFA Required: $($role.mfaRequired)" -ForegroundColor White
    Write-Host "  Justification Required: $($role.justificationRequired)" -ForegroundColor White
}

Write-Host "`nApproval Workflows:" -ForegroundColor Cyan
Write-Host "==================" -ForegroundColor Cyan

foreach ($levelName in $config.pim.approvalWorkflows.PSObject.Properties.Name) {
    $level = $config.pim.approvalWorkflows.$levelName
    Write-Host "`n$levelName:" -ForegroundColor Green
    Write-Host "  Auto-Approve: $($level.autoApprove)" -ForegroundColor White
    if (-not $level.autoApprove) {
        Write-Host "  Required Approvals: $($level.requireApproval -join ', ')" -ForegroundColor White
        Write-Host "  Approval Timeframe: $($level.approvalTimeframeHours) hours" -ForegroundColor White
        Write-Host "  Auto-Escalation: $($level.autoEscalationHours) hours" -ForegroundColor White
    }
}

Write-Host "`n========================================" -ForegroundColor Cyan
Write-Host "Next Steps:" -ForegroundColor Yellow
Write-Host "1. Configure roles in Azure Portal: https://portal.azure.com" -ForegroundColor White
Write-Host "2. Navigate to Azure AD > Privileged Identity Management" -ForegroundColor White
Write-Host "3. Configure each role with the settings shown above" -ForegroundColor White
Write-Host "4. Run: .\04-setup-monitoring.ps1" -ForegroundColor White
Write-Host ""

# Generate configuration script for manual execution
Write-Host "Generating PIM configuration helper script..." -ForegroundColor Yellow
@"
# Azure AD PIM Configuration Helper
# Generated from environment configuration
# Review and execute these commands in Azure Cloud Shell or with appropriate permissions

# Note: These are examples - adjust based on your Azure AD role definitions

# Example: Configure "Production Administrator" role settings
# UPDATE - Replace <RoleDefinitionId> with actual role GUID from your tenant

# Set activation settings
# Approvers should be created as Azure AD groups or users first
"@ | Out-File -FilePath ".\temp-pim-config-help.ps1" -Encoding UTF8

Write-Host "Configuration helper script saved to: .\temp-pim-config-help.ps1" -ForegroundColor Green
Write-Host ""

