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
    [string]$TeamProject
    [string]$ProjectName
    [int]$ProjectId
    [string]$DriveLetter
    [GitRepoDescription[]]$Repos
    [bool]$CreateScript = $false
    [bool]$PullTemplates = $false

    ProjectSetupInfo(
        # Parameter help description
        #[Parameter()]
        [int]$runIndex, 
        [int]$projectIndex, 
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
        $this.TeamProject = $teamProjectName
        $this.ProjectName = $projectName
        $this.ProjectId = $projectId
        $this.DriveLetter = $driveLetter
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

[ProjectSetupInfo[]]$setupInfos = @();


$rollUpCreateScripts = $false;


<# 
DEFUALT Script Info INIT

> $setupInfo = [ProjectSetupInfo]::new(1, 1, "", "", 0, "", $false, $false, @(""));$setupInfos += $setupInfo;

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

$TeamGroups = $projectSetupInfos | Group-Object -Property TeamProject | Sort-Object Name;

## Template Load
$setupScriptHeaderContent = Get-Content -Path $PSScriptRoot'\templateFolder\scriptHeader.ps1' -Raw;
$setupScriptBodyContent = Get-Content -Path $PSScriptRoot'\templateFolder\scriptBody.ps1' -Raw;

$scriptInfo = (Get-Item -Path $MyInvocation.MyCommand.Path).FullName;
$scriptMachineId = "$($env:COMPUTERNAME) - $($env:USERNAME)";

$TeamProjectScriptsOutput = "";
Write-Host "Generating setup scripts for the following team projects: $($TeamGroups.Count)" -ForegroundColor Green;
foreach ($group in $TeamGroups) {
    #Grouping by Team Project Name for single script runner to run all scrips by Team Project. 
    $TeamGroupsScripts = @();
    $TeamProjectScriptsOutput = "";

    # $teamProjectName = $group.Name
    # if ([string]::IsNullOrWhiteSpace($teamProjectName)) {
    #     $teamProjectName = "Unassigned"
    # }
    foreach ($projectGroup in $group.Group) {

        $setupFile = "";
        Write-Host "  Project: $($projectGroup.ProjectName), ProjectId: $($projectGroup.ProjectId), DriveLetter: $($projectGroup.DriveLetter), RepoUrl: $($projectGroup.Repos.RepoUrl)" -ForegroundColor Yellow;
    
        $projectSetupInfo = $projectGroup;
    
        $ProjectName = $projectSetupInfo.ProjectName
        # $projectId = $projectSetupInfo.ProjectId
        # $driveLetter = $projectSetupInfo.DriveLetter
        # [string[]]$repos = $projectSetupInfo.Repos

        $teamProjectFolder = Join-Path $PSScriptRoot $projectSetupInfo.TeamProject
        $teamProjectScriptsFolder = $teamProjectFolder
        $teamProjectArchiveFolder = Join-Path $PSScriptRoot "Master Archive" $projectSetupInfo.TeamProject

        Write-Host "Creating folders for Team Project: $($projectSetupInfo.TeamProject)"   -ForegroundColor Green;
        Write-Host "  Team Project Folder: $($teamProjectFolder)" -ForegroundColor Green;
        Write-Host "  Team Project Scripts Folder: $($teamProjectScriptsFolder)" -ForegroundColor Green;
        Write-Host "  Team Project Archive Folder: $($teamProjectArchiveFolder)" -ForegroundColor Green;


        New-Item -ItemType Directory -Path $teamProjectFolder -Force | Out-Null
        New-Item -ItemType Directory -Path $teamProjectScriptsFolder -Force | Out-Null
        New-Item -ItemType Directory -Path $teamProjectArchiveFolder -Force | Out-Null

        #Template Replacement Values:
        $LastAltered = "$((Get-Date).ToString('yyyy-MM-dd')) $((Get-Date).ToString('HH:mm'))"
        $pathingBackToRepoRoot = ".\..\..\..\";
        #Reset Template as apart of the loop
        $setupScriptHeaderContent = Get-Content -Path $PSScriptRoot'\templateFolder\scriptHeader.ps1' -Raw; 
        foreach ($setupInfo in ($group.Group | Sort-Object RunIndex, projectIndex)) {
            $setupScript = $setupScriptHeaderContent.Replace("{scriptMachineId}", $scriptMachineId).Replace("{PathingBackToRepoRoot}", $pathingBackToRepoRoot).Replace("{LastAltered}", $LastAltered).Replace("{scriptInfo}", $scriptInfo).Replace("{TeamProjectName}", $setupInfo.TeamProject);


            $projectName = $setupInfo.ProjectName;
            $repoList = "";
            foreach ($repo in $setupInfo.Repos.RepoUrl) {
                #Write-Host "  Project: $($setupInfo.ProjectName), ProjectId: $($setupInfo.ProjectId), DriveLetter: $($setupInfo.DriveLetter), RepoUrl: $($repo.RepoUrl)"
                $repoList += "`"$($repo)`"`,"
            }
            $repoList = $repoList.TrimEnd(',')
            $repoList = $repoList.Replace(" ", "`", `"")
            Write-Host "Project: $($setupInfo.ProjectName), ProjectId: $($setupInfo.ProjectId), DriveLetter: $($setupInfo.DriveLetter), RepoUrl: $($repoList)"

            $setupScriptBodyContent = Get-Content -Path $PSScriptRoot'\templateFolder\scriptBody.ps1' -Raw;
            $setupScript += $setupScriptBodyContent.Replace("{projectName}", $projectName).Replace("{setupInfo-ProjectId}", $setupInfo.ProjectId).Replace("{setupInfo-DriveLetter}", $setupInfo.DriveLetter).Replace("{repoList}", $repoList);
            
            $setupScript += "`ncode .";


            $setupFile = Join-Path $teamProjectScriptsFolder "Setup-$($ProjectName).ps1";
            <# 
        if (Test-Path -Path $setupFile) {
            #$k = (Join-Path $teamProjectArchiveFolder "Setup-$($projectSetupInfo.TeamProject)-$(Get-Date -Format 'yyyy-MM-dd-HH-mm').ps1");
            Copy-Item -Path $setupFile -Destination (Join-Path $teamProjectArchiveFolder "Setup-$($ProjectName)-$(Get-Date -Format 'yyyy-MM-dd-HH-mm').ps1") -Force
            Write-Host "Removing existing setup file: $setupFile"
            Remove-Item -Path $setupFile -Force
        } 
        #>

            $setupScript | Out-File -FilePath $setupFile -Encoding UTF8 -Force
            $TeamGroupsScripts += $setupFile;
        }
    }
    Write-Host "Team Project: $($group.Name)" -ForegroundColor Blue;
    # foreach ($setupInfo in ($group.Group | Sort-Object RunIndex, projectIndex)) {
    #     Write-Host "  Project: $($setupInfo.ProjectName), ProjectId: $($setupInfo.ProjectId), DriveLetter: $($setupInfo.DriveLetter)"
    # }
    foreach ($TeamProjectScript in $TeamGroupsScripts | Select-Object -Unique) {
        $TeamProjectScriptsOutput += ". `"$TeamProjectScript`"`n";
    }


    #$TeamProjectScriptsOutput = $TeamGroupsScripts -join ".`"$_`"`n"
    Write-Host "Setup scripts generated for the following team projects: $($group.Name)" -ForegroundColor Green;
    Write-Host $TeamProjectScriptsOutput -ForegroundColor Green;
    $TeamProjectScriptsOutput | Out-File -FilePath "$($PSScriptRoot)\Load-$($group.Name).ps1" -Encoding UTF8 -Force;
}

#Trace-Command -PSHost -Name ParameterBinding -Expression {Get-Item *.txt | Remove-Item}