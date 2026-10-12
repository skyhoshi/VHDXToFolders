# =====================================================================
# Cache helpers
# =====================================================================
function Write-Cache {
    param([Parameter(Mandatory)]$Data)
    $Data | ConvertTo-Json -Depth 10 | Set-Content -Path $Config.CacheFilePath -Encoding utf8
    Write-Verbose "Cache written to $($Config.CacheFilePath)."
}
