. "C:\Users\kernm\OneDrive - Farm Credit Services of America\Documents\PowerShell\Scripts\listmethodsinps1file.ps1"

$jenkinsServer = $OctopusParameters['jqj_JenkinsServer'] 
$jobURL = $jenkinsServer + $OctopusParameters['jqj_JobUrl']
if ($OctopusParameters['jqj_BuildWithParameters'].ToLower() -eq "true") {
    $buildUrl = $jobUrl + '/buildWithParameters'
}
else {
    $buildUrl = $jobUrl + '/build'
}
$failBuild = $OctopusParameters['jqj_FailBuild']
$jobTimeout = $OctopusParameters['jqj_JobTimeout']
$buildParam = $OctopusParameters['jqj_BuildParam']
$buildResult = "/lastBuild/api/json?tree=result,number,building"

$authHeader = $OctopusParameters['JenkinsAuthorizationHeader']
$crumbUrl = $jenkinsServer + "/crumbIssuer/api/xml?xpath=concat(//crumbRequestField,%22:%22,//crumb)"
$headers = New-Object "System.Collections.Generic.Dictionary[[String],[String]]"
$headers.Add("Authorization", $authHeader)
#get the crumb
try {
    
    $crumbResponse = Invoke-WebRequest -Uri $crumbUrl  -Method Get -Headers $headers #-SkipHttpErrorCheck
}
catch {
    <#Do this if a terminating exception happens#>
}
$crumbParts = $crumbResponse.Content.Split(":")
$headers.Add($crumbParts[0], $crumbParts[1])
$headers.Add('Content-Type', 'application/x-www-form-urlencoded')
if ($error.Count -gt 0) {
    Write-Host "Failed"
    Write-Host $crumbResponse
    return
}
Write-Host "Build url: " $buildURL

$response = Invoke-WebRequest -Uri $buildURL -Method Post -Headers $headers -Body $buildParam

if ($failBuild -eq "True") {
    $isBuilding = "True"
    $i = 0
    Write-Host "Max Job Duration: " $jobTimeout
    while ($isBuilding -eq "True" -and $i -lt $jobTimeout) {       
        $i += 20
        Write-Host "Continuing to wait for build to complete..."
        Start-Sleep -s 20
        $retyJobStatus = Invoke-RestMethod -Uri $jobURL$buildResult -Method Get
        $isBuilding = $retyJobStatus[0].building
        $result = $retyJobStatus[0].result
        $buildNumber = $retyJobStatus[0].number
        Write-Host "Retry Job Status: " $result " BuildNumber: "  $buildNumber  " IsBuilding: "  $isBuilding 
    }
   
    if ($result -ne "SUCCESS") {
        echo "BUILD FAILURE: build is unsuccessful or status could not be obtained."
        exit 1
    }
}