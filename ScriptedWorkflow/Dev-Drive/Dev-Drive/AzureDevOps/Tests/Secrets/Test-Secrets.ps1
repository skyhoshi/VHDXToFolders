<#
.SYNOPSIS
    Tests the secret resolution function.

.DESCRIPTION
    This script provides test functions for Resolve-Secret.
    It uses a temporary secrets file and test-only environment variables
    so real secrets are never read or modified.
#>
<#
    TEST CLEANUP
#>
Remove-Item Function:\Test-SecretFromEnvironment -ErrorAction SilentlyContinue;
Remove-Item Function:\Test-SecretFromJson -ErrorAction SilentlyContinue;
Remove-Item Function:\Test-SecretMissing -ErrorAction SilentlyContinue;
Remove-Item Function:\Resolve-Secret -ErrorAction SilentlyContinue;
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

$ResolveSecretPath = Join-Path $PSScriptRoot '..\..\Secrets\Resolve-Secret.ps1'
if (Test-Path -LiteralPath $ResolveSecretPath -PathType Leaf) {
    . $ResolveSecretPath
}
else {
    Write-Error "Resolve-Secret.ps1 not found at '$ResolveSecretPath'."
    exit;
}

if ($error.Count -gt 0) {
    Write-Error "Errors occurred during script execution."
    exit;
}

<#
    TESTS
#>

function Test-SecretFromEnvironment {
    [CmdletBinding()]
    param()

    process {
        @{ $TestJsonKey = 'from-json' } | ConvertTo-Json | Set-Content -Path $Config.SecretsFilePath -Encoding utf8
        [Environment]::SetEnvironmentVariable($TestEnvName, 'from-env')
        try {
            $result = Resolve-Secret -EnvName $TestEnvName -JsonKey $TestJsonKey
            if ($result -eq 'from-env') { 'PASS: Test-SecretFromEnvironment' } else { "FAIL: Test-SecretFromEnvironment - got '$result'" }
        }
        finally {
            [Environment]::SetEnvironmentVariable($TestEnvName, $null)
        }
    }
}

function Test-SecretFromJson {
    [CmdletBinding()]
    param()

    process {
        [Environment]::SetEnvironmentVariable($TestEnvName, $null)
        @{ $TestJsonKey = 'from-json' } | ConvertTo-Json | Set-Content -Path $Config.SecretsFilePath -Encoding utf8
        $result = Resolve-Secret -EnvName $TestEnvName -JsonKey $TestJsonKey
        if ($result -eq 'from-json') { 'PASS: Test-SecretFromJson' } else { "FAIL: Test-SecretFromJson - got '$result'" }
    }
}

function Test-SecretMissing {
    [CmdletBinding()]
    param()

    process {
        [Environment]::SetEnvironmentVariable($TestEnvName, $null)
        Remove-Item -LiteralPath $Config.SecretsFilePath -ErrorAction SilentlyContinue
        try {
            $null = Resolve-Secret -EnvName $TestEnvName -JsonKey $TestJsonKey
            'FAIL: Test-SecretMissing - expected an exception'
        }
        catch {
            'PASS: Test-SecretMissing'
        }
    }
}

Test-SecretFromEnvironment
Test-SecretFromJson
Test-SecretMissing

Remove-Item -LiteralPath $Config.SecretsFilePath -ErrorAction SilentlyContinue
