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

Remove-Item Function:\Get-AdoProjectsAndRepos -ErrorAction SilentlyContinue;
Remove-Item Function:\Read-Cache -ErrorAction SilentlyContinue;
Remove-Item Function:\Write-Cache -ErrorAction SilentlyContinue;
Remove-Item Function:\Resolve-Secret -ErrorAction SilentlyContinue;
Remove-Item Function:\Get-AdoProjects -ErrorAction SilentlyContinue;
Remove-Item Function:\Get-AdoRepositories -ErrorAction SilentlyContinue;
$error.Clear();
<#
    TEST SETUP
#>
$GetAdoProjectAndReposPath = Join-Path $PSScriptRoot '..\Get-AdoProjectsAndRepos.ps1'
if (Test-Path -LiteralPath $GetAdoProjectAndReposPath -PathType Leaf) {
    . $GetAdoProjectAndReposPath
}
else {
    Write-Error "Get-AdoProjectsAndRepos.ps1 not found at '$GetAdoProjectAndReposPath'."
    exit;
}
<#
    TESTS
#>

# Example test for using default parameters
Get-AdoProjectsAndRepos

# Example test for filtering by project name
Get-AdoProjectsAndRepos -ProjectName 'My*'

# Example test for filtering by repository name
Get-AdoProjectsAndRepos -RepoName '*Api*'

# Example test for filtering by both project and repository name
Get-AdoProjectsAndRepos -ProjectName 'My*' -RepoName '*Hub*'

# Example test for forcing a refresh without any filters
# Get-AdoProjectsAndRepos -ForceRefresh