<#
.SYNOPSIS
Invokes an Azure DevOps Build by ID with specified parameters.

.DESCRIPTION
This script queues a new build in Azure DevOps for a specified build definition ID
and passes custom parameters to be used in the pipeline.

.PARAMETER BuildDefinitionId
The ID of the build definition to queue.

.PARAMETER YamlFileDescriptor
The YAML file descriptor parameter to pass to the build.

.PARAMETER OctopusDeployProjectName
The Octopus Deploy project name parameter to pass to the build.

.PARAMETER NotificationEmail
The email address for build notifications.

.PARAMETER Organization
The Azure DevOps organization name. If not provided, reads from environment variable AZURE_DEVOPS_ORGANIZATION.

.PARAMETER Project
The Azure DevOps project name. If not provided, reads from environment variable AZURE_DEVOPS_PROJECT.

.PARAMETER PersonalAccessToken
The Personal Access Token for authentication. If not provided, reads from environment variable AZURE_DEVOPS_PAT.

.PARAMETER SourceBranch
The source branch for the build. Defaults to 'main' if not specified.

.EXAMPLE
.\Invoke-AzureDevOpsBuild.ps1 -BuildDefinitionId 123 `
    -YamlFileDescriptor "deployment.yml" `
    -OctopusDeployProjectName "MyProject" `
    -NotificationEmail "user@example.com" `
    -SourceBranch "develop"

.NOTES
Prerequisites:
- Azure DevOps Personal Access Token (PAT) with Build (queue builds) permissions
- Set AZURE_DEVOPS_ORGANIZATION, AZURE_DEVOPS_PROJECT, and AZURE_DEVOPS_PAT environment variables,
  or pass them as parameters.
#>
function Create-OktaAzureDevOpsBuildById {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $false, HelpMessage = "The Azure DevOps Build Definition ID")]
        [int]$BuildDefinitionId = 3037,

        [Parameter(Mandatory = $true, HelpMessage = "The YAML file descriptor for the build")]
        [string]$YamlFileDescriptor,

        [Parameter(Mandatory = $false, HelpMessage = "The Octopus Deploy project name")]
        [string]$OctopusDeployProjectName = "IdentityAccessManagement - Configure Okta Component - FCSA Tenant",

        [Parameter(Mandatory = $false, HelpMessage = "The notification email address")]
        [string]$NotificationEmail = " ",

        [Parameter(Mandatory = $false, HelpMessage = "Azure DevOps Organization name")]
        [string]$Organization = $env:AZURE_DEVOPS_ORGANIZATION,

        [Parameter(Mandatory = $false, HelpMessage = "Azure DevOps Project name")]
        [string]$Project = $env:AZURE_DEVOPS_PROJECT,

        [Parameter(Mandatory = $false, HelpMessage = "Azure DevOps Personal Access Token")]
        [string]$PersonalAccessToken = $env:AZURE_DEVOP_EXECUTION_PAT,

        [Parameter(Mandatory = $false, HelpMessage = "Source branch for the build")]
        [string]$SourceBranch = "main",

        [Parameter(Mandatory = $false, HelpMessage = "If set, prevents the REST API call from executing")]
        [switch]$WhatIf
    )
    begin {
        $ErrorActionPreference = "Stop"

        # Validate required parameters
        if (-not $Organization) {
            throw "Organization must be provided as parameter or set in AZURE_DEVOPS_ORGANIZATION environment variable."
        }

        if (-not $Project) {
            #throw "Project must be provided as parameter or set in AZURE_DEVOPS_PROJECT environment variable."
            $Project = "SolutionsEnablement"
        }

        if (-not $PersonalAccessToken) {
            throw "PersonalAccessToken must be provided as parameter or set in AZURE_DEVOP_EXECUTION_PAT environment variable."
        }
    }
    
    process {
        # Create base64 encoded authentication header
        $auth = [Convert]::ToBase64String([Text.Encoding]::ASCII.GetBytes(":$PersonalAccessToken"))

        # Build the Azure DevOps API URL
        $apiUrl = "https://dev.azure.com/$Organization/$Project/_apis/build/builds?api-version=7.0"
        # Write-Debug "API URL: $apiUrl"
        # Create the request body with custom template parameters
        $requestBody = @{
            definition           = @{
                id = $BuildDefinitionId
            }
            sourceBranch         = $SourceBranch
            templateParameters   = @{
                "YamlFileDescriptor"       = $YamlFileDescriptor
                "OctopusDeployProjectName" = $OctopusDeployProjectName
                "NotificationEmail"        = $NotificationEmail
            }
        } | ConvertTo-Json -Depth 10

        Write-Verbose "Request body: $requestBody"

        try {
            Write-Host "Queuing build definition $BuildDefinitionId in project $Project..." -ForegroundColor Cyan
    
            if (-not $WhatIf) {
                $response = Invoke-RestMethod -Uri $apiUrl -Method Post -Headers @{ Authorization  = "Basic $auth"; "Content-Type" = "application/json" } -Body $requestBody 

                Write-Host "Build queued successfully!" -ForegroundColor Green
                Write-Host ""
                Write-Host "Build Details:" -ForegroundColor Cyan
                Write-Host "  Build ID: $($response.id)"
                Write-Host "  Build Number: $($response.buildNumber)"
                Write-Host "  Status: $($response.status)"
                Write-Host "  URL: $($response.url)"
                Write-Host ""
                Write-Host "Parameters passed:" -ForegroundColor Cyan
                Write-Host "  YamlFileDescriptor: $YamlFileDescriptor"
                Write-Host "  OctopusDeployProjectName: $OctopusDeployProjectName"
                Write-Host "  NotificationEmail: $NotificationEmail"
        
                return $response
            }
            else {
                Write-Host "WhatIf mode enabled. Skipping API call." -ForegroundColor Yellow
                Write-Host ""
                Write-Host "Invoke-RestMethod -Uri $apiUrl -Method Post -Body $requestBody"
                Write-Host ""
                Write-Host "Would queue with parameters:" -ForegroundColor Cyan
                Write-Host "  YamlFileDescriptor: $YamlFileDescriptor"
                Write-Host "  OctopusDeployProjectName: $OctopusDeployProjectName"
                Write-Host "  NotificationEmail: $NotificationEmail"
            }
        }
        catch {
            Write-Host "Error queuing build: $($_.Exception.Message)" -ForegroundColor Red
    
            if ($_.Exception.Response) {
                $errorContent = $_.Exception.Response.Content.ReadAsStreamAsync().Result
                $reader = New-Object System.IO.StreamReader($errorContent)
                $errorBody = $reader.ReadToEnd()
                Write-Host "Response: $errorBody" -ForegroundColor Yellow
            }
    
            throw
        }
    }
    
    end {
        
    }
}
if ($PSBoundParameters.ContainsKey('Debug') -or $args.Contains('-Debug')) {
    Create-OktaAzureDevOpsBuildById -YamlFileDescriptor "deployment.yml" -NotificationEmail "user@example.com" -SourceBranch "develop" -WhatIf -Debug
}
else {
    Write-Verbose "No Command Tested"
}