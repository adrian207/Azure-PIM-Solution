<#
.SYNOPSIS
    Timezone Helper for Azure PIM Solution

.DESCRIPTION
    Handles timezone conversion between UTC (storage) and local timezone (display).
    All data is stored in UTC, but displayed in user's configured timezone.

.AUTHOR
    Adrian Johnson

.NOTES
    Best Practice: Store in UTC, Display in Local
    - Logs/audit trails: Always UTC
    - User interface: Configured timezone
    - Reports: Configured timezone with timezone indicator
#>

class TimezoneHelper {
    [string]$DisplayTimezone
    [string]$StorageTimezone
    [bool]$AutoDetect
    [string]$DateFormat
    [bool]$Use24HourFormat
    [bool]$ShowTimezoneInDisplay
    [hashtable]$Config
    
    TimezoneHelper() {
        $this.LoadConfig()
    }
    
    TimezoneHelper([string]$ConfigPath) {
        $this.LoadConfig($ConfigPath)
    }
    
    [void] LoadConfig() {
        $this.LoadConfig(".\config\environment-config.json")
    }
    
    [void] LoadConfig([string]$ConfigPath) {
        if (Test-Path $ConfigPath) {
            $config = Get-Content $ConfigPath | ConvertFrom-Json
            
            if ($config.display -and $config.display.timezone) {
                $tz = $config.display.timezone
                $this.DisplayTimezone = $tz.displayTimezone
                $this.StorageTimezone = $tz.storageTimezone
                $this.AutoDetect = $tz.autoDetect
                $this.DateFormat = $tz.dateFormat
                $this.Use24HourFormat = $tz.use24HourFormat
                $this.ShowTimezoneInDisplay = $tz.showTimezoneInDisplay
            } else {
                # Defaults
                $this.SetDefaults()
            }
        } else {
            $this.SetDefaults()
        }
        
        # Auto-detect if enabled
        if ($this.AutoDetect) {
            $this.DisplayTimezone = [System.TimeZoneInfo]::Local.Id
        }
    }
    
    [void] SetDefaults() {
        $this.DisplayTimezone = [System.TimeZoneInfo]::Local.Id
        $this.StorageTimezone = "UTC"
        $this.AutoDetect = $true
        $this.DateFormat = "yyyy-MM-dd HH:mm:ss"
        $this.Use24HourFormat = $true
        $this.ShowTimezoneInDisplay = $true
    }
    
    # Convert from UTC (storage) to display timezone
    [datetime] ToDisplayTime([datetime]$UtcDateTime) {
        if ($UtcDateTime.Kind -ne [System.DateTimeKind]::Utc) {
            $UtcDateTime = [System.TimeZoneInfo]::ConvertTimeToUtc($UtcDateTime)
        }
        
        $displayTz = [System.TimeZoneInfo]::FindSystemTimeZoneById($this.DisplayTimezone)
        return [System.TimeZoneInfo]::ConvertTimeFromUtc($UtcDateTime, $displayTz)
    }
    
    # Convert from display timezone to UTC (storage)
    [datetime] ToStorageTime([datetime]$LocalDateTime) {
        $displayTz = [System.TimeZoneInfo]::FindSystemTimeZoneById($this.DisplayTimezone)
        return [System.TimeZoneInfo]::ConvertTimeToUtc($LocalDateTime, $displayTz)
    }
    
    # Format datetime for display
    [string] FormatForDisplay([datetime]$UtcDateTime) {
        $localTime = $this.ToDisplayTime($UtcDateTime)
        
        $formatted = $localTime.ToString($this.DateFormat)
        
        if ($this.ShowTimezoneInDisplay) {
            $tzAbbr = $this.GetTimezoneAbbreviation($this.DisplayTimezone)
            $formatted = "$formatted $tzAbbr"
        }
        
        return $formatted
    }
    
    # Format datetime for storage (always UTC)
    [string] FormatForStorage([datetime]$DateTime) {
        $utcTime = $this.ToStorageTime($DateTime)
        return $utcTime.ToString("o")  # ISO 8601 format
    }
    
    # Parse datetime from storage (UTC)
    [datetime] ParseFromStorage([string]$DateTimeString) {
        return [DateTime]::Parse($DateTimeString).ToUniversalTime()
    }
    
    # Get timezone abbreviation
    [string] GetTimezoneAbbreviation([string]$TimezoneName) {
        $tz = [System.TimeZoneInfo]::FindSystemTimeZoneById($TimezoneName)
        
        # Get current abbreviation (considers DST)
        if ($tz.IsDaylightSavingTime([DateTime]::Now)) {
            return $tz.DaylightName -replace '\b(\w)\w*\s*', '$1'  # PST → PDT
        } else {
            return $tz.StandardName -replace '\b(\w)\w*\s*', '$1'  # Pacific Standard Time → PST
        }
    }
    
    # Get all available timezones
    [array] GetAvailableTimezones() {
        return [System.TimeZoneInfo]::GetSystemTimeZones() | Select-Object Id, DisplayName, BaseUtcOffset
    }
    
    # Convert event object timestamps
    [hashtable] ConvertEventForDisplay([hashtable]$Event) {
        $displayEvent = $Event.Clone()
        
        # Convert common timestamp fields
        $timestampFields = @('Timestamp', 'CreatedAt', 'UpdatedAt', 'LastAccessTime', 'ExpiresAt', 'RequestedAt', 'ApprovedAt')
        
        foreach ($field in $timestampFields) {
            if ($Event.ContainsKey($field) -and $Event[$field]) {
                try {
                    $utcTime = $this.ParseFromStorage($Event[$field])
                    $displayEvent[$field] = $this.FormatForDisplay($utcTime)
                    $displayEvent["${field}_UTC"] = $Event[$field]  # Keep original UTC
                } catch {
                    # If parsing fails, keep original
                    Write-Verbose "Could not parse timestamp field: $field"
                }
            }
        }
        
        return $displayEvent
    }
    
    # Batch convert multiple events
    [array] ConvertEventsForDisplay([array]$Events) {
        $displayEvents = @()
        
        foreach ($event in $Events) {
            if ($event -is [hashtable]) {
                $displayEvents += $this.ConvertEventForDisplay($event)
            } else {
                $displayEvents += $event
            }
        }
        
        return $displayEvents
    }
}

# Helper functions for easy use

function ConvertTo-DisplayTime {
    param(
        [Parameter(Mandatory)]
        [datetime]$UtcDateTime,
        
        [string]$ConfigPath = ".\config\environment-config.json"
    )
    
    $helper = [TimezoneHelper]::new($ConfigPath)
    return $helper.ToDisplayTime($UtcDateTime)
}

function ConvertTo-StorageTime {
    param(
        [Parameter(Mandatory)]
        [datetime]$LocalDateTime,
        
        [string]$ConfigPath = ".\config\environment-config.json"
    )
    
    $helper = [TimezoneHelper]::new($ConfigPath)
    return $helper.ToStorageTime($LocalDateTime)
}

function Format-DisplayTime {
    param(
        [Parameter(Mandatory)]
        [datetime]$UtcDateTime,
        
        [string]$ConfigPath = ".\config\environment-config.json"
    )
    
    $helper = [TimezoneHelper]::new($ConfigPath)
    return $helper.FormatForDisplay($UtcDateTime)
}

function Get-AvailableTimezones {
    param(
        [switch]$IncludeOffset
    )
    
    $timezones = [System.TimeZoneInfo]::GetSystemTimeZones()
    
    if ($IncludeOffset) {
        return $timezones | Select-Object Id, DisplayName, BaseUtcOffset | Sort-Object BaseUtcOffset
    } else {
        return $timezones | Select-Object Id, DisplayName | Sort-Object DisplayName
    }
}

# Export functions
Export-ModuleMember -Function ConvertTo-DisplayTime, ConvertTo-StorageTime, Format-DisplayTime, Get-AvailableTimezones

