. "C:\Users\kernm\OneDrive - Farm Credit Services of America\Documents\PowerShell\Scripts\listmethodsinps1file.ps1"

Write-Host "Loading Node Methods"
Write-Host "npm-InstallAndBuild - Shortcut"
function npm-InstallAndBuild {
    npm install && npm run build
}
<#
Write-Host "Node Dependency Lookup Script:"
. "C:\Users\kernm\OneDrive - Farm Credit Services of America\PowerShell\Scripts\Unsorted Single Scripts\npm dep lookup.ps1"
#>