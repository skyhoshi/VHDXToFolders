if (!(Test-Path -Path Variable:\MountTypeIsLoaded)){
    
}
$moduleLocation = "Scripts\Powershell\Modules";
$moduleName = "VHDXToFolders";
$srcParent = "$env:OneDriveConsumer\$moduleLocation\$moduleName";
Write-Host "Loading Master Script: $moduleName from $srcParent" -ForegroundColor Yellow;
# . "$srcParent\src\VHD Management Scripts\Mount-PersonalVHDXDrive.ps1"
Write-Host "Class Section" -ForegroundColor Blue;
. "$srcParent\src\Types\MountType.ps1";
. "$srcParent\src\Types\MountCategory.ps1";
. "$srcParent\src\Classes\VirtualDriveToLoad.ps1";
Write-Host "Scripts Section" -ForegroundColor Blue;
. "$srcParent\src\Device Check Scripts\Test-IsDriveMounted.ps1";
. "$srcParent\src\VHD Management Scripts\Get-CliDriveFileFromWeb.ps1";
. "$srcParent\src\VHD Management Scripts\Mount-PersonalVHDXDrive.ps1";

