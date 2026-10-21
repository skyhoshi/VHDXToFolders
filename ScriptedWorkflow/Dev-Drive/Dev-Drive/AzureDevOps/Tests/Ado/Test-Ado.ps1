

<#
.SYNOPSIS
    Tests the Azure DevOps project and repository retrieval functions.

.DESCRIPTION
    This script provides test functions for Get-AdoProjects and Get-AdoRepositories.
    It is intended to be used for verifying that the ADO functions are working correctly.



    #>
<#
    TEST CLEANUP
#>
Remove-Item Function:\Test-AdoProjects -ErrorAction SilentlyContinue;
Remove-Item Function:\Test-AdoRepositories -ErrorAction SilentlyContinue;
Remove-Item Function:\Get-AdoProjects -ErrorAction SilentlyContinue;
Remove-Item Function:\Get-AdoRepositories -ErrorAction SilentlyContinue;
$error.Clear();
$Organization = $null;
$Pat          = $null;
$BaseUrl      = $null;
$Headers = $null;

<#
    TEST SETUP
#>
# =====================================================================
# Secret resolution: $env first, then secrets.json
# =====================================================================
$ResolveSecretPath = Join-Path $PSScriptRoot '..\..\Secrets\Resolve-UserSecrets.ps1'
if (Test-Path -LiteralPath $ResolveSecretPath -PathType Leaf) {
    . $ResolveSecretPath
}
else{
    Write-Error "Resolve-UserSecrets.ps1 not found at '$ResolveSecretPath'."
    exit;
}
Write-Debug "$($BaseUrl)"
Write-Debug "$($Organization)"
Write-Debug "$($Pat.Length)"
Write-Debug "$($Headers)"
# =====================================================================
# Configuration
# =====================================================================
$Config = @{
    # Azure DevOps REST API version
    ApiVersion        = '7.1'

    # Base URL; {0} is replaced with the organization name
    BaseUrlTemplate   = 'https://dev.azure.com/{0}'

    # Local cache file and how long it stays valid
    CacheFilePath     = Join-Path $PSScriptRoot 'ado-projects-repos.cache.json'
    CacheMaxAgeHours  = 240

    # Secrets file (keep out of source control)
    SecretsFilePath   = Join-Path $PSScriptRoot 'secrets.json'

    # Environment variable names checked before secrets.json
    EnvPatName        = 'AZURE_DEVOP_EXECUTION_PAT'
    EnvOrgName        = 'AZURE_DEVOPS_ORGANIZATION'

    # Page size for the projects API (max 500 per call)
    ProjectsPageSize  = 500
}
$Organization = Resolve-UserSecrets -EnvName $Config.EnvOrgName -JsonKey 'Organization'
$Pat          = Resolve-UserSecrets -EnvName $Config.EnvPatName -JsonKey 'PersonalAccessToken'
$BaseUrl      = $Config.BaseUrlTemplate -f $Organization

# ADO PAT auth uses Basic with an empty username
$Headers = @{
    Authorization = 'Basic ' + [Convert]::ToBase64String([Text.Encoding]::ASCII.GetBytes(":$Pat"))
}

$GetAdoProjectsPath = Join-Path $PSScriptRoot '..\..\Ado\Get-AdoProjects.ps1'
$GetAdoRepositoriesPath = Join-Path $PSScriptRoot '..\..\Ado\Get-AdoRepositories.ps1'
if (Test-Path -LiteralPath $GetAdoProjectsPath -PathType Leaf) {
    . $GetAdoProjectsPath
}
else {
    Write-Error "Get-AdoProjects.ps1 not found at '$GetAdoProjectsPath'."
    exit;
}

if (Test-Path -LiteralPath $GetAdoRepositoriesPath -PathType Leaf) {
    . $GetAdoRepositoriesPath
}
else {
    Write-Error "Get-AdoRepositories.ps1 not found at '$GetAdoRepositoriesPath'."
    exit;
}


if ($error.Count -gt 0) {
    Write-Error "Errors occurred during script execution."
    exit;
}

<#
    TESTS
#>

function Test-AdoProjects{
    [CmdletBinding()]
    param()

    process {
        # Call the Get-AdoProjects function and output the results
    $projects = Get-AdoProjects
    $projects;
    }
}

function Test-AdoRepositories{
    [CmdletBinding()]
    param()

    process {
        # Call the Get-AdoRepositories function and output the results
        $repositories = Get-AdoRepositories
        $repositories;
    }
}

# Export-ModuleMember -Function Test-AdoProjects, Test-AdoRepositories;

Test-AdoProjects
Test-AdoRepositories