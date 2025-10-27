<#
.SYNOPSIS
    Risk Calculator for Azure PIM Access Events

.DESCRIPTION
    Calculates risk scores for access requests and patterns

.AUTHOR
    Adrian Johnson
#>

class RiskCalculator {
    [hashtable]$RiskFactors
    [hashtable]$RiskWeights

    RiskCalculator() {
        $this.RiskFactors = @{
            TimeOfDay = @{ Weight = 0.20 }
            DayOfWeek = @{ Weight = 0.15 }
            Location = @{ Weight = 0.25 }
            RolePrivilege = @{ Weight = 0.20 }
            Frequency = @{ Weight = 0.15 }
            History = @{ Weight = 0.05 }
        }
        
        $this.RiskWeights = @{
            Critical = 3.0
            High = 2.0
            Medium = 1.5
            Low = 1.0
        }
    }

    [double] CalculateRiskScore([object]$AccessEvent) {
        $totalScore = 0.0
        $totalWeight = 0.0
        
        # Time of day risk
        $timeRisk = $this.EvaluateTimeRisk($AccessEvent)
        $totalScore += $timeRisk * $this.RiskFactors.TimeOfDay.Weight
        $totalWeight += $this.RiskFactors.TimeOfDay.Weight
        
        # Day of week risk
        $dayRisk = $this.EvaluateDayRisk($AccessEvent)
        $totalScore += $dayRisk * $this.RiskFactors.DayOfWeek.Weight
        $totalWeight += $this.RiskFactors.DayOfWeek.Weight
        
        # Location risk
        $locationRisk = $this.EvaluateLocationRisk($AccessEvent)
        $totalScore += $locationRisk * $this.RiskFactors.Location.Weight
        $totalWeight += $this.RiskFactors.Location.Weight
        
        # Role privilege risk
        $roleRisk = $this.EvaluateRoleRisk($AccessEvent)
        $totalScore += $roleRisk * $this.RiskFactors.RolePrivilege.Weight
        $totalWeight += $this.RiskFactors.RolePrivilege.Weight
        
        # Frequency risk
        $frequencyRisk = $this.EvaluateFrequencyRisk($AccessEvent)
        $totalScore += $frequencyRisk * $this.RiskFactors.Frequency.Weight
        $totalWeight += $this.RiskFactors.Frequency.Weight
        
        # Historical risk
        $historyRisk = $this.EvaluateHistoryRisk($AccessEvent)
        $totalScore += $historyRisk * $this.RiskFactors.History.Weight
        $totalWeight += $this.RiskFactors.History.Weight
        
        # Normalize to 0-10 scale
        return ($totalScore / $totalWeight) * 10
    }

    [double] EvaluateTimeRisk([object]$Event) {
        $hour = [DateTime]::Parse($Event.Timestamp).Hour
        
        # High risk: midnight to 6am
        if ($hour -ge 0 -and $hour -lt 6) {
            return 10.0
        }
        
        # Medium risk: after hours (6pm-midnight)
        if ($hour -ge 18) {
            return 5.0
        }
        
        # Low risk: business hours (9am-5pm)
        if ($hour -ge 9 -and $hour -lt 17) {
            return 1.0
        }
        
        # Low-medium risk: early morning (6am-9am)
        return 2.0
    }

    [double] EvaluateDayRisk([object]$Event) {
        $dayOfWeek = [DateTime]::Parse($Event.Timestamp).DayOfWeek
        
        # High risk: weekends
        if ($dayOfWeek -in @('Saturday', 'Sunday')) {
            return 8.0
        }
        
        # Low risk: weekdays
        return 1.0
    }

    [double] EvaluateLocationRisk([object]$Event) {
        if (-not $Event.Location) {
            return 5.0  # Unknown location
        }
        
        # High risk locations (configure in your environment)
        $highRiskCountries = @('Russia', 'China', 'North Korea', 'Iran')
        if ($highRiskCountries -contains $Event.Location) {
            return 10.0
        }
        
        # Check if location matches user's typical locations
        # This would integrate with your user baseline data
        return 2.0
    }

    [double] EvaluateRoleRisk([object]$Event) {
        # Critical roles
        $criticalRoles = @('Global Administrator', 'Privileged Role Administrator', 'Security Administrator', 'Exchange Administrator')
        if ($Event.Role -in $criticalRoles) {
            return 10.0
        }
        
        # High privilege roles
        $highRoles = @('User Administrator', 'Helpdesk Administrator', 'Application Administrator')
        if ($Event.Role -in $highRoles) {
            return 7.0
        }
        
        # Medium privilege roles
        $mediumRoles = @('Groups Administrator', 'Teams Administrator', 'SharePoint Administrator')
        if ($Event.Role -in $mediumRoles) {
            return 4.0
        }
        
        # Low privilege roles
        return 1.0
    }

    [double] EvaluateFrequencyRisk([object]$Event) {
        # This would use historical data
        # For now, return a moderate risk
        return 3.0
    }

    [double] EvaluateHistoryRisk([object]$Event) {
        # Check if user has previous violations
        # Check if user has been flagged before
        # Return based on historical behavior
        return 2.0
    }

    [string] GetRiskCategory([double]$RiskScore) {
        if ($riskScore -ge 8.0) { return "Critical" }
        if ($riskScore -ge 6.0) { return "High" }
        if ($riskScore -ge 4.0) { return "Medium" }
        return "Low"
    }

    [string] GetRiskColor([double]$RiskScore) {
        if ($riskScore -ge 8.0) { return "Red" }
        if ($riskScore -ge 6.0) { return "Orange" }
        if ($riskScore -ge 4.0) { return "Yellow" }
        return "Green"
    }
}

Export-ModuleMember -Type RiskCalculator

