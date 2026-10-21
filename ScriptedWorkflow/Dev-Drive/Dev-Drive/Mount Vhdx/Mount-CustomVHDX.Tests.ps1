$scriptPath = Join-Path $PSScriptRoot 'Mount-CustomVHDX.ps1'
$modulePath = Join-Path $PSScriptRoot 'CustomVhdx\CustomVhdx.psd1'
Import-Module $modulePath -Force -ErrorAction Stop

Describe 'Custom VHDX module packaging' {
    It 'Provides a valid manifest with only the five public functions exported' {
        $manifest = Test-ModuleManifest -Path $modulePath -ErrorAction Stop
        $manifest.Name | Should Be 'CustomVhdx'
        $manifest.Version.ToString() | Should Be '1.0.0'
        $exports = @((Get-Command -Module CustomVhdx).Name | Sort-Object)
        ($exports -join ',') | Should Be 'Get-DefaultCustomVhdxDrive,Import-CustomVhdxDrive,Save-CustomVhdxDrive,Show-CustomVhdxDriveEditor,Sync-CustomVhdxDrive'
        @(Get-Command Assert-CustomVhdxDrive -ErrorAction SilentlyContinue).Count | Should Be 0
    }

    It 'Keeps every function in its own matching file' {
        $moduleRoot = Split-Path $modulePath
        $files = @(Get-ChildItem -LiteralPath (Join-Path $moduleRoot 'Public'), (Join-Path $moduleRoot 'Private') -Filter '*.ps1')
        $files.Count | Should Be 6
        foreach ($file in $files) {
            $tokens = $null
            $parseErrors = $null
            $ast = [System.Management.Automation.Language.Parser]::ParseFile($file.FullName, [ref]$tokens, [ref]$parseErrors)
            $parseErrors.Count | Should Be 0
            $functions = @($ast.FindAll({ param($node) $node -is [System.Management.Automation.Language.FunctionDefinitionAst] }, $true))
            $functions.Count | Should Be 1
            $functions[0].Name | Should Be $file.BaseName
        }
    }

    It 'Imports without creating configuration or opening the editor' {
        $previousLocalAppData = $env:LOCALAPPDATA
        try {
            $env:LOCALAPPDATA = Join-Path $TestDrive 'module-import'
            $output = @(Import-Module $modulePath -Force -ErrorAction Stop)
            $output.Count | Should Be 0
            (Test-Path -LiteralPath $env:LOCALAPPDATA) | Should Be $false
        }
        finally {
            $env:LOCALAPPDATA = $previousLocalAppData
        }
    }
}

InModuleScope CustomVhdx {
    Describe 'Custom VHDX drive settings' {
        $scriptPath = Join-Path (Split-Path (Get-Module CustomVhdx).ModuleBase) 'Mount-CustomVHDX.ps1'
        . $scriptPath -ConfigPath (Join-Path $TestDrive 'initial.clixml')

        # Local stubs prevent any real disk operation, even if a mock is missed.
        function Get-VHD {
            [CmdletBinding()]
            param([string]$Path)
            throw "Unexpected real VHD query: $Path"
        }
        function Mount-VHD {
            [CmdletBinding()]
            param([string]$Path)
            throw "Unexpected real mount: $Path"
        }
        function Dismount-VHD {
            [CmdletBinding()]
            param([string]$Path)
            throw "Unexpected real dismount: $Path"
        }

        BeforeEach {
            $config = Join-Path $TestDrive 'settings.clixml'
            $entries = @(
                [pscustomobject]@{ Path = 'E:\Test Drives\enabled.vhdx'; IsEnabled = $true }
                [pscustomobject]@{ Path = 'E:\Test Drives\disabled.vhdx'; IsEnabled = $false }
            )
            $script:attached = @{
                'E:\Test Drives\enabled.vhdx' = $false
                'E:\Test Drives\disabled.vhdx' = $true
            }
            Mock Get-VHD { [pscustomobject]@{ Attached = $script:attached[$Path] } }
            Mock Mount-VHD { $script:attached[$Path] = $true }
            Mock Dismount-VHD { $script:attached[$Path] = $false }
            Mock Test-Path { $true } -ParameterFilter { $PathType -eq 'Leaf' }
        }

        It 'Initializes the seven original drives as enabled without applying changes' {
            $loaded = @(Import-CustomVhdxDrive -ConfigPath (Join-Path $TestDrive 'initial.clixml'))
            $loaded.Count | Should Be 7
            $loaded[0].Path | Should Be 'E:\Shared Virtual Hard Drive Storage\Profile\OneDrive\Sky-M4-OneDrive.vhdx'
            $loaded[6].Path | Should Be 'E:\Shared Virtual Hard Drive Storage\Application Drives\Winamp\Winamp.vhdx'
            @($loaded | Where-Object { $_.IsEnabled -isnot [bool] -or -not $_.IsEnabled }).Count | Should Be 0
            Assert-MockCalled Mount-VHD -Times 0 -Exactly -Scope It
            Assert-MockCalled Dismount-VHD -Times 0 -Exactly -Scope It
        }

        It 'Persists paths and real Boolean choices across reloads and replacements' {
            Save-CustomVhdxDrive -Drives $entries -ConfigPath $config
            $loaded = @(Import-CustomVhdxDrive -ConfigPath $config)
            $loaded.Count | Should Be 2
            $loaded[0].Path | Should Be $entries[0].Path
            $loaded[1].Path | Should Be $entries[1].Path
            $loaded[0].IsEnabled | Should Be $true
            $loaded[1].IsEnabled | Should Be $false
            ($loaded[1].IsEnabled -is [bool]) | Should Be $true
            $loaded[0].IsEnabled = $false
            Save-CustomVhdxDrive -Drives $loaded -ConfigPath $config
            $reloaded = @(Import-CustomVhdxDrive -ConfigPath $config)
            $reloaded[0].IsEnabled | Should Be $false
            $reloaded[1].IsEnabled | Should Be $false
            @(Get-ChildItem -LiteralPath $TestDrive -Filter '*.tmp').Count | Should Be 0
        }

        It 'Preserves empty and single-entry lists' {
            Save-CustomVhdxDrive -Drives @() -ConfigPath $config
            @(Import-CustomVhdxDrive -ConfigPath $config).Count | Should Be 0
            Save-CustomVhdxDrive -Drives @($entries[1]) -ConfigPath $config
            $loaded = @(Import-CustomVhdxDrive -ConfigPath $config)
            $loaded.Count | Should Be 1
            $loaded[0].Path | Should Be $entries[1].Path
            $loaded[0].IsEnabled | Should Be $false
        }

        It 'Rejects string Booleans without overwriting valid settings' {
            Save-CustomVhdxDrive -Drives $entries -ConfigPath $config
            $entries[0].IsEnabled = 'false'
            { Save-CustomVhdxDrive -Drives $entries -ConfigPath $config } | Should Throw 'Boolean IsEnabled'
            $loaded = @(Import-CustomVhdxDrive -ConfigPath $config)
            $loaded[0].IsEnabled | Should Be $true
            $loaded[1].IsEnabled | Should Be $false
        }

        It 'Rejects malformed entries and duplicate normalized paths' {
            foreach ($badPath in @('relative.vhdx', 'E:\not-a-drive.txt', '')) {
                $entries[0].Path = $badPath
                { Save-CustomVhdxDrive -Drives $entries -ConfigPath $config } | Should Throw 'absolute VHD/VHDX Path'
            }
            $entries[0].Path = 'E:\Test Drives\DISABLED.vhdx'
            { Save-CustomVhdxDrive -Drives $entries -ConfigPath $config } | Should Throw 'Duplicate drive path'
            $entries[0].Path = 'E:\Test Drives\sub\..\disabled.vhdx'
            { Save-CustomVhdxDrive -Drives $entries -ConfigPath $config } | Should Throw 'Duplicate drive path'
        }

        It 'Reports corrupt or invalid stored data instead of resetting it' {
            Set-Content -LiteralPath $config -Value 'not XML'
            { Import-CustomVhdxDrive -ConfigPath $config } | Should Throw 'Data at the root level'
            (Get-Content -LiteralPath $config -Raw).Trim() | Should Be 'not XML'
            Export-Clixml -InputObject @([pscustomobject]@{ Path = $entries[0].Path; IsEnabled = 'false' }) -LiteralPath $config
            { Import-CustomVhdxDrive -ConfigPath $config } | Should Throw 'Boolean IsEnabled'
        }

        It 'Mounts enabled drives and dismounts disabled drives' {
            $results = @(Sync-CustomVhdxDrive -Drives $entries -Confirm:$false)
            $results.Count | Should Be 2
            $results[0].Action | Should Be 'Mounted'
            $results[0].Attached | Should Be $true
            $results[0].Path | Should Be $entries[0].Path
            $results[1].Action | Should Be 'Dismounted'
            $results[1].Attached | Should Be $false
            $results[1].IsEnabled | Should Be $false
            Assert-MockCalled Mount-VHD -Times 1 -Exactly -Scope It -ParameterFilter { $Path -eq 'E:\Test Drives\enabled.vhdx' }
            Assert-MockCalled Dismount-VHD -Times 1 -Exactly -Scope It -ParameterFilter { $Path -eq 'E:\Test Drives\disabled.vhdx' }
        }

        It 'Leaves matching attachment states alone' {
            $script:attached[$entries[0].Path] = $true
            $script:attached[$entries[1].Path] = $false
            $results = @(Sync-CustomVhdxDrive -Drives $entries -Confirm:$false)
            $results[0].Action | Should Be 'Unchanged'
            $results[1].Action | Should Be 'Unchanged'
            Assert-MockCalled Mount-VHD -Times 0 -Exactly -Scope It
            Assert-MockCalled Dismount-VHD -Times 0 -Exactly -Scope It
        }

        It 'Previews both changes without altering attachment states' {
            $results = @(Sync-CustomVhdxDrive -Drives $entries -WhatIf)
            $results[0].Action | Should Be 'Skipped'
            $results[0].Attached | Should Be $false
            $results[1].Action | Should Be 'Skipped'
            $results[1].Attached | Should Be $true
            Assert-MockCalled Mount-VHD -Times 0 -Exactly -Scope It
            Assert-MockCalled Dismount-VHD -Times 0 -Exactly -Scope It
        }

        It 'Honors WhatIf through the script entry point' {
            Save-CustomVhdxDrive -Drives $entries -ConfigPath $config
            Mock Get-VHD { [pscustomobject]@{ Attached = ($Path -eq 'E:\Test Drives\disabled.vhdx') } }
            $results = @(& $scriptPath -Action Sync -ConfigPath $config -WhatIf -Confirm:$false)
            $results.Count | Should Be 2
            $results[0].Action | Should Be 'Skipped'
            $results[1].Action | Should Be 'Skipped'
            Assert-MockCalled Mount-VHD -Times 0 -Exactly -Scope It
            Assert-MockCalled Dismount-VHD -Times 0 -Exactly -Scope It
        }

        It 'Preserves dot-sourced loading without opening the editor or syncing' {
            Save-CustomVhdxDrive -Drives $entries -ConfigPath $config
            . $scriptPath -ConfigPath $config
            $Drives.Count | Should Be 2
            $Drives[0].Path | Should Be $entries[0].Path
            $Drives[1].IsEnabled | Should Be $false
            Assert-MockCalled Get-VHD -Times 0 -Exactly -Scope It
            Assert-MockCalled Mount-VHD -Times 0 -Exactly -Scope It
            Assert-MockCalled Dismount-VHD -Times 0 -Exactly -Scope It
        }

        It 'Checks every image exists before changing any drive' {
            Mock Test-Path { $false } -ParameterFilter { $PathType -eq 'Leaf' -and $LiteralPath -eq 'E:\Test Drives\disabled.vhdx' }
            { Sync-CustomVhdxDrive -Drives $entries -Confirm:$false } | Should Throw 'file not found'
            Assert-MockCalled Get-VHD -Times 0 -Exactly -Scope It
            Assert-MockCalled Mount-VHD -Times 0 -Exactly -Scope It
            Assert-MockCalled Dismount-VHD -Times 0 -Exactly -Scope It
        }

        It 'Surfaces mount failures and stops subsequent changes' {
            Mock Mount-VHD { throw 'Mount failed' }
            { Sync-CustomVhdxDrive -Drives $entries -Confirm:$false } | Should Throw 'Mount failed'
            Assert-MockCalled Dismount-VHD -Times 0 -Exactly -Scope It
        }

        It 'Surfaces dismount failures' {
            Mock Dismount-VHD { throw 'Dismount failed' }
            { Sync-CustomVhdxDrive -Drives @($entries[1]) -Confirm:$false } | Should Throw 'Dismount failed'
        }

        It 'Rejects operations that do not reach the requested state' {
            Mock Mount-VHD {}
            { Sync-CustomVhdxDrive -Drives @($entries[0]) -Confirm:$false } | Should Throw 'attachment state'
        }

        It 'Saves checkbox changes through the graphical interface without applying them' {
            Save-CustomVhdxDrive -Drives $entries -ConfigPath $config
            Add-Type -AssemblyName System.Windows.Forms
            $timer = [System.Windows.Forms.Timer]::new()
            $timer.Interval = 200
            $timer.Add_Tick({
                $editor = [System.Windows.Forms.Application]::OpenForms |
                    Where-Object Text -eq 'Custom VHDX drive settings' | Select-Object -First 1
                if ($null -ne $editor) {
                    $this.Stop()
                    $editor.Controls['Drives'].SetItemChecked(0, $false)
                    $editor.Controls['Drives'].SetItemChecked(1, $true)
                    $editor.Controls['Save'].PerformClick()
                }
            })
            try {
                $timer.Start()
                $updated = @(Show-CustomVhdxDriveEditor -Drives $entries -ConfigPath $config)
            }
            finally {
                $timer.Dispose()
            }
            $updated[0].IsEnabled | Should Be $false
            $updated[1].IsEnabled | Should Be $true
            $loaded = @(Import-CustomVhdxDrive -ConfigPath $config)
            $loaded[0].IsEnabled | Should Be $false
            $loaded[1].IsEnabled | Should Be $true
            $entries[0].IsEnabled | Should Be $true
            Assert-MockCalled Mount-VHD -Times 0 -Exactly -Scope It
            Assert-MockCalled Dismount-VHD -Times 0 -Exactly -Scope It
        }

        It 'Discards checkbox changes when the graphical editor is cancelled' {
            Save-CustomVhdxDrive -Drives $entries -ConfigPath $config
            Add-Type -AssemblyName System.Windows.Forms
            $timer = [System.Windows.Forms.Timer]::new()
            $timer.Interval = 200
            $timer.Add_Tick({
                $editor = [System.Windows.Forms.Application]::OpenForms |
                    Where-Object Text -eq 'Custom VHDX drive settings' | Select-Object -First 1
                if ($null -ne $editor) {
                    $this.Stop()
                    $editor.Controls['Drives'].SetItemChecked(0, $false)
                    $editor.Controls['Cancel'].PerformClick()
                }
            })
            try {
                $timer.Start()
                $updated = @(Show-CustomVhdxDriveEditor -Drives $entries -ConfigPath $config)
            }
            finally {
                $timer.Dispose()
            }
            $updated[0].IsEnabled | Should Be $true
            $loaded = @(Import-CustomVhdxDrive -ConfigPath $config)
            $loaded[0].IsEnabled | Should Be $true
            $loaded[1].IsEnabled | Should Be $false
        }
    }
}
