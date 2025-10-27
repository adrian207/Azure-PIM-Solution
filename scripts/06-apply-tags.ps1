<#
.SYNOPSIS
    Apply or Update Tags on Azure PIM Solution Resources

.DESCRIPTION
    This script applies standardized tags to all Azure PIM Solution resources
    for organization, billing, and compliance tracking.

.PARAMETER ConfigPath
    Path to environment configuration file

.PARAMETER ResourceGroup
    Specific resource group to tag (optional)

.EXAMPLE
    .\06-apply-tags.ps1
    
    .\06-apply-tags.ps1 -ResourceGroup "rg-pim-solution"
#>

[CmdletBinding()]
param(
    [string]$ConfigPath = "..\config\environment-config.json",
    [string]$ResourceGroup = ""
)

$ErrorActionPreference = "Stop"

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "Azure PIM Solution - Tag Management" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# Load configuration
Write-Host "Loading configuration..." -ForegroundColor Yellow
$config = Get-Content $ConfigPath | ConvertFrom-Json

# Build tags hashtable
$tags = @{}
if ($config.tags) {
    $config.tags.PSObject.Properties | ForEach-Object {
        $tags[$_.Name] = $_.Value
    }
}
# Add organization-specific tags
$tags["Organization"] = $config.organization.name
$tags["ShortName"] = $config.organization.shortName
$tags["PrimaryContact"] = $config.organization.primaryContact
$tags["DeployedDate"] = (Get-Date).ToString("yyyy-MM-dd")
$tags["LastUpdated"] = (Get-Date).ToString("yyyy-MM-dd")

# Display tags
Write-Host "Tags to apply:" -ForegroundColor Yellow
foreach ($key in $tags.Keys) {
    Write-Host "  $key = $($tags[$key])" -ForegroundColor Gray
}
Write-Host ""

# Get Azure context
$context = Get-AzContext
if (-not $context) {
    Write-Error "Not connected to Azure. Please run Connect-AzAccount"
    exit 1
}

# Determine resource groups to process
$resourceGroups = @()
if ($ResourceGroup) {
    $resourceGroups += $ResourceGroup
} else {
    $resourceGroups = @($config.azure.resourceGroup.name)
}

Write-Host "Processing resource groups: $($resourceGroups -join ', ')" -ForegroundColor Yellow
Write-Host ""

$taggedResources = 0

foreach ($rgName in $resourceGroups) {
    Write-Host "Processing resource group: $rgName" -ForegroundColor Cyan
    Write-Host "=========================================" -ForegroundColor Cyan
    
    # Check if resource group exists
    $rg = Get-AzResourceGroup -Name $rgName -ErrorAction SilentlyContinue
    if (-not $rg) {
        Write-Warning "Resource group not found: $rgName, skipping..."
        continue
    }
    
    # Tag the resource group itself
    Write-Host "  Tagging resource group..." -ForegroundColor Yellow
    Set-AzResourceGroup -Name $rgName -Tag $tags | Out-Null
    $taggedResources++
    Write-Host "  Resource group tagged successfully" -ForegroundColor Green
    
    # Get all resources in the resource group
    $resources = Get-AzResource -ResourceGroupName $rgName
    
    Write-Host "  Found $($resources.Count) resources to tag" -ForegroundColor Gray
    
    foreach ($resource in $resources) {
        Write-Host "  Tagging: $($resource.Name) ($($resource.ResourceType))" -ForegroundColor Yellow
        try {
            Update-AzTag -ResourceId $resource.ResourceId -Tag $tags -Operation Merge | Out-Null
            $taggedResources++
            Write-Host "    ✓ Tagged successfully" -ForegroundColor Green
        } catch {
            Write-Warning "    ✗ Failed to tag: $_"
        }
    }
    
    Write-Host ""
}

# Summary
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "Tag Management Complete" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "Total resources tagged: $taggedResources" -ForegroundColor Green
Write-Host ""
Write-Host "Tags applied:" -ForegroundColor Yellow
$tags.GetEnumerator() | Sort-Object Name | ForEach-Object {
    Write-Host "  $($_.Key) = $($_.Value)" -ForegroundColor White
}
Write-Host ""

