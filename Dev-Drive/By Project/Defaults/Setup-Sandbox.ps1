# 
#$previousLocation = $PWD;
Mount-CurrentProject;
Set-Location $PSScriptRoot
$pathingBackToRepoRoot = ".\..\..\";
$pathingBackToDevDriveSetupFolder = "$($pathingBackToRepoRoot)Dev-Drive\Setup";
. "$($pathingBackToDevDriveSetupFolder)\setup-new-project.ps1"
##. "$($pathingBackToDevDriveSetupFolder)\setup-after-newproject.ps1"

[string[]]$repos = "git@ssh.dev.azure.com:v3/fcsamerica/Sandbox/kernm.devcontainer.envsetup";

$projectName = "Sandbox"

$projectId = 1
$driveLetter = "K"
New-DevelopmentStorageEnvironment -ProjectId $projectId -ProjectName $projectName -ProjectRootDriveLetter $driveLetter -GitRepoUrl $repos 