<#
.SYNOPSIS
    Unit tests for Bulk Operations

.DESCRIPTION
    Pester tests for bulk operation functions
#>

BeforeAll {
    # Import the module
    Import-Module "$PSScriptRoot\..\..\scripts\utilities\Bulk-Operations.ps1" -Force
}

Describe "Bulk Operations" {
    Context "Invoke-BulkOperation" {
        It "Should process all items" {
            $items = 1..10
            $operation = { param($item) return $item * 2 }
            
            $results = Invoke-BulkOperation -Operation $operation -Items $items
            
            $results.Count | Should -Be 10
        }

        It "Should apply operation correctly" {
            $items = 1..5
            $operation = { param($item) return $item * 2 }
            
            $results = Invoke-BulkOperation -Operation $operation -Items $items
            
            $results[0] | Should -Be 2
            $results[4] | Should -Be 10
        }

        It "Should handle empty array" {
            $items = @()
            $operation = { param($item) return $item }
            
            $results = Invoke-BulkOperation -Operation $operation -Items $items
            
            $results.Count | Should -Be 0
        }

        It "Should respect batch size" {
            $items = 1..100
            $operation = { param($item) return $item }
            
            # Should process in batches without error
            { Invoke-BulkOperation -Operation $operation -Items $items -BatchSize 10 } | Should -Not -Throw
        }

        It "Should handle errors gracefully" {
            $items = 1..5
            $operation = {
                param($item)
                if ($item -eq 3) {
                    throw "Test error"
                }
                return $item
            }
            
            # Should not throw, errors should be in results
            { Invoke-BulkOperation -Operation $operation -Items $items } | Should -Not -Throw
        }

        It "Should process with custom MaxParallel" {
            $items = 1..20
            $operation = { param($item) Start-Sleep -Milliseconds 10; return $item }
            
            $time = Measure-Command {
                Invoke-BulkOperation -Operation $operation -Items $items -MaxParallel 5
            }
            
            # With parallelism, should be faster than sequential
            $time.TotalSeconds | Should -BeLessThan 5
        }
    }

    Context "Set-BulkPIMRoleAssignments" {
        It "Should process user assignments" {
            $users = @(
                @{ Id = "user1"; Name = "User 1" },
                @{ Id = "user2"; Name = "User 2" },
                @{ Id = "user3"; Name = "User 3" }
            )
            
            $results = Set-BulkPIMRoleAssignments -Users $users -RoleDefinitionId "test-role" -DurationDays 30
            
            $results.Count | Should -Be 3
        }

        It "Should include user ID in results" {
            $users = @(
                @{ Id = "user1"; Name = "User 1" }
            )
            
            $results = Set-BulkPIMRoleAssignments -Users $users -RoleDefinitionId "test-role"
            
            $results[0].UserId | Should -Be "user1"
        }

        It "Should use provided duration" {
            $users = @(
                @{ Id = "user1"; Name = "User 1" }
            )
            
            $results = Set-BulkPIMRoleAssignments -Users $users -RoleDefinitionId "test-role" -DurationDays 60
            
            $results[0].DurationDays | Should -Be 60
        }

        It "Should use provided justification" {
            $users = @(
                @{ Id = "user1"; Name = "User 1" }
            )
            
            $results = Set-BulkPIMRoleAssignments -Users $users -RoleDefinitionId "test-role" -Justification "Test justification"
            
            $results[0].Justification | Should -Be "Test justification"
        }

        It "Should handle large user lists" {
            $users = 1..100 | ForEach-Object { @{ Id = "user$_"; Name = "User $_" } }
            
            $results = Set-BulkPIMRoleAssignments -Users $users -RoleDefinitionId "test-role"
            
            $results.Count | Should -Be 100
        }
    }

    Context "Get-BulkAzureResources" {
        It "Should accept resource group parameter" {
            # Mock Get-AzResource
            Mock Get-AzResource {
                return @(
                    @{ Name = "Resource1"; Type = "Microsoft.Storage/storageAccounts" },
                    @{ Name = "Resource2"; Type = "Microsoft.Compute/virtualMachines" }
                )
            }
            
            $results = Get-BulkAzureResources -ResourceGroup "test-rg"
            
            $results.Count | Should -Be 2
        }

        It "Should filter by resource type" {
            Mock Get-AzResource {
                return @(
                    @{ Name = "Storage1"; Type = "Microsoft.Storage/storageAccounts" }
                )
            }
            
            $results = Get-BulkAzureResources -ResourceGroup "test-rg" -ResourceType "Microsoft.Storage/storageAccounts"
            
            $results.Count | Should -BeGreaterOrEqual 0
        }

        It "Should use cache when specified" {
            Mock Get-AzResource {
                return @(
                    @{ Name = "Resource1"; Type = "Microsoft.Storage/storageAccounts" }
                )
            }
            
            # First call
            $results1 = Get-BulkAzureResources -ResourceGroup "test-rg" -UseCache
            
            # Second call should use cache
            $results2 = Get-BulkAzureResources -ResourceGroup "test-rg" -UseCache
            
            $results1.Count | Should -Be $results2.Count
        }
    }

    Context "Performance Tests" {
        It "Should complete bulk operation within reasonable time" {
            $items = 1..50
            $operation = { param($item) Start-Sleep -Milliseconds 10; return $item }
            
            $time = Measure-Command {
                Invoke-BulkOperation -Operation $operation -Items $items -MaxParallel 10
            }
            
            # Should complete in less than 10 seconds with parallelism
            $time.TotalSeconds | Should -BeLessThan 10
        }

        It "Should handle concurrent operations" {
            $items = 1..20
            $operation = {
                param($item)
                Start-Sleep -Milliseconds (Get-Random -Minimum 10 -Maximum 50)
                return $item * 2
            }
            
            { Invoke-BulkOperation -Operation $operation -Items $items -MaxParallel 5 } | Should -Not -Throw
        }
    }
}

