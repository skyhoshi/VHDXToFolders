@{
    RootModule = 'CustomVhdx.psm1'
    ModuleVersion = '1.0.0'
    GUID = '242b2c1e-f809-440e-a1bb-d87ca33b5038'
    Author = 'VHDXToFolders contributors'
    Description = 'Stores and edits custom VHD/VHDX settings and synchronizes drive attachment states.'
    PowerShellVersion = '7.4'
    CompatiblePSEditions = @('Core')
    FunctionsToExport = @(
        'Get-DefaultCustomVhdxDrive'
        'Import-CustomVhdxDrive'
        'Save-CustomVhdxDrive'
        'Show-CustomVhdxDriveEditor'
        'Sync-CustomVhdxDrive'
    )
    CmdletsToExport = @()
    VariablesToExport = @()
    AliasesToExport = @()
}
