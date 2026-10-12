$dir ="C:\Users\kernm\AppData\Local\Programs\Microsoft VS Code"
$bucketsdir = "$PSScriptRoot\"
$dirpath = "$dir".Replace('\', '\\')
$exepath = "$dir\Code.exe".Replace('\', '\\')
#'install-associations', 'uninstall-associations', 
'install-context', 'uninstall-context'
#, 'install-github-integration', 'uninstall-github-integration' 
| ForEach-Object {
    if (!(Test-Path "$bucketsdir\vscode\")) {
        mkdir "$bucketsdir\vscode\" | Out-Null
    }
  if (!(Test-Path "$bucketsdir\vscode\$_.reg")) {
    Invoke-RestMethod "https://raw.githubusercontent.com/ScoopInstaller/Extras/refs/heads/master/scripts/vscode/$_.reg" -OutFile "$bucketsdir\vscode\$_.reg"
  }
    $content = Get-Content "$bucketsdir\vscode\$_.reg"
    $content = $content.Replace('$codedir', $dirpath)
    $content = $content.Replace('$code', $exepath)
    # if ($global) {
    #   $content = $content.Replace('HKEY_CURRENT_USER', 'HKEY_LOCAL_MACHINE')
    # }
    $content | Set-Content -Path "$bucketsdir\vscode\$_.reg"
  
}
# if (!(Test-Path "$dir\data\extensions") -and (Test-Path "$env:USERPROFILE\.vscode\extensions")) {
#     info '[Portable Mode] Copying extensions...'
#     Copy-Item "$env:USERPROFILE\.vscode\extensions" "$dir\data" -Recurse
# }
# if (!(Test-Path "$dir\data\user-data") -and (Test-Path "$env:AppData\Code")) {
#     info '[Portable Mode] Copying user data...'
#     Copy-Item "$env:AppData\Code" "$dir\data\user-data" -Recurse
# }
# $extensions_file = "$dir\data\extensions\extensions.json"
# if ((Test-Path "$extensions_file")) {
#     info 'Adjusting path in extensions file...'
#     (Get-Content "$extensions_file") -replace '(?<=vscode(/|\\\\\\\\)).*?(?=(/|\\\\\\\\)data(/|\\\\\\\\)extensions)', $version | Set-Content "$extensions_file"
# }