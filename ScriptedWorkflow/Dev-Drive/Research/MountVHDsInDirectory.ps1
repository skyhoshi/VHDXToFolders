function Mount-VHDsInDirectory {
    <#
    .SYNOPSIS
        Finds .vhdx files in a directory and mounts any that are not already attached.

    .DESCRIPTION
        Searches the specified path for .vhdx files using Get-ChildItem, checks each one
        with Get-VHD to see if it is already mounted, and calls Mount-VHD on those that
        are not. Supports -WhatIf and -Verbose. Requires the Hyper-V PowerShell module.

    .PARAMETER SearchPath
        The root directory to search for .vhdx files.

    .PARAMETER Recurse
        When specified, searches all subdirectories under SearchPath.

    .EXAMPLE
        Mount-VHDsInDirectory -SearchPath 'D:\VHDs'

        Mounts all unmounted .vhdx files found directly in D:\VHDs.

    .EXAMPLE
        Mount-VHDsInDirectory -SearchPath 'D:\VHDs' -Recurse -Verbose

        Mounts all unmounted .vhdx files found anywhere under D:\VHDs and reports
        files that were already mounted.

    .EXAMPLE
        Mount-VHDsInDirectory -SearchPath 'D:\VHDs' -WhatIf

        Shows which .vhdx files would be mounted without actually mounting them.
    #>
    [CmdletBinding(SupportsShouldProcess)]
    param(
        [Parameter(Mandatory)]
        [string]$SearchPath,

        [switch]$Recurse
    )

    $getParams = @{
        Path    = $SearchPath
        Filter  = '*.vhdx'
        File    = $true
        Recurse = $Recurse.IsPresent
    }

    $vhdxFiles = Get-ChildItem @getParams

    if (-not $vhdxFiles) {
        Write-Warning "No .vhdx files found under '$SearchPath'."
        return
    }

    foreach ($file in $vhdxFiles) {
        try {
            $vhd = Get-VHD -Path $file.FullName -ErrorAction Stop

            if ($vhd.Attached) {
                Write-Verbose "Already mounted: $($file.FullName)"
            } else {
                if ($PSCmdlet.ShouldProcess($file.FullName, 'Mount-VHD')) {
                    Mount-VHD -Path $file.FullName -ErrorAction Stop
                    Write-Host "Mounted: $($file.FullName)"
                }
            }
        } catch {
            Write-Error "Failed to process '$($file.FullName)': $_"
        }
    }
}

Mount-VHDsInDirectory -SearchPath 'C:\Projects\Civ Sub Archive' -Recurse