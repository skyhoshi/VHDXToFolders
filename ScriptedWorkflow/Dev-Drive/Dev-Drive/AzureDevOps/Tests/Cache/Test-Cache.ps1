<#
.SYNOPSIS
    Tests the cache read/write functions.

.DESCRIPTION
    This script provides test functions for Read-Cache and Write-Cache.
    It uses a temporary cache file so the real cache is never touched.



    #>
<#
    TEST CLEANUP
#>
Remove-Item Function:\Test-CacheMissingFile -ErrorAction SilentlyContinue;
Remove-Item Function:\Test-CacheRoundTrip -ErrorAction SilentlyContinue;
Remove-Item Function:\Test-CacheWrongOrganization -ErrorAction SilentlyContinue;
Remove-Item Function:\Test-CacheExpired -ErrorAction SilentlyContinue;
Remove-Item Function:\Read-Cache -ErrorAction SilentlyContinue;
Remove-Item Function:\Write-Cache -ErrorAction SilentlyContinue;
$error.Clear();
$Organization = $null;

<#
    TEST SETUP
#>
# =====================================================================
# Configuration
# =====================================================================
$Config = @{
    CacheFilePath     = Join-Path ([IO.Path]::GetTempPath()) 'ado-projects-repos.cache.test.json'
    CacheMaxAgeHours  = 240
}
$Organization = 'TestOrg'

$ReadCachePath  = Join-Path $PSScriptRoot '..\..\Cache\Read-Cache.ps1'
$WriteCachePath = Join-Path $PSScriptRoot '..\..\Cache\Write-Cache.ps1'
if (Test-Path -LiteralPath $ReadCachePath -PathType Leaf) {
    . $ReadCachePath
}
else {
    Write-Error "Read-Cache.ps1 not found at '$ReadCachePath'."
    exit;
}

if (Test-Path -LiteralPath $WriteCachePath -PathType Leaf) {
    . $WriteCachePath
}
else {
    Write-Error "Write-Cache.ps1 not found at '$WriteCachePath'."
    exit;
}

if ($error.Count -gt 0) {
    Write-Error "Errors occurred during script execution."
    exit;
}

function New-TestCacheData {
    param(
        [string]$Org = $Organization,
        [datetime]$CachedAtUtc = (Get-Date).ToUniversalTime()
    )
    [pscustomobject]@{
        Organization = $Org
        CachedAtUtc  = $CachedAtUtc.ToString('o')
        Projects     = @([pscustomobject]@{ Name = 'TestProject'; Repositories = @('TestRepo') })
    }
}

<#
    TESTS
#>

function Test-CacheMissingFile {
    [CmdletBinding()]
    param()

    process {
        Remove-Item -LiteralPath $Config.CacheFilePath -ErrorAction SilentlyContinue
        $result = Read-Cache
        if ($null -eq $result) { 'PASS: Test-CacheMissingFile' } else { 'FAIL: Test-CacheMissingFile - expected $null' }
    }
}

function Test-CacheRoundTrip {
    [CmdletBinding()]
    param()

    process {
        Write-Cache -Data (New-TestCacheData)
        $result = Read-Cache
        if ($result -and $result.Organization -eq $Organization -and $result.Projects[0].Name -eq 'TestProject') {
            'PASS: Test-CacheRoundTrip'
        }
        else { 'FAIL: Test-CacheRoundTrip - cache data did not round-trip' }
    }
}

function Test-CacheWrongOrganization {
    [CmdletBinding()]
    param()

    process {
        Write-Cache -Data (New-TestCacheData -Org 'OtherOrg')
        $result = Read-Cache
        if ($null -eq $result) { 'PASS: Test-CacheWrongOrganization' } else { 'FAIL: Test-CacheWrongOrganization - expected $null' }
    }
}

function Test-CacheExpired {
    [CmdletBinding()]
    param()

    process {
        $old = (Get-Date).ToUniversalTime().AddHours(-($Config.CacheMaxAgeHours + 1))
        Write-Cache -Data (New-TestCacheData -CachedAtUtc $old)
        $result = Read-Cache
        if ($null -eq $result) { 'PASS: Test-CacheExpired' } else { 'FAIL: Test-CacheExpired - expected $null' }
    }
}

Test-CacheMissingFile
Test-CacheRoundTrip
Test-CacheWrongOrganization
Test-CacheExpired

Remove-Item -LiteralPath $Config.CacheFilePath -ErrorAction SilentlyContinue
