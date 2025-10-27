<#
.SYNOPSIS
    Run Threat Detection Analysis on PIM Access Events

.DESCRIPTION
    Demonstrates the AI-based threat detection system analyzing access events

.EXAMPLE
    .\run-threat-detection.ps1 -DaysToAnalyze 7
#>

[CmdletBinding()]
param(
    [int]$DaysToAnalyze = 7
)

$ErrorActionPreference = "Stop"

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "Azure PIM - Threat Detection Analysis" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# Import utilities
Import-Module ..\utilities\Anomaly-Detector.ps1 -Force
Import-Module ..\utilities\Risk-Calculator.ps1 -Force

# Initialize
$anomalyDetector = [AnomalyDetector]::new()
$riskCalculator = [RiskCalculator]::new()

Write-Host "Collecting access events from last $DaysToAnalyze days..." -ForegroundColor Yellow

# Simulate access events (in production, fetch from Azure AD)
$accessEvents = @(
    @{
        Id = "evt-001"
        UserPrincipalName = "user@company.com"
        Timestamp = (Get-Date).AddHours(-2).ToString("o")
        Role = "Global Administrator"
        Location = "United States"
    },
    @{
        Id = "evt-002"
        UserPrincipalName = "admin@company.com"
        Timestamp = (Get-Date).AddHours(-12).ToString("o")
        Role = "User Administrator"
        Location = "United States"
    },
    @{
        Id = "evt-003"
        UserPrincipalName = "user@company.com"
        Timestamp = (Get-Date).AddDays(-1).AddHours(-3).ToString("o")
        Role = "Global Administrator"
        Location = "Russia"  # Suspicious!
    }
)

Write-Host "  Found $($accessEvents.Count) events" -ForegroundColor Green

# Run anomaly detection
Write-Host "`nRunning anomaly detection..." -ForegroundColor Yellow
$anomalies = $anomalyDetector.DetectAnomalies($accessEvents)

# Display results
Write-Host "`n========================================" -ForegroundColor Cyan
Write-Host "Threat Detection Results" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan

if ($anomalies.Count -eq 0) {
    Write-Host "`n✓ No anomalies detected" -ForegroundColor Green
} else {
    Write-Host "`n⚠ Detected $($anomalies.Count) anomalies:" -ForegroundColor Yellow
    
    foreach ($anomaly in $anomalies) {
        $severityColor = switch ($anomaly.Severity) {
            "Critical" { "Red" }
            "High" { "Magenta" }
            "Medium" { "Yellow" }
            default { "Gray" }
        }
        
        Write-Host "`nAnomaly ID: $($anomaly.EventId)" -ForegroundColor $severityColor
        Write-Host "  User: $($anomaly.UserPrincipalName)" -ForegroundColor White
        Write-Host "  Timestamp: $($anomaly.Timestamp)" -ForegroundColor White
        Write-Host "  Risk Score: $([Math]::Round($anomaly.RiskScore, 2))" -ForegroundColor White
        Write-Host "  Severity: $($anomaly.Severity)" -ForegroundColor $severityColor
        Write-Host "  Type: $($anomaly.AnomalyType)" -ForegroundColor White
        Write-Host "  Recommendations:" -ForegroundColor White
        foreach ($rec in $anomaly.Recommendations) {
            Write-Host "    - $rec" -ForegroundColor Gray
        }
    }
}

# Risk summary
Write-Host "`n========================================" -ForegroundColor Cyan
Write-Host "Risk Summary" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan

$critical = ($anomalies | Where-Object { $_.Severity -eq "Critical" }).Count
$high = ($anomalies | Where-Object { $_.Severity -eq "High" }).Count
$medium = ($anomalies | Where-Object { $_.Severity -eq "Medium" }).Count
$low = ($anomalies | Where-Object { $_.Severity -eq "Low" }).Count

Write-Host "`nSeverity Breakdown:" -ForegroundColor Yellow
Write-Host "  Critical: $critical" -ForegroundColor $(if ($critical -gt 0) { "Red" } else { "Green" })
Write-Host "  High: $high" -ForegroundColor $(if ($high -gt 0) { "Magenta" } else { "Green" })
Write-Host "  Medium: $medium" -ForegroundColor $(if ($medium -gt 0) { "Yellow" } else { "Green" })
Write-Host "  Low: $low" -ForegroundColor Green

Write-Host ""

