
function Get-AzureDevOpsInfo {
    <#
.SYNOPSIS
    Retrieves Azure DevOps organization and project information for a given workspace.

.DESCRIPTION
    Returns the Azure DevOps organization and project associated with a workspace root.
    If AzureDevOpsOrg or AzureDevOpsProject are not supplied, the function attempts to
    auto-detect them by parsing the git remote URL from the repository's .git/config file.
    Both SSH (git@ssh.dev.azure.com) and HTTPS (https://dev.azure.com) remote formats are supported.

.PARAMETER WorkspaceRoot
    The root directory of the repository to inspect. Used to locate the .git/config file
    when auto-detecting org and project.

.PARAMETER AzureDevOpsOrg
    The Azure DevOps organization name. If omitted, the function attempts to detect it
    from the git remote URL.

.PARAMETER AzureDevOpsProject
    The Azure DevOps project name. If omitted, the function attempts to detect it
    from the git remote URL.

.OUTPUTS
    Hashtable with keys AzureDevOpsOrg and AzureDevOpsProject.

.EXAMPLE
    Get-AzureDevOpsInfo -WorkspaceRoot 'C:\Projects\MyRepo'

    Auto-detects org and project from the repo's git remote and returns them.

.EXAMPLE
    Get-AzureDevOpsInfo -WorkspaceRoot 'C:\Projects\MyRepo' -AzureDevOpsOrg 'MyOrg' -AzureDevOpsProject 'MyProject'

    Returns the explicitly supplied org and project without inspecting the git remote.

.NOTES
    Requires PowerShell 7.3+ for the clean block.
    See: https://learn.microsoft.com/en-us/powershell/module/microsoft.powershell.core/about/about_functions_advanced_methods
#>


    [CmdletBinding(DefaultParameterSetName = 'ParameterSet1',
        SupportsShouldProcess,
        PositionalBinding,
        HelpUri = 'http://yourwebsiteforhelp.here',
        ConfirmImpact = 'Medium')]
    [Alias('Be-lazyWithThis', 'lzy', 'Use-OldFunctionName')]
    [OutputType([String])]
    param (

        [Parameter(Mandatory = $true)]
        [string]$WorkspaceRoot,

        [Parameter(Mandatory = $false)]
        [string]$AzureDevOpsOrg,

        [Parameter(Mandatory = $false)]
        [string]$AzureDevOpsProject

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
        $orgProvided = $PSBoundParameters.ContainsKey('AzureDevOpsOrg')
        $projectProvided = $PSBoundParameters.ContainsKey('AzureDevOpsProject')
    }

    process {
        if ($pscmdlet.ShouldProcess("Target", "Operation")) {
            
            <# [CmdletBinding()]
            param(

                [Parameter(Mandatory = $true)]
                [string]$WorkspaceRoot,

                [Parameter(Mandatory = $false)]
                [string]$AzureDevOpsOrg,

                [Parameter(Mandatory = $false)]
                [string]$AzureDevOpsProject
            ) #>

            # ---------------------------------------------------------------------------
            # Auto-detect AzureDevOpsOrg / AzureDevOpsProject from the first repo's git remote
            # ---------------------------------------------------------------------------
            function Get-AzureDevOpsInfoFromGit {
                param([string]$RepoRoot)
                $configFile = Join-Path $RepoRoot ".git\config"
                if (-not (Test-Path $configFile)) { return $null }
                $content = Get-Content $configFile -Raw -ErrorAction SilentlyContinue
                if (-not $content) { return $null }
                # SSH:   git@ssh.dev.azure.com:v3/{org}/{project}/{repo}
                if ($content -match 'url\s*=\s*git@ssh\.dev\.azure\.com:v3/([^/\s]+)/([^/\s]+)/([^\s]+)') {
                    return @{ Org = $Matches[1]; Project = $Matches[2]; Repo = $Matches[3] }
                }
                # HTTPS: https://dev.azure.com/{org}/{project}/_git/{repo}
                if ($content -match 'url\s*=\s*https?://dev\.azure\.com/([^/\s]+)/([^/\s]+)/_git/([^\s]+)') {
                    return @{ Org = $Matches[1]; Project = $Matches[2]; Repo = $Matches[3] }
                }
                return $null
            }

            if (-not $orgProvided -or -not $projectProvided) {                
                $adoInfo = Get-AzureDevOpsInfoFromGit -RepoRoot $WorkspaceRoot
                if ($null -ne $adoInfo) {
                    if (-not $orgProvided) { $AzureDevOpsOrg = $adoInfo.Org; Write-Host "AzureDevOpsOrg auto-detected     : $AzureDevOpsOrg" -ForegroundColor DarkGray }
                    if (-not $projectProvided) { $AzureDevOpsProject = $adoInfo.Project; Write-Host "AzureDevOpsProject auto-detected : $AzureDevOpsProject" -ForegroundColor DarkGray }
                }
            }
        }
    }

    end {
        return @{
            AzureDevOpsOrg     = $AzureDevOpsOrg
            AzureDevOpsProject = $AzureDevOpsProject
        }
    }

    <#     clean {
        #CleanCodeHere - Added in 7.3 for more information see https://learn.microsoft.com/en-us/powershell/module/microsoft.powershell.core/about/about_functions_advanced_methods?view=powershell-7.5#clean
    } #>
}
