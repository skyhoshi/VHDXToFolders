Write-Host "Loading: Get-CliDriveFileFromWeb" -ForegroundColor DarkMagenta;

function Get-CliDriveFileFromWeb {
    begin {
        
    }
    
    process {
        # $gistId = "aa7a0bd55cf0672c9cc3bc8a04176747";
        # $gistFileName = "VirtualHardDriveList.xml";
        # $MasterDriveListUrl = "https://gist.githubusercontent.com/skyhoshi/aa7a0bd55cf0672c9cc3bc8a04176747/raw/03495e70583ea32061e1e89fafe7f98b03439eee/VirtualHardDriveList.xml";
        # $MasterDriveListUrl = "https://gist.githubusercontent.com/skyhoshi/aa7a0bd55cf0672c9cc3bc8a04176747/raw/f0585916e173d6ea77e819d99e9b13717bbc338e/VirtualHardDriveList.xml";
        # $urlEndpoint = "gists/$gistId"
        # $GistInfo = ConvertFrom-Json (hub api $urlEndpoint);
        # $GistInfo.files.$gistFileName.content
        # $DriveWebFile = "C:\Windows\Temp\Drives.xml";
        # Write-Host "Testing $DriveWebFile" -ForegroundColor green; ;
        # if (!(Test-Path -Path $DriveWebFile)) {
        #     Write-Host "Downloading Drive File" -ForegroundColor green; ;
        #     Invoke-WebRequest -Uri $MasterDriveListUrl -OutFile $DriveWebFile;
        # }
        # Write-Host "Importing File $DriveWebFile" -ForegroundColor green;
        # ConvertFrom-StringData
        # $VHDDrivesForImport = Import-Clixml -Path $DriveWebFile;
        # Write-Host "Removing File: $DriveWebFile" -ForegroundColor green;
        # Remove-item $DriveWebFile -Force;        
        $importableXML = Get-VirtaulHardDriveListFromGist;
        if ($importableXML -eq ""){ return;}
        $VHDDrivesForImport = Import-Clixml -Path $importableXML;
        $NumberOfDrives = ([System.Collections.ArrayList] $VHDDrivesForImport).Count;
        Write-Host "Drives Loaded: $NumberOfDrives" -ForegroundColor green;
    }
    
    end {
        return $VHDDrivesForImport;
    }
}
# Get-CliDriveFileFromWeb;

# Get-CliDriveFileFromWeb

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