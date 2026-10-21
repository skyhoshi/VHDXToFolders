<#
.SYNOPSIS
    Tests the secret resolution function.

.DESCRIPTION
    This script provides test functions for Resolve-UserSecrets.
    It uses a temporary secrets file and test-only environment variables
    so real secrets are never read or modified.
#>
<#
    TEST CLEANUP
#>
Remove-Item Function:\Test-UserSecretFromEnvironment -ErrorAction SilentlyContinue;
Remove-Item Function:\Test-UserSecretFromJson -ErrorAction SilentlyContinue;
Remove-Item Function:\Test-UserSecretMissing -ErrorAction SilentlyContinue;
Remove-Item Function:\Resolve-UserSecrets -ErrorAction SilentlyContinue;
$error.Clear();

<#
    TEST SETUP
#>
# =====================================================================
# Configuration
# =====================================================================
$Config = @{
    SecretsFilePath = Join-Path ([IO.Path]::GetTempPath()) 'ado-secrets.test.json'
}
$TestEnvName = 'ADO_TEST_SECRET_VALUE'
$TestJsonKey = 'TestSecret'

$ResolveSecretPath = Join-Path $PSScriptRoot '..\..\Secrets\Resolve-UserSecrets.ps1'
if (Test-Path -LiteralPath $ResolveSecretPath -PathType Leaf) {
    . $ResolveSecretPath
}
else {
    Write-Error "Resolve-UserSecrets.ps1 not found at '$ResolveSecretPath'."
    exit;
}

if ($error.Count -gt 0) {
    Write-Error "Errors occurred during script execution."
    exit;
}

<#
    TESTS
#>

function Test-UserSecretFromEnvironment {
    [CmdletBinding()]
    param()

    process {
        @{ $TestJsonKey = 'from-json' } | ConvertTo-Json | Set-Content -Path $Config.SecretsFilePath -Encoding utf8
        [Environment]::SetEnvironmentVariable($TestEnvName, 'from-env')
        try {
            $result = Resolve-UserSecrets -EnvName $TestEnvName -JsonKey $TestJsonKey
            if ($result -eq 'from-env') { 'PASS: Test-UserSecretFromEnvironment' } else { "FAIL: Test-UserSecretFromEnvironment - got '$result'" }
        }
        finally {
            [Environment]::SetEnvironmentVariable($TestEnvName, $null)
        }
    }
}

function Test-UserSecretFromJson {
    [CmdletBinding()]
    param()

    process {
        [Environment]::SetEnvironmentVariable($TestEnvName, $null)
        @{ $TestJsonKey = 'from-json' } | ConvertTo-Json | Set-Content -Path $Config.SecretsFilePath -Encoding utf8
        $result = Resolve-UserSecrets -EnvName $TestEnvName -JsonKey $TestJsonKey
        if ($result -eq 'from-json') { 'PASS: Test-UserSecretFromJson' } else { "FAIL: Test-UserSecretFromJson - got '$result'" }
    }
}

function Test-UserSecretMissing {
    [CmdletBinding()]
    param()

    process {
        [Environment]::SetEnvironmentVariable($TestEnvName, $null)
        Remove-Item -LiteralPath $Config.SecretsFilePath -ErrorAction SilentlyContinue
        try {
            $null = Resolve-UserSecrets -EnvName $TestEnvName -JsonKey $TestJsonKey
            'FAIL: Test-UserSecretMissing - expected an exception'
        }
        catch {
            'PASS: Test-UserSecretMissing'
        }
    }
}

Test-UserSecretFromEnvironment
Test-UserSecretFromJson
Test-UserSecretMissing

Remove-Item -LiteralPath $Config.SecretsFilePath -ErrorAction SilentlyContinue
