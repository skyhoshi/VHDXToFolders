#required WebAdministration
$versionMinimum = [Version]'5.1.0.0'
$versionMaximum = [Version]'5.1.99999.999'
. "C:\Users\kernm\OneDrive - Farm Credit Services of America\Documents\PowerShell\Scripts\listmethodsinps1file.ps1"

Write-WARNING "THIS SCRIPT MUST BE RUN IN Powershell 5.1 or LESS (NOT COMPATABILE WITH Powersehll 6 or 7 due to the module not working/being compatable)"
if ($versionMinimum -gt $PSVersionTable.PSVersion -AND $versionMaximum -lt $PSVersionTable.PSVersion) { 
    throw "This script requires PowerShell >= $versionMinimum and < $versionMaximum : this is due to WebAdministration not being fully available in other versions."
}

$users = @( 
    #[0]=Service Account Name,[1] IIS App Pool Name, IIS Application Name (NOT SITE NAME)
    @("PT_ElaApi_msa_o", "p-elaapi", "patronage/elastic/v1"),
    @("PT_engapi_msa_o", "p-engapi", "patronage/engine/v1"),
    @("PT_WebAPI_msa_o", "p-webapi", "patronage/v1"),
    @("PT_WebUI_msa_o", "p-webui", "patronage/web")
    @("PT_ElaApi_o", "p-elaapi", "patronage/elastic/v1"),
    @("PT_engapi_o", "p-engapi", "patronage/engine/v1"),
    @("PT_WebAPI_o", "p-webapi", "patronage/v1"),
    @("PT_WebUI_o", "p-webui", "patronage/web")

)
$previousLocaiton = Get-Location
Import-Module WebAdministration
#https://learn.microsoft.com/en-us/iis/configuration/system.applicationHost/applicationPools/add/processModel#attributes

foreach ($user in $users) {

    #Install the Acitve Directory Service Account: 
    Write-Host "===================================================="
    Write-host "Installing $($user[0]) Service Account on $(hostname)."
    Write-Host "===================================================="
    Install-adserviceaccount $user[0]
    $appPoolName = $user[1]
    #https://stackoverflow.com/questions/21415291/how-to-specify-application-pool-identity-user-and-password-from-powershell
    #Create a new IIS App Pool with the service account as a identityType of 3 (Specified Account) and is a service account so no password is needed.
    #Set-Location IIS:\\AppPools 

    if (!(test-path -path IIS:\\AppPools\$appPoolName)) {
        Write-Host "===================================================="
        Write-host "Creating $AppPoolName App Pool."
        Write-Host "===================================================="
        New-WebAppPool -Name $appPoolName
    }
    Write-Host "===================================================="
    Write-host "Creating $AppPoolName App Pool."
    Write-Host "===================================================="
    $siteApplication = "IIS:\Sites\Default Web Site\$($user[2])"
    if ((Test-Path $siteApplication )) {
        #get-webapplication -Name $user[2];
        Set-ItemProperty $siteApplication applicationPool $appPoolName
    }

    Write-Host "===================================================="
    Write-host "Setting $AppPoolName User Context."
    Write-Host "===================================================="

    Set-ItemProperty IIS:\AppPools\$appPoolName -name processModel -value @{userName = "FCSAMerica\$($user[0].ToString())" + "$".ToString(); identitytype = 3 }
    Set-ItemProperty IIS:\AppPools\$appPoolName -name managedRuntimeVersion -Value ""

    Get-ItemProperty IIS:\AppPools\$appPoolName -name processModel
    #Get-ItemPropertyValue IIS:\AppPools\$appPoolName -name processModel
    Get-ItemProperty IIS:\AppPools\$appPoolName -Name workerProcesses

}
Set-Location $previousLocaiton
function Clear-PatronageIISSites {
    $Apps = @( 
        #[0]=Service Account Name,[1] IIS App Pool Name, IIS Application Name (NOT SITE NAME)
        @("PT_ElaApi_msa_o", "p-elaapi", "patronage/elastic/v1"),
        @("PT_engapi_msa_o", "p-engapi", "patronage/engine/v1"),
        @("PT_WebAPI_msa_o", "p-webapi", "patronage/v1"),
        @("PT_WebUI_msa_o", "p-webui", "patronage/web")
    )
    foreach ($App in $Apps) {
        # if (Test-Path "IIS:\Site\Default Web Site\$($App[2])") {
        #     remove-webapplication -Site "Default Web Site" -Name $App[2]
        # }
        # remove-webAppPool -Name $app[1]
        #if (Test-Path "IIS:\Site\Default Web Site\$($App[2])") 
        #{
            #Remove-WebVirtualDirectory -Site "Default Web Site" -Name "McGruff\V2" 
            Remove-WebVirtualDirectory -Site "Default Web Site" -Application .  -Name "$($App[2])"
            # Remove-WebApplication -Site "Default Web Site" -Name $App[2]
        #}
        if (Test-Path "IIS:\AppPools\$($app[1])") {
            Remove-WebAppPool -Name $app[1]
        }

        #Virtual Directory Cleanup
    }
}