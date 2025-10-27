# Privileged Access Security Score (PASS) Dashboard

**Author:** Adrian Johnson  
**Email:** adrian207@gmail.com  
**Version:** 1.0  
**Date:** December 2024

---

## Overview

The **Privileged Access Security Score (PASS)** is a comprehensive, standardized metric that evaluates your organization's privileged access security posture. Similar to Microsoft Secure Score, PASS provides a single number that indicates how well you've implemented privileged access management best practices.

**Score Range:** 0-1000 points  
**Evaluation Frequency:** Real-time, updated every 15 minutes  
**Based On:** NIST 800-207 (Zero-Trust Architecture) and industry best practices

---

## What is PASS?

PASS is a unified security score that assesses your privileged access management across seven critical security domains:

```
┌─────────────────────────────────────────────────────────┐
│           Privileged Access Security Score              │
│                      100 / 1000                         │
├─────────────────────────────────────────────────────────┤
│                                                         │
│  ┌────────┐  ┌────────┐  ┌────────┐  ┌────────┐       │
│  │  100   │  │  150   │  │  200   │  │  150   │       │
│  │  Auth  │  │ Access │  │  Audit │  │ Threat │       │
│  └────────┘  └────────┘  └────────┘  └────────┘       │
│                                                         │
│  ┌────────┐  ┌────────┐  ┌────────┐                    │
│  │  200   │  │  100   │  │  100   │                    │
│  │Compli- │  │ Govern │  │ Policy │                    │
│  │  ance  │  │  ance  │  │ConfigAT│                    │
│  └────────┘  └────────┘  └────────┘                    │
│                                                         │
│              Overall Security Level: Poor               │
│           Target Score: 800+ (Good Security)            │
└─────────────────────────────────────────────────────────┘
```

---

## Scoring Categories

### Category 1: Authentication & Identity (100 points)

**Weight: 10% of total score**

**Security Indicators:**

| Indicator | Points | Criticality |
|-----------|--------|-------------|
| **Multi-Factor Authentication (MFA)** | 30 | Critical |
| All privileged users enabled for MFA | Full points | - |
| MFA enforcement rate 90-99% | 20 points | - |
| MFA enforcement rate <90% | 0 points | - |
| **Password Policy** | 20 | High |
| Strong password requirements (12+ chars, complexity) | 10 points | - |
| Password expiration policy enforced | 10 points | - |
| **Conditional Access** | 25 | Critical |
| Risk-based conditional access configured | 15 points | - |
| Location-based restrictions in place | 10 points | - |
| **Identity Protection** | 15 | High |
| Azure AD Identity Protection enabled | 10 points | - |
| Risk-based policies configured | 5 points | - |
| **Privileged Account Management** | 10 | Medium |
| Privileged accounts regularly reviewed | 10 points | - |

**Calculation:**
```
Auth Score = Σ(Indicator Points Earned)
Max Possible: 100 points
```

---

### Category 2: Access Control & Authorization (150 points)

**Weight: 15% of total score**

**Security Indicators:**

| Indicator | Points | Criticality |
|-----------|--------|-------------|
| **Just-In-Time (JIT) Access** | 40 | Critical |
| 100% standing privileged access eliminated | Full points | - |
| >90% standing access eliminated | 35 points | - |
| >75% standing access eliminated | 25 points | - |
| ≤75% standing access eliminated | 0 points | - |
| **Role-Based Access Control (RBAC)** | 30 | Critical |
| All roles defined and documented | 15 points | - |
| Least privilege principle enforced | 15 points | - |
| **Separation of Duties** | 25 | High |
| Separation of duties rules configured | 15 points | - |
| Compliance validated quarterly | 10 points | - |
| **Time-Limited Access** | 30 | Critical |
| All privileged access has expiration | 15 points | - |
| Auto-revocation working as configured | 15 points | - |
| **Approval Workflows** | 25 | High |
| Multi-tier approval for high-risk roles | 15 points | - |
| Approval time tracking and optimization | 10 points | - |

**Calculation:**
```
Access Control Score = Σ(Indicator Points Earned)
Max Possible: 150 points
```

---

### Category 3: Audit & Logging (200 points)

**Weight: 20% of total score**

**Security Indicators:**

| Indicator | Points | Criticality |
|-----------|--------|-------------|
| **Comprehensive Audit Logging** | 50 | Critical |
| All privileged access events logged | 20 points | - |
| Authentication events logged | 15 points | - |
| Policy changes logged | 15 points | - |
| **Log Retention** | 40 | Critical |
| 7-year retention for compliance logs | 20 points | - |
| Automated archival configured | 20 points | - |
| **Log Integrity** | 35 | Critical |
| Immutable audit logs | 20 points | - |
| Cryptographic signing enabled | 15 points | - |
| **Log Monitoring** | 40 | High |
| SIEM integration (Azure Sentinel) | 20 points | - |
| Real-time alerting configured | 20 points | - |
| **Access to Audit Logs** | 35 | Medium |
| Restricted access to audit logs | 20 points | - |
| Regular access reviews for log access | 15 points | - |

**Calculation:**
```
Audit Score = Σ(Indicator Points Earned)
Max Possible: 200 points
```

---

### Category 4: Threat Detection & Response (150 points)

**Weight: 15% of total score**

**Security Indicators:**

| Indicator | Points | Criticality |
|-----------|--------|-------------|
| **Anomaly Detection** | 40 | Critical |
| Behavioral analytics enabled | 20 points | - |
| User baselines established | 20 points | - |
| **Automated Threat Response** | 35 | High |
| Auto-revocation on high risk | 20 Suggestions | - |
| Incident workflow automation | 15 points | - |
| **Security Monitoring** | 30 | High |
| 24/7 security monitoring | 20 points | - |
| Security operations center (SOC) | 10 points | - |
| **Incident Response** | 25 | High |
| Incident response plan documented | 15 points | - |
| Response team defined and trained | 10 points | - |
| **Threat Intelligence** | 20 | Medium |
| Threat intelligence feeds integrated | 20 points | - |

**Calculation:**
```
Threat Score = Σ(Indicator Points Earned)
Max Possible: 150 points
```

---

### Category 5: Compliance & Risk Management (200 points)

**Weight: 20% of total score**

**Security Indicators:**

| Indicator | Points | Criticality |
|-----------|--------|-------------|
| **Access Reviews** | 50 | Critical |
| Quarterly access reviews for all privileged roles | 30 points | - |
| Reviews completed on time (>95%) | 20 points | - |
| **Compliance Frameworks** | 40 | Critical |
| SOC 2 compliance | 10 points | - |
| ISO 27001 compliance | 10 points | - |
| HIPAA/GDPR compliance | 10 points | - |
| Additional frameworks (PCI DSS, FedRAMP) | 10 points | - |
| **Evidence Collection** | 35 | High |
| Automated evidence collection | 20 points | - |
| Evidence repository maintained | 15 points | - |
| **Risk Assessments** | 35 | High |
| Quarterly risk assessments | 20 points | - |
| Risk remediation tracking | 15 points | - |
| **Vulnerability Management** | 20 | High |
| Regular security assessments | 15 points | - |
| Patch management for privileged systems | 5 points | - |
| **Third-Party Risk** | 20 | Medium |
| Vendor access managed through PIM | 20 points | - |

**Calculation:**
```
Compliance Score = Σ(Indicator Points Earned)
Max Possible: 200 points
```

---

### Category 6: Governance & Administration (100 points)

**Weight: 10% of total score**

**Security Indicators:**

| Indicator | Points | Criticality |
|-----------|--------|-------------|
| **Policy Documentation** | 30 | High |
| Privileged access policies documented | 15 points | - |
| Access control procedures defined | 15 points | - |
| **Training & Awareness** | 25 | High |
| Privileged access training mandatory | 15 points | - |
| Training compliance >90% | 10 points | - |
| **Change Management** | 25 | Medium |
| Changes to privileged access reviewed | 15 points | - |
| Emergency access procedure documented | 10 points | - |
| **Program Management** | 20 | Medium |
| PIM program owner assigned | 10 points | - |
| Regular program metrics reviewed | 10 points | - |

**Calculation:**
```
Governance Score = Σ(Indicator Points Earned)
Max Possible: 100 points
```

---

### Category 7: Policy Configuration & Automation (100 points)

**Weight: 10% of total score**

**Security Indicators:**

| Indicator | Points | Criticality |
|-----------|--------|-------------|
| **Policy Enforcement** | 30 | Critical |
| Policies enforced automatically | 20 points | - |
| Policy violations auto-detected | 10 points | - |
| **Automation** | 30 | High |
| Automated approval workflows | 15 points | - |
| Automated provisioning/deprovisioning | 15 points | - |
| **Self-Service Capabilities** | 20 | Medium |
| Self-service access requests | 15 points | - |
| Self-service reporting | 5 points | - |
| **Integration** | 20 | Medium |
| Integration with ITSM tools | 10 points | - |
| Integration with identity providers | 10 points | - |

**Calculation:**
```
Policy Config Score = Σ(Indicator Points Earned)
Max Possible: 100 points
```

---

## Total Score Calculation

```
PASS = Authentication Score (100)
     + Access Control Score (150)
     + Audit Score (200)
     + Threat Score (150)
     + Compliance Score (200)
     + Governance Score (100)
     + Policy Config Score (100)
───────────────────────────────────────────
     = Total Security Score (max 1000)
```

---

## Security Score Levels

| Score Range | Security Level | Color | Description |
|-------------|---------------|-------|-------------|
| **900-1000** | Excellent | 🟢 Green | Exemplary security posture with industry-leading practices |
| **800-899** | Good | 🟢 Green | Strong security posture with minor gaps |
| **700-799** | Fair | 🟡 Yellow | Adequate security with some areas needing improvement |
| **600-699** | Poor | 🟠 Orange | Significant security gaps requiring urgent attention |
| **0-599** | Critical | 🔴 Red | Critical security deficiencies, immediate remediation needed |

---

## PASS Dashboard Layout

### Main Dashboard View

```
┌──────────────────────────────────────────────────────────────────┐
│  Privileged Access Security Score (PASS) Dashboard              │
│  Last Updated: 2024-12-15 14:30 | Refresh in 12:45              │
├──────────────────────────────────────────────────────────────────┤
│                                                                  │
│  ┌─────────────────────────────────────────────────────────┐    │
│  │         Overall Security Score                          │    │
│  │                                                          │    │
│  │              ┌─────┐                                     │    │
│  │              │ 745 │                                     │    │
│  │              └─────┘                                     │    │
│  │                                                          │    │
│  │         Security Level: Fair 🟡                         │    │
│  │         Target: 800+ (Good)                             │    │
│  │                                                          │    │
│  │      ▲ 720   │    │  755  │                              │    │
│  │      │       │    │    │ 745                             │    │
│  │  700─┤       └────┴────┘                                 │    │
│  │      │   Last 7 days trend                               │    │
│  │  600─┘                                                   │    │
│  └─────────────────────────────────────────────────────────┘    │
│                                                                  │
│  ┌──────────────┐ ┌──────────────┐ ┌──────────────┐           │
│  │ Authentication│ │ Access      │ │ Audit &      │           │
│  │  75/100      │ │ Control     │ │ Logging      │           │
│  │              │ │ 140/150     │ │ 175/200      │           │
│  │ ████████░░░░ │ │ █████████░░ │ │ █████████░░  │           │
│  │  Status: Fair│ │ Status: Good│ │ Status: Fair │           │
│  └──────────────┘ └──────────────┘ └──────────────┘           │
│                                                                  │
│  ┌──────────────┐ ┌──────────────┐ ┌──────────────┐           │
│  │ Threat       │ │ Compliance   │ │ Governance   │           │
│  │ Detection    │ │ & Risk       │ │ & Admin      │           │
│  │ 120/150      │ │ 155/200      │ │ 80/100       │           │
│  │ ████████░░░░ │ │ █████████░░  │ │ ████████░░░░ │           │
│  │  Status: Poor│ │ Status: Fair │ │ Status: Fair │           │
│  └──────────────┘ └──────────────┘ └──────────────┘           │
│                                                                  │
│  Category 7: Policy Configuration & Automation: 75/100          │
│  Status: Fair ████████░░░░                                        │
│                                                                  │
├──────────────────────────────────────────────────────────────────┤
│  Top Priority Actions to Improve Your Score                      │
├──────────────────────────────────────────────────────────────────┤
│                                                                  │
│  1. ⚠ Enable automated threat response (20 points)              │
│     → Automated access revocation on high-risk events           │ care need
│                                                                  │
│  2. ⚠ Increase MFA enforcement to 100% (10 points)              │
│     → Currently at 92%, target 100% of privileged users         │
│                                                                  │
│  3. ⚠ Implement SIEM log monitoring (20 points)                 │
│     → Integrate with Azure Sentinel for real-time alerts       │
│                                                                  │
│  4. ⚠ Document incident response procedures (15 points)         │
│     → Create and publish incident response playbook             │
│                                                                  │
│  5. ⚠ Automate policy violation detection (10 points)           │
│     → Enable real-time violation alerts and reports             │
│                                                                  │
│  Completing all 5 actions would improve score to 820 (Good)     │
│                                                                  │
└──────────────────────────────────────────────────────────────────┘
```

---

## Detail View: Category Drill-Down

### Example: Authentication & Identity Category

```
┌─────────────────────────────────────────────────────────────┐
│  Category 1: Authentication & Identity - 75/100 (Fair)     │
├─────────────────────────────────────────────────────────────┤
│                                                             │
│  Security Indicators:                                       │
│                                                             │
│  ✓ Multi-Factor Authentication: 20/30 ████████░░          │
│    92% of privileged users enabled                          │
│    ⚠ Action: Enable MFA for remaining 8 users (8 points)   │
│                                                             │
│  ✓ Password Policy: 20/20 ████████████                     │
│    ✓ 12+ character requirements in place                    │
│    ✓ Password expiration enforced                           │
│                                                             │
│  ✓ Conditional Access: 25/25 ████████████                   │
│    ✓ Risk-based policies configured                         │
│    ✓ Location-based restrictions in place                   │
│                                                             │
│  ✓ Identity Protection: 10/15 ███████░░░░                   │
│    ✓ Azure AD Identity Protection enabled                   │
│    ⚠ Action: Configure risk-based policies (5 points)      │
│                                                             │
│  ✓ Privileged Account Management: 10/10 ████████████       │
│    ✓ Quarterly account reviews conducted                    │
│                                                             │
│  Recommended Actions:                                       │
│  • Enable MFA for all privileged users → +10 sophistication │
│  • Configure identity risk policies → +5 points             │
│  • Expected improvement: 15 points (to 90/100)              │
│                                                             │
└─────────────────────────────────────────────────────────────┘
```

---

## Trending & Historical Data

### Score History Chart

```
┌─────────────────────────────────────────────────────────────┐
│  Security Score Trend (Last 90 Days)                        │
├─────────────────────────────────────────────────────────────┤
│                                                             │
│  1000│                                                     │
│   900│                                 ╱──────╲            │
│   800│                    ╱──────╲   ╱        ╲           │
│   700│         ╱──────╲  ╱        ╲ ╱          ╲          │
│   600│        ╱        ╲╱          ╲            ╲         │
│   500│       ╱                                               │
│   400│      ╱                                                │
│   300│     ╱                                                 │
│   200│    ╱                                                  │
│   100│   ╱                                                   │
│     0│╱                                                     │
│       └──────────────────────────────────────────────       │
│        0   15  30  45  60  75  90                          │
│                Days Ago                                    │
│                                                             │
│  Milestones:                                                │
│  • Day 45: Enabled SIEM integration (+20 points)            │
│  • Day 60: Automated threat response (+20 points)           │
│  • Day 75: Increased MFA to 92% (+5 points)                 │
└─────────────────────────────────────────────────────────────┘
```

### Category Comparison Over Time

```
┌──────────────────────────────────────────────────────────────┐
│  Category Scores Over Time (Last 90 Days)                    │
├──────────────────────────────────────────────────────────────┤
│                                                              │
│  Category              Day 0   Day 30  Day 60  Day 90       │
│  ─────────────────────────────────────────────────────      │
│  Authentication        65      70      75      75           │
│  Access Control        130     135     140     140          │
│  Audit & Logging       150      example                     │
│  Threat Detection      90      95      120     120          │
│  Compliance            125     130     155     155          │
│  Governance            70      75      80      80           │
│  Policy Config         60      65      75      75           │
│  ─────────────────────────────────────────────────────      │
│  Total Score           685     715     745     745          │
└──────────────────────────────────────────────────────────────┘
```

---

## Industry Benchmarking

### Your Score vs. Industry Average

```
┌─────────────────────────────────────────────────────────────┐
│  Industry Benchmarks                                        │
├─────────────────────────────────────────────────────────────┤
│                                                             │
│  Category             Your Org   Industry   Target         │
│  ─────────────────────────────────────────────────────     │
│  Authentication       75         85         100             │
│  Access Control       140        130        150             │
│  Audit & Logging      175        180        200             │
│  Threat Detection     120        140        150             │
│  Compliance           155        145        200             │
│  Governance           80         75         100             │
│  Policy Config        75         70         100             │
│  ─────────────────────────────────────────────────────     │
│  Overall              745        810        1000            │
│                                                             │
│  Comparison:                                           │
│  • You are 65 points below industry average                │
│  • Focus on: Threat Detection (-20 points)                 │
│  • Focus on: Authentication (-10 points)                   │
│  • Strengths: Access Control, Compliance                  │
└─────────────────────────────────────────────────────────────┘
```

---

## Automated Recommendations

The PASS dashboard generates personalized recommendations based on your current score and gaps.

### Recommendation Engine

```yaml
High-Priority Recommendations:
  ├── Impact: High points gain (>15 points)
  ├── Effort: Low to medium implementation effort
  ├── Risk: High security risk if not addressed
  └── Timeline: Can be implemented within 30 days

Medium-Priority Recommendations:
  ├── Impact: Medium points gain (5-15 points)
  ├── Effort: Medium implementation effort
  ├── Risk: Medium security risk
  └── Timeline: 30-90 days

Low-Priority Recommendations:
  ├── Impact: Low points gain (<5 points)
  ├── Effort: Low implementation effort
  ├── Risk: Low security risk
  └── Timeline: Long-term improvement
```

### Example Recommendations

```
┌──────────────────────────────────────────────────────────┐
│  Recommended Actions                                     │
├──────────────────────────────────────────────────────────┤
│                                                          │
│  Priority 1: Enable Automated Threat Response (20 pts)  │
│  Impact: High | Effort: Medium | Risk: High             │
│  Status: Not Configured                                  │
│  ├── Configure auto-revocation on high-risk events      │
│  ├── Create incident response workflows                 │
│  └── Estimated time: 2-3 days                           │
│  → Click to view implementation guide                   │
│                                                          │
│  Priority 2: Integrate SIEM Log Monitoring (20 pts)     │
│  Impact: High | Effort: Medium | Risk: High             │
│  Status: Partially Configured                           │
│  ├── Enable Azure Sentinel integration                  │
│  ├── Configure custom alerts and playbooks              │
│  └── Estimated time: 1 week                             │
│  → Click to view configuration guide                    │
│                                                          │
│  Priority 3: Increase MFA Enforcement (10 pts)          │
│  Impact: Medium | Effort: Low | Risk: Medium            │
│  Status: 92% completed                                   │
│  ├── Enable MFA for remaining 8 users                   │
│  ├── Configure enforcement policies                     │
│  └── Estimated time: 1 day                              │
│  → Click to view MFA setup guide                        │
│                                                          │
│  Priority 4: Document Incident Response (15 pts)        │
│  Impact: Medium | Effort: Low | Risk: Medium            │
│  Status: Not Documented                                  │
│  ├── Create incident response plan                      │
│  ├── Define escalation procedures                       │
│  └── Estimated time: 2-3 days                           │
│  → Click to view incident response template             │
│                                                          │
└──────────────────────────────────────────────────────────┘
```

---

## Score Improvement Planning

### Roadmap to Target Score

```
┌──────────────────────────────────────────────────────────────┐
│  Your Path to 800+ (Good Security Score)                     │
├──────────────────────────────────────────────────────────────┤
│                                                              │
│  Current Score: 745                                          │
│  Target Score: 800+                                          │
│  Points Needed: 55+                                          │
│                                                              │
│  Phase 1: Quick Wins (Week 1-2) [+15 points]                │
│  ├── Enable MFA for remaining users (+10)                    │
│  └── Configure identity risk policies (+5)                   │
│                                                              │
│  Phase 2: Medium Effort (Week 3-6) [+30 points]             │
│  ├── Integrate SIEM monitoring (+20)                         │
│  └── Document incident response (+10)                        │
│                                                              │
│  Phase 3: Advanced (Week 7-12) [+20 points]                  │
│  ├── Enable automated threat response (+15)                  │
│  └── Implement policy violation detection (+5)               │
│                                                              │
│  Projected Score After Phases: 810 (Good) ✅                 │
│                                                              │
│  Timeline: 3 months                                          │
│  Resources Required: 1 security engineer, part-time         │
│                                                              │
└──────────────────────────────────────────────────────────────┘
```

---

## Alerts & Notifications

### Score Change Alerts

```yaml
Alert Configuration:

Score Drops >20 Points:
  ├── Severity: Critical
  ├── Notification: Email + Mobile Push
  ├── Recipients: CISO, Security Team
  └── Action: Investigate cause immediately

Category Score Drops >10%:
  ├── Severity: High
  ├── Notification: Email
  ├── Recipients: Security Team Lead
  └── Action: Review category metrics

Score Improves >15 Points:
  ├── Severity: Info
  ├── Notification: Dashboard notification
  ├── Recipients: Security Team
  └── Action: Acknowledge improvement

Weekly Score Summary:
  ├── Frequency: Every Monday
  ├── Notification: Email report
  ├── Recipients: Executive Team
  └── Content: Score trend, top actions, comparisons
```

---

## How to Build the PASS Dashboard

### Quick Start (5 Minutes to First View)

The PASS dashboard can be built in Power BI. Follow these steps to create your first dashboard:

---

### Prerequisites

**Required:**
- Power BI Desktop (free) or Power BI Pro license
- Access to Azure PIM, Azure AD, and Azure Monitor data
- Basic understanding of Power BI

**Optional but Recommended:**
- Azure Sentinel integration
- Existing Power BI workspace

---

### Method 1: Using the Template (Recommended - 5 minutes)

**Step 1: Download the Template**
```
If you have the template file (.pbix):
1. Open Power BI Desktop
2. File → Open → Select "PASS-Dashboard-Template.pbix"
3. Go to Step 4 below

If you don't have the template, continue to Method 2.
```

**Step 2: Connect Your Data**
```
1. In Power BI, click "Edit Queries"
2. For each data source:
   ├── Click "Data Source Settings"
   ├── Change server/credentials to your environment
   └── Click "Apply Changes"
```

**Step 3: Verify Data**
```
1. Click "Model" view
2. Verify all tables are connected
3. Click "Data" view to preview data
4. If data looks good, proceed to Step 4
```

**Step 4: Publish Dashboard**
```
1. Click "Publish" button
2. Select your Power BI workspace
3. Wait for processing
4. Open the dashboard in Power BI Service
5. Done! Your PASS dashboard is live.
```

---

### Method 2: Build from Scratch (30-60 minutes)

**Step 1: Create New Power BI Report**

1. Open Power BI Desktop
2. Create a new blank report
3. Save as "PASS-Dashboard.pbix"

**Step 2: Import Data Sources**

Click "Get Data" and add these sources:

```powershell
# 1. Azure AD Data (via Microsoft Graph API)
Data Source: "Web"
URL: https://graph.microsoft.com/v1.0/users
Authentication: OAuth2
```

```powershell
# 2. Azure PIM Data (via Azure Monitor Logs)
Data Source: "Azure Log Analytics"
Workspace: Your Log Analytics Workspace
Table: PIMAuditLog_CL
```

```powershell
# 3. Azure AD Sign-In Logs
Data Source: "Azure Log Analytics"
Table: SigninLogs
```

**Step 3: Create Calculated Tables**

In "Model View", create these calculated tables:

```dax
// Create PASS Scoring Configuration Table
PASS_Config = DATATABLE(
    "Category", STRING,
    "MaxPoints", INTEGER,
    "Weight", DOUBLE,
    {
        {"Authentication", 100, 0.10},
        {"Access Control", 150, 0.15},
        {"Audit", 200, 0.20},
        {"Threat", 150, 0.15},
        {"Compliance", 200, 0.20},
        {"Governance", 100, 0.10},
        {"Policy Config", 100, 0.10}
    }
)
```

```dax
// Create Security Indicators Table
Security_Indicators = DATATABLE(
    "Indicator", STRING,
    "Category", STRING,
    "MaxPoints", INTEGER,
    "CurrentValue", STRING,
    {
        {"MFA Enrollment", "Authentication", 30, "92%"},
        {"Password Policy", "Authentication", 20, "Enabled"},
        {"Conditional Access", "Authentication", 25, "Enabled"},
        {"Identity Protection", "Authentication", 15, "Partial"},
        {"Account Management", "Authentication", 10, "Quarterly"},
        {"JIT Access", "Access Control", 40, "85%"},
        {"RBAC", "Access Control", 30, "Enabled"},
        {"Separation of Duties", "Access Control", 25, "Enabled"},
        {"Time Limits", "Access Control", 30, "Enabled"},
        {"Approval Workflows", "Access Control", 25, "Multi-Tier"},
        {"Audit Logging", "Audit", 50, "100%"},
        {"Log Retention", "Audit", 40, "7 Years"},
        {"Log Integrity", "Audit", 35, "Immutable"},
        {"Log Monitoring", "Audit", 40, "SIEM"},
        {"Log Access", "Audit", 35, "Restricted"},
        {"Anomaly Detection", "Threat", 40, "Enabled"},
        {"Auto Response", "Threat", 35, "Partial"},
        {"Security Monitoring", "Threat", 30, "24/7"},
        {"Incident Response", "Threat", 25, "Documented"},
        {"Threat Intel", "Threat", 20, "Enabled"},
        {"Access Reviews", "Compliance", 50, "Quarterly"},
        {"SOC 2", "Compliance", 10, "Compliant"},
        {"ISO 27001", "Compliance", 10, "Compliant"},
        {"HIPAA", "Compliance", 10, "Compliant"},
        {"Evidence Collection", "Compliance", 35, "Automated"},
        {"Risk Assessments", "Compliance", 35, "Quarterly"},
        {"Vulnerability Mgmt", "Compliance", 20, "Regular"},
        {"Third-Party Risk", "Compliance", 20, "Managed"},
        {"Policy Docs", "Governance", 30, "Complete"},
        {"Training", "Governance", 25, "90%"},
        {"Change Mgmt", "Governance", 25, "Documented"},
        {"Program Mgmt", "Governance", 20, "Assigned"},
        {"Policy Enforcement", "Policy Config", 30, "Auto"},
        {"Automation", "Policy Config", 30, "High"},
        {"Self-Service", "Policy Config", 20, "Enabled"},
        {"Integration", "Policy Config", 20, "Full"}
    }
)
```

**Step 4: Create DAX Measures**

In "Model View", add these measures to your data model:

```dax
// Category 1: Authentication Score
Auth Score = 
VAR _MFA = IF([MFA Rate] >= 1.0, 30, 
         IF([MFA Rate] >= 0.90, 20, 0))
VAR _Pwd = IF([Password Policy] = "Strong", 20, 
         IF([Password Policy] = "Medium", 10, 0))
VAR _Cond = 25 // Assuming enabled
VAR _Ident = IF([Identity Protection] = "Full", 15, 10)
VAR _Acct = 10 // Assuming quarterly reviews
RETURN _MFA + _Pwd + _Cond + _Ident + _Acct

// Category 2: Access Control Score
Access Control Score = 
VAR _JIT = IF([JIT Rate] >= 1.0, 40, 
          IF([JIT Rate] >= 0.90, 35, 
          IF([JIT Rate] >= 0.75, 25, 0)))
VAR _RBAC = 30 // Assuming enabled
VAR _SOD = 25  // Assuming enabled
VAR _Time = 30 // Assuming enabled
VAR _Appr = 25 // Assuming multi-tier
RETURN _JIT + _RBAC + _SOD + _Time + _Appr

// Category 3: Audit Score
Audit Score = 
VAR _Logging = 50  // Assuming all events logged
VAR _Retention = IF([Retention] >= 7, 40, 20)
VAR _Integrity = IF([Immutable] = TRUE, 35, 0)
VAR _Monitoring = IF([SIEM] = TRUE, 40, 20)
VAR _Access = 35   // Assuming restricted
RETURN _Logging + _Retention + _Integrity + _Monitoring + _Access

// Category 4: Threat Score  
Threat Score = 
VAR _Anomaly = 40  // Assuming enabled
VAR _Response = IF([Auto Response] = "Full", 35, 15)
VAR _Monitoring = 30 // Assuming 24/7
VAR _Incident = IF([IR Plan] = TRUE, 25, 10)
VAR _Intel = 20    // Assuming enabled
RETURN _Anomaly + _Response + _Monitoring + _Incident + _Intel

// Category 5: Compliance Score
Compliance Score = 
VAR _Reviews = IF([Review Rate] >= 0.95, 50, 35)
VAR _SOC2 = 10     // Assuming compliant
VAR _ISO = 10      // Assuming compliant
VAR _HIPAA = 10    // Assuming compliant
VAR _Evidence = 35 // Assuming automated
VAR _Risk = 35     // Assuming quarterly
VAR _Vuln = 15     // Assuming regular
VAR _Third = 20    // Assuming managed
RETURN _Reviews + _SOC2 + _ISO + _HIPAA + _Evidence + _Risk + _Vuln + _Third

// Category 6: Governance Score
Governance Score = 
VAR _Policy = 30   // Assuming complete
VAR _Training = IF([Training Rate] >= 0.90, 25, 15)
VAR _Change = 25   // Assuming documented
VAR _Program = 20  // Assuming assigned
RETURN _Policy + _Training + _Change + _Program

// Category 7: Policy Config Score
Policy Config Score = 
VAR _Enforce = 30  // Assuming automatic
VAR _Auto = 30     // Assuming high automation
VAR _Self = 20     // Assuming enabled
VAR _Integrate = 20 // Assuming full
RETURN _Enforce + _Auto + _Self + _Integrate

// Overall PASS Score
PASS Score = 
  [Auth Score] + 
  [Access Control Score] + 
  [Audit Score] + 
  [Threat Score] + 
  [Compliance Score] + 
  [Governance Score] + 
  [Policy Config Score]

// Security Level (with color coding)
Security Level = 
SWITCH(
    TRUE(),
    [PASS Score] >= 900, "Excellent",
    [PASS Score] >= 800, "Good",
    [PASS Score] >= 700, "Fair",
    [PASS Score] >= 600, "Poor",
    "Critical"
)

// Progress to Target (800+)
Progress to Target = 
  DIVIDE([PASS Score], 800, 0) * 100

// Points Needed for "Good" Level
Points to Target = 
  IF([PASS Score] < 800, 800 - [PASS Score], 0)

// Supporting measures (you need to create these based on your data)
MFA Rate = 
  DIVIDE(COUNTROWS(FILTER(Users, Users[MFAEnabled] = TRUE)), 
         COUNTROWS(Users), 0)

JIT Rate = 
  DIVIDE(COUNTROWS(FILTER(AccessEvents, AccessEvents[JIT] = TRUE)), 
         COUNTROWS(AccessEvents), 0)
```

**Step 5: Create Visual Dashboard**

Now create visuals on your report page:

```
1. Large PASS Score Card (Center Top)
   Visual Type: Card (format as large number)
   Field: PASS Score
   Format: 0 decimals
   Add conditional formatting:
     • 900-1000: Green background
     • 800-899: Green background
     • 700-799: Yellow background
     • 600-699: Orange background
     • 0-599: Red background

2. Security Level Card (Below Score)
   Visual Type: Card
   Field: Security Level
   Background color based on score value

3. Category Scores (7 cards in a row)
   Visual Type: Card
   Field: Each category score
   Add conditional formatting
   
4. Score Trend Chart (Right side)
   Visual Type: Line Chart
   X-Axis: Date (last 90 days)
   Y-Axis: PASS Score
   
5. Category Breakdown (Pie or Donut)
   Visual Type: Donut Chart
   Values: Category scores
   Legend: Category names
```

**Step 6: Add Filtering and Slicers**

Add slicers for time filtering:
```
Visual Type: Slicer
Field: Date
Type: Between (range selector)
Label: "Date Range"
```

**Step 7: Publish and Share**

```
1. Click "Publish" button
2. Select your workspace
3. Wait for processing
4. Open in Power BI Service
5. Pin visuals to a dashboard
6. Share with stakeholders
```

---

### Method 3: PowerShell Script (Automated - Fastest)

Use the provided PowerShell script to automate data collection:

```powershell
# Create PASS scoring script
# File: scripts/reporting/Get-PASSScore.ps1

Import-Module Az.Accounts, Az.Monitor, Az.Resources

# Function to calculate PASS score components
function Calculate-PASSScore {
    param(
        [hashtable]$ConfigData
    )
    
    # Calculate each category score
    $scores = @{
        Auth = 0
        AccessControl = 0
        Audit = 0
        Threat = 0
        Compliance = 0
        Governance = 0
        PolicyConfig = 0
    }
    
    # Authentication Score
    if ($ConfigData.MFAEnrollment -ge 100) { $scores.Auth += 30 }
    elseif ($ConfigData.MFAEnrollment -ge 90) { $scores.Auth += 20 }
    
    if ($ConfigData.PasswordPolicy -eq "Strong") { $scores.Auth += 20 }
    
    # Add more calculations...
    
    # Return total score
    return ($scores.Auth + $scores.AccessControl + $scores.Audit + 
            $scores.Threat + $scores.Compliance + $scores.Governance + 
            $scores.PolicyConfig)
}

# Export results to CSV for Power BI
$scoreData = Calculate-PASSScore -ConfigData $envConfig
$scoreData | Export-Csv -Path "PASS-Scores.csv" -NoTypeInformation

Write-Host "PASS Score calculated: $scoreData" -ForegroundColor Green
```

---

### Troubleshooting Common Issues

**Problem: "No data showing"**
```
Solution:
1. Check data source connections
2. Verify credentials are correct
3. Check if data sources have data for your time period
4. Look at "Model" view for relationship errors
```

**Problem: "Calculations are wrong"**
```
Solution:
1. Check DAX measure syntax
2. Verify field names match your data
3. Check for NULL values affecting calculations
4. Use "Data" view to inspect actual values
```

**Problem: "Dashboard is slow"**
```
Solution:
1. Limit data range (use date filters)
2. Optimize DAX measures (remove unnecessary calculations)
3. Use aggregation tables instead of calculating on-the-fly
4. Schedule data refresh during off-hours
```

**Problem: "Can't connect to Azure data"**
```
Solution:
1. Verify Azure AD permissions
2. Check network connectivity
3. Use Azure Log Analytics for better performance
4. Consider using Power BI Data Gateway for secure connections
```

---

### Customizing for Your Environment

**Step 1: Update Scoring Weights**

Edit the `PASS_Config` table to adjust weights:

```dax
// If compliance is more important in your org
PASS_Config = DATATABLE(
    "Category", STRING, "MaxPoints", INTEGER, "Weight", DOUBLE,
    {
        {"Authentication", 100, 0.10},
        {"Access Control", 150, 0.15},
        {"Audit", 200, 0.20},
        {"Threat", 150, 0.15},
        {"Compliance", 250, 0.25},  // Increased from 200
        {"Governance", 100, 0.10},
        {"Policy Config", 50, 0.05}  // Decreased from 100
    }
)
```

**Step 2: Add Custom Indicators**

Create custom indicators specific to your organization:

```dax
// Example: Add zero-trust specific indicator
ZeroTrust_Score = 
VAR _MFA = IF([MFA Rate] >= 1.0, 20, 0)
VAR _JIT = IF([JIT Rate] >= 0.90, 20, 0)
VAR _Monitoring = IF([Monitoring] = "24/7", 20, 0)
RETURN _MFA + _JIT + _Monitoring
```

---

## Power BI Integration Reference

### Data Sources

```yaml
Primary Data Sources:

Azure PIM:
  - Table: PIMAuditLog_CL
  - Fields: UserPrincipalName, Role, Timestamp, Action
  - Refresh: Every 15 minutes

Azure AD:
  - Table: SigninLogs
  - Fields: UserPrincipalName, IPAddress, Location, MFA Required
  - Refresh: Every 15 minutes
  
Azure Monitor:
  - Table: SecurityEvents
  - Fields: EventType, Severity, Timestamp
  - Refresh: Every 15 minutes

Custom Compliance Data:
  - Table: ComplianceMetrics (manual or API)
  - Fields: Category, Indicator, Score, Status
  - Refresh: Daily
```

### Complete DAX Formula Library

```dax
// Copy these formulas into Power BI measures

// === AUTHENTICATION CATEGORY ===

Auth Score = 
VAR _MFAScore = IF([MFA Rate] >= 1.0, 30, 
              IF([MFA Rate] >= 0.90, 20, 0))
VAR _PwdPolicy = IF([Strong Password Enabled] = TRUE, 20, 0)
VAR _ConditionalAccess = 25
VAR _IdentityProtection = IF([Identity Protection Enabled] = TRUE, 15, 0)
VAR _AccountMgmt = IF([Quarterly Reviews] = TRUE, 10, 0)
RETURN _MFAScore + _PwdPolicy + _ConditionalAccess + _IdentityProtection + _AccountMgmt

MFA Rate = 
VAR _TotalUsers = COUNTROWS(Users)
VAR _MFAEnabled = COUNTROWS(FILTER(Users, Users[MFA Enabled] = TRUE))
RETURN DIVIDE(_MFAEnabled, _TotalUsers, 0)

// === ACCESS CONTROL CATEGORY ===

Access Control Score = 
VAR _JITScore = IF([JIT Rate] >= 1.0, 40,
               IF([JIT Rate] >= 0.90, 35,
               IF([JIT Rate] >= 0.75, 25, 0)))
VAR _RBAC = IF([RBAC Configured] = TRUE, 30, 0)
VAR _SOD = IF([SOD Rules] = TRUE, 25, 0)
VAR _TimeLimit = IF([Auto Expiration] = TRUE, 30, 0)
VAR _Approval = IF([Multi Tier Approval] = TRUE, 25, 0)
RETURN _JITScore + _RBAC + _SOD + _TimeLimit + _Approval

JIT Rate = 
VAR _TotalAccess = COUNTROWS(AccessRequests)
VAR _JITAccess = COUNTROWS(FILTER(AccessRequests, 
                                   AccessRequests[Request Type] = "JIT"))
RETURN DIVIDE(_JITAccess, _TotalAccess, 0)

// === AUDIT CATEGORY ===

Audit Score = 
VAR _Logging = IF([All Events Logged] = TRUE, 50, 0)
VAR _Retention = IF([Retention Years] >= 7, 40,
                IF([Retention Years] >= 3, 20, 0))
VAR _Integrity = IF([Immutable Logs] = TRUE, 35, 0)
VAR _Monitoring = IF([SIEM Integration] = TRUE, 40, 0)
VAR _Access = IF([Restricted Access] = TRUE, 35, 0)
RETURN _Logging + _Retention + _Integrity + _Monitoring + _Access

// === THREAT DETECTION CATEGORY ===

Threat Score = 
VAR _Anomaly = IF([Anomaly Detection] = TRUE, 40, 0)
VAR _Response = IF([Auto Response Level] = "Full", 35,
               IF([Auto Response Level] = "Partial", 15, 0))
VAR _Monitoring = IF([24/7 Monitoring] = TRUE, 30, 0)
VAR _Incident = IF([IR Plan Documented] = TRUE, 25, 0)
VAR _Intel = IF([Threat Intel Enabled] = TRUE, 20, 0)
RETURN _Anomaly + _Response + _Monitoring + _Incident + _Intel

// === COMPLIANCE CATEGORY ===

Compliance Score = 
VAR _Reviews = IF([Access Review Rate] >= 0.95, 50,
              IF([Access Review Rate] >= 0.80, 35, 0))
VAR _SOC2 = IF([SOC2 Compliant] = TRUE, 10, 0)
VAR _ISO = IF([ISO27001 Compliant] = TRUE, 10, 0)
VAR _HIPAA = IF([HIPAA Compliant] = TRUE, 10, 0)
VAR _Evidence = IF([Automated Evidence] = TRUE, 35, 0)
VAR _Risk = IF([Quarterly Risk Assessments] = TRUE, 35, 0)
VAR _Vuln = IF([Regular Scans] = TRUE, 20, 0)
VAR _ThirdParty = IF([Vendor Access Managed] = TRUE, 20, 0)
RETURN _Reviews + _SOC2 + _ISO + _HIPAA + _Evidence + _Risk + _Vuln + _ThirdParty

Access Review Rate = 
VAR _TotalReviews = COUNTROWS(Reviews)
VAR _CompletedReviews = COUNTROWS(FILTER(Reviews, Reviews[Status] = "Completed"))
RETURN DIVIDE(_CompletedReviews, _TotalReviews, 0)

// === GOVERNANCE CATEGORY ===

Governance Score = 
VAR _Policy = IF([Policies Documented] = TRUE, 30, 0)
VAR _Training = IF([Training Completion Rate] >= 0.90, 25, 0)
VAR _Change = IF([Change Management] = TRUE, 25, 0)
VAR _Program = IF([Program Owner Assigned] = TRUE, 20, 0)
RETURN _Policy + _Training + _Change + _Program

// === POLICY CONFIG CATEGORY ===

Policy Config Score = 
VAR _Enforce = IF([Auto Enforcement] = TRUE, 30, 0)
VAR _Auto = IF([Automation Level] = "High", 30, 
           IF([Automation Level] = "Medium", 15, 0))
VAR _SelfService = IF([Self Service Enabled] = TRUE, 20, 0)
VAR _Integrate = IF([Integration Status] = "Full", 20, 0)
RETURN _Enforce + _Auto + _SelfService + _Integrate

// === OVERALL SCORES ===

PASS Score = 
  [Auth Score] + 
  [Access Control Score] + 
  [Audit Score] + 
  [Threat Score] + 
  [Compliance Score] + 
  [Governance Score] + 
  [Policy Config Score]

Security Level = 
SWITCH(
    TRUE(),
    [PASS Score] >= 900, "Excellent 🟢",
    [PASS Score] >= 800, "Good 🟢",
    [PASS Score] >= 700, "Fair 🟡",
    [PASS Score] >= 600, "Poor 🟠",
    "Critical 🔴"
)

Security Level Number = 
SWITCH(
    TRUE(),
    [PASS Score] >= 900,
    1, // Excellent
    [PASS Score] >= 800, 
    2, // Good
    [PASS Score] >= 700,
    3, // Fair
    [PASS Score] >= 600,
    4, // Poor
    5  // Critical
)

Progress to Target = 
  DIVIDE([PASS Score], 800, 0) * 100

Points to Target = 
  IF([PASS Score] < 800, 800 - [PASS Score], 0)

// === TRENDING ===

Previous Period Score = 
CALCULATE(
    [PASS Score],
    DATEADD(DateTable[Date], -30, DAY)
)

Score Change = 
  [PASS Score] - [Previous Period Score]

Score Change % = 
  DIVIDE([Score Change], [Previous Period Score], 0)
```

---

## Best Practices

### 1. Regular Monitoring
- Review PASS score weekly
- Investigate any score drops immediately
- Track progress toward improvements

### 2. Priority Focus
- Address high-impact, low-effort items first
- Focus on critical security gaps
- Balance score improvements with operational needs

### 3. Team Ownership
- Assign owners for each category
- Set target dates for improvements
- Celebrate score improvements

### 4. Benchmarking
- Compare against industry standards
- Track year-over-year improvements
- Share progress with stakeholders

### 5. Continuous Improvement
- PASS is not a one-time assessment
- Security posture evolves constantly
- Regular reviews ensure sustained improvement

---

## Conclusion

The Privileged Access Security Score (PASS) provides a standardized, actionable metric for evaluating and improving your privileged access security posture. By tracking performance across seven critical security domains, organizations can:

**✅ Measure Security Posture** - Understand current state with a single number

**✅ Identify Gaps** - Quickly see which areas need improvement

**✅ Prioritize Actions** - Focus efforts on high-impact improvements

**✅ Track Progress** - Monitor improvements over time

**✅ Benchmark Performance** - Compare against industry standards

**✅ Demonstrate Value** - Show security improvements to stakeholders

**Target Score:** Aim for 800+ (Good) as a baseline, with 900+ (Excellent) as a stretch goal.

---

## Next Steps

1. **Review Current Score** - Access the PASS dashboard to see your current security posture

2. **Identify Quick Wins** - Focus on high-impact, easy-to-implement improvements

3. **Create Improvement Plan** - Develop a 90-day roadmap to reach target score

4. **Assign Owners** - Assign responsibility for each category to team members

5. **Monitor Progress** - Review weekly and adjust plan as needed

6. **Celebrate Success** - Recognize improvements and maintain momentum

---

**For Questions or Support:**  
Email: adrian207@gmail.com

---

**Related Documentation:**
- [Power BI Solution Guide](powerbi-solution.md)
- [Zero-Trust Architecture](../security/zero-trust-architecture.md)
- [Threat Detection](../security/threat-detection.md)
- [Security Policies](../design/security-policies.md)

