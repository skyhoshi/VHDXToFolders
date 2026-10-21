function Import-CustomVhdxDrive {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [string]$ConfigPath
    )

    if (-not (Test-Path -LiteralPath $ConfigPath -ErrorAction Stop)) {
        $defaults = @(Get-DefaultCustomVhdxDrive)
        Save-CustomVhdxDrive -Drives $defaults -ConfigPath $ConfigPath
    }
    $stored = Import-Clixml -LiteralPath $ConfigPath -ErrorAction Stop
    $items = @($stored)
    Assert-CustomVhdxDrive -Drives $items
    $items
}
