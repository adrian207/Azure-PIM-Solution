<#
.SYNOPSIS
    Setup Monitoring and Alerting for PIM Solution

.DESCRIPTION
    Configures Azure Monitor alerts and Log Analytics queries for the
    PIM solution based on configuration settings.

.PARAMETER ConfigPath
    Path to environment configuration file
#>

[CmdletBinding()]
param(
    [string]$ConfigPath = "..\config\environment-config.json"
)

$ErrorActionPreference = "Stop"

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "Azure PIM Solution - Monitoring Setup" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# Load configuration
Write-Host "Loading configuration..." -ForegroundColor Yellow
$config = Get-Content $ConfigPath | ConvertFrom-Json

# Check Azure connection
$context = Get-AzContext
if (-not $context) {
    Write-Error "Not connected to Azure. Please run Connect-AzAccount"
    exit 1
}

$resourceGroup = $config.azure.resourceGroup.name
$lawName = $config.monitoring.logAnalytics.workspaceName

# Get Log Analytics Workspace
$law = Get-AzOperationalInsightsWorkspace -ResourceGroupName $resourceGroup -Name $lawName
if (-not $law) {
    Write-Error "Log Analytics Workspace not found: $lawName"
    exit 1
}

Write-Host "Log Analytics Workspace: $lawName" -ForegroundColor Green
Write-Host "Workspace ID: $($law.CustomerId)" -ForegroundColor Green

# Create Action Group for alerts
Write-Host "`nCreating Action Group for alerts..." -ForegroundColor Yellow
$actionGroupName = "ag-pim-alerts"

$actionGroup = Get-AzActionGroup -ResourceGroupName $resourceGroup -Name $actionGroupName -ErrorAction SilentlyContinue
if (-not $actionGroup) {
    Write-Host "  Creating action group: $actionGroupName" -ForegroundColor Yellow
    
    $emailReceivers = @()
    foreach ($email in $config.monitoring.alerts.recipients) {
        $emailReceivers += New-AzActionGroupReceiver `
            -Name "Email-$($email.Split('@')[0])" `
            -EmailAddress $email `
            -UseCommonAlertSchema
    }
    
    $actionGroup = Set-AzActionGroup `
        -ResourceGroupName $resourceGroup `
        -Name $actionGroupName `
        -ShortName "PIMAlerts" `
        -Receiver $emailReceivers
    
    Write-Host "  Action group created successfully" -ForegroundColor Green
} else {
    Write-Host "  Action group already exists: $actionGroupName" -ForegroundColor Green
}

# Create Alert Rules
Write-Host "`nCreating alert rules..." -ForegroundColor Yellow

$alerts = @(
    @{
        Name = "PIM - Unusual Access Pattern"
        Description = "Alert when unusual privileged access patterns detected"
        Severity = "Warning"
        Query = "SigninLogs | where UserType == 'Member' | where AppDisplayName contains 'PIM' | summarize count() by bin(TimeGenerated, 1h) | where count_ > 10"
        Threshold = 10
        Aggregation = "Count"
    },
    @{
        Name = "PIM - Failed Access Attempts"
        Description = "Alert on excessive failed access attempts"
        Severity = "Warning"
        Query = "SigninLogs | where UserType == 'Member' | where AppDisplayName contains 'PIM' | where ResultType != '0' | summarize count() by bin(TimeGenerated, 1h) | where count_ > 5"
        Threshold = 5
        Aggregation = "Count"
    },
    @{
        Name = "PIM - Audit Log Collection Failure"
        Description = "Alert if audit log collection fails"
        Severity = "Critical"
        Query = "AzureDiagnostics | where Category == 'AuditLogs' | where ResultDescription contains 'failure' or ResultDescription contains 'error' | summarize count() by bin(TimeGenerated, 15m) | where count_ > 0"
        Threshold = 1
        Aggregation = "Count"
    },
    @{
        Name = "PIM - Storage Near Capacity"
        Description = "Alert when storage account is near capacity"
        Severity = "Warning"
        Query = "Perf | where ObjectName == 'Storage Account' | where CounterName == 'UsedCapacity' | summarize avg(CounterValue) by Computer, CounterName | where avg_CounterValue > 1000000000000"
        Threshold = 1000000000000
        Aggregation = "Average"
    }
)

Write-Host "Alert rules to be created:" -ForegroundColor Yellow
foreach ($alert in $alerts) {
    Write-Host "`n  Alert: $($alert.Name)" -ForegroundColor Green
    Write-Host "    Look-back: 1 hour" -ForegroundColor White
    Write-Host "    Severity: $($alert.Severity)" -ForegroundColor White
}

Write-Host "`nNote: Alert rules are not automatically created to allow review." -ForegroundColor Yellow
Write-Host "To create these alerts, use Azure Portal or Azure CLI with the queries above." -ForegroundColor Yellow

# Create sample KQL queries for Log Analytics
Write-Host "`nCreating sample KQL queries..." -ForegroundColor Yellow

$queriesPath = ".\temp-kql-queries.txt"
$sampleQueries = @"
# PIM Monitoring KQL Queries
# Use these in Log Analytics workspace

# 1. Recent PIM Access Activations
AuditLogs
| where OperationName contains "PIM" or OperationName contains "Activate"
| where TimeGenerated > ago(24h)
| project TimeGenerated, UserPrincipalName, OperationName, Result
| order by TimeGenerated desc

# 2. Access Approval Delays
let activations = AuditLogs
| where OperationName contains "Activate"
| where TimeGenerated > ago(7d)
| project ActivationTime = TimeGenerated, User = UserPrincipalName;
let approvals = AuditLogs
| where OperationName contains "Approve"
| where TimeGenerated > ago(7d)
| project ApprovalTime = TimeGenerated, User = UserPrincipalName;
activations
| join kind=inner approvals on User
| where ApprovalTime < ActivationTime
| extend ApprovalDelay = ActivationTime - ApprovalTime
| summarize AvgDelay = avg(ApprovalDelay), MaxDelay = max(ApprovalDelay), Count = count() by User
| order by AvgDelay desc

# 3. Access by Hour (Heat Map Data)
AuditLogs
| where OperationName contains "PIM"
| where TimeGenerated > ago(30d)
| extend Hour = datetime_part("hour", TimeGenerated)
| summarize Count = count() by Hour
| order by Hour asc

# 4. Failed Access Attempts
AuditLogs
| where OperationName contains "PIM"
| where Result == "failure" or Result == "error"
| where TimeGenerated > ago(24h)
| project TimeGenerated, UserPrincipalName, OperationName, Result, ResultDescription
| order by TimeGenerated desc

# 5. Most Active Users
AuditLogs
| where OperationName contains "Activate"
| where TimeGenerated > ago(30d)
| summarize ActivationCount = count(), FirstActivation = min(TimeGenerated), LastActivation = max(TimeGenerated) by UserPrincipalName
| order by ActivationCount desc
| take 20

# 6. Access Duration Analysis
AuditLogs
| where OperationName contains "Deactivate"
| where TimeGenerated > ago(30d)
| join kind=inner (
    AuditLogs
    | where OperationName contains "Activate"
    | where TimeGenerated > ago(30d)
) on UserPrincipalName
| where TimeGenerated > TimeGenerated1
| extend Duration = TimeGenerated - TimeGenerated1
| summarize AvgDuration = avg(Duration), MaxDuration = max(Duration), MinDuration = min(Duration), Count = count()
"@ | Out-File -FilePath $queriesPath -Encoding UTF8

Write-Host "Sample KQL queries saved to: $queriesPath" -ForegroundColor Green

Write-Host "`n========================================" -ForegroundColor Cyan
Write-Host "Monitoring Setup Complete" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "Next Steps:" -ForegroundColor Yellow
Write-Host "1. Review KQL queries in: $queriesPath" -ForegroundColor White
Write-Host "2. Test queries in Log Analytics workspace" -ForegroundColor White
Write-Host "3. Create custom dashboards using the queries" -ForegroundColor White
Write-Host "4. Run: .\05-deploy-powerbi.ps1" -ForegroundColor White
Write-Host ""

