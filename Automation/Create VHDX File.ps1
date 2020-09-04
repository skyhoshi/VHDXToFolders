<#
Create-PersonalVHD -AssignVHDXToPath "C:\Program Files\Arduino"  -VolumnName "ArduinoProgramFiles" -VHDXStorageLocation "D:\VHDX Storage\ProgramFile-Drives\ArduinoProgramFiles.vhdx" 
#>
function Create-PersonalVHD {
    [CmdletBinding()]
    param ( 
        # Specifies the size of the drive and volume created. 
        # [Parameter(Mandatory = $false,ParameterSetName = "DriveCreation",ValueFromPipeline = $false,ValueFromPipelineByPropertyName = $false,HelpMessage = "Specifies the size of the drive and volume created.")]
        #[Alias("PSSize")]
        #[Alias("DriveSize")]
        #[ValidateNotNullOrEmpty()]
        [UInt64]$Size = 1TB, 
        # Specifies Name visible in windows explorer of the Volume Created
        #[Parameter(Mandatory = $false,ParameterSetName = "DriveCreation",ValueFromPipeline = $false,ValueFromPipelineByPropertyName = $false,HelpMessage = "Name visible in windows explorer of the Volume Created")]
        #[Alias("PSDriveName")]
        #[Alias("Drive")]
        #[ValidateNotNullOrEmpty()]
        [string] $VolumnName = "Test Volume",
        # Specifies a Path to Mount the VHDX file to.
        #[Parameter(Mandatory = $false, ParameterSetName = "PostCreation",ValueFromPipeline = $false,ValueFromPipelineByPropertyName = $false,HelpMessage = "Path to Mount the VHDX file to.")]
        #[Alias("PSAssignPath")]
        #[ValidateNotNullOrEmpty()]
        [string] $AssignVHDXToPath, 
        # Specifies a Path to Store the VHDX file.
        #[Parameter(Mandatory = $false,ParameterSetName = "DriveCreation",ValueFromPipeline = $false,ValueFromPipelineByPropertyName = $false,HelpMessage = "Path to Store the VHDX file.")]
        #[Alias("PSStoragePath")]
        #[ValidateNotNullOrEmpty()]
        [string] $VHDXStorageLocation = "D:\VHDX TestDrive.vhdx"
    )
    
    begin {
        [System.IO.DirectoryInfo]$StorageLocation = [System.IO.DirectoryInfo]::new($VHDXStorageLocation)
        if (![System.IO.Directory]::Exists($StorageLocation.Parent)) {
            $AccessPathObj = [System.IO.Directory]::CreateDirectory($StorageLocation.Parent);
            Write-Debug $AccessPathObj;
        }

        if ([System.IO.Directory]::Exists($AssignVHDXToPath)) {
            Write-Host "Assignment Directory Already Exists"
            $AssignPathDirectoryInfo = [System.IO.DirectoryInfo]::new($AssignVHDXToPath);

            if($AssignPathDirectoryInfo.GetFiles().Count -gt 0){
                Write-Error "Assigned Folder contains files and cannot be used"
                return;
            }
            #[System.IO.DirectoryInfo]$AssignLocation = [System.IO.DirectoryInfo]::new($AssignVHDXToPath)
            #$AssignLocation.Parent
            #if (![System.IO.Directory]::Exists($AssignLocation.Parent)) {
            #    #$AccessPathObj = [System.IO.Directory]::CreateDirectory($AssignLocation.Parent);
            #    #Write-Debug $AccessPathObj;
            #}
        }
        else{
            [System.IO.Directory]::CreateDirectory($AssignVHDXToPath);
        }
    }
    
    process {
        $VHDX = New-VHD -Path ($VHDXStorageLocation) -SizeBytes $Size -Dynamic | Mount-VHD -Passthru | Initialize-Disk -PartitionStyle GPT -PassThru | New-Volume -FileSystem NTFS -FriendlyName $VolumnName -AccessPath $AssignVHDXToPath;
    }
    
    end {
        return $VHDX;
    }
}

<#
. "C:\Users\marcus\OneDrive\Scripts\Powershell\Modules\VHDXToFolders\Automation\Create VHDX File.ps1"
$AssignPath = "";
$VolumeTitle = "";
$VHDStorageFile = "";
Create-PersonalVHD -VolumnName $VolumeTitle -VHDXStorageLocation $VHDStorageFile -AssignVHDXToPath $AssignPath
#>
<#
Root: C:\Program Files\

Adobe
Android
dotnet
Microsoft Office
Microsoft Office 15
Microsoft SDKs
Microsoft SQL Server
Microsoft Update Health Tools
Microsoft VS Code
MSBuild
Reference Assemblies
UNP
VS2010Schemas
VS2012Schemas
Walabot

#>

<#
Root: C:\Program Files (x86)\
dotnet
Microsoft IoT
Microsoft SDKs
Microsoft Visual Studio
Microsoft Visual Studio Tools for Unity
Microsoft Web Tools
Microsoft.NET
Windows Kits
#>