
#using module "C:\Users\marcus\OneDrive\Scripts\Powershell\Modules\VHDXToFolders\src\Classes\MountType.ps1";
#using module "C:\Users\marcus\OneDrive\Scripts\Powershell\Modules\VHDXToFolders\src\Classes\MountCategory.ps1";
enum MountType {
    FolderLocation
    DriveLetter
};
enum MountCategory{
    Manditory
    ProfileApplication
    ProgramFilesApplication
    SecondaryMountableDrive
};
class VirtualDriveToLoad {
    VirtualDriveToLoad([System.Guid]$id, $loadOrder, $mountCategory, $driveFullLocation, $mountPath, $mountType) {
        $this.MountPath = $mountPath;
        $this.MountType = $mountType;
        $this.MountCategory = $mountCategory;
        $this.DriveFullLocation = $driveFullLocation;
        $this.LoadOrder = $loadOrder;
        $this.Id = $id;
    }
    [System.Guid] $Id = [System.Guid]::NewGuid();
    [long] $LoadOrder;
    [MountCategory] $MountCategory;
    [string] $DriveFullLocation;
    [string] $MountPath;
    [MountType] $MountType = [MountType]::FolderLocation;
}