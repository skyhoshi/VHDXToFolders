Write-Host "Loading Test-IsVHDriveMounted Function" -ForegroundColor Yellow;
function Test-IsVHDriveMounted {
    [CmdletBinding()]
    param (
        [Parameter()]
        [string]
        $ImagePath
    )
    begin {
        if (!(Test-Path -Path $ImagePath)) {
            return false;
        }
    }
    
    process {
        $VHD = Get-VHD -Path $ImagePath;
        return $VHD;
        #$DiskImage =  get-diskimage -ImagePath $ImagePath;
        #return $DiskImage.Attached;
    }
    
    end {
        $VHD = $null;
        $DiskImage = $null;
        $ImagePath = $null;
    }

}
