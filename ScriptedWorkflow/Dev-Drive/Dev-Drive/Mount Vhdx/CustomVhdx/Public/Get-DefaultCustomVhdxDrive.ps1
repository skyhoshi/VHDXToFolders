function Get-DefaultCustomVhdxDrive {
    [CmdletBinding()]
    param()

    Get-ChildItem -Path 'E:\Shared Virtual Hard Drive Storage' -Recurse -Filter '*.vhdx' -ErrorAction SilentlyContinue | ForEach-Object {
        [pscustomobject]@{ Path = $_.FullName; IsEnabled = $false }
    }
   <# Additional default VHDX drives 
    @(
        'E:\Shared Virtual Hard Drive Storage\Profile\OneDrive\Sky-M4-OneDrive.vhdx'
        'E:\Shared Virtual Hard Drive Storage\Application Drives\Scoop\Sky-M4-Scoop.vhdx'
        'E:\Shared Virtual Hard Drive Storage\Application Drives\Unity\Unity Edtior Storage.vhdx'
        'E:\Shared Virtual Hard Drive Storage\Development Drives\Personal Source Code.vhdx'
        'E:\Shared Virtual Hard Drive Storage\Application Drives\JetBrains\Jetbrains-Application-StorageDrive.vhdx'
        'E:\Shared Virtual Hard Drive Storage\Creator Storage Drives\VST-Plugins-32-64.vhdx'
        'E:\Shared Virtual Hard Drive Storage\Application Drives\Winamp\Winamp.vhdx'
    ) | ForEach-Object {
        [pscustomobject]@{ Path = $_; IsEnabled = $true }
    }#> 
}
