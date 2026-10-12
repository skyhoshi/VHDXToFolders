. "C:\Users\kernm\OneDrive - Farm Credit Services of America\Documents\PowerShell\Scripts\listmethodsinps1file.ps1"

Write-Host "Loading Setup IIS App Pool Functions"
$versionMinimum = [Version]'5.1.0.0'
$versionMaximum = [Version]'5.1.99999.999'
Write-WARNING "THIS SCRIPT MUST BE RUN IN Powershell 5.1 or LESS (NOT COMPATABILE WITH Powersehll 6 or 7 due to the module not working/being compatable)"
if ($versionMinimum -gt $PSVersionTable.PSVersion -AND $versionMaximum -lt $PSVersionTable.PSVersion) { 
    throw "This script requires PowerShell >= $versionMinimum and < $versionMaximum : this is due to WebAdministration not being fully available in other versions."
}
function New-FCSAIISAppPool {
    [CmdletBinding()]
    param (
        [Parameter()][string]$UserName,
        [Parameter()][string]$IISAppPoolRootLocation
    )
    
    begin {
        
    }
    
    process {
        
        $appPoolName = $UserName
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
        $siteApplication = "IIS:\Sites\Default Web Site\$($IISAppPoolRootLocation)"
        if ((Test-Path $siteApplication )) {
            #get-webapplication -Name $user[2];
            Set-ItemProperty $siteApplication applicationPool $appPoolName
        }

        Write-Host "===================================================="
        Write-host "Setting $AppPoolName User Context."
        Write-Host "===================================================="

        Set-ItemProperty IIS:\AppPools\$appPoolName -name processModel -value @{userName = "FCSAMerica\$($UserName.ToString())" + "$".ToString(); identitytype = 3 }
        Set-ItemProperty IIS:\AppPools\$appPoolName -name managedRuntimeVersion -Value ""

        Get-ItemProperty IIS:\AppPools\$appPoolName -name processModel
        #Get-ItemPropertyValue IIS:\AppPools\$appPoolName -name processModel
        Get-ItemProperty IIS:\AppPools\$appPoolName -Name workerProcesses
    }
    
    end {
    
    }
}

function Clear-PatronageIISSites {
    [CmdletBinding()]
    param (
        [Parameter()][string]$IISAppPoolName,
        [Parameter()][string]$IISAppPoolRootLocation,
        [Parameter()][string]$IISVirtualDirectory = $null
    )

    if (Test-Path "IIS:\Site\Default Web Site\$($IISAppPoolRootLocation)") {
        Remove-WebApplication -Site "Default Web Site" -Name $IISAppPoolRootLocation
        if ($null -eq $IISVirtualDirectory) {
            Remove-WebVirtualDirectory -Site "Default Web Site" -Name $IISVirtualDirectory -Application .
        }
    }
    if (Test-Path "IIS:\AppPools\$($IISAppPoolName)") {
        Remove-WebAppPool -Name $IISAppPoolName
    }
}

if ($DebugMode) {
    Clear-PatronageIISSites -IISAppPoolName "p-elaapi" -IISAppPoolRootLocation "patronage/elastic/v1" -IISVirtualDirectory "patronage/elastic"
    #This should return 0 if you want to start completely over.
    Get-ChildItem -Path "IIS:\Sites\Default Web Site\" | Where { $_.NodeType -eq "application" -or $_.NodeType -eq "virtualDirectory" }
}