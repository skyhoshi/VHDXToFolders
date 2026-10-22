#requires -Version 5.1

<#

.ROLE
    This script is intended to be used as a starting point for setting up a new development environment for a project. It defines the necessary information for the project setup, including project name, ID, drive letter, and Git repositories.

.SYNOPSIS
    This script sets up the initial development environment for the project.

.DESCRIPTION
    This script defines the project setup information, including project name, ID, drive letter, and Git repositories.

.NOTES
    This Script and the corresponding "Setup" directory are used to generate project Setup files that allow you to create a VDHX file and clone the defined Git Repo(s) into the newly created drives to keep your development environment organized and consistent across team members. The script is designed to be run in a PowerShell environment with the necessary permissions and modules installed.
    This script does not require Administrator rights but the scripts that this one generates MUST be run as administrator. (There is no way around this as Mount-VHD requires admin rights to run.)
    IMPORTANT: You can Rerun this setup script AND the scripts it generates. if a VHDX file is found it will automatically be mounted and the Git Repo(s) will be pulled to ensure you have the latest code. If you want to start over, delete the VHDX file and rerun this script.
    IMPORTANT: According to research Windows only allows 26 drive letters (A-Z). but previous experience(s) shows that in some instances AA, AB, AC, etc. can be used as well. This script does not currently support that and is operating system dependent.
    IMPORTANT: EJECT! the drive when your done with it. This runs Dismount-VHD via the GUI. THERE IS NO DISMOUNT SCRIPT (Yet). 
    IMPORTANT: Drives are NOT Automatically mounted when you restart your computer. You can either Mount it manually by double clicking on the VHDX file or rerun the setup script.
    IMPORTANT: This script is designed to be run in a PowerShell environment with the necessary permissions and modules installed. It is recommended to run this script in a PowerShell 7.3+ environment for optimal performance and compatibility.
#>
# EDITS Start on line 75
# No need to alter these classes as they are used to define the project setup information and generate the necessary scripts for setting up the development environment. Altering these classes may break the functionality of the script and cause issues with the setup process.

class GitRepoDescription {

    [string]$RepoUrl

    GitRepoDescription([string]$repoUrl) {
        $this.RepoUrl = $repoUrl
    }
}
class ProjectSetupInfo {
    [int]$RunIndex
    [int]$projectIndex
    [string]$TeamName
    [string]$TeamProject
    [string]$ProjectName
    [int]$ProjectId
    [string]$DriveLetter
    [string]$DriveName
    # ProjectId used for the VHDX path; shared team drives use the first project's id.
    [int]$DriveProjectId
    [bool]$IsSharedDrive = $false
    [GitRepoDescription[]]$Repos
    [bool]$CreateScript = $false
    [bool]$PullTemplates = $false

    ProjectSetupInfo(
        # Parameter help description
        #[Parameter()]
        [int]$runIndex, 
        [int]$projectIndex, 
        [string]$teamName, 
        [string]$teamProjectName, 
        [string]$projectName, 
        [int]$projectId, 
        [string]$driveLetter, 
        [bool]$createScript = $false, 
        [bool]$pullTemplates = $false, 
        [string[]]$repos = @()
        #,[GitRepoDescription[]]$repoDescriptions = @()
    ) {
        $this.RunIndex = $runIndex
        $this.projectIndex = $projectIndex
        $this.TeamName = $teamName
        $this.TeamProject = $teamProjectName
        $this.ProjectName = $projectName
        $this.ProjectId = $projectId
        $this.DriveLetter = $driveLetter
        $this.DriveName = $projectName
        $this.DriveProjectId = $projectId
        #if ($null -ne $repos -and $repos.Count -gt 0) {
        $this.Repos = @()
        #foreach ($repo in $repos) {
        $this.Repos += [GitRepoDescription]::new($repos)
        #}
        #}
        $this.CreateScript = $createScript
        $this.PullTemplates = $pullTemplates
    }
}

function Import-ProjectSetupInfo {
    [CmdletBinding()]
    [OutputType([ProjectSetupInfo])]
    param(
        [string]$Path = (Join-Path (Split-Path $PSScriptRoot -Parent) 'RepositoryList.xlsx'),
        [string]$WorksheetName = 'Repo Map'
    )

    if (-not (Test-Path -LiteralPath $Path -PathType Leaf)) {
        throw "Repository workbook not found: $Path"
    }
    else {
        write-host "Repository workbook found: $Path"
    }
    if (-not (Get-Module -ListAvailable -Name ImportExcel)) {
        throw 'ImportExcel is required. Install it with: Install-Module ImportExcel -Scope CurrentUser'
    }
    Import-Module ImportExcel -ErrorAction Stop

    $sheetNames = @(Get-ExcelSheetInfo -Path $Path | Select-Object -ExpandProperty Name)
    if ($WorksheetName -notin $sheetNames) {
        throw "Worksheet '$WorksheetName' not found in '$Path'. Available worksheets: $($sheetNames -join ', ')"
    }

    $rows = @(Import-Excel -Path $Path -WorksheetName $WorksheetName -ErrorAction Stop)
    if ($rows.Count -eq 0) {
        throw "Worksheet '$WorksheetName' contains no project rows."
    }

    $requiredColumns = @('Run Id', 'Index ID', 'Team Name', 'Project Group (Team) Name', 'Project Name', 'Repos', 'ProjectId (WorkItem)', 'Drive Letter', 'Create Script', 'Pull Templates')
    Write-Host "Checking for required columns in worksheet '$WorksheetName'..."
    Write-Host "Required columns:           $($requiredColumns -join ', ')"
    Write-Host "Columns found in worksheet: $($rows[0].PSObject.Properties.Name -join ', ')"
    $missingColumns = @($requiredColumns | Where-Object { $_ -notin $rows[0].PSObject.Properties.Name })
    if ($missingColumns.Count -gt 0) {
        throw "Worksheet '$WorksheetName' is missing columns: $($missingColumns -join ', ')"
    }
    else {
        Write-Host "All required columns are present in worksheet '$WorksheetName'."
    }

    $setupInfos = [System.Collections.Generic.List[ProjectSetupInfo]]::new()
    $rowNumber = 1
    foreach ($row in $rows) {
        $rowNumber++
        if ([string]::IsNullOrWhiteSpace([string]$row.'Project Name')) {
            throw "Worksheet '$WorksheetName', row ${rowNumber}: Project Name is required."
        }

        try {
            $flags = @{}
            foreach ($column in @('Create Script', 'Pull Templates')) {
                switch (([string]$row.$column).Trim().ToLowerInvariant()) {
                    { $_ -in @('true', '1', 'yes') } { $flags[$column] = $true }
                    { $_ -in @('false', '0', 'no', '') } { $flags[$column] = $false }
                    default { throw "${column} must be TRUE/FALSE, YES/NO, 1/0, or blank." }
                }
            }
            if ($flags['Create Script']) {
                foreach ($column in @('Run Id', 'Index ID', 'ProjectId (WorkItem)')) {
                    if ([string]::IsNullOrWhiteSpace([string]$row.$column)) {
                        throw "${column} is required."
                    }
                }

                $setupInfo = [ProjectSetupInfo]::new(
                    [int]$row.'Run Id',
                    [int]$row.'Index ID',
                    ([string]$row.'Team Name').Trim(),
                    [string]$row.'Project Group (Team) Name',
                    [string]$row.'Project Name',
                    [int]$row.'ProjectId (WorkItem)',
                    ([string]$row.'Drive Letter').Trim(),
                    [bool]$flags['Create Script'],
                    [bool]$flags['Pull Templates'],
                    @()
                )
                $setupInfo.Repos = @(
                    foreach ($repoUrl in ([string]$row.Repos -split '[;,\r\n]+')) {
                        if (-not [string]::IsNullOrWhiteSpace($repoUrl)) {
                            [GitRepoDescription]::new($repoUrl.Trim())
                        }
                    }
                )
                $setupInfos.Add($setupInfo)
            }
        }
        catch {
            throw "Worksheet '$WorksheetName', row ${rowNumber}: $($_.Exception.Message)"
        }
    }

    # Rows sharing a Team Name and Drive Letter share one drive named after the team.
    $teamDrives = $setupInfos | Where-Object { -not [string]::IsNullOrWhiteSpace($_.TeamName) } | Group-Object -Property TeamName, DriveLetter | Where-Object Count -gt 1
    foreach ($teamDrive in $teamDrives) {
        $firstOnDrive = $teamDrive.Group | Sort-Object RunIndex, projectIndex | Select-Object -First 1
        foreach ($info in $teamDrive.Group) {
            $info.DriveName = $firstOnDrive.TeamName
            $info.DriveProjectId = $firstOnDrive.ProjectId
            $info.IsSharedDrive = $true
        }
    }

    $setupInfos
}

function New-DriveReadmeContent {
    [OutputType([string])]
    param(
        [Parameter(Mandatory)]
        [ProjectSetupInfo[]]$DriveSetupInfos,
        [string]$GeneratedOn
    )

    $first = $DriveSetupInfos[0]
    $lines = [System.Collections.Generic.List[string]]::new()
    $lines.Add("# $($first.DriveLetter): $($first.DriveName)")
    $lines.Add('')
    $lines.Add("Generated $GeneratedOn by 1-Start-Here.ps1. Re-running a setup script overwrites this file.")
    $lines.Add('')
    $lines.Add('| Run Id | Index ID | Team Name | Project Group (Team) Name | Project Name | ProjectId (WorkItem) | Pull Templates |')
    $lines.Add('|---|---|---|---|---|---|---|')
    foreach ($info in $DriveSetupInfos) {
        $lines.Add("| $($info.RunIndex) | $($info.projectIndex) | $($info.TeamName) | $($info.TeamProject) | $($info.ProjectName) | $($info.ProjectId) | $($info.PullTemplates) |")
    }
    foreach ($info in $DriveSetupInfos) {
        $lines.Add('')
        $lines.Add("## $($info.ProjectName) ($($info.ProjectId))")
        $lines.Add('')
        foreach ($repoUrl in $info.Repos.RepoUrl) {
            $repoFolder = ($repoUrl -split '/')[-1]
            $lines.Add("- ``$($info.DriveLetter):\$repoFolder`` - $repoUrl")
        }
    }
    $lines -join "`n"
}

[ProjectSetupInfo[]]$setupInfos = @(Import-ProjectSetupInfo);



$rollUpCreateScripts = $false;


<# 
DEFUALT Script Info INIT

> $setupInfo = [ProjectSetupInfo]::new(1, 1, "", "", "", 0, "", $false, $false, @(""));$setupInfos += $setupInfo;

#>

<#
DO NOT EDIT BELOW THIS LINE. This section is for the script to generate the setup file for the new project. Edit the variables above and re-run the script to regenerate the setup file with the correct information.
#>

$ProjectName = ""
$projectId = 1
$driveLetter = "Z"
[string[]]$repos = ""


$projectSetupInfos = $setupInfos.Where({ $_.CreateScript -eq $true })
Write-Host "Projects Registered for generation: $($setupInfos.Count)" -ForegroundColor Green;
Write-Host "Projects with CreateScript set to true: $($projectSetupInfos.Count)" -ForegroundColor Green;
if ($null -eq $projectSetupInfos -or $projectSetupInfos.Count -eq 0) {
    Write-Host "No project setup info found with CreateScript set to true. Please set CreateScript to true for the project you want to generate the setup script for."
    exit;
}

###################################################################################################################################
## Do not edit below this line. This section is for the script to generate the setup file for the new project. Edit the variables above and re-run the script to regenerate the setup file with the correct information.
## Do not edit below this line. This section is for the script to generate the setup file for the new project. Edit the variables above and re-run the script to regenerate the setup file with the correct information.
## Do not edit below this line. This section is for the script to generate the setup file for the new project. Edit the variables above and re-run the script to regenerate the setup file with the correct information.
## Do not edit below this line. This section is for the script to generate the setup file for the new project. Edit the variables above and re-run the script to regenerate the setup file with the correct information.
## Do not edit below this line. This section is for the script to generate the setup file for the new project. Edit the variables above and re-run the script to regenerate the setup file with the correct information.
## Do not edit below this line. This section is for the script to generate the setup file for the new project. Edit the variables above and re-run the script to regenerate the setup file with the correct information.
###################################################################################################################################

######################
# Future enhancement: Add validation to ensure drive letter is not currently in use.
# The intention would be to allow the "Next Best Letter" to be used if the defined drive letter is already in use. This would allow for a more flexible setup process and reduce the likelihood of conflicts with existing drive letters.
# Get-PSDrive -PSProvider FileSystem |  Select-Object -ExpandProperty Name
# Get-CimInstance Win32_LogicalDisk |  ForEach-Object { $_.DeviceID.TrimEnd(':') }

######################
# Future enhancement: Add validation to ensure ProjectID is a User Story. 

## Template Load
$setupScriptHeaderContent = Get-Content -Path $PSScriptRoot'\templateFolder\scriptHeader.ps1' -Raw;
$setupScriptBodyContent = Get-Content -Path $PSScriptRoot'\templateFolder\scriptBody.ps1' -Raw;

$scriptInfo = (Get-Item -Path $MyInvocation.MyCommand.Path).FullName;
$scriptMachineId = "$($env:COMPUTERNAME) - $($env:USERNAME)";
$LastAltered = Get-Date -Format 'yyyy-MM-dd HH:mm'
$pathingBackToRepoRoot = ".\..\..\..\";

$driveReadmes = @{}
$readmeGeneratedOn = Get-Date -Format 'yyyy-MM-dd HH:mm'
foreach ($driveGroup in ($projectSetupInfos | Group-Object -Property { "$($_.DriveLetter)|$($_.DriveName)" })) {
    $driveReadmes[$driveGroup.Name] = New-DriveReadmeContent -DriveSetupInfos @($driveGroup.Group | Sort-Object RunIndex, projectIndex) -GeneratedOn $readmeGeneratedOn
}

# Writes one setup script with a body section per project and returns its path.
function Write-SetupScript {
    param(
        [string]$FolderName,
        [ProjectSetupInfo[]]$SetupInfos
    )

    $scriptsFolder = Join-Path $PSScriptRoot $FolderName
    New-Item -ItemType Directory -Path $scriptsFolder -Force | Out-Null
    New-Item -ItemType Directory -Path (Join-Path $PSScriptRoot "Master Archive\$FolderName") -Force | Out-Null

    $setupScript = $setupScriptHeaderContent.Replace("{scriptMachineId}", $scriptMachineId).Replace("{PathingBackToRepoRoot}", $pathingBackToRepoRoot).Replace("{LastAltered}", $LastAltered).Replace("{scriptInfo}", $scriptInfo).Replace("{TeamProjectName}", $FolderName);

    foreach ($setupInfo in ($SetupInfos | Sort-Object RunIndex, projectIndex)) {
        $repoList = "";
        foreach ($repo in $setupInfo.Repos.RepoUrl) {
            $repoList += "`"$($repo)`"`,"
        }
        $repoList = $repoList.TrimEnd(',')
        $repoList = $repoList.Replace(" ", "`", `"")
        Write-Host "  Project: $($setupInfo.ProjectName), ProjectId: $($setupInfo.ProjectId), DriveLetter: $($setupInfo.DriveLetter), DriveName: $($setupInfo.DriveName), RepoUrl: $($repoList)" -ForegroundColor Yellow

        $driveReadme = $driveReadmes["$($setupInfo.DriveLetter)|$($setupInfo.DriveName)"]
        $setupScript += $setupScriptBodyContent.Replace("{projectName}", $setupInfo.ProjectName).Replace("{setupInfo-ProjectId}", $setupInfo.ProjectId).Replace("{setupInfo-DriveLetter}", $setupInfo.DriveLetter).Replace("{setupInfo-DriveName}", $setupInfo.DriveName).Replace("{setupInfo-DriveProjectId}", $setupInfo.DriveProjectId).Replace("{repoList}", $repoList).Replace("{driveReadme}", $driveReadme);
    }
    $setupScript += "`ncode .";

    $setupFile = Join-Path $scriptsFolder "Setup-$($FolderName).ps1";
    $setupScript | Out-File -FilePath $setupFile -Encoding UTF8 -Force
    $setupFile
}

$sharedDrives = @($projectSetupInfos | Where-Object IsSharedDrive | Group-Object -Property TeamName, DriveLetter)
Write-Host "Generating setup scripts for shared team drives: $($sharedDrives.Count)" -ForegroundColor Green;
foreach ($sharedDrive in $sharedDrives) {
    $teamName = $sharedDrive.Group[0].TeamName
    Write-Host "Team Drive: $teamName ($($sharedDrive.Group[0].DriveLetter):)" -ForegroundColor Blue;
    $setupFile = Write-SetupScript -FolderName $teamName -SetupInfos $sharedDrive.Group
    Write-Host "Setup script generated: $setupFile" -ForegroundColor Green;
}

$TeamGroups = @($projectSetupInfos | Where-Object { -not $_.IsSharedDrive } | Group-Object -Property TeamProject | Sort-Object Name)
Write-Host "Generating setup scripts for the following team projects: $($TeamGroups.Count)" -ForegroundColor Green;
foreach ($group in $TeamGroups) {
    Write-Host "Team Project: $($group.Name)" -ForegroundColor Blue;
    $setupFile = Write-SetupScript -FolderName $group.Name -SetupInfos $group.Group
    Write-Host "Setup script generated: $setupFile" -ForegroundColor Green;
}

#Trace-Command -PSHost -Name ParameterBinding -Expression {Get-Item *.txt | Remove-Item}