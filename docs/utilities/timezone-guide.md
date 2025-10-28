# Timezone Configuration Guide

**Author:** Adrian Johnson  
**Email:** adrian207@gmail.com  
**Version:** 1.0  
**Date:** December 2024

---

## Overview

The Azure PIM Solution uses a **best-practice timezone approach**:
- ✅ **Store everything in UTC** (logs, audit trails, database)
- ✅ **Display in local timezone** (reports, dashboards, user interface)

**Why?** This prevents timezone confusion, ensures accurate audit trails, and provides a better user experience.

---

## Quick Start

### 1. Configure Your Timezone

Edit `config/environment-config.json`:

```json
{
  "display": {
    "timezone": {
      "displayTimezone": "Pacific Standard Time",
      "storageTimezone": "UTC",
      "autoDetect": false,
      "dateFormat": "yyyy-MM-dd HH:mm:ss",
      "use24HourFormat": true,
      "showTimezoneInDisplay": true
    }
  }
}
```

### 2. Use in Your Scripts

```powershell
# Import the timezone helper
Import-Module .\scripts\utilities\Timezone-Helper.ps1

# Convert UTC to display time
$utcTime = Get-Date -AsUTC
$localTime = ConvertTo-DisplayTime -UtcDateTime $utcTime

Write-Host "UTC Time: $utcTime"
Write-Host "Local Time: $localTime"
```

That's it! All timestamps will now display in your configured timezone.

---

## Configuration Options

### Display Timezone

**What it does:** Sets which timezone to use for displaying dates/times to users.

**Options:**
```json
"displayTimezone": "Pacific Standard Time"
```

**Common values:**
- `"Pacific Standard Time"` - US West Coast
- `"Eastern Standard Time"` - US East Coast
- `"Central Standard Time"` - US Central
- `"Mountain Standard Time"` - US Mountain
- `"GMT Standard Time"` - UK
- `"Central European Standard Time"` - Europe
- `"Tokyo Standard Time"` - Japan
- `"AUS Eastern Standard Time"` - Australia
- `"India Standard Time"` - India

**Get full list:**
```powershell
Get-AvailableTimezones | Format-Table
```

---

### Auto-Detect

**What it does:** Automatically uses the server's local timezone.

```json
"autoDetect": true
```

**When to use:**
- ✅ Single-user deployments
- ✅ Scripts running on your local machine
- ❌ Multi-user web applications (users in different timezones)
- ❌ Centralized servers (server timezone != user timezone)

---

### Date Format

**What it does:** Controls how dates are formatted for display.

```json
"dateFormat": "yyyy-MM-dd HH:mm:ss"
```

**Common formats:**
- `"yyyy-MM-dd HH:mm:ss"` → 2024-12-10 14:30:45
- `"MM/dd/yyyy hh:mm:ss tt"` → 12/10/2024 02:30:45 PM
- `"dd/MM/yyyy HH:mm"` → 10/12/2024 14:30
- `"yyyy-MM-ddTHH:mm:ssZ"` → 2024-12-10T14:30:45Z (ISO 8601)

---

### Show Timezone in Display

**What it does:** Adds timezone abbreviation to displayed times.

```json
"showTimezoneInDisplay": true
```

**Examples:**
- `true`: "2024-12-10 14:30:45 PST"
- `false`: "2024-12-10 14:30:45"

**Recommendation:** Keep this `true` to avoid confusion.

---

## Usage Examples

### Example 1: Display Access Logs

**Scenario:** Show access logs in user's local timezone.

```powershell
Import-Module .\scripts\utilities\Timezone-Helper.ps1

# Get access logs (stored in UTC)
$logs = Get-AzOperationalInsightsSearchResults -Query "AuditLogs | take 10"

# Create timezone helper
$tzHelper = [TimezoneHelper]::new()

# Convert each log entry
foreach ($log in $logs) {
    $displayLog = $tzHelper.ConvertEventForDisplay($log)
    
    Write-Host "User: $($displayLog.UserPrincipalName)"
    Write-Host "Time: $($displayLog.Timestamp)"  # Now in local timezone!
    Write-Host "UTC Time: $($displayLog.Timestamp_UTC)"  # Original UTC preserved
    Write-Host ""
}
```

**Output:**
```
User: john@company.com
Time: 2024-12-10 06:30:45 PST
UTC Time: 2024-12-10T14:30:45Z

User: jane@company.com
Time: 2024-12-10 08:15:22 PST
UTC Time: 2024-12-10T16:15:22Z
```

---

### Example 2: Store New Events in UTC

**Scenario:** Log a new access request (always store in UTC).

```powershell
Import-Module .\scripts\utilities\Timezone-Helper.ps1

$tzHelper = [TimezoneHelper]::new()

# User makes request at local time
$localRequestTime = Get-Date

# Convert to UTC for storage
$utcRequestTime = $tzHelper.ToStorageTime($localRequestTime)

# Store in database/log
$accessRequest = @{
    UserId = "user123"
    RequestedAt = $tzHelper.FormatForStorage($localRequestTime)  # ISO 8601 UTC
    Role = "Contributor"
    Duration = 4
}

Write-Host "Stored timestamp: $($accessRequest.RequestedAt)"
# Output: 2024-12-10T22:30:45.0000000Z (always UTC)
```

---

### Example 3: Power BI Report with Local Times

**Scenario:** Create Power BI report showing times in user's timezone.

```powershell
Import-Module .\scripts\utilities\Timezone-Helper.ps1

# Get data from Azure
$accessData = Get-AzRoleAssignment

# Create timezone helper
$tzHelper = [TimezoneHelper]::new()

# Convert all events for display
$displayData = $tzHelper.ConvertEventsForDisplay($accessData)

# Export for Power BI
$displayData | Export-Csv "access-report-local-time.csv" -NoTypeInformation

Write-Host "✅ Report exported with local times"
Write-Host "   Timezone: $($tzHelper.DisplayTimezone)"
```

---

### Example 4: Multi-Timezone Team

**Scenario:** Team members in different timezones viewing the same logs.

**Config for US West Coast user:**
```json
{
  "display": {
    "timezone": {
      "displayTimezone": "Pacific Standard Time"
    }
  }
}
```

**Config for US East Coast user:**
```json
{
  "display": {
    "timezone": {
      "displayTimezone": "Eastern Standard Time"
    }
  }
}
```

**Config for London user:**
```json
{
  "display": {
    "timezone": {
      "displayTimezone": "GMT Standard Time"
    }
  }
}
```

**Same UTC event:**
```
Stored in database: 2024-12-10T14:30:45Z
```

**Displayed to users:**
- West Coast: "2024-12-10 06:30:45 PST"
- East Coast: "2024-12-10 09:30:45 EST"
- London: "2024-12-10 14:30:45 GMT"

**Everyone sees the SAME event, just in their local time!**

---

## Integration with Existing Scripts

### Anomaly Detector

```powershell
Import-Module .\scripts\utilities\Anomaly-Detector.ps1
Import-Module .\scripts\utilities\Timezone-Helper.ps1

$detector = [AnomalyDetector]::new()
$tzHelper = [TimezoneHelper]::new()

# Detect anomalies (works with UTC)
$anomalies = $detector.DetectAnomalies($events)

# Convert for display
foreach ($anomaly in $anomalies) {
    $displayAnomaly = $tzHelper.ConvertEventForDisplay($anomaly)
    
    Write-Host "⚠️ Anomaly detected"
    Write-Host "   User: $($displayAnomaly.UserPrincipalName)"
    Write-Host "   Time: $($displayAnomaly.Timestamp)"  # Local time
    Write-Host "   Risk: $($displayAnomaly.RiskScore)"
}
```

---

### Risk Calculator

```powershell
Import-Module .\scripts\utilities\Risk-Calculator.ps1
Import-Module .\scripts\utilities\Timezone-Helper.ps1

$calculator = [RiskCalculator]::new()
$tzHelper = [TimezoneHelper]::new()

# Calculate risk (works with UTC)
$riskScore = $calculator.CalculateRiskScore($event)

# Display with local time
$displayEvent = $tzHelper.ConvertEventForDisplay($event)

Write-Host "Risk Assessment"
Write-Host "  User: $($displayEvent.UserPrincipalName)"
Write-Host "  Time: $($displayEvent.Timestamp)"  # Local time
Write-Host "  Risk: $riskScore"
Write-Host "  Category: $($calculator.GetRiskCategory($riskScore))"
```

---

## Best Practices

### ✅ DO:

1. **Always store in UTC**
   ```powershell
   $event.Timestamp = (Get-Date).ToUniversalTime().ToString("o")
   ```

2. **Convert to local only for display**
   ```powershell
   $displayTime = Format-DisplayTime -UtcDateTime $utcTime
   ```

3. **Keep original UTC in logs**
   ```powershell
   Write-Log "Event at $utcTime UTC ($localTime local)"
   ```

4. **Use ISO 8601 format for storage**
   ```powershell
   $timestamp = $utcTime.ToString("o")  # 2024-12-10T14:30:45.0000000Z
   ```

5. **Show timezone abbreviation in UI**
   ```powershell
   "2024-12-10 06:30:45 PST"  # Clear which timezone
   ```

---

### ❌ DON'T:

1. **Don't store local times in database**
   ```powershell
   # ❌ BAD
   $event.Timestamp = Get-Date  # Local time, ambiguous
   
   # ✅ GOOD
   $event.Timestamp = (Get-Date).ToUniversalTime()
   ```

2. **Don't mix timezones in calculations**
   ```powershell
   # ❌ BAD
   $diff = $localTime1 - $utcTime2  # Wrong!
   
   # ✅ GOOD
   $diff = $utcTime1 - $utcTime2  # Both UTC
   ```

3. **Don't assume server timezone = user timezone**
   ```powershell
   # ❌ BAD
   $localTime = Get-Date  # Server's timezone
   
   # ✅ GOOD
   $localTime = ConvertTo-DisplayTime -UtcDateTime $utcTime
   ```

4. **Don't forget daylight saving time**
   ```powershell
   # ✅ GOOD - TimezoneHelper handles DST automatically
   $tzHelper.ToDisplayTime($utcTime)
   ```

---

## Troubleshooting

### Issue: Times are 8 hours off

**Cause:** Mixing UTC and local times.

**Solution:** Check if you're storing local time instead of UTC:
```powershell
# Check if time is UTC
$time.Kind
# Should be: Utc

# Convert to UTC if needed
$utcTime = $time.ToUniversalTime()
```

---

### Issue: Daylight Saving Time causing issues

**Cause:** Manual timezone calculations don't account for DST.

**Solution:** Use TimezoneHelper which handles DST automatically:
```powershell
# ❌ BAD - Manual offset
$localTime = $utcTime.AddHours(-8)  # Breaks during DST

# ✅ GOOD - Automatic DST handling
$localTime = ConvertTo-DisplayTime -UtcDateTime $utcTime
```

---

### Issue: Different users see different times

**Cause:** This is expected! Each user has their own timezone config.

**Solution:** This is correct behavior. Store UTC, display local.

To see UTC time:
```powershell
# Original UTC is preserved in *_UTC fields
$displayEvent.Timestamp      # Local: "2024-12-10 06:30:45 PST"
$displayEvent.Timestamp_UTC  # UTC: "2024-12-10T14:30:45Z"
```

---

### Issue: Can't find timezone

**Cause:** Invalid timezone name in config.

**Solution:** Get list of valid timezones:
```powershell
Get-AvailableTimezones | Out-GridView
```

Copy the exact "Id" value to your config.

---

## Testing

### Test Timezone Conversion

```powershell
Import-Module .\scripts\utilities\Timezone-Helper.ps1

# Create test event
$testEvent = @{
    UserPrincipalName = "test@company.com"
    Timestamp = "2024-12-10T14:30:45Z"  # 2:30 PM UTC
    Role = "Test"
}

# Create helper
$tzHelper = [TimezoneHelper]::new()

# Convert for display
$displayEvent = $tzHelper.ConvertEventForDisplay($testEvent)

# Verify
Write-Host "Original UTC: $($testEvent.Timestamp)"
Write-Host "Display Time: $($displayEvent.Timestamp)"
Write-Host "Preserved UTC: $($displayEvent.Timestamp_UTC)"
Write-Host "Timezone: $($tzHelper.DisplayTimezone)"

# Expected output (if Pacific timezone):
# Original UTC: 2024-12-10T14:30:45Z
# Display Time: 2024-12-10 06:30:45 PST
# Preserved UTC: 2024-12-10T14:30:45Z
# Timezone: Pacific Standard Time
```

---

## FAQ

**Q: Why store in UTC?**
A: UTC never changes (no DST), works globally, and prevents timezone confusion in logs.

**Q: Can I use a different storage timezone?**
A: Technically yes, but UTC is the industry standard. Don't change `storageTimezone` unless you have a very specific reason.

**Q: What if users are in different timezones?**
A: Each user can have their own config file, or use `autoDetect: true` to use their local timezone.

**Q: Does this work with Power BI?**
A: Yes! Export data with local times, or use Power BI's timezone conversion features.

**Q: What about historical data already in local time?**
A: You'll need to convert it to UTC once. Create a migration script to convert all existing timestamps.

**Q: How do I handle timezone in web applications?**
A: Send UTC from backend, convert to local in JavaScript frontend using user's browser timezone.

---

## Summary

**Configuration:**
```json
{
  "display": {
    "timezone": {
      "displayTimezone": "Pacific Standard Time",
      "showTimezoneInDisplay": true
    }
  }
}
```

**Usage:**
```powershell
Import-Module .\scripts\utilities\Timezone-Helper.ps1

# Display UTC time in local timezone
$localTime = Format-DisplayTime -UtcDateTime $utcTime

# Store local time as UTC
$utcTime = ConvertTo-StorageTime -LocalDateTime $localTime
```

**Remember:**
- ✅ Store in UTC
- ✅ Display in local
- ✅ Keep both for reference
- ✅ Use TimezoneHelper for conversions

---

**Related Documentation:**
- [Anomaly Detector](../security/threat-detection.md)
- [Risk Calculator](../security/threat-detection.md)
- [Retry Handler](./retry-handler-guide.md)

**Questions?** Contact adrian207@gmail.com

