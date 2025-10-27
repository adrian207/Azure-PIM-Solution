# Using Existing Azure Infrastructure

**Author:** Adrian Johnson  
**Email:** adrian207@gmail.com  
**Version:** 1.0  
**Date:** December 2024

---

## Overview

The Azure PIM Solution is designed to work with your existing Azure infrastructure. You don't need to create new resources if you already have them—you can simply configure the solution to use what you already have.

---

## Supported Existing Resources

### Azure Key Vault

**Scenario:** You already have a Key Vault for storing secrets and certificates.

**What the solution does:**
- Detects your existing Key Vault (even if it's in a different resource group)
- Adds only the PIM-specific secrets to it
- Does NOT modify any existing secrets
- Does NOT change existing access policies (unless necessary for PIM operation)

**How to configure:**

1. **Option 1: Specify existing Key Vault name**
   Edit `config/environment-config.json`:
   ```json
   "keyVault": {
       "name": "your-existing-keyvault-name",
       "useExisting": true
   }
   ```

2. **Option 2: Let it auto-detect**
   Leave the name empty and the script will look for a Key Vault with the naming pattern in your subscription:
   ```json
   "keyVault": {
       "name": "",
       "useExisting": true
   }
   ```

**What secrets are stored:**
- `PIM-Config` - Basic configuration data
- Other PIM-specific secrets as needed

**Safety:**
- ✅ Never overwrites existing secrets
- ✅ Only adds new secrets with PIM-specific names
- ✅ Preserves all existing access policies
- ✅ Can be safely run multiple times

### Azure Storage Account

**Scenario:** You already have a Storage Account for logs and data.

**What the solution does:**
- Uses existing Storage Account
- Creates only new containers for PIM data (if they don't exist)
- Does NOT touch existing containers or data

**How to configure:**

Edit `config/environment-config.json`:
```json
"storage": {
    "accountName": "your-existing-storage-account",
    "useExisting": true
}
```

**What containers are created:**
- `audit-logs` - For PIM audit logs
- `evidence` - For compliance evidence
- `config-snapshots` - For configuration backups

**Safety:**
- ✅ Only creates containers that don't exist
- ✅ Never modifies existing containers
- ✅ Never accesses existing data in other containers
- ✅ Safe to run multiple times

### Log Analytics Workspace

**Scenario:** You already use Log Analytics for monitoring.

**What the solution does:**
- Uses existing Log Analytics workspace
- Adds PIM-specific queries and alerts
- Does NOT modify existing queries or alerts

**How to configure:**

Edit `config/environment-config.json`:
```json
"monitoring":实际上是 {
    "logAnalytics": {
        "workspaceName": "your-existing-workspace",
        "useExisting": true
    }
}
```

**Safety:**
- ✅ Preserves all existing queries
- ✅ Preserves all existing alerts
- ✅ Only adds new PIM-specific monitoring
- ✅ Won't conflict with existing monitoring

---

## Hybrid Approach

You can mix existing and new resources:

```json
{
    "azure": {
        "keyVault": {
            "name": "existing-keyvault-123",
            "useExisting": true
        },
        "storage": {
            "accountName": "pimlogsnew2024",
            "useExisting": false
        },
        "monitoring": {
            "logAnalytics": {
                "workspaceName": "existing-law-workspace",
                "useExisting": true
            }
        }
    }
}
```

This configuration:
- Uses your existing Key Vault
- Creates a new Storage Account specifically for PIM
- Uses your existing Log Analytics workspace

---

## How It Works

### Detection Logic

The scripts check for resources in this order:

1. **Look in specified resource group first**
2. **Search across all resource groups** if not found
3. **Create new resource** only if not found anywhere

### Example Flow: Key Vault

```
Script starts
    ↓
Check if Key Vault name specified in config
    ↓ Yes
Look for Key Vault with that name in current resource group
    ↓ Not found
Look for Key Vault with that name in all resource groups
    ↓ Found in different resource group
Use existing Key Vault
Add PIM-specific access policies (non-destructive)
Store PIM secrets
    ↓ Done!
```

---

## Safety Guarantees

### What the solution NEVER does:

1. ❌ Never deletes or modifies existing secrets
2. ❌ Never changes existing access policies (only adds new ones)
3. ❌ Never modifies existing storage containers or data
4. ❌ Never removes or overwrites existing queries in Log Analytics
5. ❌ Never deletes existing alerts
6. ❌ Never changes existing permissions

### What the solution DOES do:

1. ✅ Reads existing resources
2. ✅ Adds new resources with unique names
3. ✅ Adds new secrets with PIM-specific prefixes
4. ✅ Creates new containers with PIM-specific names
5. ✅ Adds new monitoring queries with clear naming

---

## Testing with Existing Resources

### Before Running Scripts

**Recommended: Test in a development environment first**

1. Copy your configuration file
2. Point to dev/test resources
3. Run the scripts
4. Verify everything works
5. Then run in production

### Verification Steps

After the scripts run, verify:

1. **Key Vault:**
   - Existing secrets still there? ✅
   - New PIM-Config secret added? ✅
   - Existing access policies unchanged? ✅

2. **Storage Account:**
   - Existing containers unchanged? ✅
   - New PIM containers created? ✅
   - Existing data untouched? ✅

3. **Log Analytics:**
   - Existing queries still work? ✅
   - New PIM queries added? ✅
   - Existing alerts still active? ✅

---

## Common Scenarios

### Scenario 1: I have a Key Vault but want new Storage

**Configuration:**
```json
{
    "keyVault": {
        "name": "my-existing-keyvault",
        "useExisting": true
    },
    "storage": {
        "accountName": "pim-new-storage-2024",
        "useExisting": false
    }
}
```

**Result:** Uses existing Key Vault, creates new Storage Account

### Scenario 2: I want everything new

**Configuration:**
```json
{
    "keyVault": {
        "name": "",
        "useExisting": false
    },
    "storage": {
        "accountName": "pimlogsnew2024",
        "useExisting": false
    }
}
```

**Result:** Creates all new resources

### Scenario 3: I want to use everything existing

**Configuration:**
```json
{
    "keyVault": {
        "name": "my-existing-keyvault",
        "useExisting": true
    },
    "storage": {
        "accountName": "my-existing-storage",
        "useExisting": true
    },
    "monitoring": {
        "logAnalytics": {
            "workspaceName": "my-existing-law",
            "useExisting": true
        }
    }
}
```

**Result:** Uses all existing resources, only adds PIM-specific content

---

## Troubleshooting

### Issue: "Cannot access Key Vault"

**Possible causes:**
- Insufficient permissions on existing Key Vault
- Key Vault network restrictions

**Solution:**
- Grant yourself "Key Vault Administrator" role on the Key Vault
- Or run scripts from an allowed network
- Or temporarily disable network restrictions

### Issue: "Storage Account already exists"

**Cause:** You specified an existing storage account name

**Solution:**
- Either specify `"useExisting": true` in config
- Or use a different storage account name

### Issue: "Script modifies my existing resources"

**This should not happen!**

**If it does:**
1. Stop the script immediately
2. Contact support: adrian207@gmail.com
3. Document what was changed
4. We'll help restore from backup

---

## Best Practices

### 1. Always Test First

Test in non-production environment before production deployment.

### 2. Use Naming Conventions

Make it clear which resources are for PIM:
- Existing resources: `mycompany-keyvault-prod`
- PIM resources: `pim-keyvault-[identifier]`

### 3. Document Your Configuration

Keep a copy of your configuration file in version control or secure storage.

### 4. Monitor Resource Usage

After deployment, monitor:
- Key Vault access patterns
- Storage capacity usage
- Log Analytics ingestion rates

### 5. Backup Before Changes

Always backup before making changes:
- Export Key Vault secrets
- Backup Storage Account data
- Export Log Analytics queries

---

## Conclusion

The Azure PIM Solution is designed to integrate seamlessly with your existing Azure infrastructure without disrupting your current operations. The scripts are conservative—they prefer to use what you have rather than create duplicates.

---

**Need Help?**  
**Author:** Adrian Johnson  
**Email:** adrian207@gmail.com

---

