function Invoke-SpecificDownload {
    <#     [CmdletBinding()]
        param (
            
        ) #>
        
        begin {
            #$MasterDriveListUrl = "https://gist.githubusercontent.com/skyhoshi/aa7a0bd55cf0672c9cc3bc8a04176747/raw/03495e70583ea32061e1e89fafe7f98b03439eee/VirtualHardDriveList.xml";
            $MasterDriveListUrl = "https://gist.githubusercontent.com/skyhoshi/aa7a0bd55cf0672c9cc3bc8a04176747/raw/f0585916e173d6ea77e819d99e9b13717bbc338e/VirtualHardDriveList.xml";
            $DriveWebFile = "C:\Windows\Temp\Drives.xml"; 
        }
        
        process {
    
            Write-Host "Testing $DriveWebFile" -ForegroundColor green; ;
            if (!(Test-Path -Path $DriveWebFile)) {
                Write-Host "Downloading Drive File" -ForegroundColor green; ;
                Invoke-WebRequest -Uri $MasterDriveListUrl -OutFile $DriveWebFile;
            }
            Write-Host "Importing File $DriveWebFile" -ForegroundColor green;
        }
        
        end {
            Write-Host "Removing File: $DriveWebFile" -ForegroundColor green;
            Remove-item $DriveWebFile -Force;
        }
    }