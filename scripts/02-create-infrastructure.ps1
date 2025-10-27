<#
.SYNOPSIS
    Create Azure Infrastructure for PIM Solution

.DESCRIPTION
    This script creates the Azure infrastructure components required for the
    PIM solution including storage accounts, Key Vault, Log Analytics, etc.

.PARAMETER ConfigPath
    Path to the environment configuration file

.PARAMETER SkipExisting
    Skip creation of resources that already exist

.EXAMPLE
    .\02-create-infrastructure.ps1
    .\02-create-infrastructure.ps1 -SkipExisting
#>

[CmdletBinding()]
param(
    [string]$ConfigPath = "..\config\environment-config.json",
    [switch]$SkipExisting = $false
)

$ErrorActionPreference = "Stop"

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "Azure PIM Solution - Infrastructure Setup" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# Load configuration
Write-Host "Loading configuration..." -ForegroundColor Yellow
$config = Get-Content $ConfigPath | ConvertFrom-Json
Write-Host "Configuration loaded: $($config.organization.name)" -ForegroundColor Green

# Get Azure context
$context = Get-AzContext
if (-not $context) {
    Write-Error "Not connected to Azure. Please run Connect-AzAccount"
    exit 1
}

Write-Host "`nAzure Context: $($context.Subscription.Name)" -ForegroundColor Green
Write-Host "Account: $($context.Account.Id)" -ForegroundColor Green

# Create resource group
Write-Host "`nCreating Resource Group..." -ForegroundColor Yellow
$resourceGroup = $config.azure.resourceGroup.name
$location = $config.azure.resourceGroup.location

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

Write-Host "  Tags to be applied:" -ForegroundColor Gray
foreach ($key in $tags.Keys) {
    Write-Host "    $key = $($tags[$key])" -ForegroundColor Gray
}

$rg = Get-AzResourceGroup -Name $resourceGroup -ErrorAction SilentlyContinue
if (-not $rg) {
    Laden-Host "  Creating resource group: $resourceGroup" -ForegroundColor Yellow
    $rg = New-AzResourceGroup -Name $resourceGroup -Location $location -Tag $tags
    Write-Host "  Resource group created successfully with tags" -ForegroundColor Green
} else {
    Write-Host "  Resource group already exists: $resourceGroup" -ForegroundColor Green
    # Update tags on existing resource group
    Write-Host "  Updating tags on existing resource group..." -ForegroundColor Yellow
    $rg = Set-AzResourceGroup -Name $resourceGroup -Tag $tags
    Write-Host "  Tags updated successfully" -ForegroundColor Green
}

# Create storage account
Write-Host "`nCreating Storage Account..." -ForegroundColor Yellow
$storageAccountName = ($config.azure.storage.accountName -replace '\[yourorg\]', $config.organization.shortName.ToLower()).Substring(0, [Math]::Min(24, ($config.azure.storage.accountName.Length)))

$storageAccount = Get-AzStorageAccount -ResourceGroupName $resourceGroup -Name $storageAccountName -ErrorAction SilentlyContinue
if (-not $storageAccount) {
    Write-Host "  Creating storage account: $storageAccountName" -ForegroundColor Yellow
    $storageAccount = New-AzStorageAccount `
        -ResourceGroupName $resourceGroup `
        -Name $storageAccountName `
        -Location $location `
        -SkuName $config.azure.storage.sku `
        -Kind "StorageV2" `
        -EnableHttpsTrafficOnly $config.azure.storage.supportsHttpsTrafficOnly `
        -Tag $tags
    Write-Host "  Storage account created successfully with tags" -ForegroundColor Green
} else {
    Write-Host "  Storage account already exists: $storageAccountName" -ForegroundColor Green
    # Update tags on existing storage account
    Write-Host "  Updating tags on existing storage account..." -ForegroundColor Yellow
    $storageAccountObject = Get-AzStorageAccount -ResourceGroupName $resourceGroup -Name $storageAccountName
    Update-AzTag -ResourceId $storageAccountObject.Id -Tag $tags -Operation Merge | Out-Null
    Write-Host "  Tags updated successfully" -ForegroundColor Green
}

# Create storage containers
Write-Host "`nCreating Storage Containers..." -ForegroundColor Yellow
$containers = @(
    "audit-logs",
    "evidence",
    "config-snapshots",
    "reports",
    "backups"
)

$storageContext = $storageAccount.Context
foreach ($container in $containers) {
    $existingContainer = Get-AzStorageContainer -Name $container -Context $storageContext -ErrorAction SilentlyContinue
    if (-not $existingContainer) {
        Write-Host "  Creating container: $container" -ForegroundColor Yellow
        New-AzStorageContainer -Name $container -Context $storageContext -Permission Off
        Write-Host "  Container created: $container" -ForegroundColor Green
    } else {
        Write-Host "  Container already exists: $container" -ForegroundColor Green
    }
}

# Create or Use Existing Key Vault
Write-Host "`nConfiguring Key Vault..." -ForegroundColor Yellow

# Check if custom Key Vault name specified in config
$keyVaultName = if ($config.azure.keyVault.name) {
    $config.azure.keyVault.name
} else {
    "kv-pim-$($config.organization.shortName.ToLower())".Substring(0, [Math]::Min(24, "kv-pim-$($config.organization.shortName.ToLower())".Length))
}

# Check if Key Vault exists in current resource group
$keyVault = Get-AzKeyVault -ResourceGroupName $resourceGroup -VaultName $keyVaultName -ErrorAction SilentlyContinue

if (-not $keyVault) {
    # Check if it exists in other resource groups
    $keyVault = Get-AzKeyVault -VaultName $keyVaultName -ErrorAction SilentlyContinue
    if ($keyVault) {
        Write-Host "  Using existing Key Vault: $keyVaultName (in resource group: $($keyVault.ResourceGroupName))" -ForegroundColor Yellow
        Write-Host "  Adding PIM access policies to existing Key Vault..." -ForegroundColor Yellow
        
        # Get current user and service principal IDs
        $currentUser = Get-AzADUser -UserPrincipalName $context.Account.Id -ErrorAction SilentlyContinue
        
        # Grant necessary permissions
        if ($currentUser) {
            Set-AzKeyVaultAccessPolicy -VaultName $keyVaultName -ObjectId $currentUser.Id -PermissionsToSecrets Get,List,Set -ErrorAction SilentlyContinue
        }
        
        # Update tags on existing Key Vault
        Write-Host "  Updating tags on existing Key Vault..." -ForegroundColor Yellow
        Update-AzTag -ResourceId $keyVault.ResourceId -Tag $tags -Operation Merge | Out-Null
        Write-Host "  Tags updated successfully" -ForegroundColor Green
        
        Write-Host "  Successfully configured existing Key Vault" -ForegroundColor Green
    } else {
        # Key Vault doesn't exist anywhere - create new one
        Write-Host "  Creating new Key Vault: $keyVaultName" -ForegroundColor Yellow
        
        # Get current user object ID for access policy
        $currentUser = Get-AzADUser -UserPrincipalName $context.Account.Id
        
        $keyVault = New-AzKeyVault `
            -ResourceGroupName $resourceGroup `
            -VaultName $keyVaultName `
            -Location $location `
            -EnabledForDeployment `
            -EnabledForDiskEncryption `
            -EnabledForTemplateDeployment `
            -EnableSoftDelete `
            -SoftDeleteRetentionInDays 7
        
        # Set access policy
        Set-AzKeyVaultAccessPolicy -VaultName $keyVaultName -ObjectId $currentUser.Id -PermissionsToKeys all -PermissionsToSecrets all -PermissionsToCertificates all
        
        # Apply tags to new Key Vault
        Update-AzTag -ResourceId $keyVault.ResourceId -Tag $tags -Operation Replace | Out-Null
        
        Write-Host "  Key Vault created successfully with tags" -ForegroundColor Green
    }
} else {
    Write-Host "  Using existing Key Vault: $keyVaultName" -ForegroundColor Green
    # Update tags on existing Key Vault
    Write-Host "  Updating tags on existing Key Vault..." -ForegroundColor Yellow
    $keyVaultObject = Get-AzKeyVault -ResourceGroupName $resourceGroup -VaultName downturn
    Update-AzTag -ResourceId $keyVaultObject.ResourceId -Tag $tags -Operation Merge | Out-Null
    Write-Host "  Tags updated successfully" -ForegroundColor Green
}

# Store Key Vault secrets for PIM solution
Write-Host "  Storing PIM configuration in Key Vault..." -ForegroundColor Yellow

$pimConfig = @{
    OrganizationName = $config.organization.name
    PrimaryContact = $config.organization.primaryContact
    Region = $config.organization.region
} | ConvertTo-Json -Compress

try {
    # Convert to secure string
    $pimConfigSecure = ConvertTo-SecureString $pimConfig -AsPlainText -Force
    Set-AzKeyVaultSecret -VaultName $keyVaultName -Name "PIM-Config" -SecretValue $pimConfigSecure -ErrorAction SilentlyContinue
    Write-Host "  Configuration stored successfully" -ForegroundColor Green
} catch {
    Write-Warning "  Could not store PIM configuration in Key Vault: $_"
    Write-Host "  Note: This is non-critical. Configuration can be stored manually if needed." -ForegroundColor Yellow
}

# Create Log Analytics Workspace
Write-Host "`nCreating Log Analytics Workspace..." -ForegroundColor Yellow
$lawName = $config.monitoring.logAnalytics.workspaceName

$law = Get-AzOperationalInsightsWorkspace -ResourceGroupName $resourceGroup -Name $lawName -ErrorAction SilentlyContinue
if (-not $law) {
    Write-Host "  Creating Log Analytics Workspace: $lawName" -ForegroundColor Yellow
    $law = New-AzOperationalInsightsWorkspace `
        -ResourceGroupName $resourceGroup `
        -Name $lawName `
        -Location $location `
        -RetentionInDays $config.monitoring.logAnalytics.retentionDays
    
    # Apply tags to Log Analytics Workspace
    Update-AzTag -ResourceId $law.ResourceId -Tag $tags -Operation Replace | Out-Null
    Write-Host "  Log Analytics Workspace created successfully with tags" -ForegroundColor Green
} else {
    Write-Host "  Log Analytics Workspace already exists: $lawName" -ForegroundColor Green
    # Update tags on existing workspace
    Write-Host "  Updating tags on existing workspace..." -ForegroundColor Yellow
    Update-AzTag -ResourceId $law.ResourceId -Tag $tags -Operation Merge | Out-Null
    Write-Host "  Tags updated successfully" -ForegroundColor Green
}

# Configure storage lifecycle policies
Write-Host "`nConfiguring Storage Lifecycle Policies..." -ForegroundColor Yellow
. .\02b-configure-lifecycle-policy.ps1 -ConfigPath $ConfigPath -StorageAccountName $storageAccountName -ResourceGroupName $resourceGroup

# Summary
Write-Host "`n========================================" -ForegroundColor Cyan
Write-Host "Infrastructure Setup Complete" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "Resources Created:" -ForegroundColor Yellow
Write-Host "  Resource Group: $resourceGroup" -ForegroundColor White
Write-Host "  Storage Account: $storageAccountName" -ForegroundColor White
Write-Host "  Key Vault: $keyVaultName" -ForegroundColor White
Write-Host "  Log Analytics: $lawName" -ForegroundColor White
Write-Host ""
Write-Host "Next Steps:" -ForegroundColor Yellow
Write-Host "1. Run: .\03-configure-pim.ps1" -ForegroundColor White
Write-Host ""

