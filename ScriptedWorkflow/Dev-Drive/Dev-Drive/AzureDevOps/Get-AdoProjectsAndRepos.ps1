#Requires -Version 7.0
function Get-AdoProjectsAndRepos {
    <#
    .SYNOPSIS
        Gets all Azure DevOps Team Projects and Git Repositories, cached locally in a JSON file.

    .DESCRIPTION
        Secrets (PAT, Organization) are resolved in this order:
            1. Environment variables ($env:AZURE_DEVOPS_EXECUTION_PAT, $env:AZURE_DEVOPS_ORGANIZATION)
            2. appsettings.json next to this script (see appsettings.json)
            3. secrets.json next to this script (see secrets.json)
        Results are cached to a JSON file and reused until the cache expires or -ForceRefresh is used.

    .PARAMETER ForceRefresh
        Ignore the cache and pull fresh data from Azure DevOps.

    .PARAMETER ProjectName
        Optional wildcard filter on Team Project name (e.g. 'Lending*').

    .PARAMETER RepoName
        Optional wildcard filter on Git Repository name (e.g. '*Api*').

    .EXAMPLE
        .\Get-AdoProjectsAndRepos.ps1
    .EXAMPLE
        .\Get-AdoProjectsAndRepos.ps1 -ProjectName 'MyProject' -RepoName '*service*' -ForceRefresh

    .NOTES
        secrets.json should contain the necessary secrets for accessing Azure DevOps.
        example: 
        {    
            "Organization": "your-ado-organization",    
            "PersonalAccessToken": "your-pat-with-Code-Read-and-Project-Read-scopes"
        }
    .INPUTS
    Inputs to this cmdlet (if any)
    .OUTPUTS
    Output from this cmdlet (if any)
    .COMPONENT
    The component this cmdlet belongs to
    .ROLE
    The role this cmdlet belongs to
    .FUNCTIONALITY
    The functionality that best describes this cmdlet
#>

    [CmdletBinding(DefaultParameterSetName = 'ParameterSet1',
        SupportsShouldProcess,
        PositionalBinding,
        HelpUri = 'http://yourwebsiteforhelp.here',
        ConfirmImpact = 'Medium')]
    [Alias('Be-lazyWithThis', 'lzy', 'Use-OldFunctionName')]
    [OutputType([pscustomobject])]
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $false,
            ValueFromPipeline,
            ValueFromPipelineByPropertyName,
            ValueFromRemainingArguments,
            Position = 3,
            ParameterSetName = 'ParameterSet1')]
        [ArgumentCompleter({ 'Force Data Retrieval Inside the 180 day window.' })]
        [switch]
        $ForceRefresh, 
        [Parameter(Mandatory = $false,
            ValueFromPipeline,
            ValueFromPipelineByPropertyName,
            ValueFromRemainingArguments,
            Position = 1,
            ParameterSetName = 'ParameterSet1')]
        [AllowNull()]
        [AllowEmptyCollection()]
        [AllowEmptyString()]
        [ArgumentCompleter({ 'Team Project Name' })]
        [string]
        $ProjectName = '*', 
        [Parameter(Mandatory = $false,
            ValueFromPipeline,
            ValueFromPipelineByPropertyName,
            ValueFromRemainingArguments,
            Position = 2,
            ParameterSetName = 'ParameterSet1')]
        [AllowNull()]
        [AllowEmptyCollection()]
        [AllowEmptyString()]
        [string]
        $RepoName = '*'

        # # Param1 help description
        # [Parameter(Mandatory,
        #     ValueFromPipeline,
        #     ValueFromPipelineByPropertyName,
        #     ValueFromRemainingArguments,
        #     Position = 0,
        #     ParameterSetName = 'ParameterSet1')]
        # [ValidateNotNull()]
        # [ValidateNotNullOrEmpty()]
        # [ValidateCount(0, 5)]
        # [ValidateSet("sun", "moon", "earth")]
        # [Alias("p1")]
        # $Param1,

        # # Param2 help description
        # [Parameter(ParameterSetName = 'ParameterSet1')]
        # [AllowNull()]
        # [AllowEmptyCollection()]
        # [AllowEmptyString()]
        # [ValidateScript({ true })]
        # [ValidateRange(0, 5)]
        # [int]
        # $Param2,

        # # Param3 help description
        # [Parameter(ParameterSetName = 'Another Parameter Set')]
        # [ValidatePattern("[a-z]*")]
        # [ValidateLength(0, 15)]
        # [String]
        # $Param3,

        # # Param4 help description
        # # Checkout the docs https://learn.microsoft.com/en-us/powershell/module/microsoft.powershell.core/about/about_functions_argument_completion?view=powershell-7.5#argumentcompletions-attribute on different ways to provide Argument Completion
        # [Parameter(ParameterSetName = 'Yet Another Parameter Set')]
        # [ArgumentCompleter({'add completer script'})]
        # [ValidateLength(0, 15)]
        # [String]
        # $Param4
    )

    begin {
        $ErrorActionPreference = 'Stop'

        $error.Clear();
        # =====================================================================
        # Configuration
        # =====================================================================
        $Config = @{
            # Azure DevOps REST API version
            ApiVersion       = '7.1'

            # Base URL; {0} is replaced with the organization name
            BaseUrlTemplate  = 'https://dev.azure.com/{0}'

            # Local cache file and how long it stays valid
            #CacheFilePath     = Join-Path $PSScriptRoot 'ado-projects-repos.cache.json'
            CacheFilePath    = Resolve-Path -LiteralPath '\ScriptDataCache\AzureDevOps\ado-projects-repos.cache.json'
            CacheMaxAgeHours = 4320 # 180 days;

            # Secrets file (keep out of source control)
            SecretsFilePath  = Join-Path $PSScriptRoot 'secrets.json'

            # Environment variable names checked before secrets.json
            EnvPatName       = 'AZURE_DEVOP_EXECUTION_PAT'
            EnvOrgName       = 'AZURE_DEVOPS_ORGANIZATION'

            # Page size for the projects API (max 500 per call)
            ProjectsPageSize = 500
        }

        # =====================================================================
        # Secret resolution: $env first, then secrets.json
        # =====================================================================
        $ResolveSecretPath = Join-Path $PSScriptRoot 'Secrets\Resolve-Secret.ps1'
        if (Test-Path -LiteralPath $ResolveSecretPath -PathType Leaf) {
            . $ResolveSecretPath
        }
        else {
            Write-Error "Resolve-Secret.ps1 not found at '$ResolveSecretPath'."
            exit;
        }


        # =====================================================================
        # Cache helpers
        # =====================================================================
        $ReadCachePath = Join-Path $PSScriptRoot 'Cache\Read-Cache.ps1'
        if (Test-Path -LiteralPath $ReadCachePath -PathType Leaf) {
            . $ReadCachePath
        }
        else {
            Write-Error "Read-Cache.ps1 not found at '$ReadCachePath'."
            exit;
        }

        $WriteCachePath = Join-Path $PSScriptRoot 'Cache\Write-Cache.ps1'
        if (Test-Path -LiteralPath $WriteCachePath -PathType Leaf) {
            . $WriteCachePath
        }
        else {
            Write-Error "Write-Cache.ps1 not found at '$WriteCachePath'."
            exit;
        }

        # =====================================================================
        # Azure DevOps API calls
        # =====================================================================
        $GetAdoProjectsPath = Join-Path $PSScriptRoot 'Ado\Get-AdoProjects.ps1'
        if (Test-Path -LiteralPath $GetAdoProjectsPath -PathType Leaf) {
            . $GetAdoProjectsPath
        }
        else {
            Write-Error "Get-AdoProjects.ps1 not found at '$GetAdoProjectsPath'."
            exit;
        }
        $GetAdoRepositoriesPath = Join-Path $PSScriptRoot 'Ado\Get-AdoRepositories.ps1'
        if (Test-Path -LiteralPath $GetAdoRepositoriesPath -PathType Leaf) {
            . $GetAdoRepositoriesPath
        }
        else {
            Write-Error "Get-AdoRepositories.ps1 not found at '$GetAdoRepositoriesPath'."
            exit;
        }

        # =====================================================================
        # Resolve secrets, Setup BaseUrl and set up ADO authentication headers
        # =====================================================================
        $Organization = Resolve-Secret -EnvName $Config.EnvOrgName -JsonKey 'Organization'
        $Pat = Resolve-Secret -EnvName $Config.EnvPatName -JsonKey 'PersonalAccessToken'
        $BaseUrl = $Config.BaseUrlTemplate -f $Organization

        # ADO PAT auth uses Basic with an empty username
        $Headers = @{
            Authorization = 'Basic ' + [Convert]::ToBase64String([Text.Encoding]::ASCII.GetBytes(":$Pat"))
        }

        # =====================================================================
        # Check for errors after loading dependencies; exit if any were encountered;
        # =====================================================================
        if ($error.Count -gt 0) {
            Write-Error "Errors occurred during script execution."
            exit;
        }

    }

    # =====================================================================
    # Main
    # =====================================================================
    
    process {
        if ($pscmdlet.ShouldProcess("Target", "Operation")) {
            $data = if ($ForceRefresh) { $null } else { Read-Cache }

            if (-not $data) {
                Write-Host "Fetching projects and repositories from $BaseUrl ..." -ForegroundColor Cyan

                $data = [pscustomobject]@{
                    Organization = $Organization
                    CachedAtUtc  = (Get-Date).ToUniversalTime().ToString('o')
                    Projects     = @(Get-AdoProjects)
                    Repositories = @(Get-AdoRepositories)
                }

                Write-Cache -Data $data
            }
            else {
                Write-Host "Loaded from cache: $($Config.CacheFilePath)" -ForegroundColor DarkGray
            }

            # Apply optional filters
            $projects = @($data.Projects | Where-Object Name -Like $ProjectName)
            $repos = @($data.Repositories | Where-Object { $_.ProjectName -like $ProjectName -and $_.Name -like $RepoName })

            Write-Host ("{0} project(s), {1} repo(s) (cached {2})" -f $projects.Count, $repos.Count, $data.CachedAtUtc) -ForegroundColor Green
        }
    }

    end {
        # Emit a single object so callers can use .Projects / .Repositories
        [pscustomobject]@{
            Organization  = $data.Organization
            CachedAtUtc   = $data.CachedAtUtc
            CacheFilePath = $Config.CacheFilePath
            ProjectCount  = $projects.Count
            RepoCount     = $repos.Count    
            Projects      = $projects
            Repositories  = $repos
        }

    }

    clean {
        #CleanCodeHere - Added in 7.3 for more information see https://learn.microsoft.com/en-us/powershell/module/microsoft.powershell.core/about/about_functions_advanced_methods?view=powershell-7.5#clean
    }
}
