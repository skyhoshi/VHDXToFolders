if (!(Test-Path -Path Variable:\MountTypeIsLoaded)){
    
}
$moduleLocation = "Scripts\Powershell\Modules";
$moduleName = "VHDXToFolders";
$srcParent = "$env:OneDriveConsumer\$moduleLocation\$moduleName";
Write-Host "Loading Master Script: $moduleName from $srcParent";
# . "$srcParent\src\VHD Management Scripts\Mount-PersonalVHDXDrive.ps1"
. "$srcParent\src\Classes\MountType.ps1";
. "$srcParent\src\Classes\MountCategory.ps1";
. "$srcParent\src\Classes\VirtualDriveToLoad.ps1";
. "$srcParent\src\Device Check Scripts\Test-IsDriveMounted.ps1";
. "$srcParent\src\VHD Management Scripts\LoadDrivesFromConfig.ps1";
. "$srcParent\src\VHD Management Scripts\Mount-PersonalVHDXDrive.ps1";

