<#
This file's content is ment to get all the files on the server (for post deploy validation)
#>
. "C:\Users\kernm\OneDrive - Farm Credit Services of America\Documents\PowerShell\Scripts\listmethodsinps1file.ps1"

<#
# For Testing locally only

$OctopusParameters = @{
    "Web Install Directory"                                                       = "D:/LightningProxy" 
    "Octopus.Release.Channel.Name"                                                = "default"
    "WebEnv"                                                                      = "local"
    "BaseFileUri"                                                                 = "https://devlightningproxyk8s.fcsamerica.net"
    "BaseUrl"                                                                     = "https://devlightningproxyk8s.fcsamerica.net/api/swagger/"
    "TokenEndpoint"                                                               = "https://devlogin.fcsamerica.com/oauth2/aus1z156vepemtJfZ0h8/v1/token"
    "Octopus.Action[Okta Console Runner].Output.LightningProxy.API Client Id"     = "0oa1z15e9uj42qlRs0h8"
    "Octopus.Action[Okta Console Runner].Output.LightningProxy.API Client Secret" = $env:0oa1z15e9uj42qlRs0h8_Token
    "Octopus.Action[Get ApiName and ApiVersion].Output.ApiName"                   = $paramApiName
    "Octopus.Action[Get ApiName and ApiVersion].Output.ApiVersion"                = $paramApiVersion
}
#>
Write-Host "Swagger.Check.ps1"
function Process {
    if ($OctopusParameters["Octopus.Release.Channel.Name"].ToLower() -eq "Default".ToLower()) {
        $apiName = $OctopusParameters["Octopus.Action[Get ApiName and ApiVersion].Output.ApiName"]
        $apiVersion = $OctopusParameters["Octopus.Action[Get ApiName and ApiVersion].Output.ApiVersion"]
        Write-Host "ApiName: $apiName"
        Write-Host "ApiVersion: $apiVersion"
    }
    else {
        $channelSplit = $OctopusParameters["Octopus.Release.Channel.Name"] -Split "-"
        $apiName = $channelSplit[0]
        $apiVersion = $channelSplit[1]
    }
    # Available Features found at : https://devfcsamerica.oktapreview.com/oauth2/aus1z156vepemtJfZ0h8/.well-known/oauth-authorization-server
    # Running against prod (using dev as the initial environment):
    #   Get Client Secret from https://devfcsamerica.oktapreview.com/admin/app/oidc_client/instance/aus1z156vepemtJfZ0h8/#tab-general
    #       Client secret is used in the powershell call
    #   Perform a `dotnet publish` in the PostDeploy test project folder
    #   then `cd bin\Debug\netcoreapp3.1\publish`
    #   then run  ..\..\..\..\RunPostDeployTests.ps1 -clientId "aus1z156vepemtJfZ0h8" -clientSecret "<secret from Okta>" -tokenEndpoint "https://devfcsamerica.oktapreview.com/oauth2/aus1z156vepemtJfZ0h8/v1/token" -webEnv "dev"

    # Dev only
    # https://devfcsamerica.oktapreview.com/admin/app/oidc_client/instance/aus1z156vepemtJfZ0h8/#tab-general
    # 

    $authToken = Get-OAuthTokenFromEndpoint -OAuthTokenEndpoint  $OctopusParameters['TokenEndpoint'] -ClientId $OctopusParameters['Octopus.Action[Okta Console Runner].Output.LightningProxy.API Client Id']  -ClientSecret  $OctopusParameters['Octopus.Action[Okta Console Runner].Output.LightningProxy.API Client Secret']
    if ($null -eq $authToken) {
        throw "Auth Token is null"
    }
    else {
        Write-Host "Auth Token: $($authToken.SubString(0, 15))"
    }
    $result = Get-ExpectedMissingFile -Token $authToken -BaseUrl $OctopusParameters['BaseFileUri'] -apiName $apiName -apiVersion $apiVersion
    $allResult = Get-Files -Token $authToken -BaseUrl $OctopusParameters['BaseUrl'] -apiName $apiName -apiVersion $apiVersion
    Write-Host "All Files Found:"
    Write-Host $allResult
    if ($result -eq $true) {
        Write-Error "File was not removed as expected"
    }
}

function Get-OAuthTokenFromEndpoint {
    [CmdletBinding()]
    param (
        [Parameter()]
        [string]
        $OAuthTokenEndpoint = $OctopusParameters['TokenEndpoint'],
        [Parameter()]
        [string]
        $ClientId = $OctopusParameters['ClientId'],
        [Parameter()]
        [string]
        $ClientSecret = $OctopusParameters['LightningProxyOktaClientSecret']
    )
    $creds = @{
        client_id     = $ClientId
        client_secret = $ClientSecret
        grant_type    = "client_credentials"
    }

    $header_token = @{"Content-Type" = "application/x-www-form-urlencoded" }

    $response = Invoke-RestMethod "$OAuthTokenEndpoint" -Method Post -Body $creds -Headers $header_token

    $token = $response.access_token
    return $token
}

function Get-ExpectedMissingFile {
    [CmdletBinding()]
    param (
        [Parameter()][string]$Token,
        [Parameter()][string]$BaseUrl,
        [Parameter()][string]$apiName,
        [Parameter()][string]$apiVersion
    )
    $header_Out = @{"authorization" = "bearer $token" }
    #$response = Invoke-RestMethod -Uri $BaseUrl -Method Get  -Headers $header_Out # -ContentType "multipart/form-data; boundary=`"$boundary`"" -Body $bodyLines
    
    $fullUrl = "$BaseUrl/$apiName/$apiVersion/swagger.json"
    Write-Host $fullUrl
    try {
        #https://learn.microsoft.com/powershell/module/microsoft.powershell.utility/invoke-webrequest?view=powershell-5.1&WT.mc_id=ps-gethelp
        $response = Invoke-WebRequest -Uri $fullUrl -Headers $header_Out
        Write-Host "$($response.StatusCode)"
        if ($response.StatusCode -eq 200) {
            return $false
        }
        return $true
    }
    catch {
        <#Do this if a terminating exception happens#>
        $StatusCode = $_.Exception.Response.StatusCode.value__
        Write-Host $StatusCode
        if ($response.StatusCode -eq 404) {
            return $true
        }
        else{
            return $false
        }
    }
    return $false
}

function Get-Files {
    [CmdletBinding()]
    param (
        [Parameter()][string]$Token,
        [Parameter()][string]$BaseUrl,
        [Parameter()][string]$apiName,
        [Parameter()][string]$apiVersion
    )
    $header_Out = @{"authorization" = "bearer $token" }
    #$response = Invoke-RestMethod -Uri $BaseUrl -Method Get  -Headers $header_Out # -ContentType "multipart/form-data; boundary=`"$boundary`"" -Body $bodyLines
    
    $fullUrl = "$BaseUrl"
    Write-Host "Get All Files Uri: $fullUrl"
    $response = Invoke-WebRequest -Uri $fullUrl -Method Get -Headers $header_Out
    return $response.Content

}
# Write-Host $($OctopusParameters)
## To Test Getting an Auth Token: 
# Write-Host $(Get-OAuthTokenFromEndpoint)


Process