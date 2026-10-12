#. "C:\Users\kernm\OneDrive - Farm Credit Services of America\Documents\PowerShell\Scripts\listmethodsinps1file.ps1"
#Write-Host "Loading Reload-Profile from: $PSCommandPath" -ForegroundColor Cyan

function Reload-Profile() {
    . $Profile.CurrentUserAllHosts 
}