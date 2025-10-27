<#
.SYNOPSIS
    Deploy Power BI Dashboards for PIM Reporting

.DESCRIPTION
    Creates Power BI workspace and provides guidance for deploying
    PIM reporting dashboards.

.PARAMETER ConfigPath
    Path to environment configuration file
#>

[CmdletBinding()]
param(
    [string]$ConfigPath = "..\config\environment-config.json"
)

$ErrorActionPreference = "Stop"

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "Azure PIM Solution - Power BI Setup" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# Load configuration
Write-Host "Loading configuration..." -ForegroundColor Yellow
$config = Get-Content $ConfigPath | ConvertFrom-Json

Write-Host "Power BI Workspace: $($config.powerbi.workspaceName)" -ForegroundColor Green
Write-Host "Refresh Schedule: $($config.powerbi.refreshSchedule.frequency)" -ForegroundColor Green

Write-Host "`nPower BI Deployment Steps:" -ForegroundColor Cyan
Write-Host "=========================" -ForegroundColor Cyan

Write-Host "`n1. Create Power BI Workspace" -ForegroundColor Yellow
Write-Host "   a. Go to https://app.powerbi.com" -ForegroundColor White
Write-Host "   b. Select 'Workspaces' > 'Create workspace'" -ForegroundColor White
Write-Host "   c. Name: $($config.powerbi.workspaceName)" -ForegroundColor White
Write-Host "   d. Assign appropriate permissions" -ForegroundColor White

Write-Host "`n2. Configure Data Source Connection" -ForegroundColor Yellow
Write-Host "   a. In Power BI Desktop, select 'Get Data'" -ForegroundColor White
Write-Host "   b. Choose 'Azure Active Directory' data connector" -ForegroundColor White
Write-H filtration "   c. Authenticate with appropriate credentials" -ForegroundColor White
Write-Host "   d. Select tables to import:" -ForegroundColor White
Write-Host "      - AuditLogs" -ForegroundColor Gray
Write-Host "      - SigninLogs" -ForegroundColor Gray
Write-Host "      - Role Management" -ForegroundColor Gray
Write-Host "      - User Information" -ForegroundColor Gray

Write-Host "`n3. Create Data Model" -ForegroundColor Yellow
Write-Host "   a. Define relationships between tables" -ForegroundColor White
Write-Host "   b. Create calculated measures for KPIs" -ForegroundColor White
Write-Host "   c. Configure data refresh schedule" -ForegroundColor White
Write-Host "   d. Publish to Power BI service" -ForegroundColor White

Write-Host "`n4. Build Dashboards" -ForegroundColor Yellow
Write-Host "   a. Create Executive Dashboard (see documentation)" -ForegroundColor White
Write-Host "   b. Create Operational Dashboards" -ForegroundColor White
Write-Host "   c. Create Self-Service Reports" -ForegroundColor White
Write-Host "   d. Configure data alerts" -ForegroundColor White

Write-Host "`n5. Configure Refresh Schedule" -ForegroundColor Yellow
foreach ($time in $config.powerbi.refreshSchedule.times) {
    Write-Host "   - $($config.powerbi.refreshSchedule.frequency) at $time" -ForegroundColor White
}

# Generate Power BI helper script
Write-Host "`nGenerating Power BI deployment helper..." -ForegroundColor Yellow

$pbixTemplate = @"
# Power BI Data Connection Configuration
# Environment: $($config.environment)
# Organization: $($config.organization.name)

# Data Source: Azure Active Directory via Microsoft Graph API
# Authentication: OAuth2 (Azure AD)

# Tables to Import:
# - AuditLogs: PIM access and activity logs
# - SigninLogs: Authentication events
# - RoleAssignments: Role assignment and eligibility information
# - Users: User directory information
# - Groups: Group membership information

# Key Measures to Create:

# 1. Risk Score Calculation
# RiskScore = 
#   SUMX(
#     FILTER(RecentActivity, AlertLevel = "High"),
#     AlertValue
#   )

# 2. Compliance Score Calculation  
# ComplianceScore = 
#   DIVIDE(
#     COUNTROWS(FILTER(Controls, Status = "Compliant")),
#     COUNTROWS(Controls),
#     0
#   ) * 100

# 3. Access Approval Time
# ApprovalTime = 
#   AVERAGE(ActivationTime - ApprovalTime)

# 4. Policy Compliance Rate
# PolicyCompliance = 
#   DIVIDE(
#     COUNTROWS(FILTER(AccessEvents, Compliant = TRUE)),
#     COUNTROWS(AccessEvents),
#     0
#   ) * 100

# Dashboard Configuration:
# Executive Dashboard:
#   - Risk Score KPI
#   - Compliance Score Gauge
#   - Active Sessions Counter
#   - Unusual Activity Summary

# Operations Dashboard:
#   - Access Request Queue
#   - Recent Activations Timeline
#   - Approval Workflow Status
#   - Access Duration Analysis
"@ | Out-File -FilePath ".\temp-powerbi-config.txt" -Encoding UTF8

Write-Host "Power BI configuration guide saved to: .\temp-powerbi-config.txt" -ForegroundColor Green

Write-Host "`n========================================" -ForegroundColor Cyan
Write-Host "Power BI Setup Complete" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "Next Steps:" -ForegroundColor Yellow
Write-Host "1. Review Power BI configuration in: .\temp-powerbi-config.txt" -ForegroundColor White
Write-Host "2. Deploy dashboards following documentation in:" -ForegroundColor White
Write-Host "   docs/reporting/powerbi-solution.md" -ForegroundColor White
Write-Host "3. Run: .\06-run-compliance-checks.ps1" -ForegroundColor White
Write-Host ""

