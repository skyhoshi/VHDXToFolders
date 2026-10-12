. "C:\Users\kernm\OneDrive - Farm Credit Services of America\Documents\PowerShell\Scripts\listmethodsinps1file.ps1"

$paramApiName = "CallItRod"
$paramApiVersion = "v12"

# $OctopusParameters = @{
#     "Web Install Directory"          = "D:/LightningProxy" 
#     "Octopus.Release.Channel.Name"   = "$paramApiName-$paramApiVersion"
#     "BaseFileUri"                    = "https://devlightningproxyk8s.fcsamerica.net"
#     "BaseUrl"                        = "https://devlightningproxyk8s.fcsamerica.net/api/swagger/"
#     "TokenEndpoint"                  = "https://devlogin.fcsamerica.com/oauth2/aus1z156vepemtJfZ0h8/v1/token" #"https://devfcsamerica.oktapreview.com/oauth2/aus1z156vepemtJfZ0h8/v1/token"
#     "ClientId"                       = "0oa1z15e9uj42qlRs0h8"
#     "LightningProxyOktaClientSecret" = "9L_13_tmNhhRY4OkmikCFdkihIopOxEi0hHoyqK8DyC02CV3tXblxPr5JH_um8N9" #$env:0oa1z15e9uj42qlRs0h8_Token
# }
$OctopusParameters = @{
    "Web Install Directory"                                                       = "S:\Code\FCSAmerica\ApiContracts\APIContracts-v2"#"D:/LightningProxy" 
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
#Write-Host $OctopusParameters.Values
Write-Host "====================================="
& S:\Code\FCSAmerica\SolutionsEnablement\LightningProxy\source\ApiContractsDeploy\Swagger.Deploy.ps1
$OctopusParameters["Octopus.Release.Channel.Name"] = "default"
Write-Host "====================================="
& S:\Code\FCSAmerica\SolutionsEnablement\LightningProxy\source\ApiContractsDeploy\Swagger.Check.ps1
Write-Host "====================================="
#& S:\Code\FCSAmerica\SolutionsEnablement\LightningProxy\source\ApiMappingDeploy\Swagger.Cleanup.ps1
# Write-Host "====================================="
# & S:\Code\FCSAmerica\SolutionsEnablement\LightningProxy\source\ApiMappingDeploy\Swagger.Check.ps1