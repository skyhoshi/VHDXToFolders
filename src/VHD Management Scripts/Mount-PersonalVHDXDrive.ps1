Write-Host "Loading Mount-PersonVHDXDrive Function"
function Mount-PersonalVHDXDrive {
    [CmdletBinding()]
    param (
        [string] $Drive
    )
    
    begin {
        if (!(Test-Path -Path  $Drive -ErrorAction SilentlyContinue )) {
            Write-Host "File does not exist please check and try again. $Drive"
            break;
        }

    }
    
    process {
        Write-Host "Processing $Drive"
        $VHD = Get-VHD -Path $Drive;
        Mount-VHD -Path $Drive -ErrorAction SilentlyContinue;
    }
    
    end {
        
    }
}