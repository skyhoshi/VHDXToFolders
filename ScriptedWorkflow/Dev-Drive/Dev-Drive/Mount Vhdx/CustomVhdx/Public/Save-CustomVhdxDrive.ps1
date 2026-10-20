function Save-CustomVhdxDrive {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [AllowEmptyCollection()]
        [object[]]$Drives,

        [Parameter(Mandatory)]
        [string]$ConfigPath
    )

    Assert-CustomVhdxDrive -Drives $Drives
    $fullPath = $ExecutionContext.SessionState.Path.GetUnresolvedProviderPathFromPSPath($ConfigPath)
    $directory = [System.IO.Path]::GetDirectoryName($fullPath)
    [System.IO.Directory]::CreateDirectory($directory) | Out-Null
    $temporaryPath = Join-Path $directory ("{0}.tmp" -f [guid]::NewGuid())
    try {
        # Replace only a complete export so a failed write leaves the old settings intact.
        Export-Clixml -InputObject @($Drives | Select-Object Path, IsEnabled) -LiteralPath $temporaryPath -Depth 3 -ErrorAction Stop
        if ([System.IO.File]::Exists($fullPath)) {
            [System.IO.File]::Replace($temporaryPath, $fullPath, [System.Management.Automation.Language.NullString]::Value)
        }
        else {
            [System.IO.File]::Move($temporaryPath, $fullPath)
        }
    }
    finally {
        if ([System.IO.File]::Exists($temporaryPath)) {
            [System.IO.File]::Delete($temporaryPath)
        }
    }
}
