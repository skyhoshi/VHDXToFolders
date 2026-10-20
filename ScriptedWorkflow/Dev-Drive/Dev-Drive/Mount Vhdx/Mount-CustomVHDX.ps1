<#
.SYNOPSIS
Stores, edits, and applies the desired state of custom VHD/VHDX drives.
.EXAMPLE
.\Mount-CustomVHDX.ps1 -Action Edit
.EXAMPLE
.\Mount-CustomVHDX.ps1 -Action Sync -WhatIf
#>
[CmdletBinding(SupportsShouldProcess)]
param(
    [ValidateSet('Edit', 'List', 'Sync')]
    [string]$Action = 'Edit',

    [string]$ConfigPath = (Join-Path "$($env:HOMEDRIVE)$($env:HOMEPATH)" '.config\VHDXToFolders\Drives.clixml')
) 
Remove-Module (Join-Path $PSScriptRoot 'CustomVhdx\CustomVhdx.psd1') -ErrorAction Ignore | Out-Null;
$Error.Clear();
Import-Module (Join-Path $PSScriptRoot 'CustomVhdx\CustomVhdx.psd1') -ErrorAction Stop;

$Drives = @(Import-CustomVhdxDrive -ConfigPath $ConfigPath);
$Drives = $Drives | Sort-Object -Unique -Property Path;


if ($MyInvocation.InvocationName -ne '.') {
    switch ($Action) {
        'Edit' { write-host "Attempting to open editor"
            $Drives = @(Show-CustomVhdxDriveEditor -Drives $Drives -ConfigPath $ConfigPath) }
        'List' { $Drives }
        'Sync' {
            $syncParameters = @{ Drives = $Drives }
            foreach ($parameterName in @('WhatIf', 'Confirm')) {
                if ($PSBoundParameters.ContainsKey($parameterName)) {
                    $syncParameters[$parameterName] = $PSBoundParameters[$parameterName]
                }
            }
            Sync-CustomVhdxDrive @syncParameters
        }
    }
}
