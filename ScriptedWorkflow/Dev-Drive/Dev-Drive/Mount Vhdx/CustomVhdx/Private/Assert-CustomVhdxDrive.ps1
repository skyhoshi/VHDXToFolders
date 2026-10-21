function Assert-CustomVhdxDrive {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [AllowEmptyCollection()]
        [object[]]$Drives
    )

    $seen = [System.Collections.Generic.HashSet[string]]::new([System.StringComparer]::OrdinalIgnoreCase)
    foreach ($drive in $Drives) {
        if ($null -eq $drive -or $drive.Path -isnot [string] -or
            [string]::IsNullOrWhiteSpace($drive.Path) -or
            -not [System.IO.Path]::IsPathFullyQualified($drive.Path) -or
            [System.IO.Path]::GetExtension($drive.Path) -notin @('.vhd', '.vhdx') -or
            $drive.IsEnabled -isnot [bool]) {
            throw 'Each drive must have an absolute VHD/VHDX Path and a Boolean IsEnabled value.'
        }
        if (-not $seen.Add([System.IO.Path]::GetFullPath($drive.Path))) {
            throw "Duplicate drive path: $($drive.Path)"
        }
    }
}
