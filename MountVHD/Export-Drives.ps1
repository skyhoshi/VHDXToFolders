$WindowsAppStorage = "O:\VHDX Storage";
$BaseVHDXStorage = "D:\VHDX Storage";
$CompoundVHDXStorage = "D:\VHDX Storage\Compound Drives";
#$ProgramFilesX64 = "D:\VHDX Storage\ProgramFile-Drives";
#$ProgramFilesX86 = "D:\VHDX Storage\ProgramFileX86-Drives";
$WorkRelated = "D:\VHDX Storage\WorkRelated";
#$SystemUserProfiles = "D:\VHDX Storage\$Env:COMPUTERNAME-Profiles";

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
$VirtualDriveToLoad7 = [VirtualDriveToLoad]::new("43de780f-b8a7-4b79-a244-126febe9b957", "7", [MountCategory]::SecondaryMountableDrive, "$CompoundVHDXStorage\Cakewalk\CakewalkCompoundDriveMountPoint\ProgramFilesCakewalkSharedSecondaryRequiresCakewalkPrimary.vhdx", "C:\Program Files\Cakewalk\Shared DXi", [MountType]::FolderLocation );
$Drives += $VirtualDriveToLoad7;
$VirtualDriveToLoad8 = [VirtualDriveToLoad]::new("2dceb684-e0d6-44c0-981e-808ec91b6809", "8", [MountCategory]::SecondaryMountableDrive, "$CompoundVHDXStorage\Cakewalk\CakewalkCompoundDriveMountPoint\ProgramFilesX86CakewalkFolder.vhdx", "", [MountType]::FolderLocation );
$Drives += $VirtualDriveToLoad8;
$VirtualDriveToLoad9 = [VirtualDriveToLoad]::new("c07770aa-8ebd-4ac5-90e3-753f56c8dc64", "9", [MountCategory]::SecondaryMountableDrive, "$CompoundVHDXStorage\Cakewalk\", "", [MountType]::FolderLocation );
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
$VirtualDriveToLoad17 = [VirtualDriveToLoad]::new("b1ac7052-bbcd-44bb-ae15-ad1715e84781", "17", [MountCategory]::ProfileApplication, "D:\VHDX Storage\AppData-Drives\Test.vhdx", "$env:LOCALAPPDATA\Test", [MountType]::FolderLocation);
$Drives += $VirtualDriveToLoad17;

$VirtualDriveToLoad18 = [VirtualDriveToLoad]::new("2d42ed7d-6789-4989-8d35-113007eea23d", "18", [MountCategory]::SecondaryMountableDrive, "D:\VHDX Storage\Compound Drives\Unity\Unity-CompoundDrive.vhdx", "D:\VHDX Storage\Compound Drives\Unity\CompoundMountFolder", [MountType]::FolderLocation);
$Drives += $VirtualDriveToLoad18;
$VirtualDriveToLoad19 = [VirtualDriveToLoad]::new("3e967373-4487-4cdf-bb6e-a2b59377c56a", "19", [MountCategory]::SecondaryMountableDrive, "D:\VHDX Storage\Compound Drives\Unity\CompoundMountFolder\Unity Edtior Storage.vhdx", "C:\Program Files\Unity", [MountType]::FolderLocation);
$Drives += $VirtualDriveToLoad19;
$VirtualDriveToLoad20 = [VirtualDriveToLoad]::new("0d4d3472-8a02-42ae-bea1-773961b277f3", "20", [MountCategory]::SecondaryMountableDrive, "D:\VHDX Storage\AppData-Drives\Jetbrains.Toolbox.vhdx", "C:\Users\marcus\AppData\Local\JetBrains", [MountType]::FolderLocation);
$Drives += $VirtualDriveToLoad20;
$VirtualDriveToLoad21 = [VirtualDriveToLoad]::new("6320f90c-fdd8-4a48-80b9-07ab5289b699", "21", [MountCategory]::SecondaryMountableDrive, "D:\VHDX Storage\AppData-Drives\Microsoft.OutlookStorage.vhdx", "C:\Users\marcus\AppData\Local\Microsoft\Outlook", [MountType]::FolderLocation);
$Drives += $VirtualDriveToLoad21;
$VirtualDriveToLoad22 = [VirtualDriveToLoad]::new("a543ef4f-175d-4786-a131-f6d7404d5319", "22", [MountCategory]::SecondaryMountableDrive, "D:\VHDX Storage\ProgramFileX86-Drives\ProgramFilesx86Android.vhdx", "C:\Program Files (x86)\Android", [MountType]::FolderLocation);
$Drives += $VirtualDriveToLoad22;

$DrivesFileStorageLocation = "~/.config/Drives/";
if (!(Test-Path $DrivesFileStorageLocation)) {
    mkdir $DrivesFileStorageLocation;
}
Export-Clixml -Path $DrivesFileStorageLocation"VirtualDriveToLoad.xml" -InputObject $Drives;
Export-Csv -Path $DrivesFileStorageLocation"VirtualDriveToLoad.csv" -InputObject $Drives;
$GitCloneFor = "https://gist.github.com/aa7a0bd55cf0672c9cc3bc8a04176747.git"

#Create new temp folder in $env:TEMP and use that to upload. but delete the folder when completed.
$TempGitRepoLocation = "$env:TEMP\DriveGit\"
if (!(Test-Path -Path $TempGitRepoLocation)) {
    "Making New Directory";
    New-Item -ItemType Directory -Path $TempGitRepoLocation | Out-Null;
}
# $PreScriptDirectory =Get-Location ;
Set-Location $TempGitRepoLocation;
if (!(Test-Path -Path "$TempGitRepoLocation\.git")) {
    git clone $GitCloneFor $TempGitRepoLocation;
}
else{
    git pull --all;
}

Copy-Item -Path $DrivesFileStorageLocation"VirtualDriveToLoad.xml" -Destination "$TempGitRepoLocation\VirtualHardDriveList.xml";

git status;
git commit -a --message "Automated Export-Drives Update";
git push --all -f;
Set-Location .. ;
Remove-item -Path $TempGitRepoLocation -Recurse -Force;
#Set-Location $PreScriptDirectory;