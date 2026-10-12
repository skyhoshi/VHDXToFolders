# 
#$previousLocation = $PWD;
Mount-CurrentProject;
Set-Location $PSScriptRoot
$pathingBackToRepoRoot = ".\..\..\";
$pathingBackToDevDriveSetupFolder = "$($pathingBackToRepoRoot)Dev-Drive\Setup";
. "$($pathingBackToDevDriveSetupFolder)\setup-new-project.ps1"
##. "$($pathingBackToDevDriveSetupFolder)\setup-after-newproject.ps1"

[string[]]$repos = "git@ssh.dev.azure.com:v3/fcsamerica/Shared.Libraries/Solution.Templates";

New-DevelopmentStorageEnvironment -ProjectId 0 -ProjectName "SharedTemplates" -ProjectRootDriveLetter 'T' -GitRepoUrl $repos #-GitRepoBranchName "experimental/dev-container"