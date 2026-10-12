#Requires -Modules WebAdministration  -RunAsAdministrator 
Write-Host "Loading Setup IIS App Pool Functions"

function New-FCSAIISAppPool {
    [CmdletBinding()]
    param (
        [Parameter()][string]$UserName,
        [Parameter()][string]$IISAppPoolRootLocation,
        [Parameter()][string]$IISApplication
    )
    
    begin {
        
    }
    
    process {
        # $previousLocation = $PWD
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
        #Set-Location "IIS:\Sites\Default Web Site\"
        Write-Host "===================================================="
        Write-host "Setting $AppPoolName Application Pool."
        Write-Host "===================================================="
        #Set-Location "IIS:\Sites\Default Web Site\$($IISApplication)"
        Set-ItemProperty "IIS:\Sites\Default Web Site\$($IISApplication)" applicationPool $UserName.ToString();
        #This setting removes the Net CLR runtime from the apppool disabling dotnet. this is usful in some situations. 
        #Set-ItemProperty IIS:\AppPools\$appPoolName -name managedRuntimeVersion -Value ""
        Write-Host "===================================================="
        Write-host "Getting AppPool Process model Settings"
        Write-Host "===================================================="
        Get-ItemProperty IIS:\AppPools\$appPoolName -name processModel
        # Write-Host "===================================================="
        # Write-host "Getting AppPool workerProcesses Settings"
        # Write-Host "===================================================="
        # #Get-ItemPropertyValue IIS:\AppPools\$appPoolName -name processModel
        # Get-ItemProperty IIS:\AppPools\$appPoolName -Name workerProcesses

        Write-Host "===================================================="
        Write-host "Getting $($IISApplication) Settings"
        Write-Host "===================================================="
        Get-ItemProperty "IIS:\Sites\Default Web Site\$($IISApplication)" | Select-Object *
        #Set-Location $previousLocation;

        # Write-Host "===================================================="
        # Write-host "Setting $($IISApplication) ACL for App Pool on Physical Path"
        # Write-Host "===================================================="
        # #$aclUserName = "FCSAMerica\$($UserName.ToString())";
        # $node = Get-ItemProperty "IIS:\Sites\Default Web Site\$($IISApplication)" | Select-Object *;
        # #$nodes | Where {$_.NodeType -eq "application" -and $_.Name -eq "$($IISApplication)"} | ForEach {   }
        # Write-Host "Attempting to add $("iis apppool\$appPoolName") to $($node.PhysicalPath)";
        # $acl = Get-Acl $node.PhysicalPath
        # $FileSystemAccessRule = (New-Object System.Security.AccessControl.FileSystemAccessRule(("iis apppool\$appPoolName"),"Modify","Allow"))
        # Write-Host $FileSystemAccessRule;
        # $acl.AddAccessRule($FileSystemAccessRule)
        # $acl | Set-Acl $node.PhysicalPath
    }
    
    end {
    
    }
}

function CreateVirtualDirectoryInSite {
    [CmdletBinding()]
    param (
        [Parameter()][string]$IISSite = "Default Web Site",
        [Parameter()][string]$IISPhysicalDirectory,
        [Parameter()][string]$IISVirtualDirectory
    )
    New-WebVirtualDirectory -Site $IISSite -Name $IISVirtualDirectory -PhysicalPath $IISPhysicalDirectory #-Name $virtualDirectoryName -Application

}
function CreateSiteByName{
    [CmdletBinding()]
    param (
        [Parameter()][string]$IISSite = "Default Web Site",
        [Parameter()][string]$IISPhysicalDirectory,
        [Parameter()][string]$IISVirtualDirectory
    )
    new-website -Name $name -ApplicationPool $ApplicationPool - 
}

function Clear-PatronageIISSites {
    [CmdletBinding()]
    param (
        [Parameter()][string]$IISAppPoolName,
        [Parameter()][string]$IISAppPoolRootLocation,
        [Parameter()][string]$IISVirtualDirectory = $null
    )

    # if (Test-Path "IIS:\Site\Default Web Site\$($IISAppPoolRootLocation)") {
    #     Remove-WebApplication -Site "Default Web Site" -Name $IISAppPoolRootLocation
    #     if ($null -eq $IISVirtualDirectory) {
    #         Remove-WebVirtualDirectory -Site "Default Web Site" -Name $IISVirtualDirectory -Application .
    #     }
    # }
    # if (Test-Path "IIS:\AppPools\$($IISAppPoolName)") {
    #     Remove-WebAppPool -Name $IISAppPoolName
    # }
}

# if ($DebugMode) {
#     Clear-PatronageIISSites -IISAppPoolName "p-elaapi" -IISAppPoolRootLocation "patronage/elastic/v1" -IISVirtualDirectory "patronage/elastic"
#     #This should return 0 if you want to start completely over.
#     Get-ChildItem -Path "IIS:\Sites\Default Web Site\" | Where-Object { $_.NodeType -eq "application" -or $_.NodeType -eq "virtualDirectory" }
# }
