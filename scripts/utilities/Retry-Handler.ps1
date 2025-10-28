<#
.SYNOPSIS
    Retry Handler with Exponential Backoff

.DESCRIPTION
    Provides robust error handling and retry logic for transient failures,
    network delays, API throttling, and other temporary issues.

.AUTHOR
    Adrian Johnson

.NOTES
    Implements industry-standard retry patterns:
    - Exponential backoff
    - Jitter to prevent thundering herd
    - Circuit breaker pattern
    - Retry budget to prevent infinite loops
#>

class RetryHandler {
    [int]$MaxRetries
    [int]$InitialDelayMs
    [int]$MaxDelayMs
    [bool]$UseJitter
    [hashtable]$RetryableErrors
    [hashtable]$Statistics
    [scriptblock]$OnRetry
    
    RetryHandler() {
        $this.MaxRetries = 3
        $this.InitialDelayMs = 1000  # 1 second
        $this.MaxDelayMs = 30000     # 30 seconds
        $this.UseJitter = $true
        
        # Define retryable error patterns
        $this.RetryableErrors = @{
            # Network errors
            "TimeoutException" = $true
            "WebException" = $true
            "SocketException" = $true
            "IOException" = $true
            
            # HTTP errors
            "429" = $true  # Too Many Requests (throttling)
            "503" = $true  # Service Unavailable
            "504" = $true  # Gateway Timeout
            "408" = $true  # Request Timeout
            
            # Azure-specific errors
            "TooManyRequests" = $true
            "ServiceUnavailable" = $true
            "GatewayTimeout" = $true
            "InternalServerError" = $true  # Sometimes transient
            
            # Connection errors
            "ConnectionReset" = $true
            "ConnectionAborted" = $true
            "NameResolutionFailure" = $true
            "ConnectFailure" = $true
        }
        
        $this.Statistics = @{
            TotalAttempts = 0
            SuccessfulAttempts = 0
            FailedAttempts = 0
            RetriedAttempts = 0
            TotalRetryDelay = 0
        }
        
        $this.OnRetry = $null
    }
    
    [object] Invoke([scriptblock]$Operation) {
        return $this.Invoke($Operation, @{})
    }
    
    [object] Invoke([scriptblock]$Operation, [hashtable]$Parameters) {
        $attempt = 0
        $lastError = $null
        
        while ($attempt -le $this.MaxRetries) {
            $attempt++
            $this.Statistics.TotalAttempts++
            
            try {
                # Execute the operation
                if ($Parameters.Count -gt 0) {
                    $result = & $Operation @Parameters
                } else {
                    $result = & $Operation
                }
                
                # Success!
                $this.Statistics.SuccessfulAttempts++
                
                if ($attempt -gt 1) {
                    Write-Verbose "✅ Operation succeeded on attempt $attempt"
                }
                
                return @{
                    Success = $true
                    Result = $result
                    Attempts = $attempt
                    Error = $null
                }
                
            } catch {
                $lastError = $_
                $errorMessage = $_.Exception.Message
                $errorType = $_.Exception.GetType().Name
                
                # Check if error is retryable
                $isRetryable = $this.IsRetryable($errorMessage, $errorType)
                
                if ($isRetryable -and $attempt -le $this.MaxRetries) {
                    # Calculate delay with exponential backoff
                    $delay = $this.CalculateDelay($attempt)
                    $this.Statistics.RetriedAttempts++
                    $this.Statistics.TotalRetryDelay += $delay
                    
                    Write-Warning "⚠️ Attempt $attempt failed: $errorMessage"
                    Write-Warning "   Retrying in $($delay)ms... ($($this.MaxRetries - $attempt + 1) retries remaining)"
                    
                    # Call retry callback if defined
                    if ($this.OnRetry) {
                        & $this.OnRetry $attempt $errorMessage $delay
                    }
                    
                    Start-Sleep -Milliseconds $delay
                    
                } else {
                    # Non-retryable error or max retries exceeded
                    $this.Statistics.FailedAttempts++
                    
                    if (-not $isRetryable) {
                        Write-Error "❌ Non-retryable error: $errorMessage"
                    } else {
                        Write-Error "❌ Max retries ($($this.MaxRetries)) exceeded: $errorMessage"
                    }
                    
                    return @{
                        Success = $false
                        Result = $null
                        Attempts = $attempt
                        Error = $lastError
                    }
                }
            }
        }
        
        # Should never reach here, but just in case
        return @{
            Success = $false
            Result = $null
            Attempts = $attempt
            Error = $lastError
        }
    }
    
    [bool] IsRetryable([string]$ErrorMessage, [string]$ErrorType) {
        # Check error type
        if ($this.RetryableErrors.ContainsKey($ErrorType)) {
            return $true
        }
        
        # Check error message for patterns
        foreach ($pattern in $this.RetryableErrors.Keys) {
            if ($ErrorMessage -like "*$pattern*") {
                return $true
            }
        }
        
        # Check for specific HTTP status codes
        if ($ErrorMessage -match "\b(429|503|504|408)\b") {
            return $true
        }
        
        # Check for common transient error phrases
        $transientPhrases = @(
            "timeout",
            "timed out",
            "connection",
            "network",
            "temporary",
            "transient",
            "unavailable",
            "throttled",
            "rate limit",
            "try again"
        )
        
        foreach ($phrase in $transientPhrases) {
            if ($ErrorMessage -like "*$phrase*") {
                return $true
            }
        }
        
        return $false
    }
    
    [int] CalculateDelay([int]$Attempt) {
        # Exponential backoff: delay = InitialDelay * 2^(attempt-1)
        $delay = $this.InitialDelayMs * [Math]::Pow(2, $Attempt - 1)
        
        # Cap at maximum delay
        $delay = [Math]::Min($delay, $this.MaxDelayMs)
        
        # Add jitter to prevent thundering herd problem
        if ($this.UseJitter) {
            $jitterRange = $delay * 0.2  # ±20% jitter
            $jitter = (Get-Random -Minimum (-$jitterRange) -Maximum $jitterRange)
            $delay = $delay + $jitter
        }
        
        return [int]$delay
    }
    
    [hashtable] GetStatistics() {
        $stats = $this.Statistics.Clone()
        
        # Calculate success rate
        if ($stats.TotalAttempts -gt 0) {
            $stats.SuccessRate = [Math]::Round(($stats.SuccessfulAttempts / $stats.TotalAttempts) * 100, 2)
        } else {
            $stats.SuccessRate = 0
        }
        
        # Calculate average retry delay
        if ($stats.RetriedAttempts -gt 0) {
            $stats.AverageRetryDelay = [Math]::Round($stats.TotalRetryDelay / $stats.RetriedAttempts, 0)
        } else {
            $stats.AverageRetryDelay = 0
        }
        
        return $stats
    }
    
    [void] ResetStatistics() {
        $this.Statistics = @{
            TotalAttempts = 0
            SuccessfulAttempts = 0
            FailedAttempts = 0
            RetriedAttempts = 0
            TotalRetryDelay = 0
        }
    }
}

# Circuit Breaker Pattern for preventing cascading failures
class CircuitBreaker {
    [int]$FailureThreshold
    [int]$SuccessThreshold
    [int]$TimeoutMs
    [string]$State  # Closed, Open, HalfOpen
    [int]$FailureCount
    [int]$SuccessCount
    [datetime]$LastFailureTime
    [hashtable]$Statistics
    
    CircuitBreaker([int]$FailureThreshold, [int]$TimeoutMs) {
        $this.FailureThreshold = $FailureThreshold
        $this.SuccessThreshold = 2  # Require 2 successes to close circuit
        $this.TimeoutMs = $TimeoutMs
        $this.State = "Closed"
        $this.FailureCount = 0
        $this.SuccessCount = 0
        $this.LastFailureTime = [datetime]::MinValue
        
        $this.Statistics = @{
            TotalCalls = 0
            SuccessfulCalls = 0
            FailedCalls = 0
            RejectedCalls = 0
            StateChanges = 0
        }
    }
    
    [object] Execute([scriptblock]$Operation) {
        $this.Statistics.TotalCalls++
        
        # Check if circuit is open
        if ($this.State -eq "Open") {
            # Check if timeout has elapsed
            $elapsedMs = ((Get-Date) - $this.LastFailureTime).TotalMilliseconds
            
            if ($elapsedMs -gt $this.TimeoutMs) {
                # Move to half-open state
                $this.State = "HalfOpen"
                $this.Statistics.StateChanges++
                Write-Verbose "🔶 Circuit breaker: Open → HalfOpen"
            } else {
                # Circuit still open, reject call
                $this.Statistics.RejectedCalls++
                Write-Warning "⛔ Circuit breaker is OPEN. Call rejected. Retry in $([Math]::Round(($this.TimeoutMs - $elapsedMs) / 1000, 1))s"
                
                return @{
                    Success = $false
                    Result = $null
                    CircuitOpen = $true
                    Error = "Circuit breaker is open"
                }
            }
        }
        
        # Execute operation
        try {
            $result = & $Operation
            
            # Success
            $this.OnSuccess()
            $this.Statistics.SuccessfulCalls++
            
            return @{
                Success = $true
                Result = $result
                CircuitOpen = $false
                Error = $null
            }
            
        } catch {
            # Failure
            $this.OnFailure()
            $this.Statistics.FailedCalls++
            
            return @{
                Success = $false
                Result = $null
                CircuitOpen = ($this.State -eq "Open")
                Error = $_.Exception.Message
            }
        }
    }
    
    [void] OnSuccess() {
        $this.FailureCount = 0
        
        if ($this.State -eq "HalfOpen") {
            $this.SuccessCount++
            
            if ($this.SuccessCount -ge $this.SuccessThreshold) {
                # Close the circuit
                $this.State = "Closed"
                $this.SuccessCount = 0
                $this.Statistics.StateChanges++
                Write-Host "✅ Circuit breaker: HalfOpen → Closed" -ForegroundColor Green
            }
        }
    }
    
    [void] OnFailure() {
        $this.SuccessCount = 0
        $this.FailureCount++
        $this.LastFailureTime = Get-Date
        
        if ($this.State -eq "HalfOpen") {
            # Open the circuit immediately in half-open state
            $this.State = "Open"
            $this.Statistics.StateChanges++
            Write-Warning "🔴 Circuit breaker: HalfOpen → Open"
            
        } elseif ($this.State -eq "Closed" -and $this.FailureCount -ge $this.FailureThreshold) {
            # Open the circuit after threshold failures
            $this.State = "Open"
            $this.Statistics.StateChanges++
            Write-Warning "🔴 Circuit breaker: Closed → Open (threshold: $($this.FailureThreshold) failures)"
        }
    }
    
    [hashtable] GetStatistics() {
        $stats = $this.Statistics.Clone()
        $stats.CurrentState = $this.State
        $stats.FailureCount = $this.FailureCount
        $stats.SuccessCount = $this.SuccessCount
        
        if ($stats.TotalCalls -gt 0) {
            $stats.SuccessRate = [Math]::Round(($stats.SuccessfulCalls / $stats.TotalCalls) * 100, 2)
            $stats.RejectionRate = [Math]::Round(($stats.RejectedCalls / $stats.TotalCalls) * 100, 2)
        }
        
        return $stats
    }
    
    [void] Reset() {
        $this.State = "Closed"
        $this.FailureCount = 0
        $this.SuccessCount = 0
        $this.LastFailureTime = [datetime]::MinValue
    }
}

# Helper function for simple retry scenarios
function Invoke-WithRetry {
    param(
        [Parameter(Mandatory)]
        [scriptblock]$Operation,
        
        [int]$MaxRetries = 3,
        
        [int]$InitialDelayMs = 1000,
        
        [int]$MaxDelayMs = 30000,
        
        [switch]$UseJitter,
        
        [scriptblock]$OnRetry
    )
    
    $retryHandler = [RetryHandler]::new()
    $retryHandler.MaxRetries = $MaxRetries
    $retryHandler.InitialDelayMs = $InitialDelayMs
    $retryHandler.MaxDelayMs = $MaxDelayMs
    $retryHandler.UseJitter = $UseJitter
    
    if ($OnRetry) {
        $retryHandler.OnRetry = $OnRetry
    }
    
    $result = $retryHandler.Invoke($Operation)
    
    if ($result.Success) {
        return $result.Result
    } else {
        throw $result.Error
    }
}

# Export classes and functions
Export-ModuleMember -Function Invoke-WithRetry

