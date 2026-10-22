# Project: {projectName}
$projectName = "{projectName}"
$projectId = {setupInfo-ProjectId}
$driveLetter = "{setupInfo-DriveLetter}"
$driveName = "{setupInfo-DriveName}"
$driveProjectId = {setupInfo-DriveProjectId}
[string[]]$repos = {repoList}
New-DevelopmentStorageEnvironment -ProjectId $driveProjectId -ProjectName $driveName -ProjectRootDriveLetter $driveLetter -GitRepoUrl $repos 

$driveReadme = @'
{driveReadme}
'@
if (Test-Path -LiteralPath "$($driveLetter):\") {
    $driveReadme | Set-Content -LiteralPath "$($driveLetter):\DRIVE-INFO.md" -Encoding UTF8
}

# Optional migration template commands (left commented intentionally) These are used for creating .NET templates for migration purposes. Uncomment and modify as needed for your specific project requirements.
# $Moniker = ""
# Create-DotNetTemplatesForMigration -API -ProjectId $projectId -ProjectName "$($projectName)$($Moniker)" -ProjectRootDriveLetter $driveLetter
# Write-Host "-----------------------------"
# Create-DotNetTemplatesForMigration -UI -ProjectId $projectId -ProjectName "$($projectName)$($Moniker)" -ProjectRootDriveLetter $driveLetter
# Write-Host "-----------------------------"
