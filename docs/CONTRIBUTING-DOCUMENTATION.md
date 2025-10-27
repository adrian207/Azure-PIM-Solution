# Documentation Style Guide

**For:** All contributors adding new features or documentation to the Azure PIM Solution

**Version:** 1.0  
**Date:** December 2024

---

## Documentation Philosophy

All documentation in this project follows **practical implementation with structured presentation** that empowers users to actually implement what they read while maintaining clear, logical organization.

### Core Principles

**Structure (Clear Organization):**
1. **Main Conclusion First** - State the key message upfront
2. **Three Supporting Ideas** - Organize content into digestible sections
3. **Logical Flow** - Each section builds on the previous

**Content (User-Friendly Action):**
4. **Actionable over Abstract** - Don't just explain concepts, show how to build them
5. **Copy-Paste Ready** - Provide working code and commands
6. **Progressive Complexity** - Start simple, build to advanced
7. **Verification Built-In** - Always include ways to verify success
8. **Time-Estimated** - Users need to know how long things take

---

## Required Structure for New Features

Every new feature document MUST follow a clear structure AND include practical sections:

### Document Structure (Clear Organization)

```
1. Main Conclusion (What this is and why it matters)
2. Three Key Supporting Ideas (Organize main content)
3. Supporting Details (Expand each idea)
4. Practical Implementation (How to build it)
5. Verification (How to verify it works)
```

### Section Templates

These sections MUST appear in order:

### 1. Overview Section
**Purpose:** Answer "What is this?"

```markdown
## Overview

Brief, clear explanation of what the feature does and why it matters.

**Key Benefits:**
- Benefit 1
- Benefit 2
- Benefit 3

**Use Cases:**
- When to use this
- Who benefits
```

### 2. How to Build Section
**Purpose:** Answer "How do I build this?"

```markdown
## How to Build [Feature Name]

### Prerequisites
- Clear list of what's needed
- Links to get required items
- Time estimate

### Method 1: Quick Start (Fastest)
Step-by-step with time estimates

### Method 2: Full Implementation (Complete)
Detailed instructions

### Method 3: Automated (PowerShell/Script)
Script-based approach if applicable
```

### 3. Implementation Details
**Purpose:** Answer "How does it work?"

- Architecture diagrams
- Component explanations
- Data flow

### 4. Configuration
**Purpose:** Answer "How do I customize this?"

- Customization options
- Examples
- Best practices

### 5. Verification
**Purpose:** Answer "Did it work?"

```markdown
## Verification

### Quick Check
Simple test to verify it's working

### Detailed Verification
Comprehensive verification script
```

### 6. Troubleshooting
**Purpose:** Answer "What's wrong?"

Common issues with solutions

---

## Documentation Template

Use this template for ALL new feature documentation:

```markdown
# [Feature Name]

**Author:** [Your Name]  
**Email:** [email]  
**Version:** 1.0  
**Date:** [Date]

---

## Overview

[What is this feature and why is it valuable?]

**Key Benefits:**
- Benefit 1
- Benefit 2
- Benefit 3

---

## How to Build [Feature Name]

### Prerequisites

**Required:**
- Item 1
- Item 2

**Optional:**
- Item 3

### Quick Start (X minutes)

**Step 1: [Action]**

```powershell
# Copy-paste ready command
```

**Step 2: [Action]**

```
Portal Steps:
1. Navigate to [location]
2. Click [button]
3. Configure [setting]
```

**Step 3: Verify**

```powershell
# Verification command
```

### Full Implementation (X hours)

[Detailed steps with code examples]

---

## Architecture / How It Works

[Technical details, diagrams, etc.]

---

## Configuration

### Basic Configuration

[Default settings]

### Advanced Configuration

[Customization options]

---

## Verification Script

```powershell
# Run this to verify implementation
Write-Host "Checking [Feature Name]..." -ForegroundColor Cyan

# Check 1
if ([condition]) {
    Write-Host "✅ [Check 1]: Working (+X points)" -ForegroundColor Green
    $score += X
} else {
    Write-Host "❌ [Check 1]: Not working" -ForegroundColor Red
}

# Summary
Write-Host "`n[Feature Name] Score: $score/X" -Foreground supports Cyan
if ($score -ge $target) {
    Write-Host "🎉 Success!" -ForegroundColor Green
}
```

---

## Troubleshooting

**Problem: [Common Issue]**
```
Solution:
1. [Step 1]
2. [Step 2]
```

---

## Best Practices

1. [Practice 1]
2. [Practice 2]

---

## Next Steps

1. [Next action]
2. [Related documentation]
```

---

## Code Examples Requirements

### PowerShell Scripts

**MUST include:**
- Full, runnable scripts (no placeholders)
- Error handling
- Output messages (Write-Host with colors)
- Verification steps
- Comments explaining what each section does

**Example Format:**
```powershell
# Install required modules
Write-Host "Installing required modules..." -ForegroundColor Cyan
Install-Module -Name Az.Accounts -Force

# Connect to Azure
Write-Host "Connecting to Azure..." -ForegroundColor Cyan
Connect-AzAccount

# Execute task
Write-Host "Creating resource..." -ForegroundColor Cyan
$resource = New-AzResource -Name "test" -ResourceGroupName "rg"
if ($resource) {
    Write-Host "✅ Resource created successfully" -ForegroundColor Green
} else {
    PLAN Write-Host "❌ Failed to create resource" -ForegroundColor Red
    exit 1
}
```

### Azure Portal Steps

**MUST include:**
- Exact navigation path
- Button/option names as they appear
- Screenshot locations (if available)
- Numbered steps

**Example Format:**
```
Portal Steps:
1. Navigate to: Azure Portal → Azure AD → Security → Conditional Access
2. Click "New Policy" button
3. Fill in the form:
   - Name: "Require MFA for Admins"
   - Users: Select "Directory roles" → "Global Administrator"
   - Grant: Select "Require MFA"
4. Click "Create" button
5. Verify policy appears in list
```

---

## Visual Elements

### Diagrams

Use ASCII art for architecture diagrams:

```markdown
```
┌─────────────────────────────────────────┐
│         User Request                    │
└──────────────┬──────────────────────────┘
               │
               ▼
┌─────────────────────────────────────────┐
│      Authentication Check                │
└──────────────┬──────────────────────────┘
               │
               ▼
┌─────────────────────────────────────────┐
│      Authorization Check                 │
└──────────────┬──────────────────────────┘
               │
               ▼
┌─────────────────────────────────────────┐
│         Grant Access                     │
└─────────────────────────────────────────┘
```
```

### Tables

Use tables for configuration, scores, etc.:

```markdown
| Feature | Points | Status |
|---------|--------|--------|
| MFA | 30 | ✅ Enabled |
| Conditional Access | 25 | ⚠️ Partial |
```

---

## Verification Requirements

**Every feature MUST include:**

1. **Quick Verification** (< 1 minute)
   - Simple check user can run
   - Clear success/failure indication

2. **Detailed Verification** (< 5 minutes)
   - Comprehensive check
   - Scoring system if applicable
   - Recommendations for improvement

**Format:**
```powershell
# Quick Check
Write-Host "Quick Check:" -ForegroundColor Cyan
# [simple commands]

# Detailed Verification
Write-Host "`nDetailed Verification:" -ForegroundColor Cyan
$score = 0
# [detailed checks with scoring]
```

---

## Troubleshooting Section Requirements

**MUST include at least 3 common problems:**

```markdown
## Troubleshooting

### Problem 1: [Error Message/Condition]

**Symptoms:**
- What user sees
- When it happens

**Solution:**
```
Exact steps to fix
```

### Problem 2: [Second Common Issue]

[Same format]

### Problem 3: [Third Common Issue]

[Same format]
```

---

## Time Estimates

**Include time estimates for:**
- Prerequisites setup
- Quick start implementation
- Full implementation
- Troubleshooting (typical)
- Learning curve

**Format:**
```
⏱️ Time Required:
- Quick Start: 5 minutes
- Full Setup: 2 hours
- Troubleshooting: 30 minutes average
```

---

## Practical Checklist for New Documentation

Before submitting documentation, verify:

- [ ] Overview explains what and why
- [ ] Prerequisites are clearly listed
- [ ] At least one "Quick Start" method (5-15 min)
- [ ] All code is copy-paste ready
- [ ] All PowerShell scripts have error handling
- [ ] All Portal steps have exact paths
- [ ] Verification script is included
- [ ] At least 3 troubleshooting items
- [ ] Time estimates provided
- [ ] Visual diagrams for complex flows
- [ ] Configuration options explained
- [ ] Best practices included

---

## Examples of Good Documentation

See these files as examples:
- `docs/reporting/pass-dashboard.md` - Complete build guide
- `docs/security/zero-trust-architecture.md` - Week-by-week implementation
- `IMPLEMENTATION-GUIDE.md` - Step-by-step walkthrough

---

## Anti-Patterns (What NOT to Do)

❌ **Don't** write conceptual-only documentation
❌ **Don't** use placeholder code or "TODO" comments
❌ **Don't** assume technical knowledge
❌ **Don't** skip verification steps
❌ **Don't** forget troubleshooting
❌ **Don't** use jargon without explanation
❌ **Don't** omit time estimates
❌ **Don't** provide incomplete examples

✅ **Do** provide working code
✅ **Do** explain every step
✅ **Do** verify everything works
✅ **Do** anticipate common issues
✅ **Do** make it beginner-friendly
✅ **Do** estimate time required
✅ **Do** test your instructions

---

## Review Checklist

Before merging documentation:

- [ ] All code tested and works
- [ ] All time estimates accurate
- [ ] No placeholder text
- [ ] Verification script runs successfully
- [ ] Troubleshooting tested on real issues
- [ ] Screenshots replaced with ASCII (if needed)
- [ ] All links work
- [ ] Follows template structure
- [ ] Peer-reviewed by someone else

---

## Getting Help

If you need help with documentation:
- Email: adrian207@gmail.com
- Reference existing documentation as examples
- Start with the template
- Test everything you write

---

**Remember:** Good documentation isn't just accurate—it's actionable. Users should be able to follow your instructions and succeed.

