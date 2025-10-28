<#
.SYNOPSIS
    Test Runner for Azure PIM Solution

.DESCRIPTION
    Runs all Pester tests and generates comprehensive reports

.AUTHOR
    Adrian Johnson
#>

param(
    [string]$OutputPath = ".\test-results",
    [switch]$ShowCoverage,
    [switch]$GenerateHTML,
    [string]$TestPath = ".\tests"
)

# Ensure Pester 5.x is loaded
Import-Module Pester -MinimumVersion 5.0 -ErrorAction Stop

Write-Host "🧪 Azure PIM Solution - Test Suite" -ForegroundColor Cyan
Write-Host "=" * 60 -ForegroundColor Cyan
Write-Host ""

# Create output directory
if (-not (Test-Path $OutputPath)) {
    New-Item -ItemType Directory -Path $OutputPath -Force | Out-Null
}

# Configure Pester
$pesterConfig = New-PesterConfiguration
$pesterConfig.Run.Path = $TestPath
$pesterConfig.Run.PassThru = $true
$pesterConfig.Output.Verbosity = 'Detailed'
$pesterConfig.TestResult.Enabled = $true
$pesterConfig.TestResult.OutputPath = Join-Path $OutputPath "test-results.xml"
$pesterConfig.TestResult.OutputFormat = 'NUnitXml'

if ($ShowCoverage) {
    $pesterConfig.CodeCoverage.Enabled = $true
    $pesterConfig.CodeCoverage.Path = ".\scripts\**\*.ps1"
    $pesterConfig.CodeCoverage.OutputPath = Join-Path $OutputPath "coverage.xml"
}

# Run tests
Write-Host "Running tests..." -ForegroundColor Yellow
$testResults = Invoke-Pester -Configuration $pesterConfig

# Display summary
Write-Host ""
Write-Host "=" * 60 -ForegroundColor Cyan
Write-Host "📊 Test Summary" -ForegroundColor Cyan
Write-Host "=" * 60 -ForegroundColor Cyan
Write-Host ""

$totalTests = $testResults.TotalCount
$passedTests = $testResults.PassedCount
$failedTests = $testResults.FailedCount
$skippedTests = $testResults.SkippedCount
$duration = $testResults.Duration.TotalSeconds

Write-Host "Total Tests:   $totalTests" -ForegroundColor White
Write-Host "Passed:        " -NoNewline
Write-Host "$passedTests" -ForegroundColor Green
Write-Host "Failed:        " -NoNewline
if ($failedTests -gt 0) {
    Write-Host "$failedTests" -ForegroundColor Red
} else {
    Write-Host "$failedTests" -ForegroundColor Green
}
Write-Host "Skipped:       $skippedTests" -ForegroundColor Yellow
Write-Host "Duration:      $([Math]::Round($duration, 2)) seconds" -ForegroundColor White
Write-Host ""

# Calculate pass rate
$passRate = if ($totalTests -gt 0) { [Math]::Round(($passedTests / $totalTests) * 100, 2) } else { 0 }
Write-Host "Pass Rate:     " -NoNewline
if ($passRate -ge 90) {
    Write-Host "$passRate%" -ForegroundColor Green
} elseif ($passRate -ge 70) {
    Write-Host "$passRate%" -ForegroundColor Yellow
} else {
    Write-Host "$passRate%" -ForegroundColor Red
}
Write-Host ""

# Show failed tests details
if ($failedTests -gt 0) {
    Write-Host "❌ Failed Tests:" -ForegroundColor Red
    Write-Host ""
    foreach ($test in $testResults.Failed) {
        Write-Host "  • $($test.ExpandedName)" -ForegroundColor Red
        Write-Host "    $($test.ErrorRecord.Exception.Message)" -ForegroundColor DarkRed
        Write-Host ""
    }
}

# Show coverage if enabled
if ($ShowCoverage -and $testResults.CodeCoverage) {
    Write-Host "📈 Code Coverage:" -ForegroundColor Cyan
    Write-Host ""
    
    $coverage = $testResults.CodeCoverage
    $coveredCommands = $coverage.CommandsExecutedCount
    $totalCommands = $coverage.CommandsAnalyzedCount
    $coveragePercent = if ($totalCommands -gt 0) { [Math]::Round(($coveredCommands / $totalCommands) * 100, 2) } else { 0 }
    
    Write-Host "Commands Executed: $coveredCommands / $totalCommands" -ForegroundColor White
    Write-Host "Coverage:          " -NoNewline
    if ($coveragePercent -ge 80) {
        Write-Host "$coveragePercent%" -ForegroundColor Green
    } elseif ($coveragePercent -ge 60) {
        Write-Host "$coveragePercent%" -ForegroundColor Yellow
    } else {
        Write-Host "$coveragePercent%" -ForegroundColor Red
    }
    Write-Host ""
}

# Generate HTML report if requested
if ($GenerateHTML) {
    Write-Host "📄 Generating HTML report..." -ForegroundColor Yellow
    
    $htmlReport = @"
<!DOCTYPE html>
<html>
<head>
    <title>Azure PIM Solution - Test Results</title>
    <style>
        body { font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif; margin: 20px; background: #f5f5f5; }
        .container { max-width: 1200px; margin: 0 auto; background: white; padding: 30px; border-radius: 8px; box-shadow: 0 2px 4px rgba(0,0,0,0.1); }
        h1 { color: #0078d4; border-bottom: 3px solid #0078d4; padding-bottom: 10px; }
        h2 { color: #333; margin-top: 30px; }
        .summary { display: grid; grid-template-columns: repeat(auto-fit, minmax(200px, 1fr)); gap: 20px; margin: 20px 0; }
        .metric { background: #f8f9fa; padding: 20px; border-radius: 4px; text-align: center; }
        .metric-value { font-size: 2em; font-weight: bold; margin: 10px 0; }
        .passed { color: #28a745; }
        .failed { color: #dc3545; }
        .skipped { color: #ffc107; }
        .test-list { list-style: none; padding: 0; }
        .test-item { padding: 10px; margin: 5px 0; border-left: 4px solid #28a745; background: #f8f9fa; }
        .test-item.failed { border-left-color: #dc3545; }
        .error-message { color: #dc3545; font-size: 0.9em; margin-top: 5px; }
        .timestamp { color: #666; font-size: 0.9em; }
    </style>
</head>
<body>
    <div class="container">
        <h1>🔐 Azure PIM Solution - Test Results</h1>
        <p class="timestamp">Generated: $(Get-Date -Format "yyyy-MM-dd HH:mm:ss")</p>
        
        <div class="summary">
            <div class="metric">
                <div>Total Tests</div>
                <div class="metric-value">$totalTests</div>
            </div>
            <div class="metric">
                <div>Passed</div>
                <div class="metric-value passed">$passedTests</div>
            </div>
            <div class="metric">
                <div>Failed</div>
                <div class="metric-value failed">$failedTests</div>
            </div>
            <div class="metric">
                <div>Pass Rate</div>
                <div class="metric-value">$passRate%</div>
            </div>
            <div class="metric">
                <div>Duration</div>
                <div class="metric-value">$([Math]::Round($duration, 2))s</div>
            </div>
        </div>
        
        <h2>Test Results by Category</h2>
"@

    # Group tests by file
    $testsByFile = $testResults.Tests | Group-Object -Property { $_.ScriptBlock.File }
    
    foreach ($group in $testsByFile) {
        $fileName = Split-Path $group.Name -Leaf
        $htmlReport += "<h3>$fileName</h3><ul class='test-list'>"
        
        foreach ($test in $group.Group) {
            $status = if ($test.Result -eq 'Passed') { 'passed' } else { 'failed' }
            $icon = if ($test.Result -eq 'Passed') { '✅' } else { '❌' }
            
            $htmlReport += "<li class='test-item $status'>$icon $($test.ExpandedName)"
            
            if ($test.Result -ne 'Passed' -and $test.ErrorRecord) {
                $htmlReport += "<div class='error-message'>$($test.ErrorRecord.Exception.Message)</div>"
            }
            
            $htmlReport += "</li>"
        }
        
        $htmlReport += "</ul>"
    }
    
    $htmlReport += @"
    </div>
</body>
</html>
"@
    
    $htmlPath = Join-Path $OutputPath "test-results.html"
    $htmlReport | Out-File $htmlPath -Encoding UTF8
    
    Write-Host "✅ HTML report generated: $htmlPath" -ForegroundColor Green
    Write-Host ""
}

# Save summary to JSON
$summary = @{
    Timestamp = (Get-Date).ToString("o")
    TotalTests = $totalTests
    PassedTests = $passedTests
    FailedTests = $failedTests
    SkippedTests = $skippedTests
    PassRate = $passRate
    Duration = $duration
    FailedTestNames = $testResults.Failed | ForEach-Object { $_.ExpandedName }
}

$summaryPath = Join-Path $OutputPath "test-summary.json"
$summary | ConvertTo-Json -Depth 5 | Out-File $summaryPath -Encoding UTF8

Write-Host "📁 Test results saved to: $OutputPath" -ForegroundColor Cyan
Write-Host ""

# Exit with appropriate code
if ($failedTests -gt 0) {
    Write-Host "❌ Tests failed!" -ForegroundColor Red
    exit 1
} else {
    Write-Host "✅ All tests passed!" -ForegroundColor Green
    exit 0
}

