$moduleLocation = "Scripts\Powershell\Modules\VHDXToFolders";
#. "C:\Users\marcus\OneDrive\Scripts\Powershell\Modules\VHDXToFolders\src\VHD Management Scripts\Mount-PersonalVHDXDrive.ps1"
. "$env:OneDriveConsumer\$moduleLocation\src\MasterScript.ps1"
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
    
    $WindowsAppStorage = "O:\VHDX Storage";
    $BaseVHDXStorage = "D:\VHDX Storage";
    $CompoundVHDXStorage = "D:\VHDX Storage\Compound Drives";
    $ProgramFilesX64 = "D:\VHDX Storage\ProgramFile-Drives";
    $ProgramFilesX86 = "D:\VHDX Storage\ProgramFileX86-Drives";
    $WorkRelated = "D:\VHDX Storage\WorkRelated";
    $SystemUserProfiles = "D:\VHDX Storage\$Env:COMPUTERNAME-Profiles";

    # $StorgaeFolders

    [array]$Drives = $();

    $VirtualDriveToLoad00 = [VirtualDriveToLoad]::new( "fdb24800-2189-4947-b14d-a668ce56cc3f", "-2147483645", [MountCategory]::Manditory, "$WorkRelated\Caseys General Store\Caseys General Store - Work.vhdx", "Q", [MountType]::DriveLetter);
    $Drives += $VirtualDriveToLoad00;
    $VirtualDriveToLoad0 = [VirtualDriveToLoad]::new( "00000000-1111-0000-0000-111111111111", "-2147483647", [MountCategory]::Manditory, "$WindowsAppStorage\SKY-M3-WindowsAppStoreStorage.vhdx", "W", [MountType]::DriveLetter);
    $Drives += $VirtualDriveToLoad0;
    $VirtualDriveToLoad1 = [VirtualDriveToLoad]::new( "a7b60caa-51d7-4f9a-8468-512cc4c023df", "1", [MountCategory]::ProfileApplication, "$BaseVHDXStorage\AppData-Drives\AutoDesk.vhdx", "$env:LOCALAPPDATA\AutoDesk", [MountType]::FolderLocation); 
    $Drives += $VirtualDriveToLoad1;
    $VirtualDriveToLoad2 = [VirtualDriveToLoad]::new("acbf419a-26fa-4ede-bc7f-4dccfa00de05", "2", [MountCategory]::ProgramFilesApplication, "$CompoundVHDXStorage\Cakewalk\Cakewalk-PrimaryStorage.vhdx", "$CompoundVHDXStorage\Cakewalk\CakewalkCompoundDriveMountPoint", [MountType]::FolderLocation );
    $Drives += $VirtualDriveToLoad2;
    $VirtualDriveToLoad3 = [VirtualDriveToLoad]::new("d0f5b3fd-dd42-49ae-97e5-1462ed1751d8", "3", [MountCategory]::ProgramFilesApplication, "$CompoundVHDXStorage\Cakewalk\bandLabCakewalkPrimary.vhdx", "$CompoundVHDXStorage\Cakewalk\BandlabCakewalkCompoundMountPoint", [MountType]::FolderLocation );
    $Drives += $VirtualDriveToLoad3;
    $VirtualDriveToLoad4 = [VirtualDriveToLoad]::new("64d566c5-ad0f-480e-8039-3ca2d1cc3680", "4", [MountCategory]::SecondaryMountableDrive, "$CompoundVHDXStorage\Cakewalk\BandlabCakewalkCompoundMountPoint\BandLabProgramFilesCakewalkCakewalkCore.vhdx", "", [MountType]::FolderLocation );
    $Drives += $VirtualDriveToLoad4;
    $VirtualDriveToLoad5 = [VirtualDriveToLoad]::new("7fa06b6c-bc8a-4a3e-a434-45c4d6545a22", "5", [MountCategory]::SecondaryMountableDrive, "$CompoundVHDXStorage\Cakewalk\CakewalkCompoundDriveMountPoint\CakewalkContentPath.vhdx", "", [MountType]::FolderLocation );
    $Drives += $VirtualDriveToLoad5;
    $VirtualDriveToLoad6 = [VirtualDriveToLoad]::new("f922e9eb-9e15-4d00-9ed5-013cdaa283aa", "6", [MountCategory]::SecondaryMountableDrive, "$CompoundVHDXStorage\Cakewalk\CakewalkCompoundDriveMountPoint\ProgramFilesCakewalkFolder.vhdx", "", [MountType]::FolderLocation );
    $Drives += $VirtualDriveToLoad6;
    $VirtualDriveToLoad7 = [VirtualDriveToLoad]::new("43de780f-b8a7-4b79-a244-126febe9b957", "7", [MountCategory]::SecondaryMountableDrive, "$CompoundVHDXStorage\Cakewalk\CakewalkCompoundDriveMountPoint\ProgramFilesCakewalkSharedSecondaryRequiresCakewalkPrimary.vhdx", "", [MountType]::FolderLocation );
    $Drives += $VirtualDriveToLoad7;
    $VirtualDriveToLoad8 = [VirtualDriveToLoad]::new("2dceb684-e0d6-44c0-981e-808ec91b6809", "8", [MountCategory]::SecondaryMountableDrive, "$CompoundVHDXStorage\Cakewalk\CakewalkCompoundDriveMountPoint\ProgramFilesX86CakewalkFolder.vhdx", "", [MountType]::FolderLocation );
    $Drives += $VirtualDriveToLoad8;
    $VirtualDriveToLoad9 = [VirtualDriveToLoad]::new("c07770aa-8ebd-4ac5-90e3-753f56c8dc64", "9", [MountCategory]::SecondaryMountableDrive, "$CompoundVHDXStorage\Cakewalk\CakewalkCompoundDriveMountPoint\ProgramFilesCakewalkSharedSecondaryRequiresCakewalkPrimary.vhdx", "C:\Program Files\Cakewalk\Shared DXi", [MountType]::FolderLocation );
    $Drives += $VirtualDriveToLoad9;
    $VirtualDriveToLoad10 = [VirtualDriveToLoad]::new("d187b3e2-a3e7-42d4-a1b9-cd20b7ecb0ef", "10", [MountCategory]::SecondaryMountableDrive, "$CompoundVHDXStorage\Cakewalk\", "C:\Program Files\Cakewalk\Shared MIDI Plugins", [MountType]::FolderLocation );
    $Drives += $VirtualDriveToLoad10;
    $VirtualDriveToLoad11 = [VirtualDriveToLoad]::new("969dce46-0db7-4313-8bd9-04d18e0896f8", "11", [MountCategory]::SecondaryMountableDrive, "$CompoundVHDXStorage\Cakewalk\", "C:\Program Files\Cakewalk\Shared Plugins", [MountType]::FolderLocation );
    $Drives += $VirtualDriveToLoad11;
    $VirtualDriveToLoad12 = [VirtualDriveToLoad]::new("fbf1cdb2-7d54-4b9b-a8d3-a15fb6b657b8", "12", [MountCategory]::SecondaryMountableDrive, "$CompoundVHDXStorage\Cakewalk\", "C:\Program Files\Cakewalk\Shared Surfaces", [MountType]::FolderLocation );
    $Drives += $VirtualDriveToLoad12;
    $VirtualDriveToLoad13 = [VirtualDriveToLoad]::new("90e04ebf-3331-4267-a826-b8df2f057416", "13", [MountCategory]::SecondaryMountableDrive, "$CompoundVHDXStorage\Cakewalk\", "C:\Program Files\Cakewalk\Shared Utilities", [MountType]::FolderLocation );
    $Drives += $VirtualDriveToLoad13;
    $VirtualDriveToLoad14 = [VirtualDriveToLoad]::new("796f4f9e-c1c4-4635-a804-1ea8ae83d7e9", "14", [MountCategory]::SecondaryMountableDrive, "$CompoundVHDXStorage\Cakewalk\", "C:\Program Files\Cakewalk\SONAR Platinum", [MountType]::FolderLocation );
    $Drives += $VirtualDriveToLoad14;
    $VirtualDriveToLoad15 = [VirtualDriveToLoad]::new("151c64dc-ddd3-494c-9960-3c0c43f96e3c", "15", [MountCategory]::SecondaryMountableDrive, "$CompoundVHDXStorage\Cakewalk\", "C:\Program Files\Cakewalk\Studio Instruments", [MountType]::FolderLocation );
    $Drives += $VirtualDriveToLoad15;
    $VirtualDriveToLoad16 = [VirtualDriveToLoad]::new("b1ac7052-bbcd-44bb-ae15-ad1715e84781", "16", [MountCategory]::SecondaryMountableDrive, "$CompoundVHDXStorage\Cakewalk\", "C:\Program Files\Cakewalk\z3ta+", [MountType]::FolderLocation );
    $Drives += $VirtualDriveToLoad16;

    $OrderedDrives = $Drives | Sort-Object -Property LoadOrder;
    foreach ($DriveItem in $OrderedDrives) {
        #[string] $mountMessage = "$DriveItem"
        #Write-Host $mountMessage
        if ([System.IO.File]::Exists($DriveItem.DriveFullLocation)) {
            Write-Host $DriveItem.DriveFullLocation " ---------> " $DriveItem.MountPath;
            Mount-PersonalVHDXDrive $DriveItem.DriveFullLocation;    
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
