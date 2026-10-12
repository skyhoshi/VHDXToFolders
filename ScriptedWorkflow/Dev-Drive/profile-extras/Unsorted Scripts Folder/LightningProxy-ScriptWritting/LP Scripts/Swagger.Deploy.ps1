<#
This File's Content is copied into : https://octopus.fcsamerica.com/app#/Spaces-1/projects/lightningproxy-api-swagger-beta/deployments/process/steps?actionId=726d9de1-159b-49a3-95d5-f816de074079
#>
. "C:\Users\kernm\OneDrive - Farm Credit Services of America\Documents\PowerShell\Scripts\listmethodsinps1file.ps1"

<#
# For Testing locally only

$OctopusParameters = @{
    "Web Install Directory"                                                       = "D:/LightningProxy" 
    "Octopus.Release.Channel.Name"                                                = "$paramApiName-$paramApiVersion"
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
Write-Host "Swagger.Deploy.ps1"

function Process {
    param(
        $storagePath = $OctopusParameters["Web Install Directory"],
        $channel = $OctopusParameters["Octopus.Release.Channel.Name"],
        $baseUrl = $OctopusParameters['BaseUrl'],
        $additionalNUnitParameters = ""
    )
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

    $fullPathLocation = "$storagePath/$apiName/$apiVersion/swagger.json"

    if (Test-Path -Path $fullPathLocation) {
        Write-Host "Full Path Location : $fullPathLocation"
    }
    else {
        throw "File not found Please check your channel and swagger file $($fullPathLocation)"
    }

    # Available Features found at : https://devlogin.fcsamerica.com/oauth2/aus1z156vepemtJfZ0h8/.well-known/oauth-authorization-server
    # Running against prod (using dev as the initial environment):
    #   Get Client Secret from https://devfcsamerica.oktapreview.com/admin/app/oidc_client/instance/aus1z156vepemtJfZ0h8/#tab-general
    #       Client secret is used in the powershell call
    #   Perform a `dotnet publish` in the PostDeploy test project folder
    #   then `cd bin\Debug\netcoreapp3.1\publish`
    #   then run  ..\..\..\..\RunPostDeployTests.ps1 -clientId "aus1z156vepemtJfZ0h8" -clientSecret "<secret from Okta>" -tokenEndpoint "https://devfcsamerica.oktapreview.com/oauth2/aus1z156vepemtJfZ0h8/v1/token" -webEnv "dev"

    # Dev only
    # https://devfcsamerica.oktapreview.com/admin/app/oidc_client/instance/aus1z156vepemtJfZ0h8/#tab-general

        
    $authToken = Get-OAuthTokenFromEndpoint -OAuthTokenEndpoint  $OctopusParameters['TokenEndpoint'] -ClientId $OctopusParameters['Octopus.Action[Okta Console Runner].Output.LightningProxy.API Client Id']  -ClientSecret  $OctopusParameters['Octopus.Action[Okta Console Runner].Output.LightningProxy.API Client Secret']
    if ($null -eq $authToken) {
        throw "Auth Token is null"
    }
    else {
        Write-Host "Auth Token: $($authToken.SubString(0, 15))"
    }

    Send-File -Token $authToken -InFileLocation $fullPathLocation -BaseUrl $baseUrl -apiName $apiName -apiVersion $apiVersion | Out-Null
}

function Get-OAuthTokenFromEndpoint {
    [CmdletBinding()]
    param (
        [Parameter()][string]
        $OAuthTokenEndpoint = $OctopusParameters['TokenEndpoint'],
        [Parameter()][string]
        $ClientId = $OctopusParameters['ClientId'],
        [Parameter()][string]
        $ClientSecret = $OctopusParameters['LightningProxyOktaClientSecret']
    )

    Write-Host "Oauth Token Endpoint : $OAuthTokenEndpoint"
    Write-Host "Client Id: $ClientId"
    Write-Host "Client Secret: $($ClientSecret.SubString(0,4))"
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

function Send-File {
    [CmdletBinding()]
    param (
        [Parameter()][string]$Token,
        [Parameter()][string]$InFileLocation,
        [Parameter()][string]$BaseUrl,
        [Parameter()][string]$apiName,
        [Parameter()][string]$apiVersion
    )
    
    Write-Host "In File Location: $InFileLocation"    
    Write-Host "Attempting to send file to $BaseUrl"
    $fileBytes = [System.IO.File]::ReadAllBytes($InFileLocation)
    $fileEnc = [System.Text.Encoding]::GetEncoding('UTF-8').GetString($fileBytes)
    $boundary = [System.Guid]::NewGuid().ToString() 
    $LF = "`r`n"

    $bodyLines = ( 
        "--$boundary",
        "Content-Disposition: form-data; name=`"apiName`"$LF",
        $apiName,
        "--$boundary",
        "Content-Disposition: form-data; name=`"apiVersion`"$LF",
        $apiVersion,
        "--$boundary",
        "Content-Disposition: form-data; name=`"swagger`"; filename=`"swagger`"",
        "Content-Type: application/octet-stream$LF",
        $fileEnc,
        "--$boundary--$LF" 
    ) -join $LF

    $header_Out = @{"authorization" = "bearer $Token" }
    Invoke-RestMethod -Uri $BaseUrl -Method Post -ContentType "multipart/form-data; boundary=`"$boundary`"" -Body $bodyLines -Headers $header_Out
}
# Write-Host $($OctopusParameters)
## To Test Getting an Auth Token: 
# Write-Host $(Get-OAuthTokenFromEndpoint)

Process