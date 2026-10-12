. "C:\Users\kernm\OneDrive - Farm Credit Services of America\Documents\PowerShell\Scripts\listmethodsinps1file.ps1"
Write-Host "Loading Jenkins Job Execution Script"
$OctopusParameters = @{
    "jqj_JobUrl"                                                                  = "/view/Solutions%20Enablement/job/LightningProxy-PostDeploymentTests" 
    "jqj_FailBuild"                                                               = "false"
    "jqj_JobTimeout"                                                              = "120"
    "jqj_BuildParam"                                                              = "EnvironmentName=dev"
    "jqj_JenkinsServer"                                                           = "https://jenkinsfcsa.fcsamerica.com"
    "jqj_BuildWithParameters"                                                     = "True"
    "JenkinsAuthorizedUsername"                                                   = "kernm" #$env:USERNAME
    "JenkinsAuthorizedUserApiKey"                                                 = "1103e9df770688f411a1030af64c7a06d0"
    "JenkinsAuthorizationHeader"                                                  = ""
}
$error.Clear();

$Text = "$($OctopusParameters['JenkinsAuthorizedUsername']):$($OctopusParameters['JenkinsAuthorizedUserApiKey'])"
#$Text;
$Bytes = [System.Text.Encoding]::Unicode.GetBytes($Text)
$EncodedText =[Convert]::ToBase64String($Bytes)
$OctopusParameters["JenkinsAuthorizationHeader"] = "basic $EncodedText";


. "C:\Users\kernm\OneDrive - Farm Credit Services of America\PowerShell\Scripts\Jenkins\Jenkins Job Execution Script.ps1"

