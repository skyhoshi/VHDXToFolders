Write-Host "Running Mount Common VHDX Drives" -ForegroundColor DarkYellow;
$RunMounting = $true;
$Drives = [System.Collections.ArrayList]::new()
<#
E:\Shared Virtual Hard Drive Storage\Application Drives\JetBrains\Jetbrains-Application-StorageDrive.vhdx
E:\Shared Virtual Hard Drive Storage\Application Drives\RubyDevKit\Ruby Including DevKit.vhdx
E:\Shared Virtual Hard Drive Storage\Application Drives\Scoop\Sky-M4-Scoop.vhdx
E:\Shared Virtual Hard Drive Storage\Application Drives\Unity\Unity Edtior Storage.vhdx
E:\Shared Virtual Hard Drive Storage\Creator Storage Drives\VST-Plugins-32-64.vhdx
E:\Shared Virtual Hard Drive Storage\Development Drives\dev.azure.com-skyhoshi.vhdx
E:\Shared Virtual Hard Drive Storage\Development Drives\General Drawings and Shared Parts.vhdx
E:\Shared Virtual Hard Drive Storage\Development Drives\Home Management Resources.vhdx
E:\Shared Virtual Hard Drive Storage\Development Drives\Mister FPGA.vhdx
E:\Shared Virtual Hard Drive Storage\Development Drives\Personal Source Code.vhdx
E:\Shared Virtual Hard Drive Storage\Development Drives\Qt Development SDK.vhdx
E:\Shared Virtual Hard Drive Storage\Game Development\LilysGameProjects.vhdx
E:\Shared Virtual Hard Drive Storage\Profile\OneDrive\Sky-M4-OneDrive.vhdx
E:\Shared Virtual Hard Drive Storage\Profile\Rose\Roses StudyDeck Insurance License.vhdx
E:\Shared Virtual Hard Drive Storage\Robot Part Software and OSs.vhdx
#>
if ($RunMounting){

$Drives.Add("E:\Shared Virtual Hard Drive Storage\Profile\OneDrive\Sky-M4-OneDrive.vhdx")| Out-Null
$Drives.Add("E:\Shared Virtual Hard Drive Storage\Application Drives\Scoop\Sky-M4-Scoop.vhdx") | Out-Null
$Drives.Add("E:\Shared Virtual Hard Drive Storage\Application Drives\Unity\Unity Edtior Storage.vhdx")| Out-Null
$Drives.Add("E:\Shared Virtual Hard Drive Storage\Development Drives\Personal Source Code.vhdx") | Out-Null
$Drives.Add("E:\Shared Virtual Hard Drive Storage\Application Drives\JetBrains\Jetbrains-Application-StorageDrive.vhdx")| Out-Null
$Drives.Add("E:\Shared Virtual Hard Drive Storage\Application Drives\ProgramFile-Drives\ProgramFiles-Adobe-CreativeCloud.vhdx") | Out-Null
$Drives.Add("E:\Shared Virtual Hard Drive Storage\Application Drives\VSCode\Sky-M4-AppData-Roaming-VsCode.vhdx") | Out-Null
$Drives.Add("E:\Shared Virtual Hard Drive Storage\Creator Storage Drives\VST-Plugins-32-64.vhdx") | Out-Null
$Drives.Add("E:\Shared Virtual Hard Drive Storage\Application Drives\Winamp\Winamp.vhdx") | Out-Null
#$Drives.Add("E:\Shared Virtual Hard Drive Storage\Application Drives\Winamp\Winamp.vhdx") | Out-Null
#$Drives.Add("E:\Shared Virtual Hard Drive Storage\Application Drives\Steam\Final Fantasy 15.vhdx") | Out-Null
}
# $Drives.Add("") | Out-Null
# $Drives.Add("") | Out-Null
# $Drives.Add("") | Out-Null
# $Drives.Add("") | Out-Null
# $Drives.Add("") | Out-Null
# $Drives.Add("") | Out-Null

if ($RunMounting){
foreach ($drive in $Drives){
    Mount-VHD -Path $drive -ErrorAction SilentlyContinue;
}
$Error;
}
else{
    Write-Host "Dry Run of Mounting complete";
}