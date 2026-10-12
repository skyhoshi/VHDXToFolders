# Class representing project setup information
# =====================================================================
# Secret resolution: $env first, then secrets.json
# =====================================================================

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