param(
    [Parameter(Mandatory)] [string]$Organization,   # e.g. "my-org" (no URL)
    [Parameter(Mandatory)] [string]$Project,        # e.g. "My Project"
    [Parameter(Mandatory)] [string]$Repository,     # repo name or repo ID
    [int]$Days = 30
)

$pat = $env:PAT
if (-not $pat) { throw "Set AZDO_PAT environment variable with an Azure DevOps PAT." }

$projectEscaped = [uri]::EscapeDataString($Project)
$base = "https://dev.azure.com/$Organization/$projectEscaped/_apis"

$headers = @{
    Authorization = "Basic " + [Convert]::ToBase64String([Text.Encoding]::ASCII.GetBytes(":$pat"))
}

function Get-Ado([string]$url) {
    Invoke-RestMethod -Method Get -Uri $url -Headers $headers
}

$fromDate = (Get-Date).AddDays(-$Days).ToString("o")

# 1) Repository metadata
$repo = Get-Ado "$base/git/repositories/$Repository?api-version=7.1"

# 2) Branches (for stale branch detection)
$branches = Get-Ado "$base/git/repositories/$($repo.id)/refs?filter=heads/&api-version=7.1"

# 3) Commits in last N days (usage)
$commits = Get-Ado "$base/git/repositories/$($repo.id)/commits?searchCriteria.fromDate=$([uri]::EscapeDataString($fromDate))&`$top=1000&api-version=7.1"

# 4) Pushes in last N days (usage)
$pushes = Get-Ado "$base/git/repositories/$($repo.id)/pushes?searchCriteria.fromDate=$([uri]::EscapeDataString($fromDate))&`$top=1000&api-version=7.1"

# 5) PRs in last N days (health + usage)
$prs = Get-Ado "$base/git/repositories/$($repo.id)/pullRequests?searchCriteria.status=all&`$top=1000&api-version=7.1"

$recentPrs = $prs.value | Where-Object { [datetime]$_.creationDate -ge [datetime]$fromDate }

# 6) Build health for this repo (optional but useful)
$builds = Get-Ado "$base/build/builds?repositoryId=$($repo.id)&repositoryType=TfsGit&minTime=$([uri]::EscapeDataString($fromDate))&`$top=200&api-version=7.1"

# Derived metrics
$activeAuthors = $commits.value | Group-Object { $_.author.email } | Sort-Object Count -Descending
$mergedPrs = $recentPrs | Where-Object { $_.status -eq "completed" }
$closedPrs = $recentPrs | Where-Object { $_.closedDate }
$avgPrHours = if ($closedPrs.Count -gt 0) {
    ($closedPrs | ForEach-Object {
        ([datetime]$_.closedDate - [datetime]$_.creationDate).TotalHours
    } | Measure-Object -Average).Average
} else { 0 }

$buildCompleted = $builds.value | Where-Object { $_.status -eq "completed" }
$buildSuccessRate = if ($buildCompleted.Count -gt 0) {
    (($buildCompleted | Where-Object { $_.result -eq "succeeded" }).Count / $buildCompleted.Count) * 100
} else { 0 }

[pscustomobject]@{
    RepoName              = $repo.name
    DefaultBranch         = $repo.defaultBranch
    WindowDays            = $Days
    Commits               = $commits.count
    Pushes                = $pushes.count
    ActiveContributors    = $activeAuthors.Count
    PullRequests          = $recentPrs.Count
    MergedPRs             = $mergedPrs.Count
    AvgPRCloseHours       = [math]::Round($avgPrHours, 1)
    BuildSuccessRatePct   = [math]::Round($buildSuccessRate, 1)
}