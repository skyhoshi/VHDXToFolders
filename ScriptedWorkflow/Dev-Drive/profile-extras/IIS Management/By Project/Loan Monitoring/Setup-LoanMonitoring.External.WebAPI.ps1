# This is intended to be a usage example. 
if (-NOT ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) {
    Write-Host "Insufficient permissions to run the entirety of this script." -ForegroundColor Red
    Write-Host "YOU MAY ENCOUNTER ERRORS : IF YOU DO PLEASE OPEN UP A RUN AS ADMINISTRATORS PROMPT." -ForegroundColor Red

}
else {
    Write-Host "YOU ARE RUNNING AS ADMINISTRATOR" -ForegroundColor Green
}

. $PSScriptRoot\..\..\main.ps1

<#
Type               Name                             Physical Path
----               ----                             -------------
application        LoanMonitoring\V1\REST           Q:\LoanMonitoringAPI\Source\WebAPI
virtualDirectory   LoanMonitoring\V1                Q:\LoanMonitoringAPI\Source\WebAPI
application        LoanMonitoring\admin\V1\REST     Q:\LoanMonitoringAPI\Admin.WebAPI
virtualDirectory   LoanMonitoring\admin\V1          Q:\LoanMonitoringAPI\Admin.WebAPI
application        LoanMonitoring\Web               Q:\LoanMonitoringWeb\WebUI

#>


$ServiceAccountName = "fcsadmz\LoanMon_msa_O"
$ServiceAccountName = "fcsamerica\LoanMon_msa_O"
$ServiceAccountName = "LoanMon_msa_O"
if ((Test-ADServiceAccount $ServiceAccountName) -ne $null) {
    Write-Host "Service account '$ServiceAccountName' exists."
}
else {
    # Must always be run first. without it the app pool will fail to create.
    Install-FCSAServiceAccount -UserName $ServiceAccountName
    Write-Host "Service account '$ServiceAccountName' does not exist."
}

$IISAppPoolName = "LoanMonitoring.WebAPI.V1"
$IISApplicationName = "LoanMonitoring/V1/REST"; #Not Site Name : This should be a formatted path to the application as a virtual directory. 
$IISStoragePhysicalPath = "Q:\LoanMonitoringAPI\Source\WebAPI\"
$IISApplicationVirtualPaths = @("/LoanMonitoring/V1/REST")
$IISVirtualDirectoryPaths = @("/LoanMonitoring/V1")

New-FCSAIISAppPool -UserName $ServiceAccountName -IISAppPoolRootLocation $IISAppPoolName -IISApplication $IISApplicationName

$IISAppPoolName = "LoanMonitoring.WebAPI.V1"
$IISApplicationName = "LoanMonitoring/Admin/V1/REST"; #Not Site Name : This should be a formatted path to the application as a virtual directory. 
$IISStoragePhysicalPath = "Q:\LoanMonitoringAPI\Admin.WebAPI\"
$IISApplicationVirtualPaths = @("/LoanMonitoring/Admin/V1/REST")
$IISVirtualDirectoryPaths = @("/LoanMonitoring/admin/V1")


New-FCSAIISAppPool -UserName $ServiceAccountName -IISAppPoolRootLocation $IISAppPoolName -IISApplication $IISApplicationName

. "K:\kernm.devcontainer.envsetup\profile-extras\IIS Management\IISManagement\Cleanup-ResetToDefaults.ps1"