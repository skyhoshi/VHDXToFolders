# =====================================================================
# Secret resolution: $env first, then secrets.json
# =====================================================================
function Resolve-Secret {
    param(
        [Parameter(Mandatory)][string]$EnvName,     # environment variable name
        [Parameter(Mandatory)][string]$JsonKey      # property name in secrets.json
    )

    # 1. Environment variable
    $value = [Environment]::GetEnvironmentVariable($EnvName)
    if (-not [string]::IsNullOrWhiteSpace($value)) {
        Write-Verbose "Using '$EnvName' from environment."
        return $value
    }

    # 2. secrets.json
    if (Test-Path $Config.SecretsFilePath) {
        $secrets = Get-Content $Config.SecretsFilePath -Raw | ConvertFrom-Json
        $value = $secrets.$JsonKey
        if (-not [string]::IsNullOrWhiteSpace($value)) {
            Write-Verbose "Using '$JsonKey' from $($Config.SecretsFilePath)."
            return $value
        }
    }

    throw "Secret not found. Set `$env:$EnvName or add '$JsonKey' to $($Config.SecretsFilePath)."
}