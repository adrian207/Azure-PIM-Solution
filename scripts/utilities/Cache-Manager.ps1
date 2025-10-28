<#
.SYNOPSIS
    Cache Manager for Azure PIM Solution

.DESCRIPTION
    Provides caching functionality to reduce API calls and improve performance

.AUTHOR
    Adrian Johnson
#>

class CacheManager {
    [string]$CacheDir
    [int]$DefaultExpirationMinutes
    [hashtable]$InMemoryCache

    CacheManager([string]$CacheDirectory, [int]$ExpirationMinutes = 15) {
        $this.CacheDir = $CacheDirectory
        $this.DefaultExpirationMinutes = $ExpirationMinutes
        $this.InMemoryCache = @{}
    }

    [bool] Contains([string]$Key) {
        # Check in-memory cache first
        if ($this.InMemoryCache.ContainsKey($Key)) {
            $item = $this.InMemoryCache[$Key]
            $expiresAt = [DateTime]::Parse($item.ExpiresAt)
            if ($expiresAt -gt (Get-Date)) {
                return $true
            } else {
                $this.InMemoryCache.Remove($Key)
            }
        }

        # Check disk cache
        $filePath = Join-Path $this.CacheDir "$Key.json"
        if (Test-Path $filePath) {
            $cachedData = Get-Content $filePath | ConvertFrom-Json
            $expiresAt = [DateTime]::Parse($cachedData.ExpiresAt)
            if ($expiresAt -gt (Get-Date)) {
                # Load into memory cache
                $this.InMemoryCache[$Key] = $cachedData
                return $true
            } else {
                Remove-Item $filePath -Force
            }
        }

        return $false
    }

    [object] Get([string]$Key) {
        if (-not $this.Contains($Key)) {
            return $null
        }

        # Try in-memory first
        if ($this.InMemoryCache.ContainsKey($Key)) {
            return $this.InMemoryCache[$Key].Data
        }

        # Load from disk
        $filePath = Join-Path $this.CacheDir "$Key.json"
        $cachedData = Get-Content $filePath | ConvertFrom-Json
        $this.InMemoryCache[$Key] = $cachedData
        return $cachedData.Data
    }

    # Overload with 2 parameters (uses default expiration)
    [void] Set([string]$Key, [object]$Value) {
        $this.Set($Key, $Value, $this.DefaultExpirationMinutes)
    }
    
    # Overload with 3 parameters (custom expiration)
    [void] Set([string]$Key, [object]$Value, [int]$ExpirationMinutes) {
        $cachedItem = [PSCustomObject]@{
            Data = $Value
            CreatedAt = (Get-Date).ToString("o")
            ExpiresAt = (Get-Date).AddMinutes($ExpirationMinutes).ToString("o")
        }

        # Store in memory
        $this.InMemoryCache[$Key] = $cachedItem

        # Store on disk
        $filePath = Join-Path $this.CacheDir "$Key.json"
        $cachedItem | ConvertTo-Json -Depth 10 | Set-Content $filePath
    }

    [void] Clear() {
        $this.InMemoryCache.Clear()
        if (Test-Path $this.CacheDir) {
            Get-ChildItem $this.CacheDir -Filter "*.json" | Remove-Item -Force
        }
    }

    [void] ClearExpired() {
        $now = Get-Date
        $keysToRemove = @()

        foreach ($key in $this.InMemoryCache.Keys) {
            $item = $this.InMemoryCache[$key]
            $expiresAt = [DateTime]::Parse($item.ExpiresAt)
            if ($expiresAt -lt $now) {
                $keysToRemove += $key
            }
        }

        foreach ($key in $keysToRemove) {
            $this.InMemoryCache.Remove($key)
        }

        # Clear expired disk cache
        if (Test-Path $this.CacheDir) {
            Get-ChildItem $this.CacheDir -Filter "*.json" | ForEach-Object {
                $cachedData = Get-Content $_.FullName | ConvertFrom-Json
                $expiresAt = [DateTime]::Parse($cachedData.ExpiresAt)
                if ($expiresAt -lt $now) {
                    Remove-Item $_.FullName -Force
                }
            }
        }
    }
}

# Classes are automatically exported in PowerShell 5.0+
# No explicit export needed for classes

