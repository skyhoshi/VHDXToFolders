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
        
        $VHD = Get-VHD -Path $Drive;
        if (!$VHD.Attached) {
            Write-Host "Attaching $Drive"
            Mount-VHD -Path $Drive -ErrorAction SilentlyContinue;
        }
    }
    
    end {
        
    }
}