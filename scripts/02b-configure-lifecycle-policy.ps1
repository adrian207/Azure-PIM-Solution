<#
.SYNOPSIS
    Configure Azure Storage Lifecycle Management Policies

.DESCRIPTION
    Sets up automatic lifecycle management for audit logs moving between
    hot, cool, and archive storage tiers.

.PARAMETER ConfigPath
    Path to environment configuration

.PARAMETER StorageAccountName
    Name of the storage account

.PARAMETER ResourceGroupName
    Name of the resource group
#>

[CmdletBinding()]
param(
    [Parameter(Mandatory)]
    [string]$ConfigPath,
    
    [Parameter(Mandatory)]
    [string]$StorageAccountName,
    
    [Parameter(Mandatory)]
    [string]$ResourceGroupName
)

$ErrorActionPreference = "Stop"

Write-Host "  Configuring lifecycle management policies..." -ForegroundColor Yellow

# Load configuration
$config = Get-Content $ConfigPath | ConvertFrom-Json

# Build lifecycle management rules
$lifecycleRules = @()

# Rule 1: Move to Cool after 365 days
$lifecycleRules += @{
    name = "MoveToCoolStorage"
    enabled = $true
    type = "Lifecycle"
    definition = @{
        filters = @{
            blobTypes = @("blockBlob")
            prefixMatch = @("audit-logs/", "evidence/")
        }
        actions = @{
            baseBlob = @{
                tierToCool = @{
                    daysAfterModificationGreaterThan = $config.archival.tiers.hot.durationDays
                }
            }
        }
    }
}

# Rule 2: Move to Archive after 1095 days
$lifecycleRules += @{
    name = "MoveToArchiveStorage"
    enabled = $true
    type = "Lifecycle"
    definition = @{
        filters = @{
            blobTypes = @("blockBlob")
            prefixMatch = @("audit-logs/", "evidence/")
        }
        actions = @{
            baseBlob = @{
                tierToArchive = @{
                    daysAfterModificationGreaterThan = $config.archival.tiers.cool.durationDays
                }
            }
        }
    }
}

# Rule 3: Delete after retention period (with warning)
$retentionDays = $config.archival.retentionYears * 365
$lifecycleRules += @{
    name = "DeleteAfterRetention"
    enabled = $true
    type = "Lifecycle"
    definition = @{
        filters = @{
            blobTypes = @("blockBlob")
            prefixMatch = @("audit-logs/", "evidence/")
        }
        actions = @{
            baseBlob = @{
                delete = @{
                    daysAfterModificationGreaterThan = $retentionDays
                }
            }
        }
    }
}

# Convert to JSON for Azure CLI (PowerShell management not available in Az.Storage)
$rulesPath = ".\temp-lifecycle-rules.json"
$lifecyclePolicy = @{
    rules = $lifecycleRules
} | ConvertTo-Json -Depth 10

Set-Content -Path $rulesPath -Value $lifecyclePolicy

Write-Host "  Lifecycle policy configured and saved to: $rulesPath" -ForegroundColor Green
Write-Host "  Note: Use Azure Portal or CLI to apply this policy:" -ForegroundColor Yellow
Write-Host "    az storage account blob-service-properties update \" -ForegroundColor White
Write-Host "      --account-name $StorageAccountName \" -ForegroundColor White
Write-Host "      --resource-group $ResourceGroupName \" -ForegroundColor White
Write-Host "      --lifecycle-policy @$rulesPath" -ForegroundColor White

