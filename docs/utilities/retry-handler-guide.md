# Retry Handler Usage Guide

**Author:** Adrian Johnson  
**Email:** adrian207@gmail.com  
**Version:** 1.0  
**Date:** December 2024

---

## What Is the Retry Handler?

The Retry Handler automatically retries failed operations caused by temporary issues like network delays, API throttling, or service unavailability. You don't need to write complex retry logic yourself - just wrap your code and it handles everything.

**Think of it like:** An automatic "try again" button that knows when and how to retry safely.

---

## Quick Start (30 seconds)

### Simple Retry - One Line

```powershell
# Import the retry handler
Import-Module .\scripts\utilities\Retry-Handler.ps1

# Wrap any command that might fail temporarily
$result = Invoke-WithRetry { Get-AzResource -ResourceGroupName "my-rg" }
```

That's it! If the command fails due to network issues or throttling, it will automatically retry up to 3 times with smart delays.

---

## Common Use Cases

### 1. Azure API Calls (Most Common)

**Problem:** Azure APIs sometimes return 429 (throttling) or 503 (unavailable) errors.

**Solution:**
```powershell
Import-Module .\scripts\utilities\Retry-Handler.ps1

# Get Azure resources with automatic retry
$resources = Invoke-WithRetry {
    Get-AzResource -ResourceGroupName "pim-rg"
}

# Assign PIM role with automatic retry
$assignment = Invoke-WithRetry {
    New-AzRoleAssignment `
        -ObjectId $userId `
        -RoleDefinitionName "Contributor" `
        -Scope "/subscriptions/$subscriptionId"
}

# Query logs with automatic retry
$logs = Invoke-WithRetry {
    Get-AzOperationalInsightsSearchResults `
        -WorkspaceId $workspaceId `
        -Query "AuditLogs | where TimeGenerated > ago(1h)"
}
```

### 2. Web API Calls

**Problem:** External APIs might be temporarily unavailable or rate-limited.

**Solution:**
```powershell
# Call ServiceNow API with retry
$ticket = Invoke-WithRetry {
    Invoke-RestMethod `
        -Uri "https://yourinstance.service-now.com/api/now/table/incident" `
        -Method POST `
        -Headers $headers `
        -Body $body
}

# Call Microsoft Graph API with retry
$users = Invoke-WithRetry {
    Invoke-RestMethod `
        -Uri "https://graph.microsoft.com/v1.0/users" `
        -Headers @{ Authorization = "Bearer $token" }
}
```

### 3. File Operations on Network Drives

**Problem:** Network drives might be temporarily unavailable.

**Solution:**
```powershell
# Read file from network share with retry
$content = Invoke-WithRetry {
    Get-Content "\\server\share\config.json" | ConvertFrom-Json
}

# Write file to network share with retry
Invoke-WithRetry {
    $data | ConvertTo-Json | Set-Content "\\server\share\output.json"
}
```

### 4. Database Queries

**Problem:** Database connections might timeout or be temporarily unavailable.

**Solution:**
```powershell
# Query database with retry
$data = Invoke-WithRetry {
    Invoke-Sqlcmd `
        -ServerInstance "sqlserver.database.windows.net" `
        -Database "mydb" `
        -Query "SELECT * FROM Users"
}
```

---

## Customizing Retry Behavior

### Change Number of Retries

```powershell
# Retry up to 5 times instead of default 3
$result = Invoke-WithRetry {
    Get-AzResource
} -MaxRetries 5
```

### Change Retry Delays

```powershell
# Start with 2 second delay, max 60 seconds
$result = Invoke-WithRetry {
    Get-AzResource
} -InitialDelayMs 2000 -MaxDelayMs 60000
```

### Disable Jitter (Not Recommended)

```powershell
# Use exact delays without randomization
$result = Invoke-WithRetry {
    Get-AzResource
} -UseJitter:$false
```

### Add Custom Logging on Retry

```powershell
# Log each retry attempt
$result = Invoke-WithRetry {
    Get-AzResource
} -OnRetry {
    param($attempt, $errorMessage, $delayMs)
    Write-Host "Retry $attempt after error: $errorMessage (waiting $delayMs ms)"
    # Could also log to file, send alert, etc.
}
```

---

## Advanced Usage

### Full Control with RetryHandler Class

```powershell
Import-Module .\scripts\utilities\Retry-Handler.ps1

# Create handler with custom settings
$retryHandler = [RetryHandler]::new()
$retryHandler.MaxRetries = 5
$retryHandler.InitialDelayMs = 2000
$retryHandler.MaxDelayMs = 60000
$retryHandler.UseJitter = $true

# Add custom retry callback
$retryHandler.OnRetry = {
    param($attempt, $errorMessage, $delayMs)
    Write-Host "⚠️ Attempt $attempt failed: $errorMessage" -ForegroundColor Yellow
    Write-Host "   Waiting $([Math]::Round($delayMs/1000, 1))s before retry..." -ForegroundColor Yellow
}

# Execute with retry
$result = $retryHandler.Invoke({
    Get-AzResource -ResourceGroupName "pim-rg"
})

# Check result
if ($result.Success) {
    Write-Host "✅ Operation succeeded after $($result.Attempts) attempt(s)" -ForegroundColor Green
    $data = $result.Result
} else {
    Write-Host "❌ Operation failed after $($result.Attempts) attempts" -ForegroundColor Red
    Write-Host "Error: $($result.Error.Exception.Message)" -ForegroundColor Red
}

# View statistics
$stats = $retryHandler.GetStatistics()
Write-Host "Total attempts: $($stats.TotalAttempts)"
Write-Host "Success rate: $($stats.SuccessRate)%"
Write-Host "Average retry delay: $($stats.AverageRetryDelay)ms"
```

### Circuit Breaker for Preventing Cascading Failures

**When to use:** When calling an external service that might go down completely.

```powershell
Import-Module .\scripts\utilities\Retry-Handler.ps1

# Create circuit breaker
# Opens after 5 failures, stays open for 60 seconds
$circuitBreaker = [CircuitBreaker]::new(5, 60000)

# Execute operations
for ($i = 0; $i -lt 100; $i++) {
    $result = $circuitBreaker.Execute({
        # Your operation here
        Invoke-RestMethod -Uri "https://api.example.com/data"
    })
    
    if ($result.Success) {
        Write-Host "✅ Request $i succeeded" -ForegroundColor Green
        $data = $result.Result
    } elseif ($result.CircuitOpen) {
        Write-Host "⛔ Request $i rejected - circuit breaker is OPEN" -ForegroundColor Red
        # Skip this request, service is down
    } else {
        Write-Host "❌ Request $i failed" -ForegroundColor Red
    }
}

# View circuit breaker statistics
$stats = $circuitBreaker.GetStatistics()
Write-Host "Circuit state: $($stats.CurrentState)"
Write-Host "Success rate: $($stats.SuccessRate)%"
Write-Host "Rejected calls: $($stats.RejectedCalls)"
```

---

## How It Works

### Exponential Backoff

The retry handler uses exponential backoff to avoid overwhelming failing services:

```
Attempt 1: Immediate
Attempt 2: Wait 1 second
Attempt 3: Wait 2 seconds
Attempt 4: Wait 4 seconds
Attempt 5: Wait 8 seconds
Attempt 6: Wait 16 seconds
...
Max wait: 30 seconds
```

### Jitter (±20%)

Adds randomness to prevent "thundering herd" when many clients retry at once:

```
Without jitter: All clients retry at exactly 2s, 4s, 8s
With jitter:    Clients retry at 1.6-2.4s, 3.2-4.8s, 6.4-9.6s
```

### Automatic Error Detection

The retry handler automatically detects these retryable errors:

**Network Errors:**
- TimeoutException
- WebException
- SocketException
- IOException
- Connection reset/aborted
- Name resolution failure

**HTTP Status Codes:**
- 429 - Too Many Requests (throttling)
- 503 - Service Unavailable
- 504 - Gateway Timeout
- 408 - Request Timeout

**Azure-Specific:**
- TooManyRequests
- ServiceUnavailable
- GatewayTimeout
- InternalServerError (sometimes transient)

**Error Message Patterns:**
- "timeout", "timed out"
- "connection", "network"
- "temporary", "transient"
- "unavailable", "throttled"
- "rate limit", "try again"

---

## Real-World Examples

### Example 1: Bulk User Provisioning

**Scenario:** Provisioning 100 users, some API calls might be throttled.

```powershell
Import-Module .\scripts\utilities\Retry-Handler.ps1

$users = Import-Csv "users.csv"

foreach ($user in $users) {
    Write-Host "Provisioning $($user.Email)..." -ForegroundColor Cyan
    
    # Create user with automatic retry
    $result = Invoke-WithRetry {
        New-AzADUser `
            -DisplayName $user.Name `
            -UserPrincipalName $user.Email `
            -MailNickname $user.Alias `
            -PasswordProfile $passwordProfile
    } -MaxRetries 5
    
    Write-Host "✅ User created: $($user.Email)" -ForegroundColor Green
}
```

### Example 2: Log Collection During Incident

**Scenario:** Collecting logs during an incident when Azure Monitor might be under load.

```powershell
Import-Module .\scripts\utilities\Retry-Handler.ps1

$retryHandler = [RetryHandler]::new()
$retryHandler.MaxRetries = 10  # Be more persistent during incidents
$retryHandler.InitialDelayMs = 5000  # Start with longer delays

# Collect logs with aggressive retry
$logs = $retryHandler.Invoke({
    Get-AzOperationalInsightsSearchResults `
        -WorkspaceId $workspaceId `
        -Query @"
            AuditLogs
            | where TimeGenerated > ago(1h)
            | where OperationName contains "PIM"
            | where ResultType == "Failure"
"@
})

if ($logs.Success) {
    $logs.Result | Export-Csv "incident-logs.csv"
    Write-Host "✅ Collected $($logs.Result.Count) log entries" -ForegroundColor Green
} else {
    Write-Host "❌ Failed to collect logs after $($logs.Attempts) attempts" -ForegroundColor Red
}
```

### Example 3: Integration with Existing Scripts

**Scenario:** Adding retry to existing deployment script.

**Before:**
```powershell
# Existing script - fails on transient errors
$resources = Get-AzResource -ResourceGroupName "pim-rg"
$roleAssignments = Get-AzRoleAssignment -Scope $scope
```

**After:**
```powershell
# Add retry handler at the top
Import-Module .\scripts\utilities\Retry-Handler.ps1

# Wrap existing calls - no other changes needed!
$resources = Invoke-WithRetry { Get-AzResource -ResourceGroupName "pim-rg" }
$roleAssignments = Invoke-WithRetry { Get-AzRoleAssignment -Scope $scope }
```

---

## Troubleshooting

### Issue: "Operation keeps failing even with retry"

**Cause:** The error might not be transient (e.g., wrong credentials, missing permissions).

**Solution:** Check the error message to see if it's a permanent error:

```powershell
$result = Invoke-WithRetry {
    Get-AzResource -ResourceGroupName "nonexistent-rg"
} -MaxRetries 3

if (-not $result.Success) {
    Write-Host "Error: $($result.Error.Exception.Message)"
    # If error is "ResourceGroupNotFound", no amount of retrying will help
}
```

### Issue: "Retries are too slow"

**Cause:** Default delays might be too long for your use case.

**Solution:** Reduce initial delay:

```powershell
$result = Invoke-WithRetry {
    Get-AzResource
} -InitialDelayMs 500 -MaxDelayMs 5000  # Faster retries
```

### Issue: "Want to see what's happening during retries"

**Cause:** Default retry is silent.

**Solution:** Add verbose logging:

```powershell
$result = Invoke-WithRetry {
    Get-AzResource
} -OnRetry {
    param($attempt, $error, $delay)
    Write-Host "Retry $attempt: $error (waiting $delay ms)" -ForegroundColor Yellow
} -Verbose
```

### Issue: "Circuit breaker keeps opening"

**Cause:** Service is genuinely down or threshold is too low.

**Solution:** Adjust threshold or add monitoring:

```powershell
# Increase failure threshold
$circuitBreaker = [CircuitBreaker]::new(10, 60000)  # Allow 10 failures

# Monitor state
$stats = $circuitBreaker.GetStatistics()
if ($stats.CurrentState -eq "Open") {
    Write-Warning "Circuit breaker is OPEN - service may be down"
    # Send alert, check service health, etc.
}
```

---

## Best Practices

### ✅ DO:
- Use retry for Azure API calls (they can be throttled)
- Use retry for external API calls (they can be unreliable)
- Use retry for network file operations
- Use circuit breaker for services that might go completely down
- Log retry attempts for troubleshooting
- Set reasonable max retries (3-5 for most cases)

### ❌ DON'T:
- Retry operations that modify state without idempotency checks
- Use infinite retries (always set MaxRetries)
- Retry authentication failures (they won't succeed)
- Retry permission errors (they're permanent)
- Use retry for local file operations (they don't need it)
- Set very short delays (< 500ms) - gives services no time to recover

---

## Performance Impact

**Successful operations:**
- Overhead: < 1ms
- Impact: Negligible

**Failed operations (with retry):**
- First retry: ~1 second delay
- Second retry: ~2 seconds delay
- Third retry: ~4 seconds delay
- Total: ~7 seconds for 3 retries

**vs. Manual retry:**
- User notices failure: ~30 seconds
- User reruns script: ~1 minute
- Total: ~1.5 minutes

**Savings:** ~1 minute 23 seconds per transient failure

---

## FAQ

**Q: Does retry work with all PowerShell commands?**
A: Yes! It works with any command or script block.

**Q: What happens if all retries fail?**
A: The original error is thrown, just like without retry.

**Q: Can I use retry in production?**
A: Yes! It's designed for production use with proper error handling.

**Q: Does retry slow down my scripts?**
A: Only when operations fail. Successful operations have < 1ms overhead.

**Q: Can I customize which errors are retryable?**
A: Yes! Use the full RetryHandler class and modify the `RetryableErrors` hashtable.

**Q: Should I use retry for everything?**
A: No. Use it for operations that might fail temporarily (network, APIs). Don't use it for local operations or permanent errors.

---

## Summary

**Simple usage:**
```powershell
Import-Module .\scripts\utilities\Retry-Handler.ps1
$result = Invoke-WithRetry { Your-Command }
```

**That's it!** The retry handler will automatically:
- ✅ Retry on transient failures
- ✅ Use exponential backoff
- ✅ Add jitter to prevent thundering herd
- ✅ Stop on permanent errors
- ✅ Return results or throw errors appropriately

**Related Documentation:**
- [Bulk Operations API](../performance/bulk-operations-api.md)
- [Distributed Caching](../performance/distributed-caching-redis.md)
- [Error Handling Best Practices](../operations/maintenance-procedures.md)

---

**Questions?** Contact adrian207@gmail.com

