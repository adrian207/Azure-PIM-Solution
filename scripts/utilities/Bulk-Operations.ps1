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
        [array]$Items,
        
        [int]$BatchSize = 50,
        
        [int]$MaxParallel = 10,
        
        [switch]$ShowProgress
    )

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

    $scriptBlock = {
        param($user)
        
        try {
            # Assign role - replace with actual PIM assignment API call
            $assignment = @{
                UserId = $user.Id
                RoleDefinitionId = $RoleDefinitionId
                DurationDays = $DurationDays
                Justification = $Justification
                Status = "Success"
            }
            return $assignment
        } catch {
            return @{
                UserId = $user.Id
                Status = "Failed"
                Error = $_.Exception.Message
            }
        }
    }

    return Invoke-BulkOperation -Operation $scriptBlock -Items $Users -BatchSize 25 -ShowProgress
}

function Get-BulkAzureResources {
    param(
        [Parameter(Mandatory)]
        [string]$ResourceGroup,
        
        [string]$ResourceType = "*",
        
        [switch]$UseCache
    )

    if ($UseCache) {
        Import-Module .\utilities\Cache-Manager.ps1 -Force
        $cache = [CacheManager]::new(".\cache", 15)
        
        $cacheKey = "resources-$ResourceGroup-$ResourceType"
        if ($cache.Contains($cacheKey)) {
            Write-Host "  Returning cached resources" -ForegroundColor Green
            return $cache.Get($cacheKey)
        }
    }

    $resources = Get-AzResource -ResourceGroupName $ResourceGroup -ResourceType $ResourceType -ErrorAction SilentlyContinue

    if ($UseCache) {
        $cache.Set($cacheKey, $resources)
    }

    return $resources
}

Export-ModuleMember -Function Invoke-BulkOperation, Set-BulkPIMRoleAssignments, Get-BulkAzureResources

