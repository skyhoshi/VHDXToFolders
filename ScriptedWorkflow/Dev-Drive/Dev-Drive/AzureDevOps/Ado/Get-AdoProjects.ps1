# =====================================================================
# Azure DevOps API calls
# =====================================================================
function Get-AdoProjects {
    $projects = [System.Collections.Generic.List[object]]::new()
    $continuationToken = $null

    # Projects API pages via the x-ms-continuationtoken response header
    do {
        $url = "$BaseUrl/_apis/projects?`$top=$($Config.ProjectsPageSize)&api-version=$($Config.ApiVersion)"
        if ($continuationToken) { $url += "&continuationToken=$continuationToken" }

        $response = Invoke-RestMethod -Uri $url -Headers $Headers -Method Get -ResponseHeadersVariable respHeaders
        $response.value | ForEach-Object { $projects.Add($_) }

        $continuationToken = $respHeaders['x-ms-continuationtoken'] | Select-Object -First 1
    } while ($continuationToken)

    # Keep only the fields we care about to keep the cache small
    $projects | ForEach-Object {
        [pscustomobject]@{
            Id             = $_.id
            Name           = $_.name
            Description    = $_.description
            State          = $_.state
            Visibility     = $_.visibility
            LastUpdateTime = $_.lastUpdateTime
            Url            = "$BaseUrl/$([uri]::EscapeDataString($_.name))"
        }
    }
}
