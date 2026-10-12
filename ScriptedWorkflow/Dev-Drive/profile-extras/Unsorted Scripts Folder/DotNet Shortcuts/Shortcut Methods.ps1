. "C:\Users\kernm\OneDrive - Farm Credit Services of America\Documents\PowerShell\Scripts\listmethodsinps1file.ps1"
Write-Host "Loading Dotnet Shortcuts"
Write-Host "Clean-ProjectBuild : Manually clears out the **\obj and **\bin folder recursively for all items with the D Attribute"
function Clean-ProjectBuild {
    $objFolders = get-childitem -path **\obj -Recurse -Attributes D 
    $binFolders = get-childitem -path **\bin -Recurse -Attributes D 

    $binFolders | Remove-Item -Force
    $objFolders | Remove-Item -Force
    #get-childitem -path **\obj -Recurse -Directory -Depth 2 |Remove-Item -Force
}