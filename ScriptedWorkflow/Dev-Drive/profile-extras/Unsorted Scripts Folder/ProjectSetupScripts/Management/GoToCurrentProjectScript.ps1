. "C:\Users\kernm\OneDrive - Farm Credit Services of America\Documents\PowerShell\Scripts\listmethodsinps1file.ps1"
# Write-Host "Loading Current Project Navigation Script(s)" -ForegroundColor Cyan;
# Write-Host "Loading Current-Scripts from: $PSCommandPath" -ForegroundColor Cyan;
# Write-Host "Loading Current-Project from: $PSCommandPath" -ForegroundColor Cyan;
# Write-Host "Loading Goto-PSJunkScripts from: $PSCommandPath" -ForegroundColor Cyan;
# Write-Host "Loading Start-TestProject from: $PSCommandPath" -ForegroundColor Cyan;
# Write-Host "Loading Mount-CurrentProject from: $PSCommandPath" -ForegroundColor Cyan;

# # Automatically discover and list all functions in this script
# $scriptPath = $PSCommandPath
# $ast = [System.Management.Automation.Language.Parser]::ParseFile($scriptPath, [ref]$null, [ref]$null)
# $functions = $ast.FindAll({ $args[0] -is [System.Management.Automation.Language.FunctionDefinitionAst] }, $true)
# $functionNames = $functions | ForEach-Object { $_.Name }
# Write-Host "Loading functions from: $PSCommandPath" -ForegroundColor Cyan
# foreach ($name in $functionNames) {
#     Write-Host "  - $name" -ForegroundColor Gray
# }
function Current-Scripts {
    
    Set-Location "C:\Users\kernm\OneDrive - Farm Credit Services of America\PowerShell\"
}
$valueScriptslias = (Get-Alias -Name "scripts" -ErrorAction Ignore)
if ($null -eq $valueScriptslias) {
    Write-Host "Creating New Alias scripts -> Current-Scripts"
    New-Alias -Name scripts -Value Current-Scripts -Description "Takes you to your current Powershell Script Folder" 
}
function Current-Project {
    
    #Set-Location "C:\source\Fcsamerica\Organization\"
    #Set-Location "C:\Source\FCSAmerica\Patronage\";
    #Set-Location "C:\Source\FCSAmerica\MarketingAndSales\Polar"
    #$currentProjectLocation ="S:\Fcsamerica\SolutionsEnablement\LightningProxy";
    Mount-CurrentProject; 
    $currentProjectLocation = "K:\";
    Set-Location $currentProjectLocation;
    $valueCNPAlias = (Get-Alias -Name "cnp" -ErrorAction Ignore)
    if ($null -eq $valueCNPAlias) {
        Write-Host "Creating New Alias cnp -> Current-Project"
        New-Alias -Name cnp -Value Current-Project -Description "Takes you to your current project" -Scope Global;
    }
}
$valueCNPAlias = (Get-Alias -Name "cnp" -ErrorAction Ignore)
if ($null -eq $valueCNPAlias) {
    Write-Host "Creating New Alias cnp -> Current-Project"
    New-Alias -Name cnp -Value Current-Project -Description "Takes you to your current project" -Scope Global
}
function Goto-PSJunkScripts {
    Set-Location "C:\Users\kernm\OneDrive - Farm Credit Services of America\PowerShell\Scripts\Unsorted Single Scripts"
}

function Start-TestProject {
    Current-Project;
    # $ExecutableWithParameters = "C:\Source\FCSAmerica\Organization\Source\Organization.ActiveDirectorySync\bin\Debug\net6.0\FCSAmerica.Organization.ActiveDirectorySync.exe --postdeploytest";
    $ExecutableWithParameters = "C:\Source\FCSAmerica\Organization\Source\Organization.Alerts\bin\Debug\net6.0\FCSAmerica.Organization.Alerts.exe";
    runas /user:fcsamerica\Organization_o  "$($ExecutableWithParameters)";
}

function Mount-CurrentProject {
    # C:\Projects\Sandbox\Sandbox.vhdx
    $SandboxLocation = "C:\Projects\Sandbox\Sandbox.vhdx"
    Mount-VHD $SandboxLocation -ErrorAction SilentlyContinue;
}