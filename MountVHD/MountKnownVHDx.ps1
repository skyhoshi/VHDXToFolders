
enum MountType {
    FolderLocation
    DriveLetter
}
class VirtualDriveToLoad {
    VirtualDriveToLoad([System.Guid]$id,$loadOrder,$driveFullLocation,$mountPath,$mountType){

    }
    [System.Guid] $Id = [System.Guid]::NewGuid();
    [long] $LoadOrder;
    [string] $DriveFullLocation;
    [string] $MountPath;
    [MountType] $MountType = [MountType]::FolderLocation;
}

function Mount-PersonalVHDXDrive {
    [CmdletBinding()]
    param (
        [string] $Drive
    )
    
    begin {
        if (!(Test-Path -Path  $Drive -ErrorAction SilentlyContinue )) {
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
<#
$WindowsAppsStoreStorage = "O:\VHDX Storage\SKY-M3-WindowsAppStoreStorage.vhdx"
Mount-PersonalVHDXDrive $WindowsAppsStoreStorage;
$AutoDeskFusion = "D:\VHDX Storage\AppData-Drives\AutoDesk.vhdx"
Mount-PersonalVHDXDrive $AutoDeskFusion;
#>
$WindowsAppStorage = "O:\VHDX Storage";
$BaseVHDXStorage = "D:\VHDX Storage";
$CompoundStorage = "D:\VHDX Storage\Compound Drives";
$ProgramFilesX64 = "D:\VHDX Storage\ProgramFile-Drives";
$ProgramFilesX86 = "D:\VHDX Storage\ProgramFileX86-Drives";
$WorkRelated = "D:\VHDX Storage\WorkRelated";
$SystemUserProfiles = "D:\VHDX Storage\$Env:COMPUTERNAME-Profiles";

$StorgaeFolders
#[VirtualDriveToLoad] 
$Drives = {
    {"00000000-1111-0000-0000-111111111111", "-2147483647", [MountCategory]::Manditory,          "O:\VHDX Storage\SKY-M3-WindowsAppStoreStorage.vhdx", "W", [MountType]::DriveLetter }
    {"a7b60caa-51d7-4f9a-8468-512cc4c023df", "1",           [MountCategory]::ProfileApplication, "$BaseVHDXStorage\AppData-Drives\AutoDesk.vhdx", "C:\Users\marcus\AppData\Local\AutoDesk", [MountType]::FolderLocation} 
    #
    <#
    {"acbf419a-26fa-4ede-bc7f-4dccfa00de05", "2", [MountCategory]::ProgramFilesApplication, "$CompoundStorage\Cakewalk\Cakewalk-PrimaryStorage.vhdx",                                                                   "$CompoundStorage\Cakewalk\CakewalkCompoundDriveMountPoint",   [MountType]::FolderLocation }
    {"d0f5b3fd-dd42-49ae-97e5-1462ed1751d8", "3", [MountCategory]::ProgramFilesApplication, "$CompoundStorage\Cakewalk\bandLabCakewalkPrimary.vhdx",                                                                    "$CompoundStorage\Cakewalk\BandlabCakewalkCompoundMountPoint", [MountType]::FolderLocation }
    {"64d566c5-ad0f-480e-8039-3ca2d1cc3680", "4", [MountCategory]::SecondaryMountableDrive, "$CompoundStorage\Cakewalk\BandlabCakewalkCompoundMountPoint\BandLabProgramFilesCakewalkCakewalkCore.vhdx",                 "",                                                            [MountType]::FolderLocation }
    {"7fa06b6c-bc8a-4a3e-a434-45c4d6545a22", "5", [MountCategory]::SecondaryMountableDrive, "$CompoundStorage\Cakewalk\CakewalkCompoundDriveMountPoint\CakewalkContentPath.vhdx",                                       "",                                                            [MountType]::FolderLocation }
    {"f922e9eb-9e15-4d00-9ed5-013cdaa283aa", "6", [MountCategory]::SecondaryMountableDrive, "$CompoundStorage\Cakewalk\CakewalkCompoundDriveMountPoint\ProgramFilesCakewalkFolder.vhdx",                                "",                                                            [MountType]::FolderLocation }
    {"43de780f-b8a7-4b79-a244-126febe9b957", "7", [MountCategory]::SecondaryMountableDrive, "$CompoundStorage\Cakewalk\CakewalkCompoundDriveMountPoint\ProgramFilesCakewalkSharedSecondaryRequiresCakewalkPrimary.vhdx","",                                                            [MountType]::FolderLocation }
    {"2dceb684-e0d6-44c0-981e-808ec91b6809", "8", [MountCategory]::SecondaryMountableDrive, "$CompoundStorage\Cakewalk\CakewalkCompoundDriveMountPoint\ProgramFilesX86CakewalkFolder.vhdx",                             "",                                                            [MountType]::FolderLocation }
    #
    {"c07770aa-8ebd-4ac5-90e3-753f56c8dc64", "", "", "C:\Program Files\Cakewalk\Shared DXi",          [MountType]::FolderLocation }
    {"d187b3e2-a3e7-42d4-a1b9-cd20b7ecb0ef", "", "", "C:\Program Files\Cakewalk\Shared MIDI Plugins", [MountType]::FolderLocation }
    {"969dce46-0db7-4313-8bd9-04d18e0896f8", "", "", "C:\Program Files\Cakewalk\Shared Plugins",      [MountType]::FolderLocation }
    {"fbf1cdb2-7d54-4b9b-a8d3-a15fb6b657b8", "", "", "C:\Program Files\Cakewalk\Shared Surfaces",     [MountType]::FolderLocation }
    {"90e04ebf-3331-4267-a826-b8df2f057416", "", "", "C:\Program Files\Cakewalk\Shared Utilities",    [MountType]::FolderLocation }
    {"796f4f9e-c1c4-4635-a804-1ea8ae83d7e9", "", "", "C:\Program Files\Cakewalk\SONAR Platinum",      [MountType]::FolderLocation }
    {"151c64dc-ddd3-494c-9960-3c0c43f96e3c", "", "", "C:\Program Files\Cakewalk\Studio Instruments",  [MountType]::FolderLocation }
    {"b1ac7052-bbcd-44bb-ae15-ad1715e84781", "", "", "C:\Program Files\Cakewalk\z3ta+",               [MountType]::FolderLocation }
#>
};

<#
fdb24800-2189-4947-b14d-a668ce56cc3f
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
#<#
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
#>
foreach ($filename in $SharedVhdxFileNames) {
    $FullVhdxPath = "$CompoundStorage\Cakewalk\CakewalkCompoundDriveMountPoint\Program Files\$filename.vhdx"
    if (!(Test-Path -Path $FullVhdxPath)) {
        $VHDX = New-VHD -Path ($FullVhdxPath) -SizeBytes 2TB -Dynamic
    }
    else{
        $VHDX = Get-VHD -Path $FullVhdxPath
    }
    #Mount-VHD -Path $VHDX
    $VHDX | Format-List;
    #    Write-Host $FullVhdxPath;
}

$Shared = New-Object -TypeName System.Collections.ArrayList;


#>
<#
CakewalkContentPath.vhdx
-a---           7/29/2020 11:36 AM      205520896 ProgramFilesCakewalkFolder.vhdx
-a---           7/29/2020 11:36 AM      205520896 ProgramFilesCakewalkSharedSecondaryRequiresCakewalkPrimary.vhdx
-a---           7/29/2020 11:26 AM     3091202048 ProgramFilesX86CakewalkFolder.vhdx
#>

<#
Name
----
mkdir "C:\Program Files\Cakewalk\Shared DXi"
mkdir "C:\Program Files\Cakewalk\Shared MIDI Plugins"
mkdir "C:\Program Files\Cakewalk\Shared Plugins"
mkdir "C:\Program Files\Cakewalk\Shared Surfaces"
mkdir "C:\Program Files\Cakewalk\Shared Utilities"
mkdir "C:\Program Files\Cakewalk\SONAR Platinum"
mkdir "C:\Program Files\Cakewalk\Studio Instruments"
mkdir "C:\Program Files\Cakewalk\z3ta+"
#>
<# 
# retrieved Using:  Get-Partition | Get-Volume | Where {$_.DriveLetter -eq $null} | Select-Object -Property AccessPaths -Unique |  Format-list

AccessPaths : {C:\Program Files\Cakewalk\Cakewalk Core\, \\?\Volume{6922d3e3-a546-4076-8c9b-ab48d51826e6}\}
AccessPaths : {C:\Program Files\Cakewalk\, \\?\Volume{544f8827-e5be-4873-b059-bf8d4b2c97e4}\}
AccessPaths : {C:\Program Files\Cakewalk\Shared DXi\, \\?\Volume{634210c5-15b7-4e8e-8636-35e88934f07c}\}
Get-Disk | Where-Object {$_.BusType -eq "File Backed Virtual"}

Get-Disk | Where-Object {$_.BusType -eq "File Backed Virtual"} | Get-Partition | Where-Object {$_.AccessPaths -ne $null} | Format-List

#>
$OrderedDrives = $Drives | Sort-Object -Property LoadOrder;
foreach ($DriveItem in $OrderedDrives) {
    Mount-PersonalVHDXDrive $DriveItem;
}

<#
\\?\Volume{fb2a315b-0de5-481e-b93f-9c67c64aa9fc}\
        *** NO MOUNT POINTS ***

    \\?\Volume{18b10d1f-6710-49f9-a468-3e40173e5527}\
        C:\

    \\?\Volume{68163d8a-5885-405d-bef6-6a12df381981}\
        *** NO MOUNT POINTS ***

    \\?\Volume{84071140-37ad-4b5c-9c71-5eca380c759d}\
        *** NO MOUNT POINTS ***

    \\?\Volume{ce581dac-2ddd-47cf-bd33-efd1bd8791d5}\
        E:\

    \\?\Volume{c4c77ab1-238d-46c0-ad5a-34bbe0e22753}\
        O:\

    \\?\Volume{a7c0a925-83d1-44a3-b308-d51e2339ffdb}\
        F:\

    \\?\Volume{e30e8f7a-d9c8-4544-bcdf-7d4ce6ba9194}\
        *** NO MOUNT POINTS ***

    \\?\Volume{c2b0c6d2-759d-4bb7-9aac-ad93930ea3aa}\
        *** NO MOUNT POINTS ***

    \\?\Volume{51fd875e-ab8e-4331-b070-3168410864e0}\
        *** NO MOUNT POINTS ***

    \\?\Volume{9e809779-17f6-4577-8251-dbed254c5c4d}\
        D:\

    \\?\Volume{ce4e4c43-e3af-4efc-9f6d-8add03e96a86}\
        W:\

    \\?\Volume{f1c962b8-45d0-4501-96f1-67882599060b}\
        C:\Users\marcus\AppData\Local\AutoDesk\

    \\?\Volume{91f6f575-c071-4d5f-afff-5c695de9d7be}\
        D:\VHDX Storage\Compound Drives\Cakewalk\CakewalkCompoundDriveMountPoint\

    \\?\Volume{6eb063ca-efae-8b50-4a22-50e68bd1de23}\
        *** NO MOUNT POINTS ***

    \\?\Volume{fe16e1c4-4a1b-6d19-46a1-021889550c9e}\
        *** NO MOUNT POINTS ***

    \\?\Volume{5ae60960-1352-483c-95d0-416c4a85e16c}\
        C:\Program Files (x86)\Cakewalk\

    \\?\Volume{38cc10f5-0000-0000-0080-000000000000}\
        *** NO MOUNT POINTS ***

    \\?\Volume{bc7eb862-c8d7-4d45-893a-10cf3124702b}\
        D:\VHDX Storage\Compound Drives\Cakewalk\CakewalkCompoundDriveMountPoint\CakewalkContentPath\

    \\?\Volume{5931c7be-7071-46b5-a902-1e99ad73eecc}\
        D:\VHDX Storage\Compound Drives\Cakewalk\BandlabCakewalkCompoundMountPoint\

    \\?\Volume{6922d3e3-a546-4076-8c9b-ab48d51826e6}\
        C:\Program Files\Cakewalk\Cakewalk Core\

    \\?\Volume{544f8827-e5be-4873-b059-bf8d4b2c97e4}\
        C:\Program Files\Cakewalk\

    \\?\Volume{634210c5-15b7-4e8e-8636-35e88934f07c}\
        C:\Program Files\Cakewalk\Shared DXi\

    \\?\Volume{be56ba75-f120-40da-bcde-a385d97cd2e0}\
        *** NO MOUNT POINTS ***

    \\?\Volume{27823b97-f214-41a7-8fd8-10e1c21312ac}\
        *** NO MOUNT POINTS ***

    \\?\Volume{9fc70741-6413-11ea-9ce8-806e6f6e6963}\
        X:\
#>


<#
get-disk -Number 7 | Get-Partition -Number 2  | Get-Volume | format-table -AutoSize
#>

#$WorkDrive1 = "D:\VHDX Storage\WorkRelated\Stine\DeesignFiles.vhdx"
#Mount-PersonalVHDXDrive $WorkDrive1;
#if (Test-Path -Path $WorkDrive1){
#    Mount-VHD -Path $WorkDrive1;
#}