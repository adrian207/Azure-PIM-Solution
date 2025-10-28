<#
.SYNOPSIS
    Bulk Operations Helper for Azure PIM Solution

.DESCRIPTION
    Provides efficient bulk operations to reduce API calls

.AUTHOR
    Adrian Johnson
#>

function Invoke-BulkOperation {
    param(
        [Parameter(Mandatory)]
        [scriptblock]$Operation,
        
        [Parameter(Mandatory)]
        [AllowEmptyCollection()]
        [array]$Items,
        
        [int]$BatchSize = 50,
        
        [int]$MaxParallel = 10,
        
        [switch]$ShowProgress
    )

    # Handle empty array
    if ($Items.Count -eq 0) {
        return @()
    }

    $batches = @()
    for ($i = 0; $i -lt $Items.Count; $i += $BatchSize) {
        $batch = $Items[$i..([Math]::Min($i + $BatchSize - 1, $Items.Count - 1))]
        $batches += ,@($batch)
    }

    $results = @()
    $totalBatches = $batches.Count
    $batchNum = 0

    # Convert scriptblock to string for parallel execution
    $operationString = $Operation.ToString()

    foreach ($batch in $batches) {
        $batchNum++
        
        if ($ShowProgress) {
            $percentComplete = [Math]::Round(($batchNum / $totalBatches) * 100)
            Write-Progress -Activity "Processing Bulk Operation" `
                -Status "Processing batch $batchNum of $totalBatches ($percentComplete%)" `
                -PercentComplete $percentComplete
        }

        # Process batch in parallel (limited by MaxParallel)
        $batchResults = $batch | ForEach-Object -Parallel {
            $op = [scriptblock]::Create($using:operationString)
            $result = & $op $_
            return $result
        } -ThrottleLimit $MaxParallel

        $results += $batchResults

        # Small delay to avoid throttling
        if ($batchNum -lt $totalBatches) {
            Start-Sleep -Milliseconds 100
        }
    }

    if ($ShowProgress) {
        Write-Progress -Activity "Processing Bulk Operation" -Completed
    }

    return $results
}

function Set-BulkPIMRoleAssignments {
    param(
        [Parameter(Mandatory)]
        [array]$Users,
        
        [Parameter(Mandatory)]
        [string]$RoleDefinitionId,
        
        [int]$DurationDays = 30,
        
        [string]$Justification = "Bulk assignment"
    )

    # Create scriptblock with variables captured
    $roleId = $RoleDefinitionId
    $duration = $DurationDays
    $justification = $Justification
    
    $scriptBlock = {
        param($user, $roleId, $duration, $justification)
        
        try {
            # Assign role - replace with actual PIM assignment API call
            $assignment = [PSCustomObject]@{
                UserId = $user.Id
                RoleDefinitionId = $roleId
                DurationDays = $duration
                Justification = $justification
                Status = "Success"
            }
            return $assignment
        } catch {
            return [PSCustomObject]@{
                UserId = $user.Id
                Status = "Failed"
                Error = $_.Exception.Message
            }
        }
    }

    # Process each user with parameters
    $results = @()
    foreach ($user in $Users) {
        $result = & $scriptBlock $user $roleId $duration $justification
        $results += $result
    }
    
    return $results
}

function Get-BulkAzureResources {
    param(
        [Parameter(Mandatory)]
        [string]$ResourceGroup,
        
        [string]$ResourceType = "*",
        
        [switch]$UseCache
    )

    if ($UseCache) {
        $cacheModulePath = Join-Path $PSScriptRoot "Cache-Manager.ps1"
        if (Test-Path $cacheModulePath) {
            Import-Module $cacheModulePath -Force
            $cacheDir = Join-Path $env:TEMP "pim-cache"
            if (-not (Test-Path $cacheDir)) {
                New-Item -ItemType Directory -Path $cacheDir -Force | Out-Null
            }
            $cache = [CacheManager]::new($cacheDir, 15)
            
            $cacheKey = "resources-$ResourceGroup-$ResourceType"
            if ($cache.Contains($cacheKey)) {
                Write-Host "  Returning cached resources" -ForegroundColor Green
                return $cache.Get($cacheKey)
            }
        }
    }

    $resources = Get-AzResource -ResourceGroupName $ResourceGroup -ResourceType $ResourceType -ErrorAction SilentlyContinue

    if ($UseCache -and $cache) {
        $cache.Set($cacheKey, $resources)
    }

    return $resources
}

Export-ModuleMember -Function Invoke-BulkOperation, Set-BulkPIMRoleAssignments, Get-BulkAzureResources

