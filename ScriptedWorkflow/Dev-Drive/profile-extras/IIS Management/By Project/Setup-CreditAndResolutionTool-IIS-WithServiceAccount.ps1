# This is intended to be a usage example. 
if (-NOT ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) {
    Write-Host "Insufficient permissions to run the entirety of this script." -ForegroundColor Red
    Write-Host "YOU MAY ENCOUNTER ERRORS : IF YOU DO PLEASE OPEN UP A RUN AS ADMINISTRATORS PROMPT." -ForegroundColor Red

}
else {
    Write-Host "YOU ARE RUNNING AS ADMINISTRATOR" -ForegroundColor Green
}

. $PSScriptRoot\..\main.ps1;

$ServiceAccountName = "webapps_msa_O"
$IISAppPoolName = "CreditAndResolutionsTool.Client"
$IISApplicationName = "CreditAndResolutionsTool/Client" #Not Site Name : This should be a formatted path to the application as a virtual directory. 

if ($DebugMode) {
    Clear-PatronageIISSites -IISAppPoolName $ServiceAccountName -IISAppPoolRootLocation "patronage/elastic/v1" -IISVirtualDirectory "patronage/elastic"
    #This should return 0 if you want to start completely over.
    Get-ChildItem -Path "IIS:\Sites\Default Web Site\" | Where-Object { $_.NodeType -eq "application" -or $_.NodeType -eq "virtualDirectory" }
}

# Must always be run first. without it the app pool will fail to create.
Install-FCSAServiceAccount -UserName $ServiceAccountName
#
New-FCSAIISAppPool -UserName $ServiceAccountName -IISAppPoolRootLocation $IISAppPoolName -IISApplication $IISApplicationName

$ServiceAccountName = "crreso_msa_O"
$IISAppPoolName = "CreditAndResolutionsTool.ServiceAPI_V1"
$IISApplicationName = "CreditAndResolutionsTool/Services/V1/ServiceAPI" #Not Site Name : This should be a formatted path to the application as a virtual directory. 

# Must always be run first. without it the app pool will fail to create.
Install-FCSAServiceAccount -UserName $ServiceAccountName
#
New-FCSAIISAppPool -UserName $ServiceAccountName -IISAppPoolRootLocation $IISAppPoolName -IISApplication $IISApplicationName

