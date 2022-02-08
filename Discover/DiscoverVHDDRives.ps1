$DriveRoot = "E:\"
$PrimaryStorageLocation = "$($DriveRoot)Shared Virtual Hard Drive Storage";
$ExcludeFolder01 = "$($PrimaryStorageLocation)\Archives" ;
$VhdxFilesInSharedFolder = (Get-ChildItem -Recurse -Include "*.vhdx" -Exclude $ExcludeFolder01);
#$VhdxFilesInSharedFolder;
#Where-Object -FilterScript {$_ -ne "Archives"} -InputObject $VhdxFilesInSharedFolder;

#ForEach-Object -InputObject $VhdxFilesInSharedFolder -Process {$_};

# $FirstFiles =  Where-Object -FilterScript {$_.DirectoryName -imatch '.*Archives.*'} -InputObject $VhdxFilesInSharedFolder;
# $FirstFiles | Select-Object -Property FullName;
#| 
#<#
$VhdxFilesInSharedFolder.ForEach({ 
        [System.IO.FileInfo]$file = [System.IO.FileInfo]$_;
        $directoryName = $file.DirectoryName;
        if ( $DirectoryName -inotmatch '.*Archive.*') {
            $file.FullName;
        }
    });

#>

$VHDXFilesToMount = $VhdxFilesInSharedFolder | Select-Object -Property FullName #| Where-Object {$_.NameString -notcontains "OLD"}
#$VHDXFilesToMount;
#$VHDXFilesToMount.Count;



<#
Application Drives
Creator Storage Drives
Development Drives
Game Development
Profile\AppData\OLD
#>

<#
Application Drives\JetBrains
Application Drives\ProgramFile-Drives
Application Drives\ProgramFileX86-Drives
Application Drives\RubyDevKit
Application Drives\Scoop
Application Drives\Scoop
Application Drives\Unity
Application Drives
Creator Storage Drives
Development Drives
Game Development
Mount Points For Compound Drives\Compound Drives\Cakewalk
Mount Points For Compound Drives\Compound Drives\Unity
Profile\AppData\OLD
Profile\OneDrive
Profile\Rose
#>
<#
New-Item -ItemType Directory -Path "$($DriveRoot)\Shared Virtual Hard Drive Storage\Archives\Application Drives\JetBrains"
New-Item -ItemType Directory -Path "$($DriveRoot)\Shared Virtual Hard Drive Storage\Archives\Application Drives\ProgramFile-Drives"
New-Item -ItemType Directory -Path "$($DriveRoot)\Shared Virtual Hard Drive Storage\Archives\Application Drives\ProgramFileX86-Drives"
New-Item -ItemType Directory -Path "$($DriveRoot)\Shared Virtual Hard Drive Storage\Archives\Application Drives\RubyDevKit"
New-Item -ItemType Directory -Path "$($DriveRoot)\Shared Virtual Hard Drive Storage\Archives\Application Drives\Scoop"
New-Item -ItemType Directory -Path "$($DriveRoot)\Shared Virtual Hard Drive Storage\Archives\Application Drives\Scoop"
New-Item -ItemType Directory -Path "$($DriveRoot)\Shared Virtual Hard Drive Storage\Archives\Application Drives\Unity"
New-Item -ItemType Directory -Path "$($DriveRoot)\Shared Virtual Hard Drive Storage\Archives\Application Drives"
New-Item -ItemType Directory -Path "$($DriveRoot)\Shared Virtual Hard Drive Storage\Archives\Creator Storage Drives"
New-Item -ItemType Directory -Path "$($DriveRoot)\Shared Virtual Hard Drive Storage\Archives\Development Drives"
New-Item -ItemType Directory -Path "$($DriveRoot)\Shared Virtual Hard Drive Storage\Archives\Game Development"
New-Item -ItemType Directory -Path "$($DriveRoot)\Shared Virtual Hard Drive Storage\Archives\Mount Points For Compound Drives\Compound Drives\Cakewalk"
New-Item -ItemType Directory -Path "$($DriveRoot)\Shared Virtual Hard Drive Storage\Archives\Mount Points For Compound Drives\Compound Drives\Unity"
New-Item -ItemType Directory -Path "$($DriveRoot)\Shared Virtual Hard Drive Storage\Archives\Profile\AppData\OLD"
New-Item -ItemType Directory -Path "$($DriveRoot)\Shared Virtual Hard Drive Storage\Archives\Profile\OneDrive"
New-Item -ItemType Directory -Path "$($DriveRoot)\Shared Virtual Hard Drive Storage\Archives\Profile\Rose"
#>


