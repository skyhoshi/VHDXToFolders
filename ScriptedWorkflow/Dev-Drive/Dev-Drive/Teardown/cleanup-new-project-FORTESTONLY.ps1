

function Get-DevDriveFileName {
    
}
function Get-DevDriveStoragePath {

}

function Get-DevDriveLetter {
    $vhdObj = get-vhd "C:\Projects\161799 Dev Containers\161799DevContainers.vhdx"
    $diskNumber = $vhdObj.DiskNumber
    $partion = get-partition -DiskNumber $diskNumber | Where-Object { ($null -ne $_.DriveLetter -OR $_.DriveLetter -ne "") -and $_.Type -eq "Basic" } | Select-Object * 
    return $partion.DriveLetter
}


function Cleanup-DevDrive {
    $error.Clear()
    $previousLocation = $PWD
    #This ProjectId Represents the ticket # your working on. 
    $ProjectId = 161799
    #This ProjectName Represents the Description of the work you doing. (should be short and no more than 3 words [keep it short as it's apart of the path])
    $ProjectName = "Dev Containers"

    #$VirtualHardDiskFileName = "testdrive1.vhdx"
    #if (!$VirtualHardDiskFileName) {
    $projectNamePart = $ProjectName.Replace(" ", "")
    $VirtualHardDiskFileName = "$ProjectId$projectNamePart.vhdx"
    #}

    $parentStorageFolder = "C:\Projects"
    set-location $parentStorageFolder
    #This ProjectStorageLocation Represents where the VHDX will be stored. for future reference and easy management.
    $ProjectStorageLocation = "$parentStorageFolder\$ProjectId $ProjectName\"

    $vhdpath = "$ProjectStorageLocation$VirtualHardDiskFileName"
    Stop-Service -Name ShellHWDetection
    $vhdObj = Get-VHD $vhdpath
    if ($vhdObj.Attached -eq $true) {
        Dismount-VHD $vhdpath -Verbose
        Test-Path $vhdpath
        if ((Test-Path $vhdpath)) {
    
            Remove-Item $ProjectStorageLocation -Force -Recurse -Verbose
        }
    }
    else {
        Write-Host "VHD is not attached so skipping dismount."
    }
    #Restart the service we stopped.
    Start-Service -Name ShellHWDetection
    Set-Location $previousLocation
}