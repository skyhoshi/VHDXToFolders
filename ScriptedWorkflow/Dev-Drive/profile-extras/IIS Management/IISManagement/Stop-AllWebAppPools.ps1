#Requires -Modules WebAdministration  -RunAsAdministrator 

# $versionMinimum = [Version]'5.1.0.0'
# $versionMaximum = [Version]'5.1.99999.999'
# Write-WARNING "THIS SCRIPT MUST BE RUN IN Powershell 5.1 or LESS (NOT COMPATABILE WITH Powersehll 6 or 7 due to the module not working/being compatable)"
# if ($versionMinimum -gt $PSVersionTable.PSVersion -AND $versionMaximum -lt $PSVersionTable.PSVersion) { 
#     throw "This script requires PowerShell >= $versionMinimum and < $versionMaximum : this is due to WebAdministration not being fully available in other versions."
# }
Write-Host "Loading Custom IIS Administation Methods... " 
#$DebugMode = $true;
function Stop-AllWebAppPools {
    param ()
    Write-Host "Attempting to stop all Web App Pools"
    $appPools = Get-ChildItem -Path "IIS:\AppPools" 
    $appPoolsByName = $appPools | Select-Object name
    foreach ($appPool in $appPoolsByName) {
        #Stop-WebAppPool  $appPool.name
        $applicationPoolName = $appPool.name
        if (Test-Path "IIS:\AppPools\$($applicationPoolName)") {
            if ((Get-WebAppPoolState -Name $applicationPoolName).Value -ne 'Stopped') {
                Write-Host ('Stopping Application Pool: {0}' -f $applicationPoolName)
                Stop-WebAppPool -Name $applicationPoolName
            }
        }
    }
}

if ($DebugMode) {
    Stop-AllWebAppPools
}