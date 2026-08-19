# Project: {projectName}
$projectName = "{projectName}"
$projectId = {setupInfo-ProjectId}
$driveLetter = "{setupInfo-DriveLetter}"
[string[]]$repos = {repoList}
New-DevelopmentStorageEnvironment -ProjectId $projectId -ProjectName $projectName -ProjectRootDriveLetter $driveLetter -GitRepoUrl $repos 

# Optional migration template commands (left commented intentionally) These are used for creating .NET templates for migration purposes. Uncomment and modify as needed for your specific project requirements.
# $Moniker = ""
# Create-DotNetTemplatesForMigration -API -ProjectId $projectId -ProjectName "$($projectName)$($Moniker)" -ProjectRootDriveLetter $driveLetter
# Write-Host "-----------------------------"
# Create-DotNetTemplatesForMigration -UI -ProjectId $projectId -ProjectName "$($projectName)$($Moniker)" -ProjectRootDriveLetter $driveLetter
# Write-Host "-----------------------------"
