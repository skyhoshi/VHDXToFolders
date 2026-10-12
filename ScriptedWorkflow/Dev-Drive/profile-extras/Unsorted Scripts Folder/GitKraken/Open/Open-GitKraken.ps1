. "C:\Users\kernm\OneDrive - Farm Credit Services of America\Documents\PowerShell\Scripts\listmethodsinps1file.ps1"
Write-Host "Loading GitKraken Open Method"
function Open-GitKraken {
    [CmdletBinding()]
    param (
        [string]$ProjectPath
    )
    
    begin {
        
    }
    
    process {
        if ($ProjectPath) { 
            if ((Test-Path $ProjectPath)) {
                $curpath = $ProjectPath
            }
        }
        if (!$curPath) {
            $curpath = (get-location).ProviderPath
        }
        $lapd = $env:localappdata
        $logf = "$env:temp\krakstart.log"
        $newestExe = Get-Item "$lapd\gitkraken\app-*\gitkraken.exe" | select -Last 1
        start-process -filepath   $newestExe -ArgumentList "--path $curpath" -redirectstandardoutput $logf
    }
    
    end {
        
    }
}

#Open-GitKraken -ProjectPath "S:\Code\ElasticConfig"