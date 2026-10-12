# # Requires -Modules WebAdministration,IISAdministration  -RunAsAdministrator 
<#
@{ ModuleName="WebAdministration"; ModuleVersion="1.0" }
@{ ModuleName="IISAdministration"; ModuleVersion="1.1.0.0" }
#>

#Requires -Modules WebAdministration,IISAdministration  -RunAsAdministrator 
. "C:\Users\kernm\OneDrive - Farm Credit Services of America\Documents\PowerShell\Scripts\listmethodsinps1file.ps1"

Write-Host "Loading Custom IIS Administation Methods... " 
#$DebugMode = $true;
function Stop-AllWebAppPools {
    param ()
    $appPools = Get-IISAppPool 
    $appPoolsByName = $appPools | Select name
    foreach ($appPool in $appPoolsByName) {
      #Stop-WebAppPool  $appPool.name
      $applicationPoolName = $appPool.name
      if((Get-WebAppPoolState -Name $applicationPoolName).Value -ne 'Stopped'){
        Write-Output ('Stopping Application Pool: {0}' -f $applicationPoolName)
        Stop-WebAppPool -Name $applicationPoolName
        }
    }
}

if ($DebugMode){
    Stop-AllWebAppPools
}
