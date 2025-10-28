<#
.SYNOPSIS
    Unit tests for Anomaly Detector

.DESCRIPTION
    Pester tests for the AnomalyDetector class
#>

BeforeAll {
    # Import the module
    Import-Module "$PSScriptRoot\..\..\scripts\utilities\Anomaly-Detector.ps1" -Force
}

Describe "AnomalyDetector" {
    BeforeEach {
        $detector = [AnomalyDetector]::new()
    }

    Context "Initialization" {
        It "Should initialize with default threshold" {
            $detector.AnomalyThreshold | Should -Be 2.0
        }

        It "Should initialize with empty baselines" {
            $detector.UserBaselines.Count | Should -Be 0
        }

        It "Should initialize with empty pattern signatures" {
            $detector.PatternSignatures.Count | Should -Be 0
        }
    }

    Context "Time-Based Anomaly Detection" {
        It "Should detect after-hours access (midnight-6am) as high risk" {
            $event = @{
                Id = "test-1"
                UserPrincipalName = "test@example.com"
                Timestamp = "2024-12-10T02:00:00Z"
                Role = "Test Role"
                Location = "US"
            }
            
            $score = $detector.CheckTimeAnomaly($event)
            $score | Should -BeGreaterThan 2.0
        }

        It "Should detect business hours access as low risk" {
            $event = @{
                Id = "test-2"
                UserPrincipalName = "test@example.com"
                Timestamp = "2024-12-10T14:00:00Z"
                Role = "Test Role"
                Location = "US"
            }
            
            $score = $detector.CheckTimeAnomaly($event)
            $score | Should -Be 0.0
        }

        It "Should detect weekend access as elevated risk" {
            $event = @{
                Id = "test-3"
                UserPrincipalName = "test@example.com"
                Timestamp = "2024-12-14T14:00:00Z"  # Saturday
                Role = "Test Role"
                Location = "US"
            }
            
            $score = $detector.CheckTimeAnomaly($event)
            $score | Should -BeGreaterThan 0.0
        }
    }

    Context "Role-Based Anomaly Detection" {
        It "Should detect high-privilege role access as elevated risk" {
            $event = @{
                Id = "test-4"
                UserPrincipalName = "test@example.com"
                Timestamp = "2024-12-10T14:00:00Z"
                Role = "Global Administrator"
                Location = "US"
            }
            
            $score = $detector.CheckRoleAnomaly($event)
            $score | Should -BeGreaterThan 1.0
        }

        It "Should detect new role usage as elevated risk" {
            # First access to establish baseline
            $event1 = @{
                Id = "test-5"
                UserPrincipalName = "newuser@example.com"
                Timestamp = "2024-12-10T14:00:00Z"
                Role = "User Administrator"
                Location = "US"
            }
            $detector.CheckRoleAnomaly($event1)

            # Second access with different role
            $event2 = @{
                Id = "test-6"
                UserPrincipalName = "newuser@example.com"
                Timestamp = "2024-12-10T15:00:00Z"
                Role = "Security Administrator"
                Location = "US"
            }
            
            $score = $detector.CheckRoleAnomaly($event2)
            $score | Should -BeGreaterThan 1.5
        }
    }

    Context "Frequency-Based Anomaly Detection" {
        It "Should detect high frequency requests as elevated risk" {
            $user = "frequent@example.com"
            
            # Simulate multiple requests
            for ($i = 0; $i -lt 15; $i++) {
                $event = @{
                    Id = "test-freq-$i"
                    UserPrincipalName = $user
                    Timestamp = (Get-Date).AddMinutes(-$i).ToString("o")
                    Role = "Test Role"
                    Location = "US"
                }
                $detector.CheckFrequencyAnomaly($event)
            }
            
            # Check final event
            $finalEvent = @{
                Id = "test-freq-final"
                UserPrincipalName = $user
                Timestamp = (Get-Date).ToString("o")
                Role = "Test Role"
                Location = "US"
            }
            
            $score = $detector.CheckFrequencyAnomaly($finalEvent)
            $score | Should -BeGreaterThan 2.0
        }
    }

    Context "Overall Risk Calculation" {
        It "Should calculate risk score for normal event" {
            $event = @{
                Id = "test-7"
                UserPrincipalName = "normal@example.com"
                Timestamp = "2024-12-10T14:00:00Z"  # Tuesday 2pm
                Role = "User Administrator"
                Location = "US"
            }
            
            $score = $detector.CalculateRiskScore($event)
            $score | Should -BeGreaterOrEqual 0.0
        }

        It "Should calculate higher risk for suspicious event" {
            $event = @{
                Id = "test-8"
                UserPrincipalName = "suspicious@example.com"
                Timestamp = "2024-12-14T02:00:00Z"  # Saturday 2am
                Role = "Global Administrator"
                Location = "Russia"
            }
            
            $score = $detector.CalculateRiskScore($event)
            $score | Should -BeGreaterThan 5.0
        }
    }

    Context "Anomaly Detection" {
        It "Should detect anomalies above threshold" {
            $events = @(
                @{
                    Id = "test-9"
                    UserPrincipalName = "user1@example.com"
                    Timestamp = "2024-12-14T02:00:00Z"  # High risk
                    Role = "Global Administrator"
                    Location = "US"
                },
                @{
                    Id = "test-10"
                    UserPrincipalName = "user2@example.com"
                    Timestamp = "2024-12-10T14:00:00Z"  # Low risk
                    Role = "User Administrator"
                    Location = "US"
                }
            )
            
            $anomalies = $detector.DetectAnomalies($events)
            $anomalies.Count | Should -BeGreaterThan 0
        }

        It "Should include severity in anomaly results" {
            $events = @(
                @{
                    Id = "test-11"
                    UserPrincipalName = "user3@example.com"
                    Timestamp = "2024-12-14T02:00:00Z"
                    Role = "Global Administrator"
                    Location = "US"
                }
            )
            
            $anomalies = $detector.DetectAnomalies($events)
            if ($anomalies.Count -gt 0) {
                $anomalies[0].Severity | Should -BeIn @("Low", "Medium", "High", "Critical")
            }
        }

        It "Should include recommendations in anomaly results" {
            $events = @(
                @{
                    Id = "test-12"
                    UserPrincipalName = "user4@example.com"
                    Timestamp = "2024-12-14T02:00:00Z"
                    Role = "Global Administrator"
                    Location = "US"
                }
            )
            
            $anomalies = $detector.DetectAnomalies($events)
            if ($anomalies.Count -gt 0) {
                $anomalies[0].Recommendations | Should -Not -BeNullOrEmpty
            }
        }
    }

    Context "Severity Calculation" {
        It "Should classify risk score 8+ as Critical" {
            $severity = $detector.CalculateSeverity(8.5)
            $severity | Should -Be "Critical"
        }

        It "Should classify risk score 5-7.9 as High" {
            $severity = $detector.CalculateSeverity(6.0)
            $severity | Should -Be "High"
        }

        It "Should classify risk score 3-4.9 as Medium" {
            $severity = $detector.CalculateSeverity(3.5)
            $severity | Should -Be "Medium"
        }

        It "Should classify risk score <3 as Low" {
            $severity = $detector.CalculateSeverity(1.5)
            $severity | Should -Be "Low"
        }
    }
}

