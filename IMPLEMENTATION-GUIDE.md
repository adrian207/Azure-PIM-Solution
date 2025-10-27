# Azure PIM Solution - Step-by-Step Implementation Guide

**For: Non-Technical Implementation Managers and Project Coordinators**

**Author:** Adrian Johnson  
**Email:** adrian207@gmail.com  
**Version:** 1.0  
**Date:** December 2024

---

## Welcome!

This guide will walk you through implementing the Azure PIM Solution step-by-step. You don't need to be a technical expert—you just need to follow the steps in order and check things off as you complete them.

**Time Required:** 8-12 hours total (can be spread over several days)  
**Who This Is For:** Project managers, business analysts, security coordinators  
**What You Need:** Basic computer skills and access to your organization's Azure account

---

## What You're Building

Think of this as setting up a secure building access system. Instead of handing out master keys to everyone permanently, this system:
- **Checks** if someone really needs access
- **Approves** their request (sometimes automatically, sometimes with manager approval)
- **Grants** temporary access that expires automatically
- **Records** everything for compliance and security audits

By the end of this guide, you'll have a working system that manages who has access to your company's critical systems.

---

## Table of Contents

1. [Before You Begin](#before-you-begin)
2. [Step 1: Prepare Your Configuration](#step-1-prepare-your-configuration)
3. [Step 2: Run the Automation Scripts](#step-2-run-the-automation-scripts)
4. [Step 3: Configure PIM Roles in Azure Portal](#step-3-configure-pim-roles-in-azure-portal)
5. [Step 4: Set Up Approval Workflows](#step-4-set-up-approval-workflows)
6. [Step 5: Create Power BI Dashboards](#step-5-create-power-bi-dashboards)
7. [Step 6: Train Your Users](#step-6-train-your-users)
8. [Step 7: Go Live and Monitor](#step-7-go-live-and-monitor)
9. [Troubleshooting](#troubleshooting)

---

## Before You Begin

### What You Need

Before starting, make sure you have:

- ✅ **Microsoft Azure Account** (with administrator access)
- ✅ **Computer running Windows 10/11**
- ✅ **PowerShell installed** (usually already on Windows)
- ✅ **List of people who need privileged access** (system administrators, IT staff, etc.)
- ✅ **List of managers who will approve access requests**
- ✅ **About 2 weeks** to complete the full implementation

### Who to Involve

You'll need to work with:
- **IT Administrator** - To help with technical setup
- **Security Officer** - To review and approve roles
- **HR Representative** - To provide user lists
- **Department Managers** - To understand who needs what access

### How Long This Takes

- **Day 1-2:** Setup and configuration (4-6 hours)
- **Day 3-5:** Testing and training (4-6 hours)
- **Day 6-10:** Gradual rollout (2-3 hours)
- **Day 11-14:** Full production use

---

## Step 1: Prepare Your Configuration

**Time Required:** 1-2 hours  
**Difficulty:** Easy (mostly filling in forms)

### What You're Doing

You're telling the system about your organization—your company name, who the key people are, what systems need protection, and who can approve access requests.

### Detailed Instructions

#### 1.1 Open the Configuration File

1. Navigate to the `config` folder in your PIM solution folder
2. Right-click on `environment-config.json`
3. Select "Open with" → Choose "Notepad" or any text editor
4. Don't worry about all the technical-looking code—we're only editing specific parts

#### 1.2 Using Existing Azure Resources (Optional)

**If you already have Azure resources (Key Vault, Storage, etc.):**

Find the `"keyVault"` section (around line 24):
```json
"keyVault": {
    "name": "",
    "useExisting": true
}
```

**To use your existing Key Vault:**
- Replace `""` with your existing Key Vault name
- Set `"useExisting"` to `true`

**The script will:**
- Use your existing Key Vault
- Only add PIM-specific secrets
- Never modify your existing secrets
- Work completely safely alongside your current setup

See `docs/operations/existing-infrastructure.md` for more details.

#### 1.3 Fill in Your Organization Details (Lines 2-7)

Find this section:
```json
"organization": {
    "name": "Your Organization Name",
    "shortName": "yourorg",
    "primaryContact": "it-security@yourorg.com",
    "region": "eastus"
}
```

**What to change:**
- `"Your Organization Name"` → Replace with your actual company name (e.g., "Acme Corporation")
- `"yourorg"` → Replace with a short version of your company name, all lowercase, no spaces (e.g., "acmecorp")
- `"it-security@yourorg.com"` → Replace with your IT security team's email address
- `"eastus"` → Keep as is (this is your Azure data center location—eastus is fine unless you're told otherwise)

**Example:**
```json
"organization": {
    "name": "Acme Corporation",
    "shortName": "acmecorp",
    "primaryContact": "security@acme.com",
    "region": "eastus"
}
```

#### 1.3 Fill in Azure Subscription Details (Lines 9-14)

Find this section:
```json
"subscription": {
    "name": "Azure Subscription Name",
    "id": ""
}
```

**To find your Azure subscription name:**
1. Go to https://portal.azure.com
2. Sign in with your Azure account
3. In the top search bar, type "Subscriptions"
4. Click on "Subscriptions"
5. Copy the name of your subscription (it's in the first column)

**What to change:**
- `"Azure Subscription Name"` → Replace with the subscription name you just copied
- Leave `"id"` empty for now (you don't need to fill this in)

#### 1.4 Update Email Addresses for Approvals (Lines 30-36)

Find the section that looks like this:
```json
"approvers": [
    "manager@yourorg.com",
    "system-owner@yourorg.com"
]
```

**What to do:**
Replace these placeholder emails with real email addresses of people who can approve access requests. These are typically:
- IT managers
- Department heads
- Security officers

**Example:**
```json
"approvers": [
    "john.smith@acme.com",
    "jane.doe@acme.com"
]
```

#### 1.5 Update Alert Recipients (Lines 130-133)

Find this section:
```json
"recipients": [
    "security-team@yourorg.com",
    "compliance@yourorg.com"
]
```

**What to do:**
Replace with email addresses of people who should receive security alerts. This is typically your security team.

#### 1.6 Save the File

1. Click File → Save (or press Ctrl+S)
2. Close the file

### Checklist for Step 1

- [ ] Organization name updated
- [ ] Short name updated (lowercase, no spaces)
- [ ] Primary contact email updated
- [ ] Azure subscription name filled in
- [ ] Approver email addresses updated
- [ ] Alert recipient email addresses updated
- [ ] File saved

**Common Mistakes to Avoid:**
- ❌ Don't add spaces in the shortName field
- ❌ Don't forget the quotes around email addresses
- ❌ Don't change the commas or brackets
- ✅ Make sure there's a comma after each entry except the last one

---

## Step 2: Run the Automation Scripts

**Time Required:** 30-60 minutes  
**Difficulty:** Moderate (but we'll guide you through it)

### What You're Doing

You're running automated scripts that create all the necessary Azure infrastructure—like setting up virtual filing cabinets, security systems, and monitoring tools.

### Detailed Instructions

#### 2.1 Open PowerShell

1. Click the **Windows Start button** (bottom left)
2. Type "PowerShell"
3. You'll see "Windows PowerShell" appear in the search results
4. **Right-click** anywhere on this result
5. Select **"Run as Administrator"**
6. If you see a security prompt asking "Do you want to allow this app to make changes?", click **Yes**

You should now see a blue window with text like:
```
Windows PowerShell
Copyright (C) Microsoft Corporation. All rights reserved.
PS C:\WINDOWS\system32>
```

**What this is:** PowerShell is a program that runs commands automatically. Think of it as giving instructions to your computer in a way that's more precise than clicking buttons.

#### 2.2 Navigate to the Scripts Folder

1. Look at the bottom of the PowerShell window—you should see something like `PS C:\WINDOWS\system32>`
2. Type this command (replace the path with where you saved the PIM solution):
```
cd "C:\Github\Azure PIM Solution\scripts"
```

3. Press **Enter**

**Tip:** If you're not sure where you saved the files, you can navigate there using File Explorer first, then copy the folder path from the address bar.

#### 2.3 Run the Prerequisites Check Script

Type this command and press **Enter**:
```
.\01-prerequisites.ps1
```

**What will happen:**
- The script will check if you have everything needed installed
- It may ask to connect to Azure (it will open a browser window for you to sign in)
- It might install some software components automatically
- This can take 10-20 minutes

**Expected messages you'll see:**
- "Loading configuration..." (yellow text)
- "Checking required Azure modules..." (yellow text)
- "Connected to Azure as: your-email@company.com" (green text)

**If you see an error:** Don't panic! Common issues:
- **"cannot be loaded because running scripts is disabled"**: You need to enable script execution (see Troubleshooting section)
- **"Module not found"**: The script will automatically install it for you—just wait
- **"Not connected to Azure"**: Follow the prompts to sign in when a browser window opens

#### 2.4 Run the Complete Deployment Script

Once Step 2.3 finishes successfully, type this command and press **Enter**:
```
.\00-quick-deploy.ps1
```

**What will happen:**
- The script will show you a summary of what it's about to do
- It will ask "Do you want to proceed with deployment? (Y/N)"
- Type **Y** and press **Enter**
- The script will now create everything automatically:
  - Azure storage accounts
  - Key vault for secrets
  - Log analytics workspace
  - Monitoring and alerts
  
**This will take 20-40 minutes**

**What to expect:**
- You'll see lots of text scrolling by
- Different sections will appear in different colors (cyan, yellow, green)
- It will show progress for each step
- At the end, you'll see "Deployment completed successfully!"

#### 2.5 Review the Results

When the script finishes, you'll see a summary. Write down or take a screenshot of the important information like:
- Resource Group name
- Storage Account name
- Key Vault name

**You'll need these in the next steps!**

### Checklist for Step 2

- [ ] Opened PowerShell as Administrator
- [ ] Navigated to scripts folder
- [ ] Ran prerequisites script successfully
- [ ] Connected to Azure when prompted
- [ ] Ran quick-deploy script successfully
- [ ] Saved the resource names for reference

**Important Notes:**
- Let the scripts run to completion—don't close the window
- If something fails, read the error message carefully
- You can always re-run the scripts later—they check if things already exist

---

## Step 3: Configure PIM Roles in Azure Portal

**Time Required:** 2-3 hours  
**Difficulty:** Moderate (requires clicking through Azure Portal)

### What You're Doing

You're setting up who can request what type of access. Think of it like creating different badge levels at a secure facility—some people might get basic access, others get VIP access, and you define who can approve these different levels.

### Detailed Instructions

#### 3.1 Open Azure Portal

1. Open your web browser
2. Go to https://portal.azure.com
3. Sign in with your Azure account
4. You should see a dashboard with various tiles and icons

#### 3.2 Find Privileged Identity Management

1. In the top search bar (where it says "Search resources, services, and docs"), type: **Privileged Identity**
2. Click on **"Privileged Identity Management"** when it appears in the results
3. You'll be taken to a new page

**What you're looking at:** This is the control center for managing privileged access in Azure.

#### 3.3 Set Up Azure AD Roles

1. In the left menu (or in the center tiles), look for and click **"Azure AD roles"**
2. You'll see options like "Overview", "Roles", "Assignments"
3. Click on **"Settings"** in the left menu

#### 3.4 Configure Your First Role

Let's start with the "Global Administrator" role as an example:

1. In the "Settings" page, you'll see a list of roles
2. Find and click **"Global Administrator"** (or "Global Reader" if you're starting with less privileged roles)
3. You'll see configuration options

**Now you'll configure several settings:**

**A. Activation Settings:**
- Find **"Maximum activation duration (hours)"**
- Set this to the number from your config file (look at your role definitions—probably 4 for production admin, 24 for dev admin)
- Find **"Require justification on activation"**
- Switch this to **"Yes"** (toggle it on)

**B. Notification Settings:**
- Find **"Send notification emails to admins when eligible role is activated"**
- Switch this to **"Yes"**

**C. Assignment Settings:**
- Find **"Allow permanent eligible assignment"**
- Leave this as **"Yes"** (default)
- Find **"Allow permanent active assignment"**
- Switch this to **"Yes"**

#### 3.5 Set Up Approval Requirements

1. Still on the role settings page
2. Look for **"Requires approval"** section
3. Click **"Edit"**
4. Toggle **"Require approval to activate"** to **"On"** (if it's not already)
5. Click **"Add approvers"**
6. Select the people from your organization who can approve this role activation
7. Click **"Done"**

**Who should be approvers?**
- IT Manager
- Department Head
- Security Officer

#### 3.6 Save Your Changes

1. Click **"Save"** at the top of the page
2. Wait for the confirmation message

#### 3.7 Repeat for Other Roles

Go back and configure the other important roles:
- Production Administrator (if you use Azure resources)
- Security Administrator
- User Administrator
- Any other custom roles you need

**Pro tip:** You can configure multiple roles at once by going back to the Settings page and selecting each one.

### Checklist for Step 3

- [ ] Opened Azure Portal
- [ ] Found Privileged Identity Management
- [ ] Configured at least 3 key roles
- [ ] Set maximum activation duration for each role
- [ ] Enabled justification requirement
- [ ] Set up approval workflows
- [ ] Assigned approvers
- [ ] Saved all changes

**Tips:**
- Take your time—there's no rush
- You can come back and adjust these settings later
- Start with just a few critical roles, then add more

---

## Step 4: Set Up Approval Workflows

**Time Required:** 1-2 hours  
**Difficulty:** Easy (mostly configuration)

### What You're Doing

You're setting up automated email approvals so managers can approve or deny access requests directly from their inbox, without needing to log into Azure.

### Detailed Instructions

#### 4.1 Understand Approval Levels

Based on your configuration file, you have different approval levels:

- **Level 1:** Automatic approval (for low-risk access)
- **Level 2:** Single manager approval (for standard access)
- **Level 3:** Dual approval (manager + system owner for high-risk access)
- **Level 4:** Executive approval (C-level for critical systems)

#### 4.2 Test the Approval Workflow

1. Still in Azure Portal, go to **Privileged Identity Management**
2. Click **"Azure AD roles"** in the left menu
3. Click **"My roles"** (this shows your available roles)
4. Find a role that says **"Eligible"** or **"Activate"**
5. Click **"Activate"**
6. Fill out the form:
   - **Reason:** Type why you need access (e.g., "Testing approval workflow")
   - **Duration:** Leave as default
7. Click **"Activate"** to submit

**What happens next:**
- If approval is required, the system sends an email to the approver
- The approver clicks a link in the email and can approve or deny
- If approved, you get access immediately
- If denied, you get a notification explaining why

#### 4.3 Train Your Approvers

Send your approvers this simple guide:

**For Approvers - How to Approve Access Requests:**

1. You receive an email with subject like "Request to activate [Role Name]"
2. Open the email
3. You'll see information about who is requesting access and why
4. Click the blue button that says **"Approve"** or **"Deny"**
5. That's it! No need to log into any special system.

**Quick Reference:**
- ✅ **Approve** if the person needs access and the reason makes sense
- ❌ **Deny** if the request seems suspicious or unnecessary
- You can also add comments before approving or denying

### Checklist for Step 4

- [ ] Understood the different approval levels
- [ ] Tested the activation process for at least one role
- [ ] Received test approval email
- [ ] Sent training materials to approvers
- [ ] Approvers understand how to use the email approval system

---

## Step 5: Create Power BI Dashboards

**Time Required:** 3-4 hours  
**Difficulty:** Moderate (visual drag-and-drop interface)

### What You're Doing

You're creating visual dashboards so executives and managers can see at a glance:
- Who has privileged access
- How many access requests are pending
- Whether you're meeting compliance requirements
- Any security issues

### Detailed Instructions

#### 5.1 Access Power BI

1. Open your web browser
2. Go to https://app.powerbi.com
3. Sign in with your work account (usually the same as your Azure account)
4. You should see the Power BI home page

#### 5.2 Create a Workspace

1. In the left sidebar, click **"Workspaces"**
2. Click the **"+" Create a workspace"** button (in the top right)
3. Fill out the form:
   - **Workspace name:** "PIM Solution Reporting" (or your preferred name)
   - **Description:** "Privileged access management reporting and dashboards"
   - Leave other settings as default
4. Click **"Save"**

**What this is:** A workspace is like a shared folder where you'll store your reports and dashboards.

#### 5.3 Install Power BI Desktop

You'll need Power BI Desktop (a free desktop app) to create reports:

1. In Power BI, click your profile icon (top right)
2. Select **"Download"** → **"Power BI Desktop"**
3. Run the installer when it downloads
4. Once installed, open Power BI Desktop

#### 5.4 Connect to Azure Active Directory Data

1. In Power BI Desktop, click **"Get Data"** button (top left)
2. Search for **"Azure Active Directory"**
3. Select it and click **"Connect"**
4. You'll be asked to sign in—use your Azure account
5. You'll see a list of tables you can import—select:
   - AuditLogs
   - SigninLogs
6. Click **"Load"**

**What this does:** This pulls data from your Azure AD about who's accessing what.

#### 5.5 Create Your First Dashboard

Now you'll create a simple executive dashboard:

1. In Power BI Desktop, look at the right side—you'll see fields from your data
2. From the **"AuditLogs"** table, drag these fields to create visuals:
   - **"TimeGenerated"** → This becomes your time axis
   - **"UserPrincipalName"** → This shows who accessed what
   - **"OperationName"** → This shows what they did

**Creating a visual:**
- Drag **"TimeGenerated"** to the canvas—Power BI creates a date picker
- Drag **"OperationName"** to the visual—now you see which operations were performed
- Drag **"UserPrincipalName"** to the visual—now you see which users

**Tips:**
- You can drag fields around to arrange them
- Click on any visual to resize it by dragging the corners
- Use the **"+ New visual"** button to add more charts

#### 5.6 Publish Your Dashboard

1. Click the **"Publish"** button (top right)
2. Select the workspace you created earlier
3. Click **"Publish"**
4. Wait for "Success!" message

#### 5.7 Share the Dashboard

1. Go back to Power BI in your browser
2. You should see your workspace with your new report
3. Click on your report to open it
4. Click **"Share"** button (top right)
5. Enter email addresses of people who should see this
6. Check **"Send email notification to recipients"**
7. Click **"Share"**

### Checklist for Step 5

- [ ] Created Power BI workspace
- [ ] Installed Power BI Desktop
- [ ] Connected to Azure AD data
- [ ] Created at least one dashboard
- [ ] Published dashboard to Power BI service
- [ ] Shared dashboard with key stakeholders

**Don't Worry If:**
- Your first dashboard looks simple—that's fine! You can always improve it
- You're not sure about all the data—you can add more charts later
- You make mistakes—you can always edit and republish

---

## Step 6: Train Your Users

**Time Required:** 2-3 hours  
**Difficulty:** Easy (mostly presenting and documentation)

### What You're Doing

You're teaching people how to use the new system so they know how to request access when they need it.

### Training Materials You Need

#### 6.1 Create a Simple User Guide

Here's a template you can use and customize:

**📍 QUICK START GUIDE: Requesting Privileged Access**

**When you need access to a system:**
1. Go to https://portal.azure.com and sign in
2. Search for "Privileged Identity Management"
3. Click "My roles"
4. Find the role you need and click "Activate"
5. Fill out the form:
   - Why do you need access?
   - How long do you need it for?
6. Click "Activate"
7. Wait for approval (you'll get an email)
8. Once approved, your access is active!

**Common Questions:**
- **Q: How long until I get approved?** A: Usually within a few hours
- **Q: What if I'm denied?** A: Contact your manager or IT
- **Q: Can I request access for longer than 4 hours?** A: Yes, but it requires special approval

#### 6.2 Conduct Training Sessions

**Schedule 30-60 minute sessions for different groups:**

**Session 1: End Users** (people who will request access)
- How to request access
- How to check if access was approved
- What to do if access is denied
- Common mistakes to avoid

**Session 2: Approvers** (managers who approve requests)
- How to review requests
- How to approve or deny from email
- What to look for when approving
- How to add comments

**Session 3: Administrators** (IT staff who manage the system)
- How to view all access
- How to manually revoke access if needed
- How to troubleshoot issues
- How to run reports

### Checklist for Step 6

- [ ] Created user guide for end users
- [ ] Created approval guide for managers
- [ ] Scheduled training sessions
- [ ] Conducted end user training (minimum 10 users)
- [ ] Conducted approver training (all approvers)
- [ ] Conducted administrator training (IT staff)
- [ ] Collected feedback and answered questions

---

## Step 7: Go Live and Monitor

**Time Required:** Ongoing  
**Difficulty:** Easy (mostly monitoring and responding)

### What You're Doing

You're launching the system for everyone to use and making sure it's working well.

### Phase 1: Soft Launch (Week 1)

**Steps:**
1. Enable PIM for a small pilot group (10-20 users)
2. Have them use it for their normal work
3. Monitor for issues daily
4. Gather feedback at end of week
5. Adjust as needed

**What to Monitor:**
- Are people able to request access successfully?
- Are approvers responding in time?
- Are there any errors or technical issues?
- What feedback are users giving?

### Phase 2: Department Rollout (Weeks 2-3)

**Steps:**
1. Enable PIM for IT department
2. Enable PIM for security team
3. Monitor closely
4. Address any issues immediately
5. Gradually add more departments

### Phase 3: Full Organization (Week 4)

**Steps:**
1. Enable PIM for remaining departments
2. Monitor system performance
3. Continue gathering feedback
4. Make final adjustments

### Daily Monitoring Checklist

**Every Day (5 minutes):**
- [ ] Check for any security alerts
- [ ] Review pending access requests
- [ ] Check if anyone is reporting issues
- [ ] Verify system is running normally

**Every Week (30 minutes):**
- [ ] Review compliance metrics
- [ ] Check Power BI dashboards
- [ ] Review user feedback
- [ ] Plan improvements

**Every Month (2 hours):**
- [ ] Review all access granted in past month
- [ ] Run compliance reports
- [ ] Update documentation
- [ ] Train new users or approvers

### Checklist for Step 7

- [ ] Conducted soft launch with pilot group
- [ ] Completed department rollout
- [ ] Enabled for full organization
- [ ] Established daily monitoring routine
- [ ] Set up weekly review process
- [ ] Plan monthly reports and audits

---

## Troubleshooting

### Common Issues and Solutions

#### Issue: "Scripts cannot be run because they're disabled"

**Solution:**
1. Open PowerShell as Administrator
2. Type: `Set-ExecutionPolicy RemoteSigned`
3. Press Enter
4. Type Y and press Enter
5. Try running the scripts again

#### Issue: Can't connect to Azure

**Solution:**
1. Check your internet connection
2. Try signing out and back into Azure Portal
3. Clear your browser cache
4. Try a different browser

#### Issue: PowerShell command not found

**Solution:**
1. Make sure you opened PowerShell (not Command Prompt)
2. Make sure you're in the correct folder
3. Type `cd "C:\Github\Azure PIM Solution\scripts"` again
4. Make sure you're typing the command exactly as shown

#### Issue: Configuration file error

**Solution:**
1. Open the config file
2. Check for missing commas between entries
3. Make sure all text is inside quotes
4. Make sure you didn't accidentally delete any brackets { } or [ ]
5. Use a JSON validator online to check for errors

#### Issue: Someone didn't get approval email

**Solution:**
1. Check their spam folder
2. Verify their email address is correct in Azure AD
3. Make sure approver permissions are set correctly
4. Try resending the request

### When to Ask for Help

**Contact your IT team if:**
- Scripts fail with technical errors you can't understand
- Azure Portal is not accessible
- Users cannot access systems after requesting
- You see security alerts you don't understand

**Contact the solution author (adrian207@gmail.com) if:**
- Configuration file won't validate
- Scripts produce unexpected results
- You need clarification on documentation

---

## Final Checklist

### Pre-Launch Checklist

- [ ] Configuration file completed
- [ ] Automation scripts run successfully
- [ ] Azure Portal PIM roles configured
- [ ] Approval workflows tested
- [ ] At least one Power BI dashboard created
- [ ] Users trained (minimum 10 users)
- [ ] Approvers trained
- [ ] Monitoring plan in place
- [ ] Support process defined

### Post-Launch Checklist (After 1 Month)

- [ ] All users are successfully requesting access
- [ ] Approvers are responding within SLA
- [ ] No major security incidents
- [ ] Compliance reports generated successfully
- [ ] Dashboard is being used by management
- [ ] Feedback collected from users
- [ ] Improvements identified and planned

---

## Congratulations! 🎉

You've successfully implemented the Azure PIM Solution! You should be proud—this is a complex system that will significantly improve your organization's security and compliance.

### What You've Accomplished

✅ Automated privileged access management  
✅ Established compliance with major frameworks  
✅ Created real-time monitoring and reporting  
✅ Built a secure, scalable solution  
✅ Trained your organization on best practices  

### Ongoing Maintenance

Remember:
- Monitor the system daily (just 5 minutes!)
- Review reports weekly
- Update roles and approvers as your organization changes
- Keep documentation up to date

### Getting Help

- **Documentation:** See `/docs` folder for detailed technical docs
- **Scripts:** See `scripts/README-SCRIPTS.md` for script help
- **Author:** adrian207@gmail.com

---

**Last Updated:** December 2024  
**Author:** Adrian Johnson  
**Email:** adrian207@gmail.com

