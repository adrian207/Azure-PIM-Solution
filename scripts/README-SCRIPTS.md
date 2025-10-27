# Azure PIM Solution - Deployment Scripts

**Author:** Adrian Johnson  
**Email:** adrian207@gmail.com  
**Version:** 1.0  
**Date:** December 2024

---

## Overview

This directory contains automated deployment scripts for the Azure PIM Solution. These scripts automate the creation and configuration of Azure resources, PIM settings, monitoring, and reporting.

---

## Prerequisites

### Required Software
- PowerShell 7.0 or higher
- Azure PowerShell modules (Az.*)
- Microsoft Graph PowerShell modules
- Azure CLI (optional, for some operations)

### Required Permissions
- Azure Subscription Owner or Contributor
- Azure AD Global Administrator
- Microsoft Graph Directory.ReadWrite.All

### Initial Setup
1. Install required PowerShell modules (scripts check and install automatically)
2. Connect to Azure: `Connect-AzAccount`
3. Connect to Microsoft Graph: `Connect-MgGraph`

---

## Configuration

### Before Running Scripts

1. **Edit Configuration File**
   - Open `config/environment-config.json`
   - Update organization-specific values:
     - Organization name and details
     - Email addresses for alerts and approvals
     - Azure region and subscription details
     - Role definitions and approval workflows
     - Compliance framework selections

2. **Review Security Settings**
   - Approval workflows
   - Maximum access durations
   - MFA requirements
   - Justification requirements

---

## Script Execution Order

Scripts should be run in sequence:

```
01-prerequisites.ps1          # Check prerequisites and install modules
         ↓
02-create-infrastructure.ps1  # Create Azure resources (storage, Key Vault, etc.)
         ↓
03-configure-pim.ps1          # Configure PIM role settings
         ↓
04-setup-monitoring.ps1       # Setup monitoring and alerting
         ↓
05-deploy-powerbi.ps1         # Deploy Power BI dashboards
         ↓
06-run-compliance-checks.ps1  # Verify compliance configuration
```

---

## Script Descriptions

### 01-prerequisites.ps1
**Purpose:** Validates prerequisites and prepares environment

**What it does:**
- Checks PowerShell version
- Verifies required modules are installed
- Connects to Azure and Microsoft Graph
- Validates subscription and permissions

**Usage:**
```powershell
.\01-prerequisites.ps1
.\01-prerequisites.ps1 -ConfigPath "C:\custom-config.json"
```

**Output:**
- Configuration validation
- Module installation status
- Connection status

---

### 02-create-infrastructure.ps1
**Purpose:** Creates Azure infrastructure components

**What it creates:**
- Resource Group
- Storage Account with containers
- Azure Key Vault
- Log Analytics Workspace
- Configures lifecycle policies

**Usage:**
```powershell
.\02-create-infrastructure.ps1
.\02-create-infrastructure.ps1 -SkipExisting
```

**Parameters:**
- `-ConfigPath`: Path to configuration file
- `-SkipExisting`: Skip resources that already exist

**Output:**
- Resource creation status
- Resource names and IDs
- Temporary configuration files

---

### 03-configure-pim.ps1
**Purpose:** Configures Azure AD PIM role settings

**What it does:**
- Displays role configuration summaries
- Generates PIM configuration guidance
- Provides step-by-step manual configuration instructions

**Usage:**
```powershell
.\03-configure-pim.ps1
```

**Note:** Azure AD PIM role configuration requires Azure Portal or Graph API access. This script provides configuration guidance.

**Output:**
- Role configuration summary
- Approval workflow details
- Helper script for manual configuration

---

### 04-setup-monitoring.ps1
**Purpose:** Configures monitoring and alerting

**What it creates:**
- Action Groups for alerts
- Alert rule definitions (displayed for manual creation)
- KQL queries for Log Analytics

**Usage:**
```powershell
.\04-setup-monitoring.ps1
```

**Output:**
- Action group creation status
- Sample KQL queries (saved to file)
- Alert rule definitions

---

### 05-deploy-powerbi.ps1
**Purpose:** Deploys Power BI reporting solution

**What it provides:**
- Power BI deployment instructions
- Data model configuration guidance
- Dashboard creation steps
- Refresh schedule configuration

**Usage:**
```powershell
.\05-deploy-powerbi.ps1
```

**Note:** Power BI dashboards require manual creation in Power BI Desktop. This script provides detailed deployment guidance.

**Output:**
- Deployment steps and instructions
- Data connection configuration guide
- Sample DAX measures

---

### 06-run-compliance-checks.ps1
**Purpose:** Verifies compliance configuration

**What it checks:**
- Role definitions
- Approval workflows
- Monitoring configuration
- Evidence collection setup

**Usage:**
```powershell
.\06-run-compliance-checks.ps1
```

**Output:**
- Compliance check results
- Missing configurations
- Recommendations for improvement

---

## Customization

### Environment-Specific Configuration

Edit `config/environment-config.json` to customize:

**Organization Details:**
```json
{
  "organization": {
    "name": "Your Organization Name",
    "shortName": "yourorg",
    "primaryContact": "it-security@yourorg.com",
    "region": "eastus"
  }
}
```

**PIM Roles:**
```json
{
  "pim": {
    "roles": {
      "productionAdministrator": {
        "name": "Production Administrator",
        "maxDurationHours": 4,
        "approvers": ["manager@yourorg.com"],
        "mfaRequired": true
      }
    }
  }
}
```

**Archival Settings:**
```json
{
  "archival": {
    "retentionYears": 7,
    "tiers": {
      "hot": { "durationDays": 365 },
      "cool": { "durationDays": 1095 },
      "archive": { "durationDays": 2555 }
    }
  }
}
```

---

## Troubleshooting

### Common Issues

**Issue: "Module not found"**
```
Solution: Run script 01-prerequisites.ps1 to auto-install modules
Or manually: Install-Module -Name <ModuleName> -Force
```

**Issue: "Not connected to Azure"**
```
Solution: Run Connect-AzAccount
```

**Issue:idVerification failed"
```
Solution: Check Azure AD roles and permissions
Required: Global Administrator or Privileged Role Administrator
```

**Issue: Resource creation fails**
```
Solution: Check naming conventions (Azure has specific naming rules)
- Storage accounts: 3-24 lowercase characters
- Key Vaults: 3-24 alphanumeric characters
- Resource names must be globally unique where applicable
```

**Issue: Configuration not applied**
```
Solution: Some configurations require manual steps in Azure Portal
Review script output for specific instructions
```

---

## Advanced Usage

### Running Individual Scripts

You can run individual scripts if re-deploying specific components:

```powershell
# Only recreate storage account
.\02-create-infrastructure.ps1

# Only update monitoring
.\04-setup-monitoring.ps1
```

### Dry Run Mode

To preview what will be created without making changes:

```powershell
# Review configuration first
.\01-prerequisites.ps1

# Scripts provide preview output before making changes
```

### Non-Interactive Stories

For unattended deployments:

```powershell
# Set environment variables
$env:AZURE_SUBSCRIPTION = "your-subscription-id"
$env:AZURE_AD_TENANT = "your-tenant-id"

# Connect with service principal
Connect-AzAccount -ServicePrincipal -Credential $credential

# Run scripts
.\01-prerequisites.ps1
.\02-create-infrastructure.ps1
# etc.
```

---

## Output and Logs

### Script Output
- Console output with progress indicators
- Color-coded status messages (Green=Success, Yellow=Warning, Red=Error)
- Summary reports at completion

### Temporary Files
Scripts may create temporary files:
- `temp-*.json`: Configuration files
- `temp-*.txt`: Helper guides
- `temp-*.ps1`: Helper scripts

Review and use these files as needed. They can be safely deleted after deployment.

### Logging
Enable detailed logging:
```powershell
# Save output to log file
.\01-prerequisites.ps1 *> deployment.log

# View last session log
Get-Content deployment.log
```

---

## Security Considerations

### Configuration File Security
- **DO NOT** commit configuration files with real credentials to version control
- Store production configurations securely (Azure Key Vault, Azure DevOps Library)
- Use different configurations for dev, test, and production

### Credential Management
- Use service principals for automated deployments
- Store credentials in Azure Key Vault
- Enable MFA for all administrative accounts
- Rotate credentials regularly

### Audit Trail
All script executions are logged in Azure Activity Log
Monitor: Azure Portal > Subscriptions > Activity Log

---

## Support

For issues or questions:
- **Author:** Adrian Johnson
- **Email:** adrian207@gmail.com
- **Documentation:** See `/docs` directory for detailed documentation

---

## Version History

**Version 1.0** (December 2024)
- Initial release
- Core deployment scripts
- Configuration framework
- Documentation

---

**Last Updated:** December 2024

