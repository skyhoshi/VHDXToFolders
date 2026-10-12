#.\Invoke-AzureDevOpsBuild.ps1 -BuildDefinitionId 3037 -YamlFileDescriptor "deployment.yml" -OctopusDeployProjectName "MyProject" -NotificationEmail "user@example.com" -SourceBranch "develop"
. "$(Join-Path $PSScriptRoot 'Setup\Invoke-AzureDevOpsBuild.ps1')";
$OctopusDeployProjectName = "IdentityAccessManagement - Configure Okta Component - FCSA Tenant"
$NotificationEmail = " "
$sourceBranch = "feature/255395-CIV-add-authenticated-endpoints"
$sourceBranch = "master"
$WhatIfPreference = "Inquire";
$DebugMode = $true;
$WhatIfMode = $false;
$list = @(
    <#  "Applications.CustomerInfoVault.API.CTPO"
    , "Applications.CustomerInfoVault.Tests.CTPO"
    , "Applications.CustomerInfoVault.API.FCMA"
    , "Applications.CustomerInfoVault.Tests.FCMA"
    , "Applications.CustomerInfoVault.API"
    , "Applications.CustomerInfoVault.Tests"
    , "AuthorizationServers.CustomerInfoVault"
    , "AuthorizationServers.CommonApiAuthServer"    
    #>
);
$buildConfigurations = [System.Collections.ArrayList]@(
    # @{
    #     YamlFileDescriptor       = "deployment.yml"
    #     OctopusDeployProjectName = $OctopusDeployProjectName
    #     NotificationEmail        = $NotificationEmail
    #     SourceBranch             = $sourceBranch
    # },
    # @{
    #     YamlFileDescriptor       = "another-deployment.yml"
    #     OctopusDeployProjectName = $OctopusDeployProjectName
    #     NotificationEmail        = $NotificationEmail
    #     SourceBranch             = $sourceBranch
    # }
)

foreach ($item in $list) {
    $singleBuildConfiguration = @{
        YamlFileDescriptor       = $item
        OctopusDeployProjectName = $OctopusDeployProjectName
        NotificationEmail        = $NotificationEmail
        SourceBranch             = $sourceBranch
    }
    $buildConfigurations.Add($singleBuildConfiguration) | Out-Null;
}
# $singleBuildConfiguration = @{
#     YamlFileDescriptor       = "Applications.CustomerInfoVault.API.CTPO"
#     OctopusDeployProjectName = $OctopusDeployProjectName
#     NotificationEmail        = $NotificationEmail
#     SourceBranch             = $sourceBranch
# }




foreach ($config in $buildConfigurations) {
    if($WhatIfMode){
        Write-Host "WhatIf mode is enabled. The following build would be triggered:" -ForegroundColor Yellow
        Write-Host "Build Definition ID: 3037" -ForegroundColor Cyan
        Write-Host "YAML File Descriptor: $($config.YamlFileDescriptor)" -ForegroundColor Cyan
        Write-Host "Octopus Deploy Project Name: $($config.OctopusDeployProjectName)" -ForegroundColor Cyan
        Write-Host "Notification Email: $($config.NotificationEmail)" -ForegroundColor Cyan
        Write-Host "Source Branch: $($config.SourceBranch)" -ForegroundColor Cyan
        Write-Host "Organization: $env:AZURE_DEVOPS_ORGANIZATION" -ForegroundColor Cyan
        Write-Host "Project: $env:AZURE_DEVOPS_PROJECT" -ForegroundColor Cyan
        Create-OktaAzureDevOpsBuildById -YamlFileDescriptor $config.YamlFileDescriptor -NotificationEmail $config.NotificationEmail -SourceBranch $config.SourceBranch -WhatIf -Debug
    }
    else {
        Create-OktaAzureDevOpsBuildById -YamlFileDescriptor $config.YamlFileDescriptor -NotificationEmail $config.NotificationEmail -SourceBranch $config.SourceBranch
    }
    Write-Host "---------------------------------------------" -ForegroundColor Green
}
#Create-OktaAzureDevOpsBuildById -BuildDefinitionId 3037 -YamlFileDescriptor "deployment.yml" -OctopusDeployProjectName "MyProject" -NotificationEmail "user@example.com" -SourceBranch "develop"


# Applications.CustomerInfoVault.API.CTPO
# Applications.CustomerInfoVault.API.FCMA
# Applications.CustomerInfoVault.API.FCSA
# Applications.CustomerInfoVault.Tests.CTPO
# Applications.CustomerInfoVault.Tests.FCMA
# Applications.CustomerInfoVault.Tests.FCSA
# AuthorizationServers.CustomerInfoVault
#AuthorizationServers.CommonApiAuthServer