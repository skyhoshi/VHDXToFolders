$moduleLocation = "Scripts\Powershell\Modules\VHDXToFolders";

#. "C:\Users\marcus\OneDrive\Scripts\Powershell\Modules\VHDXToFolders\src\VHD Management Scripts\Mount-PersonalVHDXDrive.ps1"
. "$env:POWERSHELLSCRIPTSTORE\$moduleLocation\src\MasterScript.ps1"

<#
d825ac9f-78af-433f-9e40-3f0eb5e47960
0dfc760a-4444-43fe-bf6b-6c00a267c9dc
16840241-51dc-4e45-984c-910f4ebfdd52
be0d9ae3-b8e6-478c-aea7-a54b0deecea2
1731db29-8924-4758-ba5b-556923d86d8f
73d9a6c1-c4bf-407d-b699-18be999d6c52
657ffec5-8167-47ef-9c0b-000b9098338a
8d2fbba7-8fc1-4e3c-a56f-1acbf8494746
c746baf4-540a-4fe4-881d-599d87f08910
3175e3f1-9449-496d-923d-fadb50b499bc
6e03791f-b2be-44e1-a602-19e943a13971
4b9ab45e-504b-4fc3-884e-13ffdde13698
959e474f-cc6d-430b-a3f4-4bc0261a6d5b
#>
function Load-VhdStorageDrives {
    [CmdletBinding()]
    param (
        [Parameter()]
        [Array]
        $Drives
    )

    $OrderedDrives = $Drives | Sort-Object -Property LoadOrder;
    foreach ($DriveItem in $OrderedDrives) {
        #[string] $mountMessage = "$DriveItem"
        #Write-Host $mountMessage
        if ([System.IO.File]::Exists($DriveItem.DriveFullLocation)) {
            # Write-Host $DriveItem.DriveFullLocation " ---------> " $DriveItem.MountPath;
            if ((([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator))) {
                Mount-PersonalVHDXDrive $DriveItem.DriveFullLocation;    
            }
        }
    }
}

<#
get-disk -Number 7 | Get-Partition -Number 2  | Get-Volume | format-table -AutoSize
#>

#$WorkDrive1 = "D:\VHDX Storage\WorkRelated\Stine\DeesignFiles.vhdx"
#Mount-PersonalVHDXDrive $WorkDrive1;
#if (Test-Path -Path $WorkDrive1){
#    Mount-VHD -Path $WorkDrive1;
#}

<#
$SharedVhdxFileNames = New-Object -TypeName System.Collections.ArrayList;
$SharedVhdxFileNames += "ProgramFilesCakewalkSharedDXi.Test";

$SharedVhdxFileNames += "ProgramFilesCakewalkSharedDXi";
$SharedVhdxFileNames += "ProgramFilesCakewalkSharedMIDIPlugins";
$SharedVhdxFileNames += "ProgramFilesCakewalkSharedPlugins";
$SharedVhdxFileNames += "ProgramFilesCakewalkSharedSurfaces";
$SharedVhdxFileNames += "ProgramFilesCakewalkSharedUtilities";
$SharedVhdxFileNames += "ProgramFilesCakewalkSONARPlatinum";
$SharedVhdxFileNames += "ProgramFilesCakewalkStudioInstruments";
$SharedVhdxFileNames += "ProgramFilesCakewalkz3ta+";

foreach ($filename in $SharedVhdxFileNames) {
    $FullVhdxPath = "$CompoundVHDXStorage\Cakewalk\CakewalkCompoundDriveMountPoint\Program Files\$filename.vhdx"
    if (!(Test-Path -Path $FullVhdxPath) {
        $VHDX = New-VHD -Path ($FullVhdxPath) -SizeBytes 2TB -Dynamic
    }
    else {
        $VHDX = Get-VHD -Path $FullVhdxPath
    }
    #Mount-VHD -Path $VHDX
    $VHDX | Format-List;
    #    Write-Host $FullVhdxPath;
}

$Shared = New-Object -TypeName System.Collections.ArrayList;
#> 

<# 
# retrieved Using:  Get-Partition | Get-Volume | Where {$_.DriveLetter -eq $null} | Select-Object -Property AccessPaths -Unique |  Format-list
Get-Disk | Where-Object {$_.BusType -eq "File Backed Virtual"}
Get-Disk | Where-Object {$_.BusType -eq "File Backed Virtual"} | Get-Partition | Where-Object {$_.AccessPaths -ne $null} | Format-List
#>
