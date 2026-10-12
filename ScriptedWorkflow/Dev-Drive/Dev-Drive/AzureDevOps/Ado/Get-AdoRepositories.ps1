# =====================================================================
# Azure DevOps API calls
# =====================================================================

function Get-AdoRepositories {
    # Org-level endpoint returns repos across all projects in a single call
    $url = "$BaseUrl/_apis/git/repositories?api-version=$($Config.ApiVersion)"
    $response = Invoke-RestMethod -Uri $url -Headers $Headers -Method Get

    $response.value | ForEach-Object {
        [pscustomobject]@{
            Id            = $_.id
            Name          = $_.name
            ProjectId     = $_.project.id
            ProjectName   = $_.project.name
            DefaultBranch = $_.defaultBranch
            Size          = $_.size
            IsDisabled    = $_.isDisabled
            RemoteUrl     = $_.remoteUrl
            SshUrl        = $_.sshUrl
            WebUrl        = $_.webUrl
        }
    }
}