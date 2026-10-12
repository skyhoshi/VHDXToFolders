# # # Requires -Modules WebAdministration  -RunAsAdministrator 
# <#
# @{ ModuleName="WebAdministration"; ModuleVersion="1.0" }
# #>

# #Requires -Modules WebAdministration  -RunAsAdministrator 
# $versionMinimum = [Version]'5.1.0.0'
# $versionMaximum = [Version]'5.1.99999.999'
# Write-WARNING "THIS SCRIPT MUST BE RUN IN Powershell 5.1 or LESS (NOT COMPATABILE WITH Powersehll 6 or 7 due to the module not working/being compatable)"
# if ($versionMinimum -gt $PSVersionTable.PSVersion -AND $versionMaximum -lt $PSVersionTable.PSVersion) { 
#     throw "This script requires PowerShell >= $versionMinimum and < $versionMaximum : this is due to WebAdministration not being fully available in other versions."
# }
. "C:\Users\kernm\OneDrive - Farm Credit Services of America\Documents\PowerShell\Scripts\listmethodsinps1file.ps1"

Write-Host "Loading Custom IIS Administation Methods... " 
$DebugMode = $true
New-Alias -Name AppCmd -Value "$env:SystemRoot\System32\inetsrv\appcmd.exe" -Force
function Stop-AllWebAppPools {
    param ()
   
    Write-Host "Attempting to stop all Web App Pools"
    # $appPools = Get-ChildItem -Path "IIS:\AppPools" 
    # $appPoolsByName = $appPools | Select name
    # foreach ($appPool in $appPoolsByName) {
    #     #Stop-WebAppPool  $appPool.name
    #     $applicationPoolName = $appPool.name
    #     if (Test-Path "IIS:\AppPools\$($applicationPoolName)") {
    #         if ((Get-WebAppPoolState -Name $applicationPoolName).Value -ne 'Stopped') {
    #             Write-Host ('Stopping Application Pool: {0}' -f $applicationPoolName)
    #             Stop-WebAppPool -Name $applicationPoolName
    #         }
    #     }
    # }

    # Get the list of all application pools with their states
    AppCmd list apppools | ForEach-Object {
        # Ensure the output is split correctly
        $appPoolNameState = $_ -split '"'
        $appPoolName = $appPoolNameState[1].Trim()
        $appPoolAttributeInfo = $appPoolNameState[2].Replace("(", "").Replace(")", "") -split ','
        $appPoolState = ($appPoolAttributeInfo[2].Trim() -split ':')[1].Trim()
        Write-Host "App Pool: $appPoolName, State: $appPoolState"

        # Stop the app pool only if it is not already stopped
        if ($appPoolState -ne 'Stopped') {
            AppCmd stop apppool /apppool.name:"$appPoolName"
            Write-Host "Stopped App Pool: $appPoolName"
        }
        else {
            Write-Warning "Unexpected output format: $_"
        }
    }
}

if ($DebugMode) {
    Stop-AllWebAppPools
}