<#
.SYNOPSIS
    Unit tests for Cache Manager

.DESCRIPTION
    Pester tests for the CacheManager class
#>

BeforeAll {
    # Import the module
    Import-Module "$PSScriptRoot\..\..\scripts\utilities\Cache-Manager.ps1" -Force
    
    # Create temp cache directory
    $script:testCacheDir = Join-Path $TestDrive "test-cache"
    New-Item -ItemType Directory -Path $script:testCacheDir -Force | Out-Null
}

AfterAll {
    # Cleanup
    if (Test-Path $script:testCacheDir) {
        Remove-Item $script:testCacheDir -Recurse -Force
    }
}

Describe "CacheManager" {
    BeforeEach {
        $cache = [CacheManager]::new($script:testCacheDir, 15)
    }

    AfterEach {
        $cache.Clear()
    }

    Context "Initialization" {
        It "Should initialize with cache directory" {
            $cache.CacheDir | Should -Be $script:testCacheDir
        }

        It "Should initialize with default expiration" {
            $cache.DefaultExpirationMinutes | Should -Be 15
        }

        It "Should initialize with empty in-memory cache" {
            $cache.InMemoryCache.Count | Should -Be 0
        }
    }

    Context "Set and Get Operations" {
        It "Should store and retrieve simple value" {
            $cache.Set("test-key", "test-value")
            $value = $cache.Get("test-key")
            
            $value | Should -Be "test-value"
        }

        It "Should store and retrieve complex object" {
            $testObject = @{
                Name = "Test"
                Value = 123
                Items = @("a", "b", "c")
            }
            
            $cache.Set("complex-key", $testObject)
            $retrieved = $cache.Get("complex-key")
            
            $retrieved.Name | Should -Be "Test"
            $retrieved.Value | Should -Be 123
            $retrieved.Items.Count | Should -Be 3
        }

        It "Should return null for non-existent key" {
            $value = $cache.Get("non-existent")
            $value | Should -BeNullOrEmpty
        }

        It "Should use custom expiration time" {
            $cache.Set("short-lived", "value", 1)  # 1 minute
            $cache.Contains("short-lived") | Should -Be $true
        }
    }

    Context "Contains Operation" {
        It "Should return true for existing key" {
            $cache.Set("exists", "value")
            $cache.Contains("exists") | Should -Be $true
        }

        It "Should return false for non-existent key" {
            $cache.Contains("does-not-exist") | Should -Be $false
        }

        It "Should return false for expired key" {
            # Set with very short expiration
            $cache.Set("expired", "value", -1)  # Already expired
            Start-Sleep -Milliseconds 100
            $cache.Contains("expired") | Should -Be $false
        }
    }

    Context "Expiration Handling" {
        It "Should not return expired items" {
            # Create item that expires immediately
            $cache.Set("expires-now", "value", -1)
            Start-Sleep -Milliseconds 100
            
            $value = $cache.Get("expires-now")
            $value | Should -BeNullOrEmpty
        }

        It "Should clear expired items from memory" {
            $cache.Set("item1", "value1", -1)  # Expired
            $cache.Set("item2", "value2", 60)  # Valid
            
            Start-Sleep -Milliseconds 100
            $cache.ClearExpired()
            
            $cache.Contains("item1") | Should -Be $false
            $cache.Contains("item2") | Should -Be $true
        }
    }

    Context "Disk Persistence" {
        It "Should persist cache to disk" {
            $cache.Set("disk-test", "persisted-value")
            
            $filePath = Join-Path $script:testCacheDir "disk-test.json"
            Test-Path $filePath | Should -Be $true
        }

        It "Should load from disk if not in memory" {
            $cache.Set("disk-load", "value-from-disk")
            
            # Clear in-memory cache
            $cache.InMemoryCache.Clear()
            
            # Should load from disk
            $value = $cache.Get("disk-load")
            $value | Should -Be "value-from-disk"
        }

        It "Should remove expired disk cache files" {
            $cache.Set("disk-expired", "value", -1)
            Start-Sleep -Milliseconds 100
            
            $cache.ClearExpired()
            
            $filePath = Join-Path $script:testCacheDir "disk-expired.json"
            Test-Path $filePath | Should -Be $false
        }
    }

    Context "Clear Operations" {
        It "Should clear all cache items" {
            $cache.Set("item1", "value1")
            $cache.Set("item2", "value2")
            $cache.Set("item3", "value3")
            
            $cache.Clear()
            
            $cache.InMemoryCache.Count | Should -Be 0
            $cache.Contains("item1") | Should -Be $false
            $cache.Contains("item2") | Should -Be $false
            $cache.Contains("item3") | Should -Be $false
        }

        It "Should clear disk cache files" {
            $cache.Set("disk1", "value1")
            $cache.Set("disk2", "value2")
            
            $cache.Clear()
            
            $files = Get-ChildItem $script:testCacheDir -Filter "*.json"
            $files.Count | Should -Be 0
        }
    }

    Context "Performance" {
        It "Should handle multiple rapid operations" {
            for ($i = 0; $i -lt 100; $i++) {
                $cache.Set("key-$i", "value-$i")
            }
            
            for ($i = 0; $i -lt 100; $i++) {
                $value = $cache.Get("key-$i")
                $value | Should -Be "value-$i"
            }
        }

        It "Should retrieve from memory faster than disk" {
            $cache.Set("memory-test", "value")
            
            # Measure memory retrieval
            $memoryTime = Measure-Command {
                $cache.Get("memory-test")
            }
            
            # Clear memory, force disk load
            $cache.InMemoryCache.Clear()
            
            # Measure disk retrieval
            $diskTime = Measure-Command {
                $cache.Get("memory-test")
            }
            
            # Memory should be faster (though this might be flaky)
            $memoryTime.TotalMilliseconds | Should -BeLessOrEqual $diskTime.TotalMilliseconds
        }
    }
}

