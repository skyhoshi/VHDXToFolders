Write-Host  "Executing: $PSScriptRoot\Import-MountCustomVhdx.ps1"

if (!(Test-Path Function:\\Mount-CustomVHDX)){
    #. "O:\Marcus\OneDrive - Sora Family Directory\Scripts\Drive and File Data Scripts\MoundVHD\LoadScript.ps1"
    $SharedVirtualDriveStorageLocation = "E:\Shared Virtual Hard Drive Storage\";
function Set-LocationToSharedStorage{
    Set-Location $SharedVirtualDriveStorageLocation;
}

function Mount-CustomVHDX{
    
    $MountVHDXScriptLocation = "E:\Shared Virtual Hard Drive Storage\Mount-CommonVHDx.ps1";

    if(Test-Path -Path $SharedVirtualDriveStorageLocation){
        if (Test-Path -Path $MountVHDXScriptLocation){
            . $MountVHDXScriptLocation
        }
        else{
            Write-Error "Common VHDX Mount Script is missing from E:\Shared Virtual Hard Drive Storage\Mount-CommonVHDx.ps1"
        }
    }    
}
}

Mount-CustomVHDX