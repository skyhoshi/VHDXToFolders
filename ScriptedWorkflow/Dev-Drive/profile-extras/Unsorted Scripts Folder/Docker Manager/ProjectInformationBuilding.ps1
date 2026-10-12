. "C:\Users\kernm\OneDrive - Farm Credit Services of America\Documents\PowerShell\Scripts\listmethodsinps1file.ps1"
if (-not('DockerProject' -as [type])) { 
    Write-Host "Need Classes not found. Attempting to instance..."
. "C:\Users\kernm\OneDrive - Farm Credit Services of America\Documents\PowerShell\Scripts\Docker Manager\Classes\ProjectManagerClass.ps1"
}

function Get-DockerProjects {
    [CmdletBinding()]
    param (
        
    )
    
    begin {
        [System.Collections.ArrayList]$projects = @()
        
    }
    
    process {
        
        

    }
    
    end {
     return $projects;   
    }
}

function Get-EnterpriseStatusProject(){
    $project = [DockerProject]::new();
    $project.$Index = 0;
    $project.Title = "Enterprise Status";
    $project.SourceLocation = "";
}