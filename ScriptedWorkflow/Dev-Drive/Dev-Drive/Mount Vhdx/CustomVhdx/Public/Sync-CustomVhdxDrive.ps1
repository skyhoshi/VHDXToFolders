function Sync-CustomVhdxDrive {
    [CmdletBinding(SupportsShouldProcess, ConfirmImpact = 'High')]
    param(
        [Parameter(Mandatory)]
        [AllowEmptyCollection()]
        [object[]]$Drives
    )

    Assert-CustomVhdxDrive -Drives $Drives
    # Validate every file before making any changes to the attached drives.
    foreach ($drive in $Drives) {
        if (-not (Test-Path -LiteralPath $drive.Path -PathType Leaf -ErrorAction Stop)) {
            throw "VHD/VHDX file not found: $($drive.Path)"
        }
    }
    foreach ($drive in $Drives) {
        $vhd = Get-VHD -Path $drive.Path -ErrorAction Stop
        $result = 'Unchanged'
        if ($drive.IsEnabled -ne $vhd.Attached) {
            $operation = if ($drive.IsEnabled) { 'Mount VHD/VHDX' } else { 'Dismount VHD/VHDX' }
            $result = 'Skipped'
            if ($PSCmdlet.ShouldProcess($drive.Path, $operation)) {
                if ($drive.IsEnabled) {
                    Mount-VHD -Path $drive.Path -ErrorAction Stop
                    $result = 'Mounted'
                }
                else {
                    Dismount-VHD -Path $drive.Path -ErrorAction Stop
                    $result = 'Dismounted'
                }
                $vhd = Get-VHD -Path $drive.Path -ErrorAction Stop
                if ($vhd.Attached -ne $drive.IsEnabled) {
                    throw "The requested attachment state was not reached for: $($drive.Path)"
                }
            }
        }
        [pscustomobject]@{
            Path = $drive.Path
            IsEnabled = $drive.IsEnabled
            Attached = $vhd.Attached
            Action = $result
        }
    }
}
