function Get-CliDriveFileFromWeb {
    begin {
        
    }
    
    process {
        $MasterDriveListUrl = "https://gist.githubusercontent.com/skyhoshi/aa7a0bd55cf0672c9cc3bc8a04176747/raw/03495e70583ea32061e1e89fafe7f98b03439eee/VirtualHardDriveList.xml";
        $DriveWebFile = "C:\Windows\Temp\Drives.xml";
        if (!(Test-Path -Path $DriveWebFile)) {
            Write-Host "Downloading Drive File";
            Invoke-WebRequest -Uri $MasterDriveListUrl -OutFile $DriveWebFile;
        }
        Remove-item $DriveWebFile -Force;
        $VHDDrivesForImport = Import-Clixml -Path $DriveWebFile;
    }
    
    end {
        return $VHDDrivesForImport;
    }
}

$DrivesFromWeb = Get-CliDriveFileFromWeb;
#$DriveById = $VHDDrivesForImport | Where-Object -Property Id -EQ -Value "fdb24800-2189-4947-b14d-a668ce56cc3f";
$DriveById = $DrivesFromWeb | Where-Object { $_.Id -eq "fdb24800-2189-4947-b14d-a668ce56cc3f" } #-Property Id -EQ -Value "fdb24800-2189-4947-b14d-a668ce56cc3f";
Write-Host "Drive By Id------------------------";
$DriveById;
Write-Host "END--------------------------------";
<#
$DriveByCategory = $VHDDrivesForImport | Where-Object -Property MountCategory -In -Value "Manditory", [MountCategory]::Manditory; #-EQ -Value [MountCategory]::Manditory;
Write-Host "Drive By Category------------------";
$DriveByCategory;
Write-Host "END--------------------------------";
#>
#[VirtualDriveToLoad] $VirtDriveToLoad = [VirtualDriveToLoad]$DriveById;
#$VirtDriveToLoad;
#$DebugDriveName = $VirtDriveToLoad.DriveFullLocation;
#Write-Host "Testing Virtual Drive To Load: $DebugDriveName";