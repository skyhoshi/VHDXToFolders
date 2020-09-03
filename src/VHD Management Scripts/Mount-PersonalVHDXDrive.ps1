Write-Host "Loading Mount-PersonVHDXDrive Function" -ForegroundColor Yellow;
function Mount-PersonalVHDXDrive {
    [CmdletBinding()]
    param (
        [string] $Drive
    )
    
    begin {
        if (!(Test-Path -Path  $Drive -ErrorAction SilentlyContinue )) {
            Write-Host "File does not exist please check and try again. $Drive" -ForegroundColor Red;
            break;
        }

    }
    
    process {
        
        $VHD = Get-VHD -Path $Drive;
        if (!$VHD.Attached) {
            Write-Host "Attaching $Drive" -ForegroundColor Green;
            Mount-VHD -Path $Drive -ErrorAction SilentlyContinue;
        }
    }
    
    end {
        
    }
}