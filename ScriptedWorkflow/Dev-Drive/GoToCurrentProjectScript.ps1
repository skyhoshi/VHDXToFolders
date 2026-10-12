Write-Host "Loading Current Project Navigation Script(s)"

<#
.SYNOPSIS
This function will Initialize Profile Scripts that run automatically based on the host thats being initalized

.DESCRIPTION
WARNING: These Profile Scripts do have a cascade effect (load multiple profile scripts), Understand the profile / host script load process before altering scripts. This function will Initialize Profile Scripts that run automatically based on the host thats being initalized 

.EXAMPLE
An example

.NOTES
General notes
#>
function InitilizeProfiles {
    if ((Read-Host -Prompt "Initialize Profiles?").ToLower() -contains "y") {
        $HostFile = $PROFILE.AllUsersAllHosts;
        if (!(Test-Path -Path $HostFile)) {
            $CreateHost = Read-Host -Prompt "Would you like to create $HostFile"
            if ($CreateHost.ToLower() -contains "y") {
                New-Item -ItemType File -Path $HostFile -Force
            }
            $CreateHost = "N";
        }
        $HostFile = $PROFILE.AllUsersCurrentHost;
        if (!(Test-Path -Path $HostFile)) {
            $CreateHost = Read-Host -Prompt "Would you like to create $HostFile"
            if ($CreateHost.ToLower() -contains "y") {
                New-Item -ItemType File -Path $HostFile -Force
            }
            $CreateHost = "N";
        }
        $HostFile = $PROFILE.CurrentUserAllHosts;
        if (!(Test-Path -Path $HostFile)) {
            $CreateHost = Read-Host -Prompt "Would you like to create $HostFile"
            if ($CreateHost.ToLower() -contains "y") {
                New-Item -ItemType File -Path $HostFile -Force
            }
            $CreateHost = "N";
        }
        $HostFile = $PROFILE.CurrentUserCurrentHost;
        if (!(Test-Path -Path $HostFile)) {
            $CreateHost = Read-Host -Prompt "Would you like to create $HostFile"
            if ($CreateHost.ToLower() -contains "y") {
                New-Item -ItemType File -Path $HostFile -Force
            }
            $CreateHost = "N";
        }
    }
    
}

function Current-Scripts {
    $PowershellLocalProfileScriptStorage = "~\OneDrive - Farm Credit Services of America\PowerShell\"
    if ((Test-Path $PowershellLocalProfileScriptStorage )) {
        Set-Location $PowershellLocalProfileScriptStorage 
    }
    else{
        InitilizeProfiles;
    }
}

<#
.SYNOPSIS
Shortcuts the need to Change directories to the location of the current solution you are working on.

.DESCRIPTION
Long description

.EXAMPLE
Current-Project

.NOTES
This requires manual updating and profile reloading for it to navigate after a change in working project.
#>
function Current-Project {
<#
This Method needs to be updated manually. I was attempting to tie it to an environment variable but have not completed that step.
#>

    $currentProjectLocation = "L:\"
    Set-Location $currentProjectLocation
    $valueCNPAlias = (Get-Alias -Name "cnp" -ErrorAction Ignore)
    if ($null -eq $valueCNPAlias) {
        Write-Host "Creating New Alias cnp -> Current-Project"
        New-Alias -Name cnp -Value Current-Project -Description "Takes you to your current project" -Scope Global
    }
}


function Goto-PSJunkScripts {
    Set-Location "C:\Users\kernm\OneDrive - Farm Credit Services of America\PowerShell\Scripts\Unsorted Single Scripts"
}

function Start-TestProject {
    Current-Project
    # $ExecutableWithParameters = "C:\Source\FCSAmerica\Organization\Source\Organization.ActiveDirectorySync\bin\Debug\net6.0\FCSAmerica.Organization.ActiveDirectorySync.exe --postdeploytest";
    $ExecutableWithParameters = "C:\Source\FCSAmerica\Organization\Source\Organization.Alerts\bin\Debug\net6.0\FCSAmerica.Organization.Alerts.exe"
    runas /user:fcsamerica\Organization_o  "$($ExecutableWithParameters)"
}


function Mount-CurrentProject {
    # C:\Projects\Sandbox\Sandbox.vhdx
    $SandboxLocation = "C:\Projects\Sandbox\Sandbox.vhdx"
    Mount-VHD $SandboxLocation;
}

## Adding Alias's for the (Current-*) Methods. when used in conjunction with the profile script every time you load a host these alias' are set to the proper methods. allowing uniform experiences across hosts. 

$valueScriptslias = (Get-Alias -Name "scripts" -ErrorAction Ignore)
if ($null -eq $valueScriptslias) {
    Write-Host "Creating New Alias scripts -> Current-Scripts"
    New-Alias -Name scripts -Value Current-Scripts -Description "Takes you to your current Powershell Script Folder" 
}
$valueCNPAlias = (Get-Alias -Name "cnp" -ErrorAction Ignore)
if ($null -eq $valueCNPAlias) {
    Write-Host "Creating New Alias cnp -> Current-Project"
    New-Alias -Name cnp -Value Current-Project -Description "Takes you to your current project" -Scope Global
}


