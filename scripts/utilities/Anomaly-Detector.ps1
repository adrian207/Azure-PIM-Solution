<#
.SYNOPSIS
    Anomaly Detection System for Azure PIM

.DESCRIPTION
    Detects unusual patterns in access requests and user behavior

.AUTHOR
    Adrian Johnson
#>

class AnomalyDetector {
    [hashtable]$UserBaselines
    [hashtable]$PatternSignatures
    [double]$AnomalyThreshold

    AnomalyDetector() {
        $this.UserBaselines = @{}
        $this.PatternSignatures = @{}
        $this.AnomalyThreshold = 2.0  # Standard deviations
    }

    [object] DetectAnomalies([array]$AccessEvents) {
        $anomalies = @()
        
        foreach ($event in $AccessEvents) {
            $riskScore = $this.CalculateRiskScore($event)
            
            if ($riskScore -gt $this.AnomalyThreshold) {
                $anomaly = @{
                    EventId = $event.Id
                    UserPrincipalName = $event.UserPrincipalName
                    Timestamp = $event.Timestamp
                    RiskScore = $riskScore
                    AnomalyType = $this.IdentifyAnomalyType($event, $riskScore)
                    Severity = $this.CalculateSeverity($riskScore)
                    Recommendations = $this.GetRecommendations($event)
                }
                $anomalies += $anomaly
            }
        }
        
        return $anomalies
    }

    [double] CalculateRiskScore([object]$Event) {
        $score = 0.0
        
        # Check time-based anomalies
        $score += $this.CheckTimeAnomaly($event)
        
        # Check location-based anomalies
        $score += $this.CheckLocationAnomaly($event)
        
        # Check role-based anomalies
        $score += $this.CheckRoleAnomaly($event)
        
        # Check frequency anomalies
        $score += $this.CheckFrequencyAnomaly($event)
        
        # Check pattern anomalies
        $score += $this.CheckPatternAnomaly($event)
        
        return $score
    }

    [double] CheckTimeAnomaly([object]$Event) {
        if (-not $Event.Timestamp) { return 0.0 }
        
        $dateTime = [DateTime]::Parse($Event.Timestamp).ToUniversalTime()
        $hour = $dateTime.Hour
        $score = 0.0
        
        # Access outside business hours (9am-5pm UTC)
        if ($hour -lt 9 -or $hour -gt 17) {
            $score += 1.5
        }
        
        # Access during typical off-hours (midnight-6am UTC)
        if ($hour -ge 0 -and $hour -lt 6) {
            $score += 2.5  # High risk
        }
        
        # Access on weekends
        $dayOfWeek = $dateTime.DayOfWeek
        if ($dayOfWeek -in @('Saturday', 'Sunday')) {
            $score += 1.5
        }
        
        return $score
    }

    [double] CheckLocationAnomaly([object]$Event) {
        if (-not $Event.Location) { return 0.0 }
        
        $score = 0.0
        $userBaseline = $this.GetUserBaseline($Event.UserPrincipalName)
        
        if ($userBaseline -and $userBaseline.LastLocations -notcontains $Event.Location) {
            # New location not in user's typical locations
            $score += 2.0
            
            # Check for impossible travel (too far from last location too quickly)
            if ($userBaseline.LastLocation) {
                $distance = $this.CalculateDistance($userBaseline.LastLocation, $Event.Location)
                $timeDiff = ([DateTime]::Parse($Event.Timestamp) - [DateTime]::Parse($userBaseline.LastAccessTime)).TotalHours
                
                # If traveled far quickly (< 8 hours), high risk
                if ($distance -gt 1000 -and $timeDiff -lt 8) {
                    $score += 3.0  # Very high risk - impossible travel
                }
            }
        }
        
        # Update baseline
        $this.UpdateUserBaseline($Event.UserPrincipalName, $Event.Location, $Event.Timestamp)
        
        return $score
    }

    [double] CheckRoleAnomaly([object]$Event) {
        $score = 0.0
        $userBaseline = $this.GetUserBaseline($Event.UserPrincipalName)
        
        if ($userBaseline) {
            # User accessing role they haven't used before
            if ($userBaseline.UsedRoles -notcontains $Event.Role) {
                $score += 2.0
            }
            
            # User accessing high-privilege role (e.g., Global Admin)
            $highPrivilegeRoles = @('Global Administrator', 'Privileged Role Administrator', 'Security Administrator')
            if ($Event.Role -in $highPrivilegeRoles) {
                $score += 1.5
            }
        }
        
        # Update baseline
        if ($userBaseline) {
            if ($userBaseline.UsedRoles -notcontains $Event.Role) {
                $userBaseline.UsedRoles += $Event.Role
            }
        }
        
        return $score
    }

    [double] CheckFrequencyAnomaly([object]$Event) {
        $score = 0.0
        if (-not $Event.Timestamp) { return 0.0 }
        
        $userBaseline = $this.GetUserBaseline($Event.UserPrincipalName)
        
        if ($userBaseline) {
            # Calculate requests in last 24 hours
            $recentRequests = $userBaseline.RecentRequests | Where-Object {
                $_ -and ([DateTime]::Parse($_) -gt [DateTime]::Parse($Event.Timestamp).AddHours(-24))
            }
            
            $requestCount = $recentRequests.Count
            $avgRequests = if ($userBaseline.AverageDailyRequests) { $userBaseline.AverageDailyRequests } else { 1 }
            
            # More than 3x average requests in last 24 hours
            if ($requestCount -gt ($avgRequests * 3)) {
                $score += 2.0
            }
            
            # More than 10 requests in last hour (potential automated attack)
            $lastHourRequests = $recentRequests | Where-Object {
                ([DateTime]::Parse($_) -gt [DateTime]::Parse($Event.Timestamp).AddHours(-1))
            }
            if ($lastHourRequests.Count -gt 10) {
                $score += 3.0  # Very high risk
            }
        }
        
        # Update baseline
        if ($userBaseline) {
            $userBaseline.RecentRequests += $Event.Timestamp
            $userBaseline.RecentRequests = $userBaseline.RecentRequests | Where-Object {
                [DateTime]::Parse($_) -gt [DateTime]::Now.AddDays(-30)
            }
        }
        
        return $score
    }

    [double] CheckPatternAnomaly([object]$Event) {
        $score = 0.0
        $signature = "$($Event.UserPrincipalName)-$($Event.Role)-$([DateTime]::Parse($Event.Timestamp).DayOfWeek)"
        
        if (-not $this.PatternSignatures[$signature]) {
            # New pattern not seen before
            $score += 1.0
            $this.PatternSignatures[$signature] = 1
        } else {
            $this.PatternSignatures[$signature]++
        }
        
        return $score
    }

    [string] IdentifyAnomalyType([object]$Event, [double]$RiskScore) {
        $types = @()
        
        if ($this.CheckTimeAnomaly($Event) -gt 0) {
            $types += "Time-Based Anomaly"
        }
        if ($this.CheckLocationAnomaly($Event) -gt 0) {
            $types += "Location-Based Anomaly"
        }
        if ($this.CheckRoleAnomaly($Event) -gt 0) {
            $types += "Role-Based Anomaly"
        }
        if ($this.CheckFrequencyAnomaly($Event) -gt 0) {
            $types += "Frequency-Based Anomaly"
        }
        
        return ($types -join ", ")
    }

    [string] CalculateSeverity([double]$RiskScore) {
        if ($RiskScore -ge 5.0) { return "Critical" }
        if ($RiskScore -ge 3.0) { return "High" }
        if ($RiskScore -ge 2.0) { return "Medium" }
        return "Low"
    }

    [array] GetRecommendations([object]$Event) {
        $recommendations = @()
        
        if ($this.CheckTimeAnomaly($Event) -gt 0) {
            $recommendations += "Review access outside business hours"
        }
        if ($this.CheckLocationAnomaly($Event) -gt 0) {
            $recommendations += "Verify user location and implement MFA"
        }
        if ($this.CheckRoleAnomaly($Event) -gt 0) {
            $recommendations += "Confirm user needs this role access"
        }
        if ($this.CheckFrequencyAnomaly($Event) -gt 0) {
            $recommendations += "Investigate potential automated attack"
            $recommendations += "Consider implementing rate limiting"
        }
        
        return $recommendations
    }

    hidden [object] GetUserBaseline([string]$UserPrincipalName) {
        if (-not $this.UserBaselines[$UserPrincipalName]) {
            $this.UserBaselines[$UserPrincipalName] = @{
                LastLocation = $null
                LastLocations = @()
                LastAccessTime = $null
                UsedRoles = @()
                RecentRequests = @()
                AverageDailyRequests = 0
            }
        }
        return $this.UserBaselines[$UserPrincipalName]
    }

    hidden [void] UpdateUserBaseline([string]$UserPrincipalName, [string]$Location, [string]$Timestamp) {
        $baseline = $this.GetUserBaseline($UserPrincipalName)
        $baseline.LastAccessTime = $Timestamp
        
        if ($Location -ne $baseline.LastLocation) {
            $baseline.LastLocation = $Location
            if ($baseline.LastLocations -notcontains $Location) {
                $baseline.LastLocations += $Location
            }
            # Keep only last 5 locations
            if ($baseline.LastLocations.Count -gt 5) {
                $baseline.LastLocations = $baseline.LastLocations[-5..-1]
            }
        }
    }

    hidden [int] CalculateDistance([string]$Location1, [string]$Location2) {
        # Simplified distance calculation (in km)
        # In production, use proper geolocation service
        return 1000  # Placeholder
    }
}

# Classes are automatically exported in PowerShell 5.0+
# No explicit export needed for classes

