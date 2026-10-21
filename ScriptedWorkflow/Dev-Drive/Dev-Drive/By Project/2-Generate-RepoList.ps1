# Exclusion filters are fuzzy (case/separator-insensitive contains, wildcards allowed); a repo matching ANY value in ANY filter is excluded.
# e.g. -ExcludeTeamProjectName 'archive','intern' -ExcludeRepoName 'qa'
[CmdletBinding()]
param(
    [string[]] $ExcludeProjectId = @(),
    [string[]] $ExcludeRepoId = @(),
    [string[]] $ExcludeTeamProjectName = @("Archive", "deprecated", "2021 Intern Team 3","Android Robolectric Test","Block-a-thon","DevOps_PoC", "AI Engineering", "AI Team", "QA"),
    [string[]] $ExcludeRepoName = @("SSIS","QA", "Test", "Demo")
)

function Test-FuzzyMatch {
    param([string] $Value, [string[]] $Patterns)

    if (-not $Patterns -or $Patterns.Count -eq 0) { return $false }

    # Ignore case and separators so 'my api', 'My-Api' and 'my_api' all match 'MyApi'
    $normalizedValue = $Value -replace '[^a-zA-Z0-9]', ''
    foreach ($pattern in $Patterns) {
        $normalizedPattern = $pattern -replace '[^a-zA-Z0-9*?]', ''
        if ($normalizedValue -like "*$normalizedPattern*") { return $true }
    }
    return $false
}

# =====================================================================
# Secret resolution: $env first, then secrets.json
# =====================================================================
$GetAdoProjectsAndReposPath = Join-Path $PSScriptRoot '..\AzureDevOps\Get-AdoProjectsAndRepos.ps1'
if (Test-Path -LiteralPath $GetAdoProjectsAndReposPath -PathType Leaf) {
    . $GetAdoProjectsAndReposPath
}
else {
    Write-Error "Get-AdoProjectsAndRepos.ps1 not found at '$GetAdoProjectsAndReposPath'."
    exit;
}

$AdoProjectsAndRepos = Get-AdoProjectsAndRepos;
# $d = Get-Content 'D:\ScriptDataCache\AzureDevOps\ado-projects-repos.cache.json' -Raw | ConvertFrom-Json; $ids = @($d.Projects.Id); "Projects: $($d.Projects.Count)  Repos: $($d.Repositories.Count)"; $un = @($d.Repositories | Where-Object { $_.ProjectId -notin $ids }); "Unmatched repos: $($un.Count)"; $un | Select-Object -First 5 Name, ProjectId, ProjectName | Format-Table
#$AdoProjectsAndRepos | Format-Table -AutoSize;

$CsvPath = 'D:\ScriptDataCache\AzureDevOps\ado-project-repo-list.csv'

$projectsById = @{}
foreach ($project in $AdoProjectsAndRepos.Projects) { $projectsById[$project.Id] = $project }

$filteredRepos = @($AdoProjectsAndRepos.Repositories | Where-Object {
        $resolvedProjectName = if ($projectsById.ContainsKey($_.ProjectId)) { $projectsById[$_.ProjectId].Name } else { $_.ProjectName }
        -not (
            (Test-FuzzyMatch $_.ProjectId $ExcludeProjectId) -or
            (Test-FuzzyMatch $_.Id $ExcludeRepoId) -or
            (Test-FuzzyMatch $_.Name $ExcludeRepoName) -or
            (Test-FuzzyMatch $resolvedProjectName $ExcludeTeamProjectName)
        )
    })

$unmatched = @($filteredRepos | Where-Object { -not $projectsById.ContainsKey($_.ProjectId) })
$skipUnmatched = $false
if ($unmatched.Count -gt 0) {
    Write-Warning "$($unmatched.Count) repo(s) have a ProjectId that does not match any Team Project:"
    $unmatched | Select-Object Name, ProjectId, ProjectName | Format-Table -AutoSize | Out-Host

    $choice = Read-Host "[U]se the repo's own ProjectName, [S]kip these repos, or [A]bort? (U/S/A)"
    switch ($choice.ToUpperInvariant()) {
        'U' { }
        'S' { $skipUnmatched = $true }
        default { Write-Host 'Aborted.' -ForegroundColor Yellow; return }
    }
}

$rows = foreach ($repo in $filteredRepos) {
    $project = $projectsById[$repo.ProjectId]
    if (-not $project -and $skipUnmatched) { continue }

    [pscustomobject]@{
        TeamProjectName   = if ($project) { $project.Name } else { $repo.ProjectName }
        RepoName          = $repo.Name
        SshUrl            = $repo.SshUrl
        ProjectId         = $repo.ProjectId
        DefaultBranch     = $repo.DefaultBranch
    }
}

if (@($rows).Count -eq 0) {
    Write-Warning "No repos matched the filters; '$CsvPath' was not modified."
    return
}

$rows | Sort-Object TeamProjectName | Export-Csv -LiteralPath $CsvPath -NoTypeInformation -Encoding utf8
Write-Host "Wrote $(@($rows).Count) row(s) to $CsvPath" -ForegroundColor Green

