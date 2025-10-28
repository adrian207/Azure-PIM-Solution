<#
.SYNOPSIS
    Unit tests for Risk Calculator

.DESCRIPTION
    Pester tests for the RiskCalculator class
#>

BeforeAll {
    # Import the module
    Import-Module "$PSScriptRoot\..\..\scripts\utilities\Risk-Calculator.ps1" -Force
}

Describe "RiskCalculator" {
    BeforeEach {
        $calculator = [RiskCalculator]::new()
    }

    Context "Initialization" {
        It "Should initialize with risk factors" {
            $calculator.RiskFactors.Count | Should -BeGreaterThan 0
        }

        It "Should have correct risk factor weights" {
            $calculator.RiskFactors.TimeOfDay.Weight | Should -Be 0.20
            $calculator.RiskFactors.Location.Weight | Should -Be 0.25
            $calculator.RiskFactors.RolePrivilege.Weight | Should -Be 0.20
        }

        It "Should initialize with risk weights" {
            $calculator.RiskWeights.Critical | Should -Be 3.0
            $calculator.RiskWeights.High | Should -Be 2.0
        }
    }

    Context "Time Risk Evaluation" {
        It "Should return high risk for midnight-6am access" {
            $event = @{
                Timestamp = "2024-12-10T03:00:00Z"
            }
            
            $risk = $calculator.EvaluateTimeRisk($event)
            $risk | Should -Be 10.0
        }

        It "Should return low risk for business hours access" {
            $event = @{
                Timestamp = "2024-12-10T14:00:00Z"
            }
            
            $risk = $calculator.EvaluateTimeRisk($event)
            $risk | Should -Be 1.0
        }

        It "Should return medium risk for after-hours access" {
            $event = @{
                Timestamp = "2024-12-10T20:00:00Z"
            }
            
            $risk = $calculator.EvaluateTimeRisk($event)
            $risk | Should -Be 5.0
        }
    }

    Context "Day Risk Evaluation" {
        It "Should return high risk for weekend access" {
            $event = @{
                Timestamp = "2024-12-14T14:00:00Z"  # Saturday
            }
            
            $risk = $calculator.EvaluateDayRisk($event)
            $risk | Should -Be 8.0
        }

        It "Should return low risk for weekday access" {
            $event = @{
                Timestamp = "2024-12-10T14:00:00Z"  # Tuesday
            }
            
            $risk = $calculator.EvaluateDayRisk($event)
            $risk | Should -Be 1.0
        }
    }

    Context "Location Risk Evaluation" {
        It "Should return medium risk for unknown location" {
            $event = @{
                Location = $null
            }
            
            $risk = $calculator.EvaluateLocationRisk($event)
            $risk | Should -Be 5.0
        }

        It "Should return high risk for high-risk countries" {
            $event = @{
                Location = "Russia"
            }
            
            $risk = $calculator.EvaluateLocationRisk($event)
            $risk | Should -Be 10.0
        }

        It "Should return low risk for normal locations" {
            $event = @{
                Location = "United States"
            }
            
            $risk = $calculator.EvaluateLocationRisk($event)
            $risk | Should -BeLessOrEqual 5.0
        }
    }

    Context "Role Risk Evaluation" {
        It "Should return critical risk for Global Administrator" {
            $event = @{
                Role = "Global Administrator"
            }
            
            $risk = $calculator.EvaluateRoleRisk($event)
            $risk | Should -Be 10.0
        }

        It "Should return high risk for privileged roles" {
            $event = @{
                Role = "User Administrator"
            }
            
            $risk = $calculator.EvaluateRoleRisk($event)
            $risk | Should -Be 7.0
        }

        It "Should return medium risk for standard admin roles" {
            $event = @{
                Role = "Teams Administrator"
            }
            
            $risk = $calculator.EvaluateRoleRisk($event)
            $risk | Should -Be 4.0
        }

        It "Should return low risk for low-privilege roles" {
            $event = @{
                Role = "Directory Reader"
            }
            
            $risk = $calculator.EvaluateRoleRisk($event)
            $risk | Should -Be 1.0
        }
    }

    Context "Overall Risk Score Calculation" {
        It "Should calculate risk score within 0-10 range" {
            $event = @{
                Timestamp = "2024-12-10T14:00:00Z"
                Location = "US"
                Role = "User Administrator"
            }
            
            $score = $calculator.CalculateRiskScore($event)
            $score | Should -BeGreaterOrEqual 0.0
            $score | Should -BeLessOrEqual 10.0
        }

        It "Should calculate higher risk for suspicious event" {
            $suspiciousEvent = @{
                Timestamp = "2024-12-14T03:00:00Z"  # Saturday 3am
                Location = "Russia"
                Role = "Global Administrator"
            }
            
            $normalEvent = @{
                Timestamp = "2024-12-10T14:00:00Z"  # Tuesday 2pm
                Location = "US"
                Role = "Directory Reader"
            }
            
            $suspiciousScore = $calculator.CalculateRiskScore($suspiciousEvent)
            $normalScore = $calculator.CalculateRiskScore($normalEvent)
            
            $suspiciousScore | Should -BeGreaterThan $normalScore
        }

        It "Should not divide by zero with empty event" {
            $event = @{}
            
            { $calculator.CalculateRiskScore($event) } | Should -Not -Throw
        }
    }

    Context "Risk Category Classification" {
        It "Should classify score 8+ as Critical" {
            $category = $calculator.GetRiskCategory(8.5)
            $category | Should -Be "Critical"
        }

        It "Should classify score 6-7.9 as High" {
            $category = $calculator.GetRiskCategory(6.5)
            $category | Should -Be "High"
        }

        It "Should classify score 4-5.9 as Medium" {
            $category = $calculator.GetRiskCategory(4.5)
            $category | Should -Be "Medium"
        }

        It "Should classify score <4 as Low" {
            $category = $calculator.GetRiskCategory(2.0)
            $category | Should -Be "Low"
        }
    }

    Context "Risk Color Classification" {
        It "Should return Red for critical risk" {
            $color = $calculator.GetRiskColor(9.0)
            $color | Should -Be "Red"
        }

        It "Should return Orange for high risk" {
            $color = $calculator.GetRiskColor(7.0)
            $color | Should -Be "Orange"
        }

        It "Should return Yellow for medium risk" {
            $color = $calculator.GetRiskColor(5.0)
            $color | Should -Be "Yellow"
        }

        It "Should return Green for low risk" {
            $color = $calculator.GetRiskColor(2.0)
            $color | Should -Be "Green"
        }
    }
}

