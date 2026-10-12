#Requires -Version 5.1
<#
.SYNOPSIS
    Scans local workspace drives for .sln and .csproj files, classifies projects,
    detects MSMQ usage, and generates grouped inventory reports in Markdown format.

.DESCRIPTION
    1. Discovers all .sln files on local fixed drives (excluding O: and P:)
    2. Parses project references from each .sln
    3. Classifies each referenced .csproj as: web, exe, or library
       - web  : contains IIS / IIS Express / Sdk.Web / Web project GUID
       - exe  : OutputType is Exe/WinExe and not web
       - library : everything else
    4. Detects MSMQ usage via System.Messaging / MSMQ / MessageQueue references
    5. Writes Markdown-formatted reports with tables instead of bullet points

.PARAMETER OutputDir
    Folder where all report files are written. Default: D:\kernm.devcontainer.envsetup

.PARAMETER ExcludeDrives
    Comma-separated list of drive letters to exclude. Default: O, P

.PARAMETER ExcludeSlnPaths
    List of SLN paths to exclude from processing. Accepts absolute paths (drive letter is stripped)
    or relative paths. Defaults to a pre-populated exclusion list.

.EXAMPLE
    .\Run-ProjectInventory_MARKDOWN.ps1
    .\Run-ProjectInventory_MARKDOWN.ps1 -OutputDir "C:\Reports"
#>
[CmdletBinding()]
param(
    [string]$OutputDir       = 'D:\ProjectInventoryReports', #Default output directory for reports
    [string[]]$IncludeOnlyDrives = @(),
    [string[]]$ExcludeDrives = @('C', 'D', 'W','O','P'), #Excluded Drives: C: (Windows), D: (Dev-Drive), F: (Dev-Drive) , O: (Network Drive), P: (Network Drive)
    [string[]]$ExcludeSlnPaths = @(
        # 'M:\AgriLytic\Components\Admin\Admin.sln',
        # 'M:\AgriLytic\Components\BatchRunner\BatchRunner.sln',
        # 'M:\AgriLytic\Components\CacheApi\CacheApi.sln',
        # 'M:\AgriLytic\Components\Hmda\HmdaReport.sln',
        # 'M:\AgriLytic\Components\Tests\AutomatedTesting\AutomatedTesting.sln',
        # 'M:\AgriLytic\Source\AgriLytic.sln',
        # 'N:\LoanIQDataMart\Source\LoanIQDataMartSolution\LIQAll.sln',
        # 'N:\LoanIQDataMart\Source\LoanIQDataMartSolution\LiqUI.sln',
        # 'N:\LoanIQDataMart\Source\LoanIQDataMartSolution\LIQWebApi.sln',
        # 'R:\CollateralHub\Source\CollateralHub\CollateralHub.ClickOnce.sln',
        # 'R:\CollateralHub\Source\CollateralHub\CollateralHub.sln',
        # 'R:\CollateralHub\Source\SpiderwebGraphDemo\Demo.WpfGraphApplication.sln',
        # 'R:\Financial Data Mart\src\FinancialDataMart.sln',
        # 'R:\NetFins.worktrees\main\BuildProcessTemplates\Solution\BuildProcessTemplates\BuildProcessTemplates.sln',
        # 'R:\NetFins.worktrees\main\Source\NetFins\ClientProxy\ClientProxy.sln',
        # 'R:\NetFins.worktrees\main\Source\NetFins\NetFins.sln',
        # 'R:\NetFins.worktrees\main\UITests\UITests.sln',
        # 'R:\NetFins.worktrees\main\UITests\UITests\UITests.sln',
        # 'R:\NetFins\src\Agrinomics.sln',
        # 'S:\CreditAndResolutionsTool\QA\AB Tester\src\BetterConsoleApp.sln',
        # 'S:\CreditAndResolutionsTool\QA\ApiTestingTool\ApiTestingTool.sln',
        # 'S:\CreditAndResolutionsTool\src\CreditAndResolutionsTool.sln',
        # 'U:\OperationScope\Source\OperationScope.sln',
        # 'V:\PinPointClient\Source\AdminTools_Solution\AdminTools_Solution.sln',
        # 'V:\PinPointClient\Source\Client_Solution\Client_Solution.sln',
        #'R:\CreditAndResolutionsTool\Source\CreditAndResolutionsTool.sln'
        #,'U:\Renewal.WebAPI\Quoting_ProofOfConcept\InsuranceQuoting_ProofOfConcept.sln'
    )
)
$KnownNoteableProjects = [System.Collections.Generic.Dictionary[string,string]]::new()

# $KnownNoteableProjects.Add('', '🟢')
# $KnownNoteableProjects.Add('', '🟠')

$KnownNoteableProjects.Add('J:\TransactCivSubscriber\Source\WCFHost\WCFHost.csproj', '🟠')
$KnownNoteableProjects.Add('I:\OktaCIVSubscriber\Source\CivSubscriber\CivSubscriber.csproj', '🟠')
$KnownNoteableProjects.Add('G:\FindIt\FindIt.Crawler\FindIt.Crawler.csproj', '🟢')
$KnownNoteableProjects.Add('G:\FindIt\FindIt.CivSubscriber\FindIt.CivSubscriber.csproj', '🟠')
$KnownNoteableProjects.Add('G:\FindIt\UpdateEuasData\UpdateEuasData.csproj', '🟢')
$KnownNoteableProjects.Add('G:\FindIt\FindIt.Web\FindIt.Web.csproj', '🟢')
$KnownNoteableProjects.Add('G:\FindIt\FindIt.IndexCustomers\FindIt.IndexCustomers.csproj', '🟢')
$KnownNoteableProjects.Add('H:\CivSubscriber\LoanMonitoringCivSubscriber.csproj', '🟠')
$KnownNoteableProjects.Add('K:\Ada\Source\Service Layer\WebServiceHost\WebServiceHost.csproj', '🟠')
$KnownNoteableProjects.Add('L:\CivSubscriber\Source\FCSAmerica.AgentPro.CIVSubscriber\FCSAmerica.AgentPro.CIVSubscriber.csproj', '🟠')
$KnownNoteableProjects.Add('M:\AgriLytic\Components\CIVSubscriber\Agrilytic.Services.CIVSubscription\Agrilytic.Services.CIVSubscription.csproj', '🟠')
$KnownNoteableProjects.Add('N:\LoanIQDataMart\Source\LoanIQDataMartCivSubscriberSolution\LIQDataMartCIVSubscriber\LIQDataMartCIVSubscriber.csproj', '🟠')
$KnownNoteableProjects.Add('Q:\CIVSubscriber\Source\LASSICIVSubscriber\LASSICIVSubscriber\WCFHost.csproj', '🟠')
$KnownNoteableProjects.Add('S:\CreditAndResolutionsTool\Source\CIVSubscriber\CIVSubscriber.csproj', '🟠')
$KnownNoteableProjects.Add('T:\CivSubscriber\Source\DocuClick.CIVSubscriber\DocuClick.CIVSubscriber.csproj', '🟠')
$KnownNoteableProjects.Add('U:\OperationScope\Source\CivSubscriber\CivSubscriber.csproj', '🟠')
$KnownNoteableProjects.Add('V:\PinPointClient\Source\PinPointCIVAdapter\PinPointCivHost\PinPointCivHost.csproj', '🟠')
$KnownNoteableProjects.Add('K:\Ada\Source\Jobs\AdaConsole\JobConsole.csproj', '🟢')
$KnownNoteableProjects.Add('K:\Ada\Source\Service Layer\WebApi\WebApi.csproj', '🟢')
$KnownNoteableProjects.Add('K:\Ada\Source\Presentation Layer\WebUI\WebUI.csproj', '🟢')
$KnownNoteableProjects.Add('S:\CreditAndResolutionsTool\Source\DelinquentLoanProcess\BackendProcesses.csproj', '🟢')
$KnownNoteableProjects.Add('S:\CreditAndResolutionsTool\Source\DocumentLauncher\DocumentLauncher.csproj', '🟢')

# Enforce stricter PowerShell syntax rules to catch common bugs early
Set-StrictMode -Version Latest

# Continue on non-terminating errors (e.g. permission-denied on locked folders) so the
# scan completes even if individual paths cannot be read
$ErrorActionPreference = 'Continue'

# Timestamp used to suffix every output filename so repeated runs never overwrite each other
$timestamp = Get-Date -Format 'yyyy-MM-dd_HHmmss'

# ── Helper function ─────────────────────────────────────────────────────────────
# Normalize-SlnExclusionPath
#   Converts any SLN path (absolute or relative) into a drive-letter-free, lowercase,
#   backslash-trimmed string so that exclusion matching works regardless of which drive
#   letter is in use on the current machine.
#   Example:  'M:\AgriLytic\Source\AgriLytic.sln'  -->  '\agrilytic\source\agrilytic.sln'
function Normalize-SlnExclusionPath ([string]$p) {
    $p = $p.Trim()
    if ($p -match '^[A-Za-z]:\\') { $p = $p.Substring(2) }
    return $p.ToLowerInvariant().TrimEnd('\')
}

# Pre-process the caller-supplied exclusion list once so we're not re-normalising
# the same strings inside the inner filter loop below
$excludeNormalized = $ExcludeSlnPaths | ForEach-Object { Normalize-SlnExclusionPath $_ }

# ── 1. Resolve drives ───────────────────────────────────────────────────────────
# Query WMI for all logical disks that are local fixed drives (DriveType 3).
# Network drives (4), removable drives (2), and CD-ROM (5) are intentionally skipped.
# The result is intersected with the candidate list and the exclusion list so only
# the intended workspace drives are scanned.
Write-Host "`n[1/5] Resolving local fixed drives..." -ForegroundColor Cyan
$localFixed = Get-CimInstance Win32_LogicalDisk | Where-Object { $_.DriveType -eq 3 -and $_.DeviceID } | ForEach-Object { $_.DeviceID.TrimEnd(':').ToUpper() }

# Remove any drive letter that appears in the ExcludeDrives parameter (default: O and P)
$drives = $localFixed | Where-Object { $ExcludeDrives -notcontains $_ } | Sort-Object
if ($IncludeOnlyDrives.Count -gt 0) {
    # If the caller specified an explicit list of drives to include, intersect with that list
    $drives = $IncludeOnlyDrives
}
Write-Host "      Drives to scan: $($drives -join ', ')"

# ── 2. Find all SLN files ────────────────────────────────────────────────────────
# Recursively search each drive for Visual Studio solution files (.sln).
# .git directories are excluded to avoid picking up vendor copies or submodule caches.
# Each result is tagged with the drive letter it came from for later grouping.
Write-Host "[2/5] Discovering .sln files..." -ForegroundColor Cyan
$slnFiles = @()
foreach ($d in $drives) {
    $root = "$d`:\"; 
    $slnFiles += Get-ChildItem -Path $root -Recurse -File -Filter *.sln -ErrorAction SilentlyContinue | Where-Object { $_.FullName -notmatch '\\.git(\\|$)' } | Select-Object @{n='Drive';e={$d}}, FullName, DirectoryName, BaseName
}
Write-Host "      Found $($slnFiles.Count) .sln files (before exclusions)"



# Filter out SLN files listed in the ExcludeSlnPaths parameter.
# The comparison is drive-letter-agnostic: both the discovered path and the exclusion
# entry have their drive letters stripped before comparison, so 'R:\...' and '\...'
# both match correctly.
$slnFiles = $slnFiles | Where-Object {
    # Normalise the discovered path to a drive-letter-free lowercase string
    $tail = (Normalize-SlnExclusionPath $_.FullName) -replace '^[a-z]:', ''
    $keep = $true
    foreach ($ex in $excludeNormalized) {
        $exTail = $ex -replace '^[a-z]:', ''   # normalise exclusion entry the same way
        if ($tail -eq $exTail) { $keep = $false; break }   # match found: exclude this SLN
    }
    $keep   # $true keeps the file; $false drops it
}
Write-Host "      Remaining after exclusions  : $($slnFiles.Count) .sln files"
if ($null -ne $excludeNormalized -and $excludeNormalized.Count -gt 0) {
    Write-Host "      Excluded SLN count          : $($ExcludeSlnPaths.Count)" -ForegroundColor DarkYellow
}
#SHORTHAND: 
# $slnFiles = $slnFiles | Where-Object { (Normalize-SlnExclusionPath $_.FullName) -notin $excludeNormalized }
# Write-Host "      Remaining after exclusions  : $($slnFiles.Count) .sln files"
# if ($excludeNormalized.Count -gt 0) { Write-Host "      Excluded SLN count          : $($ExcludeSlnPaths.Count)" -ForegroundColor DarkYellow }

# ── 3. Parse SLN project references ─────────────────────────────────────────────
# Visual Studio .sln files list every project they contain using lines like:
#   Project("{FAE04EC0-...}") = "MyProject", "..\MyProject\MyProject.csproj", "{GUID}"
# The regex below captures the project name (group 1) and relative path (group 2).
# The relative path is resolved to a full absolute path using the SLN's directory as base.
Write-Host "[3/5] Parsing project references from SLN files..." -ForegroundColor Cyan
$projRefs = @()
# Regex matches the Project(...) = "name", "relativePath", "{guid}" line format
$rx = '^Project\("\{[^\}]+\}"\)\s*=\s*"([^"]+)",\s*"([^"]+)",\s*"\{[^\}]+\}"'
foreach ($s in $slnFiles) {
    $slnLines = Get-Content -Path $s.FullName -ErrorAction SilentlyContinue
    foreach ($line in $slnLines) {
        if ($line -match $rx) {
            $name = $matches[1]                          # project friendly name
            $rel  = $matches[2].Replace('\\', '\')      # relative path to project file
            if ([string]::IsNullOrWhiteSpace($rel)) { continue }   # skip blank paths
            $ext  = [System.IO.Path]::GetExtension($rel).ToLowerInvariant()
            if ([string]::IsNullOrWhiteSpace($ext)) { continue }   # skip solution folders (no extension)
            # Resolve the relative path against the SLN's directory to get a full absolute path
            $full = [System.IO.Path]::GetFullPath((Join-Path $s.DirectoryName $rel))
            $projRefs += [pscustomobject]@{ Drive=$s.Drive; SolutionPath=$s.FullName; SolutionName=$s.BaseName; ProjectName=$name; ProjectRefPath=$rel; ProjectTypeExt=$ext; ProjectFullPath=$full }
        }
    }
}
# De-duplicate: same project can be referenced by multiple SLNs; keep one row per SLN+project combo
$projRefs = $projRefs | Sort-Object SolutionPath, ProjectFullPath, ProjectName -Unique
# Split into primary (.csproj) and secondary (all other project types)
# For .csproj: further de-dup by project file path so each file is classified once
$csRefs = $projRefs | Where-Object { $_.ProjectTypeExt -eq '.csproj' } | Sort-Object ProjectFullPath -Unique
$secondary = $projRefs | Where-Object { $_.ProjectTypeExt -ne '.csproj' } | Select-Object Drive, SolutionPath, SolutionName, ProjectName, ProjectTypeExt, ProjectFullPath
Write-Host "      Total project refs parsed : $($projRefs.Count)"
Write-Host "      Unique .csproj refs        : $($csRefs.Count)"
Write-Host "      Secondary project types    : $($secondary.Count)"

# ── 4. Classify each .csproj ─────────────────────────────────────────────────────
# Read the raw XML content of each .csproj and apply two independent checks:
#
#  Project Type Classification (web / exe / library)
#  -------------------------------------------------------
#  web     : project file mentions IIS, IIS Express, Microsoft.NET.Sdk.Web, or the
#            ASP.NET web project GUID {349c5851-...}. This covers both legacy
#            (<ProjectTypeGuids>) and SDK-style (Sdk="Microsoft.NET.Sdk.Web") web projects.
#  exe     : <OutputType> is Exe or WinExe (console or Windows app), and not already web.
#  library : all other projects (class libraries, test projects, WCF service libraries, etc.)
#
#  MSMQ Detection
#  -------------------------------------------------------
#  Flags the project if any of these appear in the .csproj text:
#    - System.Messaging       (classic .NET MSMQ reference)
#    - MSMQ or MessageQueue   (direct MSMQ type or config references)
#    - Microsoft.MessageQueuing (COM interop / native MSMQ component)
Write-Host "[4/5] Classifying .csproj files..." -ForegroundColor Cyan
$classRows = @()
foreach ($r in $csRefs) {
    $p = $r.ProjectFullPath
    # If the project file no longer exists on disk, record it as 'missing' and move on
    if (!(Test-Path $p)) {
        $classRows += [pscustomobject]@{ Drive=$r.Drive; Component=$r.ProjectName; Path=$p; SourceSolution=$r.SolutionPath; ProjectType='missing'; MSMQ='unknown'; DetectedBy='file_missing'; MSMQDetectedBy='' }
        continue
    }
    # Read the entire .csproj as a single string for regex matching
    $txt    = Get-Content -Path $p -Raw -ErrorAction SilentlyContinue
    $isWeb  = $false
    $det    = @()   # tracks which rule triggered the classification

    # ── Web detection rules (any match forces 'web') ──────────────────────────
    if ($txt -match '(?i)IIS\s*Express|IISExpress|\bIIS\b')                            { $isWeb = $true; $det += 'IIS/IISExpress' }   # IIS binding in project settings
    if ($txt -match '(?i)Microsoft\.NET\.Sdk\.Web')                                     { $isWeb = $true; $det += 'Sdk.Web'        }   # SDK-style web project
    if ($txt -match '(?i)ProjectTypeGuids.*\{349c5851-65df-11da-9384-00065b846f21\}')   { $isWeb = $true; $det += 'WebProjectGuid' }   # legacy ASP.NET web project GUID

    # ── exe / library fallback ────────────────────────────────────────────────
    if ($isWeb) {
        $ptype = 'web'
    } elseif ($txt -match '(?i)<OutputType>\s*(Exe|WinExe)\s*</OutputType>') {
        $ptype = 'exe';     $det += 'OutputType'              # explicit console or WinForms/WPF exe
    } else {
        # No OutputType, or OutputType = Library -> treat as library (the safe default)
        $ptype = 'library'; $det += if ($txt -match '(?i)<OutputType>\s*Library\s*</OutputType>') { 'OutputType' } else { 'DefaultNoOutputType' }
    }

    # ── MSMQ detection ────────────────────────────────────────────────────────
    $msmq   = $false
    $md     = @()   # tracks which MSMQ indicator was found
    if ($txt -match '(?i)System\.Messaging')            { $msmq = $true; $md += 'System.Messaging'         }   # classic .NET reference
    if ($txt -match '(?i)\bMSMQ\b|MessageQueue')        { $msmq = $true; $md += 'MSMQ/MessageQueue'        }   # direct type / config keyword
    if ($txt -match '(?i)Microsoft\.MessageQueuing')    { $msmq = $true; $md += 'Microsoft.MessageQueuing' }   # COM interop

    $classRows += [pscustomobject]@{
        Drive          = $r.Drive
        Component      = $r.ProjectName
        Path           = $p
        SourceSolution = $r.SolutionPath
        ProjectType    = $ptype
        MSMQ           = if ($msmq) { 'yes' } else { 'no' }
        DetectedBy     = ($det -join ';')    # semicolon-separated list of triggered rules
        MSMQDetectedBy = ($md  -join ';')    # semicolon-separated list of MSMQ indicators found
    }}

# ── 5. Write reports ─────────────────────────────────────────────────────────────
# All output files are written to OutputDir with a timestamp suffix so each run
# produces a fresh, uniquely named set of files without overwriting prior results.
Write-Host "[5/5] Writing reports to $OutputDir ..." -ForegroundColor Cyan
New-Item -Path $OutputDir -ItemType Directory -Force | Out-Null

# Declare all output file paths up front for clarity
$slnCsv       = Join-Path $OutputDir "sln_discovered_$timestamp.csv"                          # all .sln files found (post-exclusion)
$refCsv       = Join-Path $OutputDir "sln_project_references_all_$timestamp.csv"              # every project ref parsed from every SLN
$classCsv     = Join-Path $OutputDir "sln_csproj_classification_$timestamp.csv"               # classified .csproj list
$secondaryCsv = Join-Path $OutputDir "sln_secondary_project_types_$timestamp.csv"             # non-.csproj project refs (vbproj, sqlproj, etc.)
$groupTxt     = Join-Path $OutputDir "sln_projects_grouped_by_drive_type_msmq_$timestamp.md" # human-readable: drive > type > MSMQ
$groupCsv     = Join-Path $OutputDir "sln_projects_grouped_by_drive_type_msmq_$timestamp.csv" # spreadsheet version of same
$slnGroupTxt  = Join-Path $OutputDir "csproj_grouped_by_sln_$timestamp.md"                   # human-readable: SLN > projects
$slnGroupCsv  = Join-Path $OutputDir "csproj_grouped_by_sln_$timestamp.csv"                   # spreadsheet version of same
$summaryTxt   = Join-Path $OutputDir "sln_rebuild_summary_$timestamp.md"                     # totals and MSMQ callout list

# ── Raw data CSVs ────────────────────────────────────────────────────────────
# These are the source-of-truth exports; all TXT reports are derived from classRows
$slnFiles | Sort-Object Drive, FullName | Export-Csv -NoTypeInformation -Path $slnCsv
$projRefs | Sort-Object Drive, SolutionName, ProjectTypeExt, ProjectName | Export-Csv -NoTypeInformation -Path $refCsv
$classRows | Sort-Object Drive, ProjectType, MSMQ, Component | Export-Csv -NoTypeInformation -Path $classCsv
$secondary | Sort-Object ProjectTypeExt, Drive, ProjectName | Export-Csv -NoTypeInformation -Path $secondaryCsv
$classRows | Sort-Object Drive, ProjectType, MSMQ, Component | Select-Object Drive, ProjectType, MSMQ, Component, Path, SourceSolution | Export-Csv -NoTypeInformation -Path $groupCsv
$classRows | Sort-Object SourceSolution, Drive, Component | Select-Object SourceSolution, Drive, Component, ProjectType, MSMQ, Path | Export-Csv -NoTypeInformation -Path $slnGroupCsv

# ── TXT report 1: Grouped by Drive > Type > MSMQ (Markdown format) ──────────
# Produces a three-level hierarchy so you can quickly see how many projects of each
# classification and MSMQ status exist on each drive, formatted as Markdown with tables
# Markdown Report 1: Grouped by Drive > Type > MSMQ
$lines = @('# Projects Grouped by Drive, Type, and MSMQ', '', "Generated: $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')", '')
foreach ($dg in ($classRows | Group-Object Drive | Sort-Object Name)) {
    $lines += "## Drive: $($dg.Name):"
    $lines += ''
    foreach ($tg in ($dg.Group | Group-Object ProjectType | Sort-Object Name)) {
        $lines += "### Type: $($tg.Name)"
        $lines += ''
        foreach ($mg in ($tg.Group | Group-Object MSMQ | Sort-Object Name)) {
            $lines += "#### MSMQ: $($mg.Name) (Count: $($mg.Count))"
            $lines += ''
            $lines += '| Project | Path |'
            $lines += '|---------|------|'
            foreach ($p in ($mg.Group | Sort-Object Component)) { $lines += "| $($p.Component) | $($p.Path) |" }
            $lines += ''
        }
    }
}
$lines | Set-Content -Path $groupTxt

# ── TXT report 2: Grouped by SLN (Markdown format) ───────────────────────────
# Lists every SLN in scope, and under each SLN every referenced .csproj project
# with its classification and MSMQ flag. This is the key deliverable for tracing
# which solution owns which component. Uses Markdown tables instead of bullet points.
# Markdown Report 2: Grouped by SLN
$lines2 = @('# C# Projects Grouped by Solution (SLN)', '', "Generated: $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')", '', '## Noteable Projects Legend', '', 'The following projects are known to be important or noteworthy. They are marked with symbols in the Importance column of the table below.', '')
$lines2 += 'Tables are sorted by SLN, then by project name. Type is an interpreted column. MSMQ indicates whether the project references System.Messaging. Path is the full path to the project file. (relative to the system in which the script was run)', ''
$lines2 += '## Legend for Importance Column', '', '| Symbol | Meaning |', '|--------|---------|', '| 🟢 | Executable - Possible Affected Deployable |', '| 🟠 | CIV Subscriber Executable (deployable) |', ''
foreach ($sg in ($classRows | Group-Object SourceSolution | Sort-Object Name)) {
    $slnName = [System.IO.Path]::GetFileNameWithoutExtension($sg.Name)
    $lines2 += "## [SLN] $slnName"
    $lines2 += ''
    $lines2 += "**Path:** $($sg.Name)"
    $lines2 += ""; $lines2 += "**Project Count:** $($sg.Count)"
    $lines2 += ''
    # $lines2 += '| Drive | Project | Type | MSMQ | Path |Importance|'
    # $lines2 += '|-------|---------|------|------|------|----------|'
    #$lines2 += '| Project (Name) | Type | MSMQ | Path |Importance|'
    #$lines2 += '|---------|------|------|------|----------|'
    $lines2 += '| Project (Name) | Type | Path |Importance|'
    $lines2 += '|---------|------|------|----------|'
    #foreach ($p in ($sg.Group | Sort-Object Drive, Component)) { $lines2 += "| $($p.Drive): | $($p.Component) | $($p.ProjectType) | $($p.MSMQ) | $($p.Path) | $($KnownNoteableProjects[$p.Path]) |" }
    #foreach ($p in ($sg.Group | Sort-Object Drive, Component)) { $lines2 += "| $($p.Component) | $($p.ProjectType) | $($p.MSMQ) | $($p.Path) | $($KnownNoteableProjects[$p.Path]) |" }
    foreach ($p in ($sg.Group | Sort-Object Drive, Component)) { $lines2 += "| $($p.Component) | $($p.ProjectType)  | $($p.Path) | $($KnownNoteableProjects[$p.Path]) |" }
    $lines2 += ''
}
$lines2 | Set-Content -Path $slnGroupTxt

# ── TXT report 3: Summary ────────────────────────────────────────────────────
# High-level counts plus a callout list of every project that uses MSMQ in Markdown format
# Markdown Report 3: Summary
$sum = @('# Scan Summary Report', '', "Generated: $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')", '', '## Configuration', '', "- **Timestamp:** $timestamp", "- **Excluded Drives:** $($ExcludeDrives -join ', ')", "- **Scanned Drives:** $($drives -join ', ')", '', '## Results', '', '| Metric | Count |', '|--------|-------|', "| SLN files found | $($slnFiles.Count) |", "| SLN files excluded | $($ExcludeSlnPaths.Count) |", "| Total project references parsed | $($projRefs.Count) |", "| Unique .csproj projects | $($classRows.Count) |", '', '### Project Type Distribution', '', '| Type | Count |', '|------|-------|')
$sum += $classRows | Group-Object ProjectType | Sort-Object Name | ForEach-Object { "| $($_.Name) | $($_.Count) |" }
$sum += '', '### MSMQ Usage', '', '| Status | Count |', '|--------|-------|'
$sum += $classRows | Group-Object MSMQ | Sort-Object Name | ForEach-Object { "| $($_.Name) | $($_.Count) |" }
$sum += '', '### Projects with MSMQ = yes', '', '| Drive | Project | Source Solution |', '|-------|---------|-----------------|'
$sum += $classRows | Where-Object { $_.MSMQ -eq 'yes' } | Sort-Object Drive, Component | ForEach-Object { "| $($_.Drive): | $($_.Component) | $([System.IO.Path]::GetFileNameWithoutExtension($_.SourceSolution)) |" }
$sum += '', '### Secondary Project Types', '', '| Type | Count |', '|------|-------|'
$sum += $secondary | Group-Object ProjectTypeExt | Sort-Object Name | ForEach-Object { "| $($_.Name) | $($_.Count) |" }
$sum | Set-Content -Path $summaryTxt

# ── Done ─────────────────────────────────────────────────────────────────────────
# Print all output file paths and echo the summary to the console so results are
# visible without needing to open a file
Write-Host "`n  Reports written:" -ForegroundColor Green
@($slnCsv, $refCsv, $classCsv, $secondaryCsv, $groupTxt, $groupCsv, $slnGroupTxt, $slnGroupCsv, $summaryTxt) | ForEach-Object { Write-Host "    $_" }
Write-Host "`n  Summary (Markdown format):" -ForegroundColor Green
Get-Content $summaryTxt | Write-Host
