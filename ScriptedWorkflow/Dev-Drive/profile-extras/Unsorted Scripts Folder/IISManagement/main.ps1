#Requires -Modules WebAdministration  -RunAsAdministrator 
. "C:\Users\kernm\OneDrive - Farm Credit Services of America\Documents\PowerShell\Scripts\listmethodsinps1file.ps1"

Write-Host "Loading IIS Management Scripts"
Write-Host "Current State of Debug Mode: $DebugMode"
# # Requires -Modules WebAdministration  -RunAsAdministrator 
<#
@{ ModuleName="WebAdministration"; ModuleVersion="1.0" }
#>


$versionMinimum = [Version]'5.1.0.0'
$versionMaximum = [Version]'5.1.99999.999'
Write-WARNING "THIS SCRIPT MUST BE RUN IN Powershell 5.1 or LESS (NOT COMPATABILE WITH Powersehll 6 or 7 due to the module not working/being compatable)"
if ($versionMinimum -gt $PSVersionTable.PSVersion -AND $versionMaximum -lt $PSVersionTable.PSVersion) { 
    throw "This script requires PowerShell >= $versionMinimum and < $versionMaximum : this is due to WebAdministration not being fully available in other versions."
}
. "$($PSScriptRoot)\SetupAppPoolWithGMSAAccount\AddGSMA.ps1"
. "$($PSScriptRoot)\IISManagement\Setup-IISAppPoolWithServiceAccount.ps1"
. "$($PSScriptRoot)\IISManagement\Stop-AllWebAppPools.ps1"