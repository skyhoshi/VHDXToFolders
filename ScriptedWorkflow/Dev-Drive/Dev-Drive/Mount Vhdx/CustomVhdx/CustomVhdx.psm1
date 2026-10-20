$functionFiles = @(
    'Private\Assert-CustomVhdxDrive.ps1'
    'Public\Get-DefaultCustomVhdxDrive.ps1'
    'Public\Import-CustomVhdxDrive.ps1'
    'Public\Save-CustomVhdxDrive.ps1'
    'Public\Show-CustomVhdxDriveEditor.ps1'
    'Public\Sync-CustomVhdxDrive.ps1'
)

foreach ($functionFile in $functionFiles) {
    . (Join-Path $PSScriptRoot $functionFile)
}

Export-ModuleMember -Function @(
    'Get-DefaultCustomVhdxDrive'
    'Import-CustomVhdxDrive'
    'Save-CustomVhdxDrive'
    'Show-CustomVhdxDriveEditor'
    'Sync-CustomVhdxDrive'
)
