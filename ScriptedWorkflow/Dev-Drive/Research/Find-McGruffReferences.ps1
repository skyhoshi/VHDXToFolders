<#
.SYNOPSIS
    Searches all source code for one or more configurable search terms and generates
    a Markdown report with Azure DevOps deep-links to each match.

.DESCRIPTION
    Scans every text-based source file under the workspace root for any occurrence
    of the -SearchTerms (case-insensitive).  For each match it:
      - Records the repo, file path, and line number
      - Builds an Azure DevOps permalink to the exact line
      - Writes a grouped Markdown report to References.md

    Run this script whenever you want a fresh, up-to-date inventory.

    Files can be suppressed via -ExcludePatterns, which accepts any mix of:
      - File name wildcards    e.g. "*.postman_collection.json", "packages.config"
      - Partial path segments  e.g. "QA/", "bin/", "obj/"
      - Full or partial paths  e.g. "WebAPI.External/source/External.WebApi.IntegrationTests"

    The -SortBy parameter controls how files are ordered within each section:
      FIFO      - filesystem discovery order (default)
      Folder    - alphabetically by folder path then filename
      Solution  - grouped by repo / solution, then by folder path

.PARAMETER WorkspaceRoot
    Root folder of the multi-repo workspace.  Defaults to the directory that
    contains this script (u:\).

.PARAMETER OutputFile
    Full path for the generated Markdown report.  When omitted, the name is built
    automatically as Search-References-{Drive}-{RepoNames}-{Timestamp}.md inside OutputDir.

.PARAMETER OutputDir
    Directory where the auto-named report is written.  Default: D:\ProjectInventoryReports.
    Ignored when OutputFile is supplied explicitly.

.PARAMETER AzureDevOpsOrg
    Azure DevOps organisation name.  Default: fcsamerica

.PARAMETER AzureDevOpsProject
    Azure DevOps project name.  Default: AgentPro

.PARAMETER SearchTerms
    One or more terms to search for (case-insensitive).  A line is included in the
    report when it contains ANY of the supplied terms.  Defaults to @('McGruff').

.PARAMETER Branch
    Git branch name used in the DevOps permalink.  Default: main

.PARAMETER RepoMap
    Ordered hashtable mapping workspace sub-folder names to Azure DevOps repository names.
    Keys are folder names directly under WorkspaceRoot; values are the DevOps repo names.
    Update this table if a repo is renamed or a new repo is added.

.PARAMETER ExcludeLinePatterns
    One or more wildcard or literal strings matched (case-insensitive) against the trimmed
    text of each matching line.  Lines whose text matches any pattern are silently omitted
    from the report.  Useful for filtering out noise such as using-directives.
    Example: "using FCSAmerica.IdentityAccessManagement.McGruffCompatibility;"

.PARAMETER ExcludeFileLines
    One or more "FileName.ext:LineNumber" entries that suppress a specific line in a
    specific file.  Matching is case-insensitive on the filename.  If every matching
    line in a file is suppressed, the file does not appear in the report at all.
    Example: "McGruffSettings.cs:42"  "Startup.cs:17"

.EXAMPLE
    .\Find-McGruffReferences.ps1

.EXAMPLE
    .\Find-McGruffReferences.ps1 -WorkspaceRoot "u:\" -Branch "develop"

.EXAMPLE
    # Exclude QA / test artefacts and sort alphabetically by folder
    .\Find-McGruffReferences.ps1 -SortBy Folder `
        -ExcludePatterns "QA/","*.postman_collection.json","*.postman_environment.json","UnitTests"

.EXAMPLE
    # Exclude packages.config files and a specific project folder
    .\Find-McGruffReferences.ps1 -SortBy Solution `
        -ExcludePatterns "packages.config","WebAPI.External/source/External.WebApi.IntegrationTests"
#>

[CmdletBinding()]
param(
    [string]  $WorkspaceRoot = $PSScriptRoot,
    [string]  $OutputFile = '',
    [string]  $OutputDir = 'D:\ProjectInventoryReports',
    [string]  $AzureDevOpsOrg = "fcsamerica",
    [string]  $AzureDevOpsProject = "AgentPro",
    [string]  $Branch = "main",

    # One or more search terms (case-insensitive).  A line matches when it contains ANY term.
    [string[]]$SearchTerms = @('McGruff'),

    # One or more patterns to exclude. Each pattern is matched (wildcard) against
    # the file's name AND against its repo-relative forward-slash path.
    # Examples: "packages.config"  "*.postman_collection.json"  "QA/"  "obj/"
    [string[]]$ExcludePatterns = @(),

    # One or more wildcard/literal strings matched against each line's trimmed text.
    # Lines whose content matches any pattern are omitted from the report.
    # Example: "using FCSAmerica.IdentityAccessManagement.McGruffCompatibility;"
    [string[]]$ExcludeLinePatterns = @(),

    # One or more "FileName.ext:LineNumber" pairs that suppress an exact line in a specific
    # file.  If all matching lines in a file are suppressed, the file is omitted entirely.
    # Example: "McGruffSettings.cs:42"  "Startup.cs:17"
    [string[]]$ExcludeFileLines = @(),

# File extensions to include in the search
    [string[]]$IncludeExtensions = @("*.cs", "*.config", "*.json", "*.xml","*.csproj", "*.vbproj", "*.yml", "*.yaml","*.txt", "*.md", "*.ps1", "*.sql"),

    # Folder where per-search-term scan caches are stored.
    # Defaults to the FIND_REFS_CACHE_DIR environment variable.
    # Leave empty (or unset the env var) to disable caching.
    [string]  $CacheDir = $env:FIND_REFS_CACHE_DIR,

    # When present, deletes the existing cache file before scanning so all
    # files are re-read from disk regardless of any cached state.
    [switch]  $ClearCache,

    # Sort order for files within each report section.
    # FIFO     = filesystem discovery order
    # Folder   = alphabetical by directory path then filename
    # Solution = by repo/solution name, then by folder path
    [ValidateSet('FIFO', 'Folder', 'Solution')]
    [string]  $SortBy = 'FIFO',

    # Top-level grouping of the report body.
    # Category        = group by category first, then by file  (default)
    # RepoThenCategory = group by repository first, then category, then file
    [ValidateSet('Category', 'RepoThenCategory')]
    [string]  $GroupBy = 'RepoThenCategory',

    # Ordered map of workspace sub-folder name -> Azure DevOps repository name.
    # Omit to auto-discover all sub-folders under WorkspaceRoot (C:\ drive requires explicit definition).
    [System.Collections.Specialized.OrderedDictionary]
    $RepoMap = $null
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

# Auto-discover repos when RepoMap is not supplied
if ($null -eq $RepoMap) {
    $drive = [System.IO.Path]::GetPathRoot($WorkspaceRoot)
    if ($drive -ieq 'C:\') {
        throw "WorkspaceRoot is on C:\ – RepoMap must be defined explicitly to avoid scanning the system drive."
    }
    $RepoMap = [ordered]@{}
    Get-ChildItem -Path $WorkspaceRoot -Directory | Sort-Object Name | ForEach-Object {
        $RepoMap[$_.Name] = $_.Name
    }
    Write-Host "RepoMap auto-discovered: $($RepoMap.Keys -join ', ')" -ForegroundColor DarkGray
}

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

$orgProvided     = $PSBoundParameters.ContainsKey('AzureDevOpsOrg')
$projectProvided = $PSBoundParameters.ContainsKey('AzureDevOpsProject')
if (-not $orgProvided -or -not $projectProvided) {
    foreach ($folderName in $RepoMap.Keys) {
        $adoInfo = Get-AzureDevOpsInfoFromGit -RepoRoot (Join-Path $WorkspaceRoot $folderName)
        if ($null -ne $adoInfo) {
            if (-not $orgProvided)     { $AzureDevOpsOrg     = $adoInfo.Org;     Write-Host "AzureDevOpsOrg auto-detected     : $AzureDevOpsOrg" -ForegroundColor DarkGray }
            if (-not $projectProvided) { $AzureDevOpsProject = $adoInfo.Project; Write-Host "AzureDevOpsProject auto-detected : $AzureDevOpsProject" -ForegroundColor DarkGray }
            break
        }
    }
}

# ---------------------------------------------------------------------------
# Cache setup
# Cache is keyed by a short hash of the SearchTerms so that different term
# sets never share cached results.  Each cache entry stores the file's
# size+last-write signature and the raw (pre-exclusion) matching lines.
# ---------------------------------------------------------------------------
$cacheEnabled = -not [string]::IsNullOrWhiteSpace($CacheDir)
$cacheTable   = @{}   # AbsPath -> @{ Sig; Matches = @(@{ LineNumber; LineText }) }
$cachePath    = $null
$cacheModified = $false

if ($env:FIND_REFS_CACHE_ENABLED -eq "true") {
    $cacheEnabled = $true
}
else{
    $cacheEnabled = $false
}

if ($cacheEnabled) {
    if (-not (Test-Path $CacheDir)) {
        $null = New-Item -ItemType Directory -Path $CacheDir -Force
    }
    $termsKey      = (($SearchTerms | Sort-Object | ForEach-Object { $_.ToLower() }) -join '|') + $WorkspaceRoot;
    $termsKeyBytes = [System.Text.Encoding]::UTF8.GetBytes($termsKey);
    $termsHashBytes = [System.Security.Cryptography.MD5]::Create().ComputeHash($termsKeyBytes)
    $termsHashStr  = [System.BitConverter]::ToString($termsHashBytes).Replace('-','').Substring(0,8).ToLower()
    $cachePath     = Join-Path $CacheDir "findref_$termsHashStr.json"

    if ($ClearCache -and (Test-Path $cachePath)) {
        Remove-Item $cachePath -Force
        Write-Host "Cache cleared : $cachePath" -ForegroundColor Yellow
    }

    if (Test-Path $cachePath) {
        try {
            $cacheJson = Get-Content $cachePath -Raw | ConvertFrom-Json
            foreach ($prop in $cacheJson.Files.PSObject.Properties) {
                $cacheTable[$prop.Name] = @{
                    Sig     = [string]$prop.Value.Sig
                    Matches = @($prop.Value.Matches | ForEach-Object {
                        @{ LineNumber = [int]$_.LineNumber; LineText = [string]$_.LineText }
                    })
                }
            }
            Write-Host "Cache loaded  : $($cacheTable.Count) file entries <- $cachePath" -ForegroundColor DarkGray
        }
        catch {
            Write-Warning "Cache unreadable, ignoring: $_"
            $cacheTable = @{}
        }
    }
}


if ($ExcludePatterns.Count -gt 0) {
    Write-Host "Excluding files matching patterns: $($ExcludePatterns -join ', ')" -ForegroundColor Yellow
    $ExcludePatterns += @("README.md", "packages/", "QA/", "obj/", "bin/", "packages.config", "*.postman_collection.json", "*.postman_environment.json")
}



# ---------------------------------------------------------------------------
# File+line exclusion helper
# Suppresses a specific line number within a specific file.
# Entry format: "[path/]FileName.ext:LineNumber"
#   - Bare filename:  "McGruffSettings.cs:42"
#   - Partial path:   "Source/McGruffSettings.cs:42"
# The path portion is matched (case-insensitive) against BOTH the bare filename
# and the repo-relative forward-slash path, identical to Test-Excluded.
# ---------------------------------------------------------------------------
function Test-FileLineExcluded {
    param(
        [string]$FileName,
        [string]$RepoRelPath,   # forward-slash repo-relative path, e.g. /Source/Foo.cs
        [int]   $LineNumber
    )
    foreach ($entry in $ExcludeFileLines) {
        # Split on the LAST colon so paths with drive letters or dots are safe
        $lastColon = $entry.LastIndexOf(':')
        if ($lastColon -lt 1) { continue }               # malformed entry – skip
        $entryLine = $entry.Substring($lastColon + 1)
        if (-not ($entryLine -match '^\d+$')) { continue } # not a number – skip
        if ([int]$entryLine -ne $LineNumber) { continue }

        $entryPath = $entry.Substring(0, $lastColon).Replace('\', '/').TrimStart('/')

        # Match against bare filename
        if ($FileName -ilike $entryPath) { return $true }

        # Match against repo-relative path (partial match, same as Test-Excluded)
        $cleanRel = $RepoRelPath.Replace('\', '/').TrimStart('/')
        if ($cleanRel -ilike "*$entryPath") { return $true }
    }
    return $false
}

# ---------------------------------------------------------------------------
# Line-exclusion helper
# A line is excluded when its trimmed text matches ANY of the -ExcludeLinePatterns.
#   - Patterns with wildcards (* ? [) use -ilike for glob matching.
#   - All other patterns use a case-insensitive substring/contains check so that
#     quotes, attribute ordering, and minor whitespace differences in config files
#     do not prevent a match.
# ---------------------------------------------------------------------------
function Test-LineExcluded {
    param([string]$LineText)
    $trimmed = $LineText.Trim()
    foreach ($pattern in $ExcludeLinePatterns) {
        if ($pattern -match '[*?\[]') {
            # Wildcard pattern
            if ($trimmed -ilike $pattern) { return $true }
        }
        else {
            # Literal pattern – substring contains (case-insensitive)
            if ($trimmed.IndexOf($pattern, [System.StringComparison]::OrdinalIgnoreCase) -ge 0) { return $true }
        }
    }
    return $false
}

# ---------------------------------------------------------------------------
# Exclusion helper
# A file is excluded when ANY of the -ExcludePatterns matches either:
#   (a) the filename alone                e.g. pattern "packages.config"
#   (b) the repo-relative forward-slash path  e.g. pattern "QA/" or "obj/"
# Patterns may contain the standard wildcards * and ?.
# ---------------------------------------------------------------------------
function Test-Excluded {
    param(
        [System.IO.FileInfo]$File,
        [string]            $RepoRelPath   # forward-slash repo-relative path, e.g. /Source/Foo.cs
    )
    foreach ($pattern in $ExcludePatterns) {
        # Normalise the pattern to forward slashes so partial-path patterns work on Windows
        $normPattern = $pattern.Replace('\', '/')

        # Match against the bare filename
        if ($File.Name -like $normPattern) { return $true }

        # Match against the repo-relative path (strip leading slash for simpler wildcard matching)
        $cleanRel = $RepoRelPath.TrimStart('/')
        if ($cleanRel -like "*$normPattern*") { return $true }
    }
    return $false
}

# ---------------------------------------------------------------------------
# Helper: resolve the current branch from a repo's .git/HEAD file.
# Falls back to $DefaultBranch when .git is absent or HEAD is detached.
# ---------------------------------------------------------------------------
function Get-RepoBranch {
    param([string]$RepoRoot, [string]$DefaultBranch = $Branch)
    $headFile = Join-Path $RepoRoot ".git\HEAD"
    if (Test-Path $headFile) {
        $content = Get-Content $headFile -Raw -ErrorAction SilentlyContinue
        if ($content -match 'ref: refs/heads/(.+)') {
            return $Matches[1].Trim()
        }
    }
    return $DefaultBranch
}

# ---------------------------------------------------------------------------
# Helper: resolve the Azure DevOps repo name from .git/config remote URL.
# Parses the /_git/<name> segment; falls back to $DefaultName.
# ---------------------------------------------------------------------------
function Get-RepoNameFromGit {
    param([string]$RepoRoot, [string]$DefaultName)
    $configFile = Join-Path $RepoRoot ".git\config"
    if (Test-Path $configFile) {
        $content = Get-Content $configFile -Raw -ErrorAction SilentlyContinue
        if ($content -match '/_git/([^\s"/?&#]+)') {
            return $Matches[1].Trim()
        }
    }
    return $DefaultName
}

# ---------------------------------------------------------------------------
# Helper: build a DevOps file URL with optional line anchor
# ---------------------------------------------------------------------------
function Get-DevOpsUrl {
    param(
        [string]$Repo,
        [string]$RepoRelativePath,   # forward-slash path within the repo, e.g. /Source/Foo.cs
        [int]   $Line = 0,
        [string]$BranchName = $Branch
    )
    $base = "https://dev.azure.com/$AzureDevOpsOrg/$AzureDevOpsProject/_git/$Repo"
    $url = "${base}?path=$RepoRelativePath&version=GB$BranchName"
    if ($Line -gt 0) { $url += "&line=$Line&lineEnd=$Line&lineStartColumn=1&lineEndColumn=9999" }
    return $url
}

# ---------------------------------------------------------------------------
# Scan every repo
# ---------------------------------------------------------------------------
Write-Host "Scanning workspace: $WorkspaceRoot" -ForegroundColor Cyan
Write-Host "Search terms  : $($SearchTerms -join ', ')" -ForegroundColor Cyan
if ($cacheEnabled) {
    Write-Host "Cache file    : $cachePath" -ForegroundColor Cyan
}

# Each entry: [RepoFolder, RepoName, FileRepoRelPath, AbsPath, LineNumber, LineText, DiscoveryIndex]
$allMatches = [System.Collections.Generic.List[PSCustomObject]]::new()
$excludedFiles = [System.Collections.Generic.List[string]]::new()
$discoveredRepoNames = [System.Collections.Generic.List[string]]::new()
$discoveryIdx = 0

foreach ($folderName in $RepoMap.Keys) {
    $repoRoot = Join-Path $WorkspaceRoot $folderName

    if (-not (Test-Path $repoRoot)) {
        Write-Warning "Repo folder not found, skipping: $repoRoot"
        continue
    }

    # Resolve repo name and current branch from .git metadata (fall back to RepoMap / param)
    $repoName   = Get-RepoNameFromGit -RepoRoot $repoRoot -DefaultName $RepoMap[$folderName]
    $repoBranch = Get-RepoBranch      -RepoRoot $repoRoot -DefaultBranch $Branch

    if (-not $discoveredRepoNames.Contains($repoName)) { $discoveredRepoNames.Add($repoName) }

    Write-Host "  Scanning $folderName -> repo '$repoName' (branch: $repoBranch) ..." -ForegroundColor DarkCyan

    $files = Get-ChildItem -Path $repoRoot -Recurse -File -Include $IncludeExtensions -ErrorAction SilentlyContinue

    foreach ($file in $files) {
        # Build repo-relative path up front (needed for exclusion check)
        $relPath = $file.FullName.Substring($repoRoot.Length).Replace("\", "/")
        if (-not $relPath.StartsWith("/")) { $relPath = "/" + $relPath }

        # Apply exclusion patterns before reading the file
        if ($ExcludePatterns.Count -gt 0 -and (Test-Excluded -File $file -RepoRelPath $relPath)) {
            $excludedFiles.Add("$folderName$relPath")
            continue
        }

        # ------------------------------------------------------------------
        # Cache lookup: if this file's size+last-write matches a cached entry
        # use the stored raw matches; otherwise scan from disk.
        # ------------------------------------------------------------------
        $fileSig        = "$($file.Length):$($file.LastWriteTimeUtc.Ticks)"
        $rawLineMatches = $null

        if ($cacheEnabled -and $cacheTable.ContainsKey($file.FullName)) {
            $entry = $cacheTable[$file.FullName]
            if ($entry.Sig -eq $fileSig) {
                $rawLineMatches = $entry.Matches   # cache hit
            }
        }

        if ($null -eq $rawLineMatches) {
            # Cache miss – read and scan the file

            # Skip binary-like files
            try {
                $bytes = [System.IO.File]::ReadAllBytes($file.FullName) | Select-Object -First 8192
                if ($bytes -contains 0) {
                    if ($cacheEnabled) {
                        $cacheTable[$file.FullName] = @{ Sig = $fileSig; Matches = @() }
                        $cacheModified = $true
                    }
                    continue
                }
            }
            catch { continue }

            try   { $lines = [System.IO.File]::ReadAllLines($file.FullName) }
            catch { continue }

            $rawLineMatches = [System.Collections.Generic.List[hashtable]]::new()
            for ($i = 0; $i -lt $lines.Count; $i++) {
                $lineHit = $false
                foreach ($term in $SearchTerms) {
                    if ($lines[$i] -imatch [regex]::Escape($term)) { $lineHit = $true; break }
                }
                if ($lineHit) {
                    $rawLineMatches.Add(@{ LineNumber = $i + 1; LineText = $lines[$i].Trim() })
                }
            }

            # Store result in cache (including empty list for files with no matches)
            if ($cacheEnabled) {
                $cacheTable[$file.FullName] = @{ Sig = $fileSig; Matches = @($rawLineMatches) }
                $cacheModified = $true
            }
        }

        # Apply per-line exclusions and accumulate final matches
        $fileHasMatch = $false
        foreach ($rm in $rawLineMatches) {
            if ($ExcludeLinePatterns.Count -gt 0 -and (Test-LineExcluded      -LineText $rm.LineText)) { continue }
            if ($ExcludeFileLines.Count   -gt 0 -and (Test-FileLineExcluded  -FileName $file.Name -RepoRelPath $relPath -LineNumber $rm.LineNumber)) { continue }
            if (-not $fileHasMatch) { $fileHasMatch = $true; $discoveryIdx++ }
            $allMatches.Add([PSCustomObject]@{
                    RepoFolder     = $folderName
                    RepoName       = $repoName
                    Branch         = $repoBranch
                    RelPath        = $relPath
                    AbsPath        = $file.FullName
                    FileName       = $file.Name
                    Directory      = [System.IO.Path]::GetDirectoryName($file.FullName)
                    LineNumber     = $rm.LineNumber
                    LineText       = $rm.LineText
                    DiscoveryIndex = $discoveryIdx
                })
        }
    }  # end foreach ($file in $files)
}  # end foreach ($folderName in $RepoMap.Keys)

# Save cache if any entries were added or updated
if ($cacheEnabled -and $cacheModified) {
    try {
        [PSCustomObject]@{
            Version = '1'
            SavedAt = (Get-Date -Format 'o')
            Terms   = $SearchTerms
            Files   = $cacheTable
        } | ConvertTo-Json -Depth 5 | Set-Content -Path $cachePath -Encoding UTF8
        Write-Host "Cache saved   : $($cacheTable.Count) entries -> $cachePath" -ForegroundColor DarkGray
    }
    catch {
        Write-Warning "Could not save cache: $_"
    }
}

# Build output file path from drive letter + repo names when not explicitly supplied
if ([string]::IsNullOrWhiteSpace($OutputFile)) {
    $driveLetter  = ($WorkspaceRoot -replace '^([A-Za-z]):.*', '$1').ToUpper()
    $repoSegment  = ($discoveredRepoNames | Select-Object -Unique) -join '-'
    $timestamp    = Get-Date -Format 'yyyyMMddHHmmss'
    $OutputFile   = Join-Path $OutputDir "Search-References-${driveLetter}-${repoSegment}-${timestamp}.md"
}

Write-Host ""
Write-Host "Total matches : $($allMatches.Count)" -ForegroundColor Green
if ($excludedFiles.Count -gt 0) {
    Write-Host "Excluded files: $($excludedFiles.Count)" -ForegroundColor DarkYellow
}
Write-Host "Sort order    : $SortBy" -ForegroundColor Cyan
Write-Host "Group by      : $GroupBy" -ForegroundColor Cyan

# ---------------------------------------------------------------------------
# Categorise matches by file type / content
# ---------------------------------------------------------------------------

# Build a single regex alternation from all SearchTerms for use in category rules
$searchTermsPattern = ($SearchTerms | ForEach-Object { [regex]::Escape($_) }) -join '|'

function Get-Category {
    param([PSCustomObject]$m)

    $path = $m.RelPath
    $text = $m.LineText

    if ($path -match "packages\.config") { return "NuGet Package References" }
    if ($path -match "Web\.config|app\.config|Web\.Release") { return "Configuration Files" }
    if ($path -match "ISettings\.cs") { return "Settings Interfaces" }
    if ($path -match "SettingService\.cs|Settings\.cs" -and
        $path -notmatch "Test|Spec") { return "Settings Classes" }
    if ($path -match "I($searchTermsPattern)") { return "Interfaces" }
    if ($path -match "($searchTermsPattern).*(Factory|Wrapper)" -and
        $path -notmatch "I[A-Z]") { return "Implementation Classes" }
    if ($path -match "UnityConfig|Startup") { return "Dependency Injection Registration" }
    if ($path -match "UnitTest|IntegrationTest|Spec|Test") { return "Tests" }
    if ($path -match "\.postman_collection|\.postman_environment|Postman") { return "QA / Postman Collections" }
    if ($text -match "using.*($searchTermsPattern)") { return "Using Directives" }
    return "Other Source Files"
}

# ---------------------------------------------------------------------------
# Sort helper – returns a sorted pipeline of file groups based on -SortBy
# ---------------------------------------------------------------------------
function Sort-FileGroups {
    param($Groups)
    switch ($SortBy) {
        'FIFO' { $Groups | Sort-Object { ($_.Group | Measure-Object DiscoveryIndex -Minimum).Minimum } }
        'Folder' { $Groups | Sort-Object { $_.Group[0].Directory } }
        'Solution' { $Groups | Sort-Object { "$($_.Group[0].RepoName)|$($_.Group[0].Directory)" } }
    }
}

# ---------------------------------------------------------------------------
# Build the Markdown document
# ---------------------------------------------------------------------------
$timestamp = Get-Date -Format "yyyy-MM-dd HH:mm"
$sb = [System.Text.StringBuilder]::new()

$null = $sb.AppendLine("# Source Code References – $($SearchTerms -join ', ')")
$null = $sb.AppendLine("")
$null = $sb.AppendLine("> **Generated:** $timestamp  ")
$null = $sb.AppendLine("> **Script:** ``Find-McGruffReferences.ps1``  ")
$null = $sb.AppendLine("> **Workspace:** ``$WorkspaceRoot``  ")
$null = $sb.AppendLine("> **DevOps Org / Project:** $AzureDevOpsOrg / $AzureDevOpsProject  ")
$null = $sb.AppendLine("> **Branch:** $Branch  ")
$null = $sb.AppendLine("> **Search terms:** $($SearchTerms -join ', ')  ")
if ($cacheEnabled) {
    $null = $sb.AppendLine("> **Cache:** ``$cachePath``  ")
}
$null = $sb.AppendLine("> **Sort order:** $SortBy  ")
$null = $sb.AppendLine("> **Group by:** $GroupBy  ")
if ($ExcludePatterns.Count -gt 0) {
    $patternList = $ExcludePatterns -join ", "
    $null = $sb.AppendLine("> **Excluded patterns:** ``$patternList``  ")
    $null = $sb.AppendLine("> **Files excluded:** $($excludedFiles.Count)  ")
}
$null = $sb.AppendLine("")
$null = $sb.AppendLine("---")
$null = $sb.AppendLine("")
$null = $sb.AppendLine("## Summary")
$null = $sb.AppendLine("")
$null = $sb.AppendLine("| Repository | Matches |")
$null = $sb.AppendLine("|---|---|")

$byRepo = $allMatches | Group-Object RepoName | Sort-Object Name
foreach ($grp in $byRepo) {
    $null = $sb.AppendLine("| $($grp.Name) | $($grp.Count) |")
}
$null = $sb.AppendLine("| **Total** | **$($allMatches.Count)** |")
if ($excludedFiles.Count -gt 0) {
    $null = $sb.AppendLine("")
    $null = $sb.AppendLine("> $($excludedFiles.Count) file(s) were excluded by pattern filter and do not appear in the counts above.")
}
$null = $sb.AppendLine("")
$null = $sb.AppendLine("---")
$null = $sb.AppendLine("")

# Attach Category to every match (needed by both modes)
$taggedMatches = $allMatches |
    ForEach-Object { $_ | Add-Member -NotePropertyName Category -NotePropertyValue (Get-Category $_) -PassThru }

# ---------------------------------------------------------------------------
# Shared inner renderer: emit all files in a pre-grouped collection
# ---------------------------------------------------------------------------
function Write-FileSection {
    param(
        [System.Text.StringBuilder]$Builder,
        [object[]]$Matches,
        [int]$HeadingLevel = 3   # '###' by default
    )
    $prefix = '#' * $HeadingLevel
    $byFile = Sort-FileGroups -Groups ($Matches | Group-Object AbsPath)
    foreach ($fileGrp in $byFile) {
        $first   = $fileGrp.Group[0]
        $fileUrl = Get-DevOpsUrl -Repo $first.RepoName -RepoRelativePath $first.RelPath -BranchName $first.Branch
        $null = $Builder.AppendLine("$prefix [$($first.RepoName) – $($first.FileName)]($fileUrl)")
        $null = $Builder.AppendLine("")
        $null = $Builder.AppendLine("**Path:** ``$($first.RepoFolder)$($first.RelPath)``  ")
        $null = $Builder.AppendLine("")
        $null = $Builder.AppendLine("| Line | Code | DevOps Link |")
        $null = $Builder.AppendLine("|---:|---|---|")
        foreach ($m in ($fileGrp.Group | Sort-Object LineNumber)) {
            $lineUrl = Get-DevOpsUrl -Repo $m.RepoName -RepoRelativePath $m.RelPath -Line $m.LineNumber -BranchName $m.Branch
            $escaped = $m.LineText -replace "\|", "\|" -replace "`r", ""
            $null = $Builder.AppendLine("| $($m.LineNumber) | ``$escaped`` | [View]($lineUrl) |")
        }
        $null = $Builder.AppendLine("")
    }
}

if ($GroupBy -eq 'Category') {
    # -----------------------------------------------------------------------
    # Mode: Category  (original behaviour)
    # H2 = category  |  H3 = file
    # -----------------------------------------------------------------------
    $categories = $taggedMatches | Group-Object Category | Sort-Object Name
    foreach ($cat in $categories) {
        $null = $sb.AppendLine("## $($cat.Name)")
        $null = $sb.AppendLine("")
        Write-FileSection -Builder $sb -Matches $cat.Group -HeadingLevel 3
    }
}
else {
    # -----------------------------------------------------------------------
    # Mode: RepoThenCategory
    # H2 = repository  |  H3 = category  |  H4 = file
    # -----------------------------------------------------------------------
    $byRepo = $taggedMatches | Group-Object RepoName | Sort-Object Name
    foreach ($repoGrp in $byRepo) {
        $null = $sb.AppendLine("## Repo: $($repoGrp.Name)")
        $null = $sb.AppendLine("")
        $categories = $repoGrp.Group | Group-Object Category | Sort-Object Name
        foreach ($cat in $categories) {
            $null = $sb.AppendLine("### $($cat.Name)")
            $null = $sb.AppendLine("")
            Write-FileSection -Builder $sb -Matches $cat.Group -HeadingLevel 4
        }
    }
}



# ---------------------------------------------------------------------------
# Appendix: NuGet package versions
# ---------------------------------------------------------------------------


# $packageMatches = $allMatches | Where-Object { $_.RelPath -match "packages\.config" }
# $packageLines = $packageMatches | Where-Object { $_.LineText -match 'id=".*McGruff' }
# if ($packageLines.Count -ne 0) {

#     $null = $sb.AppendLine("---")
#     $null = $sb.AppendLine("")
#     $null = $sb.AppendLine("## Appendix: McGruff NuGet Package Versions Found")
#     $null = $sb.AppendLine("")
#     $null = $sb.AppendLine("| Package | Version | packages.config |")
#     $null = $sb.AppendLine("|---|---|---|")


#     foreach ($pm in ($packageLines | Sort-Object { $_.LineText })) {
#         if ($pm.LineText -match 'id="([^"]+)".*version="([^"]+)"') {
#             $pkgId = $Matches[1]
#             $pkgVer = $Matches[2]
#             $pkgUrl = Get-DevOpsUrl -Repo $pm.RepoName -RepoRelativePath $pm.RelPath -Line $pm.LineNumber
#             $null = $sb.AppendLine("| $pkgId | $pkgVer | [View]($pkgUrl) |")
#         }
#     }
# }
$null = $sb.AppendLine("")
$null = $sb.AppendLine("---")
$null = $sb.AppendLine("")
$null = $sb.AppendLine("*Report generated by ``Find-McGruffReferences.ps1``. Re-run the script to refresh.*")

# ---------------------------------------------------------------------------
# Write output file
# ---------------------------------------------------------------------------
[System.IO.File]::WriteAllText($OutputFile, $sb.ToString(), [System.Text.Encoding]::UTF8)
Write-Host ""
Write-Host "Report written to: $OutputFile" -ForegroundColor Green
