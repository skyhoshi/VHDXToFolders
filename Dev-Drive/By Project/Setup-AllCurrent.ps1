# 
##$previousLocation = $PWD
<#
Mount-CurrentProject
Set-Location $PSScriptRoot
$pathingBackToRepoRoot = ".\..\..\";
$pathingBackToDevDriveSetupFolder = "$($pathingBackToRepoRoot)Dev-Drive\Setup";
. "$($pathingBackToDevDriveSetupFolder)\setup-new-project.ps1"
. "$($pathingBackToDevDriveSetupFolder)\setup-after-newproject.ps1"
[string[]]$repos = "git@ssh.dev.azure.com:v3/fcsamerica/MyAccount/MyAccount.Auth"
$projectName = "MyAccountAuth"
$projectId = 194081
$driveLetter = "M"
New-DevelopmentStorageEnvironment -ProjectId $projectId -ProjectName $projectName -ProjectRootDriveLetter $driveLetter -GitRepoUrl $repos 
Create-DotNetTemplatesForMigration -ProjectId $projectId -ProjectName $projectName -ProjectRootDriveLetter $driveLetter
#>
$dir = "K:\kernm.devcontainer.envsetup\Dev-Drive\By Project\"
$scripts = Get-ChildItem -Path $dir -Filter *.ps1 | Where-Object { $_.Name -ne 'Setup-AllCurrent.ps1' -and $_.Name -ne 'Setup-.ps1' }


# Loop through each script and execute it
foreach ($script in $scripts) {
    Write-Output "Running $($script.Name)..."
    & $script.FullName
}
