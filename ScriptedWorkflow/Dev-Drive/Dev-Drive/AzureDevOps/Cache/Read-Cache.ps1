# =====================================================================
# Cache helpers
# =====================================================================
function Read-Cache {
    if (-not (Test-Path $Config.CacheFilePath)) {
        Write-Verbose 'No cache file found.'
        return $null
    }

    $cache = Get-Content $Config.CacheFilePath -Raw | ConvertFrom-Json

    # Cache from a different org is not usable
    if ($cache.Organization -ne $Organization) {
        Write-Verbose "Cache is for org '$($cache.Organization)', not '$Organization'."
        return $null
    }

    $ageHours = ((Get-Date).ToUniversalTime() - [datetime]$cache.CachedAtUtc).TotalHours
    if ($ageHours -gt $Config.CacheMaxAgeHours) {
        Write-Verbose ("Cache expired ({0:N1}h old, max {1}h)." -f $ageHours, $Config.CacheMaxAgeHours)
        return $null
    }

    Write-Verbose ("Using cache ({0:N1}h old)." -f $ageHours)
    return $cache
}
