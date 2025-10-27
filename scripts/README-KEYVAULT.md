# Key Vault Integration Guide

## Quick Answer

**Yes, the scripts are flexible enough to use existing Key Vaults safely.**

The solution will:
- ✅ Detect your existing Key Vault (even in different resource groups)
- ✅ Only add PIM-specific secrets with clear naming
- ✅ Never modify or delete existing secrets
- ✅ Never change existing access policies
- ✅ Work safely alongside your current setup

---

## How It Works

### Detection Logic

```
1. Check config for specified Key Vault name
   ↓
2. Look in current resource group
   ↓
3. Search all resource groups if not found
   ↓
4. Use existing if found, create new if not
   ↓
5. Add PIM secrets with unique names
```

### Safety Guarantees

**What it DOES:**
- Adds secrets named `PIM-*` (e.g., `PIM-Config`)
- Adds minimal access policies for PIM operations only
- Respects all existing secrets and policies

**What it DOES NOT:**
- ❌ Never touches existing secrets
- ❌ Never removes access policies
- ❌ Never changes existing configurations

---

## Configuration Options

### Option 1: Auto-Detect Existing Key Vault

Leave the name empty in config:
```json
"keyVault": {
    "name": "",
    "useExisting": true
}
```

The script will search for a Key Vault and use it if found.

### Option 2: Specify Exact Name

Provide your exact Key Vault name:
```json
"keyVault": {
    "name": "mycompany-keyvault-prod",
    "useExisting": true
}
```

The script will use this specific Key Vault.

### Option 3: Create New

Don't specify a name and set useExisting to false:
```json
"keyVault": {
    "name": "",
    "useExisting": false
}
```

The script will create a new Key Vault.

---

## Example Output

When using an existing Key Vault:

```
Creating Key Vault...
  Using existing Key Vault: mycompany-keyvault-prod (in resource group: rg-company-shared)
  Adding PIM access policies to existing Key Vault...
  Successfully configured existing Key Vault
  Storing PIM configuration in Key Vault...
  Configuration stored successfully
```

---

## What Secrets Are Added

Only PIM-specific secrets are added:

- **PIM-Config** - Basic PIM configuration
- **PIM-[other]** - Future PIM secrets will follow this naming

These are clearly identifiable and won't conflict with your existing secrets.

---

## Troubleshooting

### "Access Denied" Error

**Cause:** Insufficient permissions on existing Key Vault

**Solution:**
1. Grant yourself "Key Vault Secrets Officer" role on the Key Vault
2. Or add your user to Key Vault access policies manually

### "Key Vault Not Found"

**Cause:** Wrong name or Key Vault in different subscription

**Solution:**
1. Verify Key Vault name is correct
2. Ensure you're in the correct Azure subscription
3. Check all resource groups

---

## Need More Details?

See: `docs/operations/existing-infrastructure.md` for comprehensive documentation

