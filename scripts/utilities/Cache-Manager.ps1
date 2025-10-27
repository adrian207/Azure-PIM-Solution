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
            if ($item.ExpiresAt -gt (Get-Date)) {
                return $true
            } else {
                $this.InMemoryCache.Remove($Key)
            }
        }

        # Check disk cache
        $filePath = Join-Path $this.CacheDir "$Key.json"
        if (Test-Path $filePath) {
            $cachedData = Get-Content $filePath | ConvertFrom-Json
            if ($cachedData.ExpiresAt -gt (Get-Date)) {
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

    [void] Set([string]$Key, [object]$Value, [int]$ExpirationMinutes = 0) {
        if ($ExpirationMinutes -eq 0) {
            $ExpirationMinutes = $this.DefaultExpirationを取り出utes
        }

        $cachedItem = @{
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
            if ($item.ExpiresAt -lt $now) {
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
                if ($cachedData.ExpiresAt -lt $now) {
                    Remove-Item $_.FullName -Force
                }
            }
        }
    }
}

# Export the class
Export-ModuleMember -Type CacheManager

