function New-DevelopmentStorageEnvironment {
    param (
        #This ProjectId Represents the ticket # your working on. 
        [Parameter(HelpMessage = "Long ID Usually Story Id from AzureDevOps")]
        [Int64]$ProjectId,
        #This ProjectName Represents the Description of the work you doing. (should be short and no more than 3 words [keep it short as it's apart of the path])
        [Parameter(HelpMessage = "String Representation of the work for this env.")]
        [string]$ProjectName,
        #Choose a Drive Letter can be A-ZZZ (AA, AAA or combos therof can be used.)
        [Parameter(Mandatory, HelpMessage = "Drive Letter for Project Defaults to L")]
        [Char]$ProjectRootDriveLetter = "L",
        #Name your dirve Accordingly, We Recomment using the ProjectId and Project Name but you can name it as you like.
        [Parameter(HelpMessage = "Allows you to override the name of the VHDx File Created. (will be ProjectID and ProjectName with all spaces removed.)")]
        [string]$VirtualHardDiskFileName,
        #We Recommend Leaving this as is, Disk is Dynamically size (takes space when needed) and setting it smaller could cause issues if you reach it's limit. (fill a 20GB drive and having to expand it is dangerious)
        [Parameter(HelpMessage = "Suggession: DO NOT edit this. can be lowered but can cause problems if you reach the size limit and need to expand/resize the drive. (RISKY to Edit)")]
        [Int64]$vhdsize = 1TB
        
    )

    $error.clear()
    $PrimaryProjectStorageLocation = "C:\Projects"

    ### DANGER EDITING BELOW ###
    #Store Previous location to allow this to be run from anywhere.
    $previousLocation = $PWD
    <#Setup Location and Naming of items for VHD File#>
    if (!$VirtualHardDiskFileName) {
        $projectNamePart = $ProjectName.Replace(" ", "")
        $VirtualHardDiskFileName = "$ProjectId$projectNamePart.vhdx"
    }

    #This ProjectStorageLocation Represents where the VHDX will be stored. for future reference and easy management.
    $ProjectStorageLocation = "$($PrimaryProjectStorageLocation)\$ProjectName\$ProjectId$ProjectName\"
    Write-Host "Creating Env for $ProjectStorageLocation"
    if (!(Test-Path $ProjectStorageLocation)) {
        #Creating the directory for write (VHDX Storage Location)
        New-Item -ItemType Directory -Path $ProjectStorageLocation | Out-Null
    }
    $vhdpath = "$($ProjectStorageLocation)$($VirtualHardDiskFileName)"
    ##############################################################################################################################################################
    $vhd = New-VHD -Path $vhdpath -Dynamic -SizeBytes $vhdsize; 
    $mountedvhd = $vhd | Mount-VHD -Passthru 
    $initializedMountedVhd = $mountedvhd | Initialize-Disk -PartitionStyle GPT -Passthru 
    $partitionedInitalizedMountedVHD = $initializedMountedVhd | New-Partition -DriveLetter $ProjectRootDriveLetter -UseMaximumSize 
    $formattedPartition = $partitionedInitalizedMountedVHD | Format-Volume -NewFileSystemLabel "$ProjectId $ProjectName" -FileSystem ReFS -Confirm:$false -Force 

    Write-Host "Vhd: $vhd"
    Write-Host $vhd | Format-Table -Property *
    Write-Host "Mounted Vhd: $mountedvhd"
    Write-Host $mountedvhd | Format-Table -Property *
    Write-Host "Initialized Mounted Vhd: $initializedMountedVhd"
    Write-Host $initializedMountedVhd | Format-Table -Property *
    Write-Host "Partitioned Initalized Mounted VHD: $partitionedInitalizedMountedVHD"
    Write-Host $partitionedInitalizedMountedVHD | Format-Table -Property *
    Write-Host "Formatted Partition: $formattedPartition"
    Write-Host $formattedPartition | Format-Table -Property *

}

New-DevelopmentStorageEnvironment -ProjectId 12345 -ProjectName "TestProject" -ProjectRootDriveLetter "L"



