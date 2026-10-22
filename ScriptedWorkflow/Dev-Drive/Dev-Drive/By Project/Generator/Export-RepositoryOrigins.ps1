[CmdletBinding()]
param(
    [Parameter()]
    [string]$RootPath = $PSScriptRoot,

    [Parameter()]
    [ValidateRange(0, 20)]
    [int]$Depth = 1,

    [Parameter()]
    [string]$OutputPath,

    [Parameter()]
    [ValidateSet('Ssh', 'Https')]
    [string]$UrlProtocol = 'Ssh'
)

$ErrorActionPreference = 'Stop'
$null = Get-Command git -ErrorAction Stop
$root = Get-Item -LiteralPath $RootPath
if (-not $root.PSIsContainer) {
    throw "RootPath must be a directory: $RootPath"
}
if ([string]::IsNullOrWhiteSpace($OutputPath)) {
    $OutputPath = Join-Path $root.FullName 'repository-origins.md'
}

function ConvertTo-MarkdownCell {
    param([string]$Value)
    $Value.Replace('|', '&#124;').Replace("`r", ' ').Replace("`n", ' ')
}

$folders = @($root)
$currentLevel = @($root)
for ($level = 1; $level -le $Depth; $level++) {
    $currentLevel = @($currentLevel | ForEach-Object {
        Get-ChildItem -LiteralPath $_.FullName -Directory -Force |
            Where-Object { $_.Name -ne '.git' -and -not ($_.Attributes -band [IO.FileAttributes]::ReparsePoint) }
    })
    $folders += $currentLevel
}

$repositories = @(foreach ($folder in $folders) {
    if (-not (Test-Path -LiteralPath (Join-Path $folder.FullName '.git'))) {
        continue
    }
    $relativePath = '.'
    if ($folder.FullName -ne $root.FullName) {
        $relativePath = $folder.FullName.Substring($root.FullName.TrimEnd('\', '/').Length + 1).Replace('\', '/')
    }
    $origins = @(git -C $folder.FullName config --get-all remote.origin.url)
    $gitExitCode = $LASTEXITCODE
    if ($gitExitCode -gt 1) {
        throw "Failed to read origin for $($folder.FullName) (git exit code $gitExitCode)."
    }
    if ($origins.Count -eq 0) {
        $origins = @('(no origin configured)')
    }
    foreach ($origin in $origins) {
        $organization = $null
        $project = $null
        $repository = $null
        if ($origin -match '^https?://(?:[^/@]+@)?dev\.azure\.com/(?<organization>[^/]+)/(?<project>[^/]+)/_git/(?<repository>[^/?#]+)') {
            $organization = $Matches.organization
            $project = $Matches.project
            $repository = $Matches.repository
        } elseif ($origin -match '^(?:git@ssh\.dev\.azure\.com:v3/|ssh://git@ssh\.dev\.azure\.com(?::\d+)?/v3/)(?<organization>[^/]+)/(?<project>[^/]+)/(?<repository>[^/?#]+)') {
            $organization = $Matches.organization
            $project = $Matches.project
            $repository = $Matches.repository
        } elseif ($origin -match '^https?://(?:[^/@]+@)?(?<organization>[^./]+)\.visualstudio\.com/(?:DefaultCollection/)?(?<project>[^/]+)/_git/(?<repository>[^/?#]+)') {
            $organization = $Matches.organization
            $project = $Matches.project
            $repository = $Matches.repository
        }
        $httpsUrl = ''
        $sshUrl = ''
        if ($organization -and $project -and $repository) {
            $encodedOrganization = [Uri]::EscapeDataString([Uri]::UnescapeDataString($organization))
            $encodedProject = [Uri]::EscapeDataString([Uri]::UnescapeDataString($project))
            $encodedRepository = [Uri]::EscapeDataString([Uri]::UnescapeDataString($repository))
            $httpsUrl = "https://dev.azure.com/$encodedOrganization/$encodedProject/_git/$encodedRepository"
            $sshUrl = "git@ssh.dev.azure.com:v3/$encodedOrganization/$encodedProject/$encodedRepository"
        }
        [pscustomobject]@{
            Folder = $relativePath
            Origin = $origin
            HttpsUrl = $httpsUrl
            SshUrl = $sshUrl
            Organization = [Uri]::UnescapeDataString([string]$organization)
            TeamProject = [Uri]::UnescapeDataString([string]$project)
            RepositoryName = [Uri]::UnescapeDataString([string]$repository)
        }
    }
})

$azureRepositories = @($repositories | Where-Object { $_.TeamProject } |
    Sort-Object Organization, TeamProject, RepositoryName -Unique)
$repositoryCount = @($repositories | Select-Object -ExpandProperty Folder -Unique).Count
$projectCount = @($azureRepositories | Select-Object Organization, TeamProject -Unique).Count
$lines = @(
    '# Repository Origins'
    ''
    "Scan root: $($root.FullName)"
    "Maximum child-folder depth: $Depth (root is depth 0)."
    "Found $repositoryCount Git repositories and $projectCount Azure DevOps team projects."
    ''
    '## Remote Origin URLs'
    ''
    '| Local Folder | Remote Origin URL | HTTPS URL | SSH URL |'
    '| --- | --- | --- | --- |'
)
foreach ($entry in $repositories) {
    $lines += "| $(ConvertTo-MarkdownCell $entry.Folder) | $(ConvertTo-MarkdownCell $entry.Origin) | $(ConvertTo-MarkdownCell $entry.HttpsUrl) | $(ConvertTo-MarkdownCell $entry.SshUrl) |"
}
$lines += @(
    ''
    '## Azure DevOps Team Projects and Repository Names'
    ''
    'Names are extracted from the origin URLs, with URL-encoded characters decoded.'
    ''
    '| Team Project | Repository Name | Repository URL |'
    '| --- | --- | --- |'
)
foreach ($entry in $azureRepositories) {
    $repositoryUrl = $entry.SshUrl
    if ($UrlProtocol -eq 'Https') {
        $repositoryUrl = $entry.HttpsUrl
    }
    $lines += "| $(ConvertTo-MarkdownCell $entry.TeamProject) | $(ConvertTo-MarkdownCell $entry.RepositoryName) | $(ConvertTo-MarkdownCell $repositoryUrl) |"
}
Set-Content -LiteralPath $OutputPath -Value $lines -Encoding UTF8
Write-Output "Exported $repositoryCount repositories and $projectCount Azure DevOps team projects to $OutputPath"