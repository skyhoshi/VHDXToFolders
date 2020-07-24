function Mount-PersonalVHDXDrive {
    [CmdletBinding()]
    param (
        [string] $Drive
    )
    
    begin {
        if (!(Test-Path -Path  $Drive -ErrorAction SilentlyContinue )){
            Write-Host "File does not exist please check and try again. $Drive"
            break;
        }
    }
    
    process {
        Write-Host "Processing"
        Mount-VHD -Path $Drive -ErrorAction SilentlyContinue;
    }
    
    end {
        
    }
}
$WindowsAppsStoreStorage = "O:\VHDX Storage\SKY-M3-WindowsAppStoreStorage.vhdx"
Mount-PersonalVHDXDrive $WindowsAppsStoreStorage;
$AutoDeskFusion = "D:\VHDX Storage\AppData-Drives\AutoDesk.vhdx"
Mount-PersonalVHDXDrive $AutoDeskFusion;

<#
get-disk -Number 7 | Get-Partition -Number 2  | Get-Volume | format-table -AutoSize
#>

#$WorkDrive1 = "D:\VHDX Storage\WorkRelated\Stine\DeesignFiles.vhdx"
#Mount-PersonalVHDXDrive $WorkDrive1;
#if (Test-Path -Path $WorkDrive1){
#    Mount-VHD -Path $WorkDrive1;
#}