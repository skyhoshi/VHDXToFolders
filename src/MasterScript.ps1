if (!(Test-Path -Path Variable:\MountTypeIsLoaded)) {
    $RunAsValue = ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator);
    if ($RunAsValue) {
        $moduleLocation = "Scripts\Powershell\Modules";
        $moduleName = "VHDXToFolders";
        $srcParent = "$env:OneDriveConsumer\$moduleLocation\$moduleName";
        Write-Host "Loading Master Script: $moduleName from $srcParent" -ForegroundColor DarkMagenta;
        # . "$srcParent\src\VHD Management Scripts\Mount-PersonalVHDXDrive.ps1"
        Write-Host "Class Section" -ForegroundColor Blue;
        . "$srcParent\src\Types\MountType.ps1";
        . "$srcParent\src\Types\MountCategory.ps1";
        . "$srcParent\src\Classes\VirtualDriveToLoad.ps1";
        Write-Host "Scripts Section" -ForegroundColor Blue;
        . "$srcParent\src\Methods\Get\Get-CliDriveFileFromWeb.ps1";
        . "$srcParent\src\Methods\Mount\Mount-PersonalVHDXDrive.ps1";
        . "$srcParent\src\Methods\Test\Test-IsDriveMounted.ps1";
    }    
}
