# This is intended to be a usage example. 
if (-NOT ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) {
    Write-Host "Insufficient permissions to run the entirety of this script." -ForegroundColor Red
    Write-Host "YOU MAY ENCOUNTER ERRORS : IF YOU DO PLEASE OPEN UP A RUN AS ADMINISTRATORS PROMPT." -ForegroundColor Red

}
else {
    Write-Host "YOU ARE RUNNING AS ADMINISTRATOR" -ForegroundColor Green
}

. $PSScriptRoot\..\main.ps1;

$ServiceAccountName = "PayHist_msa_O"
$IISAppPoolName = "PaymentHistory.WebAPI.V1"


$IISApplicationName = "PaymentHistory\V1\REST" #Not Site Name : This should be a formatted path to the application as a virtual directory. 

# Must always be run first. without it the app pool will fail to create.
Install-FCSAServiceAccount -UserName $ServiceAccountName
#
New-FCSAIISAppPool -UserName $ServiceAccountName -IISAppPoolRootLocation $IISAppPoolName -IISApplication $IISApplicationName

