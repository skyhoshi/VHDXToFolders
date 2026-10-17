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