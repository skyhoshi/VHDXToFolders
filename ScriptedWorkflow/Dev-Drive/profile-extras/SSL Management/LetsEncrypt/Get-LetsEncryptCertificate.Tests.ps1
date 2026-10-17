#Requires -Version 5.1
#Requires -Modules @{ ModuleName = 'Pester'; ModuleVersion = '4.10.1'; MaximumVersion = '4.999.999' }
# Offline tests: no Namecheap or ACME network calls and no service changes.
$targetScript = Join-Path $PSScriptRoot 'Get-LetsEncryptCertificate.ps1'

function Set-PAServer { param($DirectoryUrl) }
function New-PACertificate {
    param($Domain, $Name, $Contact, $AcceptTOS, $Plugin, $PluginArgs,
        $PfxPassSecure, $Install, $DnsSleep, $Force, $ErrorAction)
}
function Get-PACertificate { param($Name) }

Describe 'Get-LetsEncryptCertificate offline behavior' {
    BeforeEach {
        $script:runPath = Join-Path $TestDrive ([guid]::NewGuid().ToString())
        $null = New-Item -ItemType Directory -Path $script:runPath
        $script:exportPath = Join-Path $script:runPath 'exports'
        $script:options = @{
            NamecheapUsername = 'test-user'
            NamecheapApiKey = ConvertTo-SecureString 'fake-api-key' -AsPlainText -Force
            PfxPassword = ConvertTo-SecureString 'fake-pfx-password' -AsPlainText -Force
            AcceptTOS = $true
            OutputDirectory = $script:exportPath
            Confirm = $false
            WarningAction = 'SilentlyContinue'
        }
        $script:fakeCertificate = [pscustomobject]@{
            AllSANs = @('sorafamily.com', '*.sorafamily.com')
            NotAfter = (Get-Date).AddDays(60)
            Thumbprint = 'TEST-THUMBPRINT'
            CertFile = Join-Path $script:runPath 'cert.cer'
            ChainFile = Join-Path $script:runPath 'chain.cer'
            FullChainFile = Join-Path $script:runPath 'fullchain.cer'
            KeyFile = Join-Path $script:runPath 'cert.key'
            PfxFullChain = Join-Path $script:runPath 'fullchain.pfx'
        }
        foreach ($property in 'CertFile', 'ChainFile', 'FullChainFile', 'KeyFile', 'PfxFullChain') {
            Set-Content -LiteralPath $script:fakeCertificate.$property -Value "fixture-$property"
        }
        Mock Get-Module {
            [pscustomobject]@{ Version = [version]'4.30.0'; Path = 'offline-module.psd1' }
        } -ParameterFilter { $Name -eq 'Posh-ACME' }
        Mock Import-Module {}
        Mock Set-PAServer {}
        Mock New-PACertificate {}
        $global:LetsEncryptTestCertificate = $script:fakeCertificate
        Mock Get-PACertificate { $global:LetsEncryptTestCertificate }
        Mock Read-Host { throw 'Unexpected secret prompt' }
    }

    AfterAll {
        Remove-Variable -Name LetsEncryptTestCertificate -Scope Global
    }

    It 'Exports both PFX and PEM with the requested names and secure plugin arguments' {
        $result = & $targetScript @script:options
        $result.Server | Should Be 'LE_PROD'
        ($result.Domains -join ',') | Should Be 'sorafamily.com,*.sorafamily.com'
        $result.Thumbprint | Should Be 'TEST-THUMBPRINT'
        $result.IisInstalled | Should Be $false
        $result.NginxDeployed | Should Be $false
        (Get-Content -LiteralPath $result.CertificatePem) | Should Be 'fixture-CertFile'
        (Get-Content -LiteralPath $result.ChainPem) | Should Be 'fixture-ChainFile'
        (Get-Content -LiteralPath $result.FullChainPem) | Should Be 'fixture-FullChainFile'
        (Get-Content -LiteralPath $result.PrivateKeyPem) | Should Be 'fixture-KeyFile'
        (Get-Content -LiteralPath $result.Pfx) | Should Be 'fixture-PfxFullChain'
        ($result.PSObject.Properties.Name -contains 'PfxPassword') | Should Be $false
        ($result.PSObject.Properties.Name -contains 'NamecheapApiKey') | Should Be $false
        Assert-MockCalled New-PACertificate -Times 1 -Exactly -Scope It -ParameterFilter {
            $Plugin -eq 'Namecheap' -and $PluginArgs.NCUsername -eq 'test-user' -and
            $PluginArgs.NCApiKey -is [Security.SecureString] -and
            $PfxPassSecure -is [Security.SecureString] -and
            -not $Force -and -not $Install -and $Contact -eq 'skyacem@hotmail.com' -and $DnsSleep -eq 120
        }
    }

    It 'Reexports a cached certificate when issuance returns no new object' {
        $first = & $targetScript @script:options
        Set-Content -LiteralPath $script:fakeCertificate.KeyFile -Value 'updated-key-fixture'
        $second = & $targetScript @script:options
        $second.Thumbprint | Should Be $first.Thumbprint
        (Get-Content -LiteralPath $second.PrivateKeyPem) | Should Be 'updated-key-fixture'
        Assert-MockCalled Get-PACertificate -Times 2 -Exactly -Scope It
        Assert-MockCalled New-PACertificate -Times 2 -Exactly -Scope It -ParameterFilter { -not $Force }
    }

    It 'Isolates staging exports from production exports' {
        $production = & $targetScript @script:options
        $staging = & $targetScript @script:options -Staging
        $staging.OutputDirectory | Should Be (Join-Path $script:exportPath 'staging')
        $staging.Server | Should Be 'LE_STAGE'
        (Get-Content -LiteralPath $production.Pfx) | Should Be 'fixture-PfxFullChain'
        Assert-MockCalled Set-PAServer -Times 1 -Exactly -Scope It -ParameterFilter { $DirectoryUrl -eq 'LE_STAGE' }
    }

    It 'Does not perform issuance, prompts, or writes during WhatIf' {
        $null = & $targetScript @script:options -WhatIf
        (Test-Path -LiteralPath $script:exportPath) | Should Be $false
        Assert-MockCalled Import-Module -Times 0 -Exactly -Scope It
        Assert-MockCalled New-PACertificate -Times 0 -Exactly -Scope It
        Assert-MockCalled Read-Host -Times 0 -Exactly -Scope It
    }

    It 'Requires explicit agreement to the terms' {
        $script:options.AcceptTOS = $false
        { & $targetScript @script:options } | Should -Throw 'AcceptTOS'
        Assert-MockCalled New-PACertificate -Times 0 -Exactly -Scope It
    }

    It 'Rejects duplicate domains before issuance' {
        { & $targetScript @script:options -Domain 'sorafamily.com', 'SORAFAMILY.COM' } |
            Should -Throw 'duplicate'
        Assert-MockCalled New-PACertificate -Times 0 -Exactly -Scope It
    }

    It 'Rejects invalid certificate names before issuance' {
        { & $targetScript @script:options -Domain 'a.*.sorafamily.com' } |
            Should -Throw 'Invalid DNS'
        Assert-MockCalled New-PACertificate -Times 0 -Exactly -Scope It
    }

    It 'Rejects staging IIS deployment before module loading' {
        { & $targetScript @script:options -Staging -InstallIis -IisSiteName 'Family' -IisHostName 'www.sorafamily.com' } |
            Should -Throw 'cannot be deployed'
        Assert-MockCalled Import-Module -Times 0 -Exactly -Scope It
    }

    It 'Rejects staging nginx deployment before hook resolution' {
        { & $targetScript @script:options -Staging -NginxDeployScript 'missing.ps1' } |
            Should -Throw 'cannot be deployed'
        Assert-MockCalled New-PACertificate -Times 0 -Exactly -Scope It
    }

    It 'Rejects incomplete IIS options before issuance' {
        { & $targetScript @script:options -InstallIis } | Should -Throw 'requires'
        Assert-MockCalled New-PACertificate -Times 0 -Exactly -Scope It
    }

    It 'Rejects IIS parameters without opt-in' {
        { & $targetScript @script:options -IisSiteName 'Family' } | Should -Throw 'require -InstallIis'
        Assert-MockCalled New-PACertificate -Times 0 -Exactly -Scope It
    }

    It 'Surfaces the installation command when the dependency is absent' {
        Mock Get-Module {} -ParameterFilter { $Name -eq 'Posh-ACME' }
        { & $targetScript @script:options } | Should -Throw 'Install-Module Posh-ACME'
        Assert-MockCalled New-PACertificate -Times 0 -Exactly -Scope It
    }

    It 'Rejects empty secrets before issuance' {
        $script:options.PfxPassword = [Security.SecureString]::new()
        { & $targetScript @script:options } | Should -Throw 'nonempty SecureStrings'
        Assert-MockCalled New-PACertificate -Times 0 -Exactly -Scope It
    }

    It 'Passes Force only when deliberately requested' {
        $null = & $targetScript @script:options -Force -DnsSleepSeconds 300
        Assert-MockCalled New-PACertificate -Times 1 -Exactly -Scope It -ParameterFilter { $Force -and $DnsSleep -eq 300 }
    }

    It 'Propagates ACME failure without exporting an old certificate' {
        Mock New-PACertificate { throw 'ACME validation failed' }
        { & $targetScript @script:options } | Should -Throw 'ACME validation failed'
        (Test-Path -LiteralPath (Join-Path $script:exportPath 'privkey.pem')) | Should Be $false
        Assert-MockCalled Get-PACertificate -Times 0 -Exactly -Scope It
    }

    It 'Rejects expired certificates without exporting' {
        $script:fakeCertificate.NotAfter = (Get-Date).AddSeconds(-1)
        { & $targetScript @script:options } | Should -Throw 'unexpired'
        (Test-Path -LiteralPath (Join-Path $script:exportPath 'privkey.pem')) | Should Be $false
    }

    It 'Rejects a mismatched SAN set without exporting' {
        $script:fakeCertificate.AllSANs = @('*.sorafamily.com')
        { & $targetScript @script:options } | Should -Throw 'names do not match'
        (Test-Path -LiteralPath (Join-Path $script:exportPath 'privkey.pem')) | Should Be $false
    }

    It 'Rejects missing artifacts before writing any export' {
        Remove-Item -LiteralPath $script:fakeCertificate.KeyFile
        { & $targetScript @script:options } | Should -Throw 'missing or empty'
        (Test-Path -LiteralPath (Join-Path $script:exportPath 'cert.pem')) | Should Be $false
    }

    It 'Restricts the output ACL and removes explicit broad file access on rerun' {
        $first = & $targetScript @script:options
        $fileAcl = Get-Acl -LiteralPath $first.PrivateKeyPem
        $everyone = [Security.Principal.SecurityIdentifier]::new('S-1-1-0')
        $fileAcl.AddAccessRule([Security.AccessControl.FileSystemAccessRule]::new($everyone, 'Read', 'Allow'))
        Set-Acl -LiteralPath $first.PrivateKeyPem -AclObject $fileAcl
        $second = & $targetScript @script:options
        (Get-Acl -LiteralPath $second.OutputDirectory).AreAccessRulesProtected | Should Be $true
        $rules = (Get-Acl -LiteralPath $second.PrivateKeyPem).Access
        $actualSids = @($rules | ForEach-Object {
            $_.IdentityReference.Translate([Security.Principal.SecurityIdentifier]).Value
        } | Sort-Object -Unique)
        $expectedSids = @(
            [Security.Principal.WindowsIdentity]::GetCurrent().User.Value
            'S-1-5-18'
            'S-1-5-32-544'
        ) | Sort-Object -Unique
        ($actualSids -join ',') | Should Be ($expectedSids -join ',')
    }

    It 'Invokes the nginx hook with export paths and no secret properties' {
        $hook = Join-Path $script:runPath 'deploy.ps1'
        Set-Content -LiteralPath $hook -Value @'
param($Certificate)
if ($Certificate.PSObject.Properties.Name -contains 'PfxPassword') { throw 'Secret exposed' }
if (-not (Test-Path -LiteralPath $Certificate.FullChainPem)) { throw 'Missing chain' }
if (-not (Test-Path -LiteralPath $Certificate.PrivateKeyPem)) { throw 'Missing key' }
Set-Content -LiteralPath (Join-Path $Certificate.OutputDirectory 'hook.txt') -Value $Certificate.Thumbprint
'@
        $result = & $targetScript @script:options -NginxDeployScript $hook
        $result.NginxDeployed | Should Be $true
        (Get-Content -LiteralPath (Join-Path $result.OutputDirectory 'hook.txt')) | Should Be 'TEST-THUMBPRINT'
    }

    It 'Propagates a throwing nginx hook and retains exports for retry' {
        $hook = Join-Path $script:runPath 'deploy.ps1'
        Set-Content -LiteralPath $hook -Value "param(`$Certificate); throw 'Deployment failed'"
        { & $targetScript @script:options -NginxDeployScript $hook } | Should -Throw 'Deployment failed'
        (Get-Content -LiteralPath (Join-Path $script:exportPath 'fullchain.pem')) | Should Be 'fixture-FullChainFile'
    }

    It 'Fails when the nginx hook returns a nonzero native exit code' {
        $hook = Join-Path $script:runPath 'deploy.ps1'
        Set-Content -LiteralPath $hook -Value 'param($Certificate); & $env:ComSpec /c "exit 7"'
        { & $targetScript @script:options -NginxDeployScript $hook } | Should -Throw 'exit code 7'
    }
}
