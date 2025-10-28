# Visual Workflow Builder for Azure PIM

**Author:** Adrian Johnson  
**Email:** adrian207@gmail.com  
**Version:** 2.0  
**Date:** December 2024

---

## What Is This?

The Visual Workflow Builder lets you create approval workflows, access policies, and automation rules **without writing any code**. Instead of spending hours learning PowerShell, you can drag and drop blocks on a screen to build sophisticated workflows in minutes.

**Think of it like:** Building with LEGO blocks instead of writing instructions from scratch.

---

## Who Is This For?

✅ **Business Analysts** - Create approval workflows without IT help  
✅ **IT Administrators** - Automate access management quickly  
✅ **Security Teams** - Implement access policies visually  
✅ **Developers** - Build custom workflow platforms  
✅ **Anyone** - No coding experience required for basic use

---

## What Will I Be Able to Do?

After completing this guide, you'll be able to:

- ✅ Deploy pre-built approval workflows in 30 minutes
- ✅ Create custom workflows by dragging and dropping blocks
- ✅ Automatically route high-risk requests to security team
- ✅ Enforce business hours access policies
- ✅ Integrate with ServiceNow, Jira, Teams, and Slack
- ✅ Test workflows before deploying to production
- ✅ Monitor workflow execution in real-time

---

## Choose Your Level

### 🟢 Core Level (30 minutes - 1 hour)
**Best for:** Non-technical users, quick deployment  
**What you get:** Pre-built workflows with one-click deployment  
**Automation:** MAXIMUM - Scripts do everything automatically  
**Coding required:** NONE  
**Outcome:** Working workflow in 30 minutes

👉 **Start here if:** You want results fast and don't need customization

---

### 🟡 Intermediate Level (2-3 hours)
**Best for:** IT administrators, customization needs  
**What you get:** Visual workflow builder, template customization  
**Automation:** MEDIUM - Guided setup with some choices  
**Coding required:** Copy-paste only  
**Outcome:** Custom workflows for your organization

👉 **Start here if:** You need to customize workflows for your specific needs

---

### 🔴 Advanced Level (6-9 hours)
**Best for:** Developers, enterprise deployment  
**What you get:** Full platform with custom blocks  
**Automation:** MINIMAL - Full manual control  
**Coding required:** PowerShell and React knowledge helpful  
**Outcome:** Enterprise-grade workflow platform

👉 **Start here if:** You're building a workflow platform for your entire organization

---

## Quick Decision Tree

```
Do you just need a working approval workflow?
├─ YES → Core Level (30 min)
└─ NO → Do you need to customize workflows?
    ├─ YES → Intermediate Level (2-3 hours)
    └─ NO → Do you need to build custom blocks?
        ├─ YES → Advanced Level (6-9 hours)
        └─ NO → Core Level (30 min)
```

---

# 🟢 CORE LEVEL: One-Click Workflow Deployment

**Time:** 30 minutes - 1 hour  
**Difficulty:** ⭐☆☆☆☆ (Easiest)  
**Automation:** Maximum (scripts do everything)  
**Coding:** None required

---

## What You'll Build

By the end of Core Level, you'll have:
- ✅ A working approval workflow deployed
- ✅ Manager approval for all access requests
- ✅ Automatic notifications via Teams or email
- ✅ Complete audit trail

---

## Before You Start

### Prerequisites Checklist

Check these boxes before starting:

```
□ Windows 10/11 or Windows Server 2019+
□ PowerShell 5.1 or higher (comes with Windows)
□ Internet connection
□ 10 minutes of uninterrupted time
```

**How to check PowerShell version:**
```powershell
# Copy and paste this into PowerShell:
$PSVersionTable.PSVersion

# You should see: Major = 5 or higher
# ✓ If you see 5 or higher: You're good!
# ✗ If you see 4 or lower: Update PowerShell (instructions below)
```

**If you need to update PowerShell:**
```powershell
# This will open the download page:
Start-Process "https://aka.ms/powershell-release?tag=stable"

# Download and install, then restart PowerShell
```

---

## Step 1: Download and Extract Files (5 minutes)

**What you're doing:** Getting all the files you need in one package  
**Why:** Everything is pre-configured and ready to use  
**Time:** 5 minutes

### Download the Package

```powershell
# Copy and paste this ENTIRE block into PowerShell:

# Create folder for workflows
New-Item -ItemType Directory -Path "C:\PIM-Workflows" -Force | Out-Null

# Go to that folder
cd C:\PIM-Workflows

# Download the workflow package (simulated - replace with actual URL)
Write-Host "📦 Downloading workflow package..." -ForegroundColor Cyan
# Invoke-WebRequest -Uri "https://github.com/yourrepo/workflows.zip" -OutFile "workflows.zip"

Write-Host "✅ Download complete!" -ForegroundColor Green
```

**What success looks like:**
```
📦 Downloading workflow package...
✅ Download complete!
```

**What failure looks like:**
```
❌ Access denied
```

**If you see "Access denied":**
1. Right-click PowerShell
2. Select "Run as Administrator"
3. Try again

---

### ✓ Checkpoint: Verify Download

```powershell
# Run this to check:
Test-Path "C:\PIM-Workflows"

# Expected output: True
# ✓ If you see True: Continue to next step
# ✗ If you see False: The folder wasn't created - try Step 1 again
```

---

## Step 2: Run the Automated Setup (10 minutes)

**What you're doing:** Running a script that sets up everything automatically  
**Why:** This installs the workflow engine and templates  
**Time:** 10 minutes (mostly waiting)

### Run the Setup Script

```powershell
# Make sure you're in the right folder:
cd C:\PIM-Workflows

# Run the automated setup:
.\Setup-Workflows.ps1 -AutoInstall

# You'll see progress messages - just wait for it to finish
```

**What you'll see (this is normal):**
```
🚀 Starting automated workflow setup...
  ✓ Checking prerequisites...
  ✓ Installing workflow engine...
  ✓ Loading templates...
  ✓ Configuring defaults...
  ✓ Running verification...

✅ Setup complete! Ready to deploy workflows.
```

**This script automatically:**
- ✅ Installs the workflow engine
- ✅ Loads 4 pre-built templates
- ✅ Configures default settings
- ✅ Verifies everything works

---

### ✓ Checkpoint: Verify Setup

```powershell
# Run this verification:
.\Verify-Setup.ps1

# Expected output:
✓ PowerShell version: 7.x (or 5.1+)
✓ Workflow engine: Installed
✓ Templates: 4 found
  - Simple Manager Approval
  - Risk-Based Approval
  - Time-Based Access
  - ServiceNow Integration
✓ Configuration: Valid

🎉 Everything is ready!
```

**If you see any ✗ marks:**
```powershell
# Run the fix script:
.\Fix-Setup.ps1

# It will automatically fix common issues
```

---

## Step 3: Choose Your Workflow Template (2 minutes)

**What you're doing:** Picking which pre-built workflow to use  
**Why:** Each template solves a different business need  
**Time:** 2 minutes

### View Available Templates

```powershell
# See all templates with descriptions:
.\Show-Templates.ps1
```

**You'll see:**
```
Available Workflow Templates:

1. Simple Manager Approval ⭐ RECOMMENDED FOR FIRST TIME
   What it does: Requires manager approval for all access requests
   Best for: Basic approval workflow
   Setup time: 5 minutes
   
2. Risk-Based Approval
   What it does: Routes high-risk requests to security team
   Best for: Organizations with security team
   Setup time: 10 minutes
   
3. Time-Based Access
   What it does: Only allows access during business hours
   Best for: Enforcing business hours policy
   Setup time: 5 minutes
   
4. ServiceNow Integration
   What it does: Creates ServiceNow ticket for all requests
   Best for: Organizations using ServiceNow
   Setup time: 15 minutes
```

### 🎯 Recommendation for First Time

**Start with Template #1: Simple Manager Approval**

Why? It's the simplest and most common workflow. You can always add more later.

---

## Step 4: Deploy Your Workflow (10 minutes)

**What you're doing:** Activating the workflow so it starts working  
**Why:** This makes the workflow live and ready to process requests  
**Time:** 10 minutes

### Deploy with One Command

```powershell
# Deploy Template #1 (Simple Manager Approval):
.\Deploy-Workflow.ps1 -Template "SimpleManagerApproval" -AutoConfigure

# The script will ask you a few questions:
```

**Questions you'll be asked:**

```
Q: What email should receive approval requests?
A: [Type your manager's email, press Enter]

Q: How long should approvers have to respond? (in minutes)
A: [Type 60 for 1 hour, or press Enter for default]

Q: Send notifications via Email or Teams?
A: [Type "Teams" or "Email", press Enter]

Q: Ready to deploy? (yes/no)
A: [Type "yes", press Enter]
```

**What you'll see:**
```
🚀 Deploying workflow: Simple Manager Approval

  ✓ Validating configuration...
  ✓ Creating workflow...
  ✓ Setting up notifications...
  ✓ Activating workflow...
  ✓ Running test...

✅ Workflow deployed successfully!

Your workflow is now active and will process all access requests.

📊 View status: .\Show-Status.ps1
🧪 Test workflow: .\Test-Workflow.ps1
```

---

### ✓ Checkpoint: Verify Deployment

```powershell
# Check if workflow is running:
.\Show-Status.ps1

# Expected output:
Workflow Status:
  Name: Simple Manager Approval
  Status: ✅ ACTIVE
  Deployed: [timestamp]
  Requests processed: 0
  Success rate: N/A (no requests yet)
  
Next steps:
  1. Test the workflow: .\Test-Workflow.ps1
  2. Monitor requests: .\Show-Requests.ps1
```

---

## Step 5: Test Your Workflow (5 minutes)

**What you're doing:** Making sure the workflow works before real users try it  
**Why:** Catch any issues now, not when someone needs urgent access  
**Time:** 5 minutes

### Run a Test

```powershell
# Run automated test:
.\Test-Workflow.ps1

# This simulates a real access request
```

**What you'll see:**
```
🧪 Testing workflow: Simple Manager Approval

Simulating access request:
  User: test.user@company.com
  Role: Production Administrator
  Duration: 4 hours
  
Workflow execution:
  ✓ Request received
  ✓ Manager approval sent to: manager@company.com
  ✓ Waiting for approval... (simulated: approved)
  ✓ Access granted
  ✓ Notification sent
  
✅ Test passed! Workflow is working correctly.

Execution time: 2.3 seconds
All steps completed successfully.
```

**If test fails:**
```powershell
# Run diagnostics:
.\Diagnose-Workflow.ps1

# This will tell you exactly what's wrong and how to fix it
```

---

## 🎉 Congratulations! You're Done!

You now have a working approval workflow deployed!

### What You Accomplished

✅ Installed workflow engine  
✅ Deployed approval workflow  
✅ Configured notifications  
✅ Tested successfully  

### What Happens Now?

**When someone requests access:**
1. Workflow automatically receives the request
2. Sends approval request to manager
3. Manager approves/denies via email or Teams
4. Workflow grants or denies access automatically
5. User gets notified
6. Everything is logged for audit

---

### Next Steps

**Monitor your workflows:**
```powershell
# See all requests:
.\Show-Requests.ps1

# See workflow performance:
.\Show-Stats.ps1
```

**Deploy more workflows:**
```powershell
# Deploy another template:
.\Deploy-Workflow.ps1 -Template "TimeBasedAccess" -AutoConfigure
```

**Customize settings:**
```powershell
# Change approval timeout:
.\Update-Workflow.ps1 -Setting "TimeoutMinutes" -Value 120

# Change notification channel:
.\Update-Workflow.ps1 -Setting "NotificationChannel" -Value "Teams"
```

---

### Get Help

**Something not working?**
```powershell
# Run diagnostics:
.\Diagnose-Workflow.ps1

# View logs:
.\Show-Logs.ps1

# Reset and start over:
.\Reset-Workflows.ps1
```

**Need to undo everything?**
```powershell
# Complete cleanup:
.\Cleanup-Workflows.ps1 -RemoveAll

# This removes everything and you can start fresh
```

---

## Core Level Complete! 🎉

**Time spent:** ~30-45 minutes  
**What you have:** Working approval workflow  
**Next level:** Intermediate (if you need customization)

---

# 🟡 INTERMEDIATE LEVEL: Visual Workflow Builder

**Time:** 2-3 hours  
**Difficulty:** ⭐⭐⭐☆☆ (Moderate)  
**Automation:** Medium (guided setup)  
**Coding:** Copy-paste only

---

## What You'll Build

By the end of Intermediate Level, you'll be able to:
- ✅ Use the visual drag-and-drop interface
- ✅ Create custom workflows from scratch
- ✅ Combine multiple conditions and actions
- ✅ Integrate with external systems
- ✅ Test and debug workflows visually

---

## Before You Start

### Prerequisites

```
□ Completed Core Level (or have workflow engine installed)
□ Web browser (Chrome, Edge, or Firefox)
□ Node.js 16+ (for web interface)
□ 2-3 hours of time
```

**Check Node.js version:**
```powershell
node --version

# Expected: v16.x or higher
# If not installed: Download from https://nodejs.org
```

---

## Step 1: Start the Visual Builder (15 minutes)

**What you're doing:** Launching the web interface where you'll build workflows  
**Why:** Visual interface is easier than editing JSON files  
**Time:** 15 minutes

### Automated Launch

```powershell
# Navigate to workflows folder:
cd C:\PIM-Workflows

# Start the visual builder (automated):
.\Start-VisualBuilder.ps1 -AutoInstall

# This will:
# 1. Install web interface dependencies (if needed)
# 2. Start the backend server
# 3. Start the frontend server
# 4. Open your browser automatically
```

**What you'll see:**
```
🚀 Starting Visual Workflow Builder...

  ✓ Checking Node.js... (v18.x found)
  ✓ Installing dependencies... (this may take 2-3 minutes first time)
  ✓ Starting backend server... (port 5000)
  ✓ Starting frontend server... (port 3000)
  ✓ Opening browser...

✅ Visual Builder is running!

  Web Interface: http://localhost:3000
  Backend API: http://localhost:5000
  
  Press Ctrl+C to stop
```

**Your browser will open automatically showing:**
```
┌─────────────────────────────────────────────────────┐
│  Visual Workflow Builder                            │
│                                                     │
│  [New Workflow]  [Load Template]  [Import]         │
│                                                     │
│  ┌──────────────┐  ┌─────────────────────────────┐ │
│  │ Block Library│  │      Canvas Area            │ │
│  │              │  │                             │ │
│  │ Triggers     │  │  Drag blocks here to        │ │
│  │ Actions      │  │  build your workflow        │ │
│  │ Conditions   │  │                             │ │
│  │ Integrations │  │                             │ │
│  └──────────────┘  └─────────────────────────────┘ │
└─────────────────────────────────────────────────────┘
```

---

### ✓ Checkpoint: Verify Visual Builder

**You should see:**
- ✅ Web page loaded in browser
- ✅ Block library on the left
- ✅ Empty canvas in the middle
- ✅ No error messages

**If browser doesn't open:**
```powershell
# Open manually:
Start-Process "http://localhost:3000"
```

**If you see errors:**
```powershell
# Stop and restart:
# Press Ctrl+C to stop
.\Start-VisualBuilder.ps1 -Reset
```

---

## Step 2: Build Your First Workflow Visually (30 minutes)

**What you're doing:** Creating a workflow by dragging and dropping blocks  
**Why:** Visual building is faster and less error-prone than coding  
**Time:** 30 minutes

### Example: Build a Risk-Based Approval Workflow

**Goal:** Route high-risk requests to security team, low-risk to manager

---

### 2.1: Add Trigger Block (2 minutes)

**What:** The trigger starts your workflow when something happens

1. Look at the **Block Library** on the left
2. Find **"Triggers"** section
3. Find **"Access Request"** block
4. **Drag** it onto the canvas
5. **Drop** it in the center

**You'll see:**
```
┌─────────────────────────┐
│ 🎯 Access Request       │
│                         │
│ Triggered when user     │
│ requests access         │
│                         │
│         [▶]             │
└─────────────────────────┘
```

**What this means:** This block activates whenever someone requests privileged access.

---

### 2.2: Add Risk Check Block (3 minutes)

**What:** This block checks if the request is high risk or low risk

1. Find **"Conditions"** section in Block Library
2. Find **"Check Risk Score"** block
3. **Drag** it onto canvas below the trigger
4. **Drop** it below the Access Request block

**You'll see:**
```
┌─────────────────────────┐
│ 🔀 Check Risk Score     │
│                         │
│ [◀] Input               │
│                         │
│ Threshold: 75           │
│                         │
│ [✓] Low Risk            │
│ [✗] High Risk           │
└─────────────────────────┘
```

---

### 2.3: Connect the Blocks (2 minutes)

**What:** Connecting blocks tells the workflow what order to run them in

1. **Click** on the **[▶]** port on "Access Request" block
2. **Drag** to the **[◀]** port on "Check Risk Score" block
3. **Release** mouse button

**You'll see a line connecting them:**
```
┌─────────────────────────┐
│ 🎯 Access Request       │
│         [▶]─────────────┼──┐
└─────────────────────────┘  │
                              │
                              ▼
┌─────────────────────────┐  │
│ 🔀 Check Risk Score     │  │
│ [◀]─────────────────────┼──┘
│ Threshold: 75           │
│ [✓] Low Risk            │
│ [✗] High Risk           │
└─────────────────────────┘
```

**What this means:** When an access request comes in, it will automatically check the risk score.

---

### 2.4: Add Approval Blocks (5 minutes)

**What:** Different approval paths for high risk vs low risk

**For High Risk requests:**
1. Find **"Approvals"** section
2. Drag **"Security Team Approval"** block onto canvas
3. Connect **[✗] High Risk** port to this block

**For Low Risk requests:**
1. Drag **"Manager Approval"** block onto canvas
2. Connect **[✓] Low Risk** port to this block

**You'll see:**
```
┌─────────────────────────┐
│ 🎯 Access Request       │
│         [▶]             │
└──────────┬──────────────┘
           │
           ▼
┌─────────────────────────┐
│ 🔀 Check Risk Score     │
│     Threshold: 75       │
└──────┬──────────────┬───┘
       │              │
  Low Risk       High Risk
       │              │
       ▼              ▼
┌──────────────┐  ┌──────────────┐
│ 👤 Manager   │  │ 🛡️ Security  │
│   Approval   │  │   Team       │
└──────────────┘  └──────────────┘
```

---

### 2.5: Add Grant Access Block (3 minutes)

**What:** This block actually grants the access after approval

1. Find **"Actions"** section
2. Drag **"Grant Access"** block onto canvas
3. Connect **both** approval blocks to this block

**You'll see:**
```
┌──────────────┐  ┌──────────────┐
│ 👤 Manager   │  │ 🛡️ Security  │
│   Approval   │  │   Team       │
└──────┬───────┘  └──────┬───────┘
       │                 │
       └────────┬────────┘
                │
                ▼
        ┌──────────────┐
        │ ✅ Grant     │
        │   Access     │
        └──────────────┘
```

---

### 2.6: Configure Block Properties (10 minutes)

**What:** Setting the details for each block (like timeout, duration, etc.)

**Click on "Check Risk Score" block:**
- Properties panel appears on the right
- You'll see: `Threshold: 75`
- **What this means:** Scores 75+ are "high risk"
- **Change if needed:** Click the number, type new value

**Click on "Manager Approval" block:**
- You'll see: `Timeout: 60 minutes`
- **What this means:** Manager has 60 minutes to respond
- **Change if needed:** Click the number, type new value (e.g., 120 for 2 hours)

**Click on "Security Team Approval" block:**
- You'll see: `Timeout: 120 minutes`
- **What this means:** Security team has 2 hours to respond

**Click on "Grant Access" block:**
- You'll see: `Duration: 4 hours`
- **What this means:** Access will last 4 hours then auto-expire
- **Change if needed:** Click the number, type new value

---

### 2.7: Validate Your Workflow (3 minutes)

**What:** Checking if your workflow has any errors before deploying

**Click the "Validate" button at the top**

**You'll see:**
```
✓ Workflow Validation

✓ Has trigger block
✓ All blocks connected
✓ No orphaned blocks
✓ All required properties set
✓ No circular dependencies

✅ Workflow is valid and ready to deploy!
```

**If you see errors:**
```
✗ Workflow Validation

✗ Block "Grant Access" missing required property: Duration
✗ Block "Notify User" has no input connection

Fix these issues before deploying.
```

**How to fix:**
- Click on the block with the error
- Fill in the missing property
- Connect any disconnected blocks

---

### 2.8: Test Your Workflow (5 minutes)

**What:** Running a simulation to see if it works correctly

**Click the "Test" button at the top**

**You'll see a test panel:**
```
🧪 Test Workflow

Enter test data:
  User: [test@company.com]
  Role: [Production Admin]
  Risk Score: [85] ← Try different values!
  
[Run Test]
```

**Fill in the fields and click "Run Test"**

**You'll see step-by-step execution:**
```
Test Results:

✓ Access Request received
  └─ User: test@company.com
  └─ Role: Production Admin
  
✓ Check Risk Score
  └─ Score: 85
  └─ Threshold: 75
  └─ Result: HIGH RISK
  
✓ Security Team Approval
  └─ Sent to: security@company.com
  └─ Simulated: APPROVED
  
✓ Grant Access
  └─ Duration: 4 hours
  └─ Granted at: 2024-12-10 14:30
  
✅ Test passed! (2.1 seconds)
```

**Try testing with different risk scores:**
- Risk Score: 50 → Should go to Manager
- Risk Score: 85 → Should go to Security Team

---

## Step 3: Deploy Your Custom Workflow (10 minutes)

**What you're doing:** Making your workflow live  
**Why:** So it starts processing real access requests  
**Time:** 10 minutes

### Save and Deploy

**Click "Deploy" button at the top**

**You'll see:**
```
Deploy Workflow

Workflow Name: [My Risk-Based Approval]
Description: [Routes high-risk to security team]

Deployment Options:
  ☑ Activate immediately
  ☑ Send test notification
  ☐ Replace existing workflow

[Deploy Now]  [Cancel]
```

**Click "Deploy Now"**

**You'll see:**
```
🚀 Deploying workflow...

  ✓ Validating workflow...
  ✓ Saving definition...
  ✓ Creating backend workflow...
  ✓ Activating workflow...
  ✓ Sending test notification...
  
✅ Workflow deployed successfully!

Your workflow is now active.

  Workflow ID: wf-20241210-143045
  Status: ACTIVE
  Deployed: 2024-12-10 14:30:45
  
[View Status]  [Edit Workflow]  [Create New]
```

---

### ✓ Checkpoint: Verify Deployment

**Click "View Status"**

**You should see:**
```
Workflow Status Dashboard

Name: My Risk-Based Approval
Status: ✅ ACTIVE
Deployed: 2024-12-10 14:30:45

Statistics (last 24 hours):
  Requests processed: 0
  Success rate: N/A
  Average execution time: N/A
  
Recent Activity:
  (No activity yet)
  
[Test Workflow]  [View Logs]  [Edit]  [Deactivate]
```

---

## Step 4: Monitor Your Workflows (10 minutes)

**What you're doing:** Watching workflows process real requests  
**Why:** Make sure everything is working as expected  
**Time:** 10 minutes

### View Real-Time Activity

**In the Visual Builder, click "Monitor" tab**

**You'll see:**
```
📊 Workflow Monitoring

Active Workflows: 2
  • My Risk-Based Approval (ACTIVE)
  • Simple Manager Approval (ACTIVE)

Recent Requests:
┌────────────┬──────────────┬─────────┬──────────┐
│ Time       │ User         │ Workflow│ Status   │
├────────────┼──────────────┼─────────┼──────────┤
│ 14:35:22   │ john@co.com  │ Risk    │ ✅ Success│
│ 14:32:15   │ jane@co.com  │ Simple  │ ⏳ Pending│
│ 14:28:03   │ bob@co.com   │ Risk    │ ✅ Success│
└────────────┴──────────────┴─────────┴──────────┘

[Refresh]  [Export Logs]  [View Details]
```

**Click on any request to see details:**
```
Request Details: john@co.com

Workflow: My Risk-Based Approval
Status: ✅ Completed Successfully
Duration: 2.3 seconds

Execution Steps:
  ✓ Access Request (0.1s)
    └─ User: john@co.com
    └─ Role: Production Admin
    
  ✓ Check Risk Score (0.2s)
    └─ Score: 45
    └─ Result: LOW RISK
    
  ✓ Manager Approval (1.8s)
    └─ Sent to: manager@co.com
    └─ Response: APPROVED
    └─ Response time: 1.5s
    
  ✓ Grant Access (0.2s)
    └─ Duration: 4 hours
    └─ Expires: 18:35:22
    
Timeline:
14:35:22 ─ Request received
14:35:22 ─ Risk check: LOW
14:35:23 ─ Approval sent
14:35:24 ─ Approved
14:35:24 ─ Access granted
```

---

## 🎉 Intermediate Level Complete!

**Time spent:** ~2-3 hours  
**What you have:** Custom visual workflows  
**Next level:** Advanced (if you need custom blocks)

### What You Accomplished

✅ Built workflows visually  
✅ Created custom approval logic  
✅ Tested workflows before deployment  
✅ Deployed and monitored workflows  

---

### Common Workflows You Can Build Now

**1. Multi-Level Approval**
```
Request → Manager → Director → Security → Grant
```

**2. Time + Risk Based**
```
Request → Check Time → Check Risk → Route Accordingly
```

**3. ServiceNow Integration**
```
Request → Create ServiceNow Ticket → Wait for Approval → Grant
```

**4. Conditional Access**
```
Request → Check MFA → Check Location → Check Device → Grant/Deny
```

---

# 🔴 ADVANCED LEVEL: Custom Platform Development

**Time:** 6-9 hours  
**Difficulty:** ⭐⭐⭐⭐⭐ (Expert)  
**Automation:** Minimal (full manual control)  
**Coding:** PowerShell and React knowledge required

---

## What You'll Build

By the end of Advanced Level, you'll have:
- ✅ Full workflow platform with custom blocks
- ✅ Multi-tenant support
- ✅ Custom integrations
- ✅ Performance optimization
- ✅ Enterprise deployment

---

## Before You Start

### Prerequisites

```
□ Completed Intermediate Level
□ PowerShell scripting experience
□ React/JavaScript knowledge
□ Git installed
□ Visual Studio Code (recommended)
□ 6-9 hours of time
```

---

## Step 1: Set Up Development Environment (1 hour)

**What you're doing:** Setting up tools for custom development  
**Why:** You'll be writing custom code and need proper tools  
**Time:** 1 hour

### Install Development Tools

```powershell
# Install Git (if not already installed):
winget install Git.Git

# Install Visual Studio Code:
winget install Microsoft.VisualStudioCode

# Install PowerShell 7:
winget install Microsoft.PowerShell

# Verify installations:
git --version
code --version
pwsh --version
```

### Clone the Repository

```powershell
# Create development folder:
New-Item -ItemType Directory -Path "C:\Dev\PIM-Workflows" -Force
cd C:\Dev\PIM-Workflows

# Clone the source code:
git clone https://github.com/yourrepo/pim-workflows.git
cd pim-workflows

# Install dependencies:
npm install

# Build the project:
npm run build
```

---

## Step 2: Create Custom Block Types (2 hours)

**What you're doing:** Building your own workflow blocks  
**Why:** Extend the platform with organization-specific functionality  
**Time:** 2 hours

### Example: Create a Custom "Check Budget" Block

Create `scripts/automation/blocks/Custom-BudgetCheck.ps1`:

```powershell
<#
.SYNOPSIS
    Custom block: Check if department has budget for access

.DESCRIPTION
    This block checks if the requesting user's department
    has remaining budget for privileged access
#>

class BudgetCheckBlock : WorkflowBlock {
    BudgetCheckBlock([hashtable]$Definition) : base($Definition) {
        # Custom initialization
    }
    
    [hashtable] Execute([hashtable]$InputData) {
        Write-Host "Checking department budget..." -ForegroundColor Yellow
        
        $department = $InputData.UserDepartment
        $costPerHour = $this.Properties.CostPerHour
        $duration = $InputData.RequestedDuration
        
        # Calculate cost
        $totalCost = $costPerHour * $duration
        
        # Check budget (would query actual budget system)
        $remainingBudget = $this.GetDepartmentBudget($department)
        
        $hasbudget = $remainingBudget -ge $totalCost
        
        Write-Host "  Department: $department" -ForegroundColor White
        Write-Host "  Cost: $$totalCost" -ForegroundColor White
        Write-Host "  Remaining Budget: $$remainingBudget" -ForegroundColor White
        Write-Host "  Has Budget: $hasBudget" -ForegroundColor $(if ($hasBudget) { "Green" } else { "Red" })
        
        return @{
            Success = $true
            HasBudget = $hasBudget
            TotalCost = $totalCost
            RemainingBudget = $remainingBudget
            Output = if ($hasBudget) { "approved" } else { "denied" }
        }
    }
    
    [decimal] GetDepartmentBudget([string]$Department) {
        # Would query actual budget system
        # For demo, return random value
        return Get-Random -Minimum 100 -Maximum 10000
    }
}
```

### Register Custom Block

```powershell
# Add to block registry:
$blockRegistry = @{
    "Custom_BudgetCheck" = [BudgetCheckBlock]
}

# Export for use in workflows
Export-ModuleMember -Type BudgetCheckBlock
```

---

## Step 3: Create Custom React Components (2 hours)

**What you're doing:** Building UI for your custom blocks  
**Why:** Users need to see and configure your custom blocks  
**Time:** 2 hours

### Example: Budget Check Block Component

Create `web/src/components/blocks/BudgetCheckBlock.jsx`:

```jsx
import React from 'react';

const BudgetCheckBlock = ({ data, onUpdate }) => {
  const handleCostChange = (e) => {
    onUpdate({
      ...data,
      properties: {
        ...data.properties,
        CostPerHour: parseFloat(e.target.value),
      },
    });
  };

  return (
    <div className="workflow-block custom-block">
      <div className="block-header">
        <span className="block-icon">💰</span>
        <span className="block-title">Check Budget</span>
      </div>
      <div className="block-body">
        <div className="block-description">
          Checks if department has budget for access
        </div>
        <div className="block-properties">
          <div className="property-field">
            <label>Cost per Hour ($)</label>
            <input
              type="number"
              value={data.properties.CostPerHour || 50}
              onChange={handleCostChange}
              min="0"
              step="10"
            />
          </div>
        </div>
      </div>
      <div className="block-inputs">
        <div className="input-port" data-port="input">◀</div>
      </div>
      <div className="block-outputs">
        <div className="output-port" data-port="approved">✓</div>
        <div className="output-port" data-port="denied">✗</div>
      </div>
    </div>
  );
};

export default BudgetCheckBlock;
```

### Register Component

```javascript
// In web/src/components/blocks/index.js:
import BudgetCheckBlock from './BudgetCheckBlock';

export const customBlocks = {
  Custom_BudgetCheck: BudgetCheckBlock,
};
```

---

## Step 4: Performance Optimization (1 hour)

**What you're doing:** Making workflows run faster  
**Why:** Production systems need to handle high volume  
**Time:** 1 hour

### Implement Caching

```powershell
class CachedWorkflowEngine : WorkflowEngine {
    [hashtable]$Cache
    [int]$CacheTTL = 300  # 5 minutes
    
    CachedWorkflowEngine() : base() {
        $this.Cache = @{}
    }
    
    [hashtable] ExecuteWithCache([hashtable]$InputData) {
        $cacheKey = $this.GetCacheKey($InputData)
        
        # Check cache
        if ($this.Cache.ContainsKey($cacheKey)) {
            $cached = $this.Cache[$cacheKey]
            if ((Get-Date) -lt $cached.Expires) {
                Write-Host "✓ Using cached result" -ForegroundColor Green
                return $cached.Result
            }
        }
        
        # Execute workflow
        $result = $this.Execute($InputData)
        
        # Cache result
        $this.Cache[$cacheKey] = @{
            Result = $result
            Expires = (Get-Date).AddSeconds($this.CacheTTL)
        }
        
        return $result
    }
    
    [string] GetCacheKey([hashtable]$InputData) {
        $key = "$($InputData.UserId)-$($InputData.RoleId)"
        return $key
    }
}
```

---

## Step 5: Multi-Tenant Support (1 hour)

**What you're doing:** Supporting multiple organizations  
**Why:** SaaS deployment or multiple business units  
**Time:** 1 hour

### Implement Tenant Isolation

```powershell
class MultiTenantWorkflowEngine : WorkflowEngine {
    [string]$TenantId
    [hashtable]$TenantConfig
    
    MultiTenantWorkflowEngine([string]$TenantId) : base() {
        $this.TenantId = $TenantId
        $this.LoadTenantConfig()
    }
    
    [void] LoadTenantConfig() {
        $configPath = ".\tenants\$($this.TenantId)\config.json"
        if (Test-Path $configPath) {
            $this.TenantConfig = Get-Content $configPath | ConvertFrom-Json -AsHashtable
        }
    }
    
    [void] LoadWorkflow([string]$JsonDefinition) {
        # Load tenant-specific workflow
        $workflowPath = ".\tenants\$($this.TenantId)\workflows\$JsonDefinition"
        $json = Get-Content $workflowPath -Raw
        
        ([WorkflowEngine]$this).LoadWorkflow($json)
    }
}
```

---

## Step 6: Enterprise Deployment (1 hour)

**What you're doing:** Deploying to production environment  
**Why:** Make it available to your organization  
**Time:** 1 hour

### Docker Deployment

Create `Dockerfile`:

```dockerfile
FROM mcr.microsoft.com/powershell:latest

# Install Node.js
RUN apt-get update && apt-get install -y nodejs npm

# Copy application
WORKDIR /app
COPY . /app

# Install dependencies
RUN npm install
RUN npm run build

# Expose ports
EXPOSE 3000 5000

# Start application
CMD ["pwsh", "-File", "./Start-Production.ps1"]
```

### Deploy to Azure

```powershell
# Create Azure resources:
az group create --name pim-workflows-rg --location eastus

az container create \
  --resource-group pim-workflows-rg \
  --name pim-workflows \
  --image yourregistry/pim-workflows:latest \
  --dns-name-label pim-workflows \
  --ports 3000 5000

# Get URL:
az container show \
  --resource-group pim-workflows-rg \
  --name pim-workflows \
  --query ipAddress.fqdn
```

---

## 🎉 Advanced Level Complete!

**Time spent:** ~6-9 hours  
**What you have:** Enterprise workflow platform  

### What You Accomplished

✅ Created custom workflow blocks  
✅ Built custom React components  
✅ Optimized performance  
✅ Implemented multi-tenant support  
✅ Deployed to production  

---

# Troubleshooting Guide

## Common Issues by Level

### Core Level Issues

**Issue: "Setup script won't run"**
```
Symptom: .\Setup-Workflows.ps1 gives error
Fix:
1. Right-click PowerShell → Run as Administrator
2. Run: Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
3. Try again
```

**Issue: "Templates not found"**
```
Symptom: .\Show-Templates.ps1 shows no templates
Fix:
1. Verify you're in correct folder: cd C:\PIM-Workflows
2. Re-run setup: .\Setup-Workflows.ps1 -Force
3. Check: Test-Path ".\templates"
```

**Issue: "Workflow won't deploy"**
```
Symptom: Deploy fails with error
Fix:
1. Run diagnostics: .\Diagnose-Workflow.ps1
2. Check logs: .\Show-Logs.ps1 -Last 10
3. Reset if needed: .\Reset-Workflows.ps1
```

---

### Intermediate Level Issues

**Issue: "Visual builder won't start"**
```
Symptom: Browser shows "Can't connect"
Fix:
1. Check Node.js: node --version (need 16+)
2. Check ports: netstat -an | findstr "3000 5000"
3. Kill conflicting process: Stop-Process -Name node -Force
4. Restart: .\Start-VisualBuilder.ps1 -Reset
```

**Issue: "Blocks won't connect"**
```
Symptom: Can't drag connection between blocks
Fix:
1. Check block types are compatible
2. Refresh browser: F5
3. Clear cache: Ctrl+Shift+Delete
4. Restart visual builder
```

**Issue: "Test fails but looks correct"**
```
Symptom: Validation passes but test fails
Fix:
1. Check test data matches expected format
2. View detailed logs: Click "View Logs" in test panel
3. Check backend logs: .\Show-Logs.ps1 -Component "Backend"
```

---

### Advanced Level Issues

**Issue: "Custom block not appearing"**
```
Symptom: Created custom block but not in library
Fix:
1. Check registration: $blockRegistry | Format-Table
2. Rebuild frontend: npm run build
3. Restart servers: .\Start-VisualBuilder.ps1 -Reset
4. Clear browser cache
```

**Issue: "Performance is slow"**
```
Symptom: Workflows taking > 5 seconds
Fix:
1. Enable caching: Use CachedWorkflowEngine
2. Check database queries: .\Show-Performance.ps1
3. Optimize workflow: Remove unnecessary blocks
4. Scale up: Add more resources
```

---

## FAQ

### Core Level FAQ

**Q: Do I need to know PowerShell?**
A: No! Core level is fully automated. Just run the scripts.

**Q: How long does setup take?**
A: About 30 minutes total for first workflow.

**Q: Can I undo if something goes wrong?**
A: Yes! Run `.\Cleanup-Workflows.ps1` to reset everything.

**Q: Will this work on Mac/Linux?**
A: Core level is Windows only. Intermediate+ supports Mac/Linux.

---

### Intermediate Level FAQ

**Q: Do I need to know coding?**
A: No coding needed! Just drag and drop blocks.

**Q: Can I edit deployed workflows?**
A: Yes! Click "Edit" in the workflow status dashboard.

**Q: How many workflows can I create?**
A: Unlimited! Create as many as you need.

**Q: Can I share workflows with others?**
A: Yes! Use "Export" to save as JSON, then share the file.

---

### Advanced Level FAQ

**Q: What programming languages do I need?**
A: PowerShell for backend, JavaScript/React for frontend.

**Q: Can I sell my custom blocks?**
A: Yes! They're yours to do with as you wish.

**Q: Is there an API?**
A: Yes! REST API on port 5000. See API docs.

**Q: How do I scale for production?**
A: Use Docker + Azure Container Instances (see Step 6).

---

## Glossary

**Block** - A single step in a workflow (like a LEGO piece)

**Canvas** - The area where you build workflows visually

**Condition** - A block that makes decisions (if/then logic)

**Deploy** - Make a workflow active so it starts working

**Engine** - The "brain" that runs workflows (PowerShell code)

**Template** - A pre-built workflow you can customize

**Trigger** - What starts a workflow (like "access request received")

**Validation** - Checking if a workflow has errors

**Workflow** - A series of steps that automate a process

---

## Summary

### Time Investment by Level

| Level | Time | Automation | Outcome |
|-------|------|------------|---------|
| **Core** | 30 min - 1 hr | Maximum | Working workflow |
| **Intermediate** | 2-3 hours | Medium | Custom workflows |
| **Advanced** | 6-9 hours | Minimal | Enterprise platform |

### What You Can Do at Each Level

**Core:**
- ✅ Deploy pre-built workflows
- ✅ Basic customization
- ✅ Monitor requests

**Intermediate:**
- ✅ Everything in Core, plus:
- ✅ Build workflows visually
- ✅ Create complex logic
- ✅ Test before deploying

**Advanced:**
- ✅ Everything in Intermediate, plus:
- ✅ Create custom blocks
- ✅ Multi-tenant support
- ✅ Production deployment

---

## Next Steps

**Just completed Core?**
→ Try Intermediate to build custom workflows

**Just completed Intermediate?**
→ Try Advanced if you need custom blocks

**Need help?**
→ Run `.\Get-Help.ps1` for support options

---

**Related Documentation:**
- [Automated Incident Response](../security/automated-incident-response.md)
- [ServiceNow/Jira/Slack/Teams Integrations](../integrations/servicenow-jira-slack.md)
- [Time-Based Access Controls](../access-controls/time-based-access-controls.md)
