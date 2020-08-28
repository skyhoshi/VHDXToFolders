Write-Host "Loading Test-IsVHDriveMounted Function";
function Test-IsVHDriveMounted {
    [CmdletBinding()]
    param (
        [Parameter()]
        [string]
        $ImagePath
    )
    begin {
        if (!(Test-Path -Path $ImagePath)){
            return false;
        }
    }
    
    process {
       $DiskImage =  get-diskimage -ImagePath $ImagePath;
       return $DiskImage.Attached;
    }
    
    end {
        $DiskImage = $null;
        $ImagePath = $null;
    }

}
