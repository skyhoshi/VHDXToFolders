# C:\Users\kernm\.nuget\packages\nunit.consolerunner\3.16.3\tools\nunit3-console.exe
. "C:\Users\kernm\OneDrive - Farm Credit Services of America\Documents\PowerShell\Scripts\listmethodsinps1file.ps1"

function Run-LNP {
    # param (
    #     $NunitConsolePath = $OctopusParameters['NunitConsolePath'],
    $clientId = '0oa1z15e9uj42qlRs0h8'
    $clientSecret = ''
    $tokenEndpoint = "https://devlogin.fcsamerica.com/oauth2/aus1z156vepemtJfZ0h8/v1/token"
    $webEnv = 'dev'
    $testBaseUrl = "https://devlightningproxyk8s.fcsamerica.net"
    #$testBaseUrl = "http://localhost:5078"
    #     $additionalNUnitParameters = ""
    # )
    # C:\Source\FCSAmerica\SolutionsEnablement\LightningProxy\test\PostDeploymentTests\bin\Debug\net6.0\
    # RunPostDeployTests.ps1
    $local_nunit_console_exe = "C:\Users\kernm\.nuget\packages\nunit.consolerunner\3.17.0\tools\nunit3-console.exe"
    $local_nunit_console_exe = "\\teamserver\library\NUnit\NUnit3.17.0\nunit3-console.exe"
    $runLocation = "S:\Code\FCSAmerica\SolutionsEnablement\LightningProxy\test\PostDeploymentTests\bin\Debug\net6.0\"
    $scriptToExecute = "$($runLocation)RunPostDeployTests.ps1"
    $previousLocation = $PWD
    Set-Location $runLocation
    Write-Host "$PWD"
    $command = "$scriptToExecute -NunitConsolePath $local_nunit_console_exe -clientId $clientId -clientSecret $clientSecret -tokenEndpoint $tokenEndpoint -webEnv $webEnv -testBaseUrl $testBaseUrl" # -additionalNUnitParameters '--explore'"
    #Write-Host "Running $command "
    Invoke-Expression -Command $command
    Set-Location $previousLocation
}
Run-LNP
#{Octopus.Action[Okta Console Runner].Output.Organization AuthServer Audience}