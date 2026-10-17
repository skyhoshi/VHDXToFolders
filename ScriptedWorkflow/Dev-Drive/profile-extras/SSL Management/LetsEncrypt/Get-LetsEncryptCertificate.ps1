#Requires -Version 5.1
<#
.SYNOPSIS
Issues, reuses, or renews a Let's Encrypt certificate using Namecheap DNS.
.DESCRIPTION
Exports password-protected PFX and PEM files. Defaults to sorafamily.com and
*.sorafamily.com. Posh-ACME retains account/order state under the current user's
profile. Rerun as that same user; a new certificate is requested only when due,
unless -Force is supplied. No scheduled task is created.

Requires Posh-ACME 4.x, Namecheap authoritative DNS, enabled Namecheap API access,
and an allowlisted public IPv4 address. No inbound HTTP port is needed.
Use -AcceptTOS only after reviewing https://letsencrypt.org/repository/.

PEM private keys are unencrypted. Output directory access is restricted to the
current user, local Administrators, and SYSTEM. Protect Posh-ACME's state too.
Do not run concurrently or edit the DNS zone during validation.
.PARAMETER NamecheapUsername
Namecheap account username. Never pass an API key as this parameter.
.PARAMETER NamecheapApiKey
Namecheap API key as a SecureString. Prompts securely when omitted.
.PARAMETER PfxPassword
Nonempty PFX password as a SecureString. Prompts securely when omitted.
.PARAMETER Staging
Uses Let's Encrypt staging and OutputDirectory\staging. Certificates are untrusted;
IIS and nginx deployment are prohibited.
.PARAMETER InstallIis
Updates only the specified, pre-existing local IIS HTTPS SNI bindings on port 443.
Requires elevated Windows PowerShell 5.1 and WebAdministration. Never creates
bindings, changes routing, or deletes old certificates.
.PARAMETER NginxDeployScript
An existing PowerShell deployment script, invoked with -Certificate <object>.
The object contains export paths, domains, thumbprint, and expiry, but no secrets.
The hook must securely deploy FullChainPem and PrivateKeyPem, run nginx -t,
and reload only after validation. It must throw on failure and check native exit
codes. It runs on every successful invocation, even when renewal is not due.
.EXAMPLE
.\Get-LetsEncryptCertificate.ps1 -NamecheapUsername 'your-account' -AcceptTOS -Staging
.EXAMPLE
.\Get-LetsEncryptCertificate.ps1 -NamecheapUsername 'your-account' -AcceptTOS
.EXAMPLE
.\Get-LetsEncryptCertificate.ps1 -NamecheapUsername 'your-account' -AcceptTOS `
    -InstallIis -IisSiteName 'Family' -IisHostName 'sorafamily.com','www.sorafamily.com'
#>
[CmdletBinding(SupportsShouldProcess, ConfirmImpact = 'Medium')]
param(
    [Parameter(Mandatory)]
    [ValidateNotNullOrEmpty()]
    [string]$NamecheapUsername,

    [Security.SecureString]$NamecheapApiKey,
    [Security.SecureString]$PfxPassword,

    [ValidateNotNullOrEmpty()]
    [string[]]$Domain = @('sorafamily.com', '*.sorafamily.com'),

    [ValidatePattern('^[^@\s]+@[^@\s]+\.[^@\s]+$')]
    [string]$Email = 'skyacem@hotmail.com',

    [ValidateNotNullOrEmpty()]
    [string]$OutputDirectory = (Join-Path $HOME '.certs\letsencrypt\sorafamily.com'),

    [ValidatePattern('^[A-Za-z0-9][A-Za-z0-9._-]*$')]
    [string]$OrderName = 'sorafamily.com-wildcard',

    [ValidateRange(30, 3600)]
    [int]$DnsSleepSeconds = 120,

    [switch]$AcceptTOS,
    [switch]$Staging,
    [switch]$Force,
    [switch]$InstallIis,
    [string]$IisSiteName,
    [string[]]$IisHostName,
    [string]$NginxDeployScript
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

function Test-CertificateHostName {
    param([string]$HostName, [string[]]$CertificateNames)

    foreach ($name in $CertificateNames) {
        if ($HostName -ieq $name) { return $true }
        if ($name.StartsWith('*.')) {
            $suffix = $name.Substring(1)
            if ($HostName.EndsWith($suffix, [StringComparison]::OrdinalIgnoreCase)) {
                $label = $HostName.Substring(0, $HostName.Length - $suffix.Length)
                if ($label.Length -gt 0 -and -not $label.Contains('.')) { return $true }
            }
        }
    }
    return $false
}

if ([Environment]::OSVersion.Platform -ne [PlatformID]::Win32NT) {
    throw 'This script targets Windows. Use Posh-ACME directly for other platforms.'
}
if (-not $AcceptTOS) {
    throw 'Review https://letsencrypt.org/repository/ and supply -AcceptTOS to consent.'
}
foreach ($name in $Domain) {
    if ($name -notmatch '^(?:\*\.)?(?:[A-Za-z0-9](?:[A-Za-z0-9-]{0,61}[A-Za-z0-9])?\.)+[A-Za-z]{2,63}$') {
        throw "Invalid DNS certificate name: '$name'. Use ASCII DNS names or punycode."
    }
}
if (@($Domain | Sort-Object -Unique).Count -ne $Domain.Count) {
    throw 'Domain must not contain duplicate names.'
}
if ($Staging -and ($InstallIis -or $NginxDeployScript)) {
    throw 'Staging certificates are untrusted and cannot be deployed by this script.'
}
if (-not $InstallIis -and ($IisSiteName -or $IisHostName)) {
    throw 'IIS site/hostname parameters require -InstallIis.'
}
if ($InstallIis -and (-not $IisSiteName -or -not $IisHostName)) {
    throw '-InstallIis requires -IisSiteName and at least one -IisHostName.'
}
if ($NginxDeployScript) {
    $hook = Get-Item -LiteralPath $NginxDeployScript
    if ($hook.PSIsContainer -or $hook.Extension -ine '.ps1') {
        throw '-NginxDeployScript must identify an existing .ps1 file.'
    }
    $NginxDeployScript = $hook.FullName
}

$outputPath = $ExecutionContext.SessionState.Path.GetUnresolvedProviderPathFromPSPath($OutputDirectory)
if ($Staging) { $outputPath = Join-Path $outputPath 'staging' }
$server = if ($Staging) { 'LE_STAGE' } else { 'LE_PROD' }
if (-not $PSCmdlet.ShouldProcess(
    "$($Domain -join ', ') [$server]",
    "Issue/reuse/renew via Namecheap, export to '$outputPath', and run opted-in deployments"
)) { return }

$iisBindings = @()
if ($InstallIis) {
    if ($PSVersionTable.PSEdition -ne 'Desktop') {
        throw 'For IIS installation, rerun using elevated Windows PowerShell 5.1 (powershell.exe).'
    }
    $identity = [Security.Principal.WindowsIdentity]::GetCurrent()
    $principal = [Security.Principal.WindowsPrincipal]::new($identity)
    if (-not $principal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
        throw '-InstallIis requires an elevated Windows PowerShell session.'
    }
    Import-Module WebAdministration -ErrorAction Stop
    $sites = @(Get-Website | Where-Object { $_.Name -eq $IisSiteName })
    if ($sites.Count -ne 1) { throw "IIS site '$IisSiteName' was not found." }
    foreach ($hostName in @($IisHostName | Sort-Object -Unique)) {
        if ($hostName -notmatch '^(?:[A-Za-z0-9](?:[A-Za-z0-9-]{0,61}[A-Za-z0-9])?\.)+[A-Za-z]{2,63}$' -or
            -not (Test-CertificateHostName $hostName $Domain)) {
            throw "IIS hostname '$hostName' must be a concrete hostname covered by Domain."
        }
        $matches = @($sites[0].Bindings.Collection | Where-Object {
            $_.protocol -eq 'https' -and $_.bindingInformation -like "*:443:$hostName"
        })
        if ($matches.Count -ne 1) {
            throw "Expected exactly one existing HTTPS port 443 binding for '$hostName' on '$IisSiteName'."
        }
        if (([int]$matches[0].sslFlags -band 1) -eq 0 -or ([int]$matches[0].sslFlags -band 2) -ne 0) {
            throw "Binding '$hostName' must use SNI without Central Certificate Store."
        }
        $iisBindings += $matches[0]
    }
}

$module = Get-Module -ListAvailable -Name Posh-ACME |
    Where-Object { $_.Version.Major -eq 4 } |
    Sort-Object Version -Descending | Select-Object -First 1
if (-not $module) {
    throw "Posh-ACME 4.x is required. Install it explicitly: Install-Module Posh-ACME -Scope CurrentUser -MaximumVersion '4.999.999'"
}
Import-Module -Name $module.Path -ErrorAction Stop

if (-not $NamecheapApiKey) { $NamecheapApiKey = Read-Host 'Namecheap API key' -AsSecureString }
if (-not $PfxPassword) { $PfxPassword = Read-Host 'Password for exported PFX (nonempty)' -AsSecureString }
if ($NamecheapApiKey.Length -eq 0 -or $PfxPassword.Length -eq 0) {
    throw 'NamecheapApiKey and PfxPassword must be nonempty SecureStrings.'
}

$null = New-Item -ItemType Directory -Path $outputPath -Force
$acl = Get-Acl -LiteralPath $outputPath
$acl.SetAccessRuleProtection($true, $false)
foreach ($rule in @($acl.Access)) {
    $null = $acl.RemoveAccessRuleSpecific($rule)
}
$currentUser = [Security.Principal.WindowsIdentity]::GetCurrent().User
$allowedSids = @(
    $currentUser,
    <#
    S-1-5-18 identifies Local System (SYSTEM), the highly privileged account used by Windows and many system services. S-1-5-32-544 identifies the local Administrators group—not one particular administrator account.
    #>
    [Security.Principal.SecurityIdentifier]::new('S-1-5-18'),
    [Security.Principal.SecurityIdentifier]::new('S-1-5-32-544')
)
foreach ($sid in $allowedSids) {
    $rule = [Security.AccessControl.FileSystemAccessRule]::new(
        $sid, 'FullControl', 'ContainerInherit, ObjectInherit', 'None', 'Allow'
    )
    $acl.AddAccessRule($rule)
}
# Persist only modified access-control sections, not audit policy.
if ($PSVersionTable.PSEdition -eq 'Desktop') {
    [IO.DirectoryInfo]::new($outputPath).SetAccessControl($acl)
} else {
    [IO.FileSystemAclExtensions]::SetAccessControl([IO.DirectoryInfo]::new($outputPath), $acl)
}

Write-Warning 'Namecheap must host authoritative DNS, have API access enabled, and allowlist your public IPv4. Back up DNS records; avoid concurrent runs or zone edits.'
Set-PAServer -DirectoryUrl $server | Out-Null
$request = @{
    Domain = $Domain
    Name = $OrderName
    Contact = $Email
    AcceptTOS = $true
    Plugin = 'Namecheap'
    PluginArgs = @{ NCUsername = $NamecheapUsername; NCApiKey = $NamecheapApiKey }
    PfxPassSecure = $PfxPassword
    Install = $false
    DnsSleep = $DnsSleepSeconds
    Force = $Force.IsPresent
    ErrorAction = 'Stop'
}
# New-PACertificate reuses completed orders before their renewal window and resumes
# pending orders; explicitly retrieve the certificate even when no new one is issued.
$null = New-PACertificate @request
$certificate = Get-PACertificate -Name $OrderName
if (-not $certificate -or $certificate.NotAfter -le (Get-Date)) {
    throw 'ACME did not produce a usable, unexpired certificate. Nothing was deployed.'
}
if (@(Compare-Object -ReferenceObject @($Domain | Sort-Object) -DifferenceObject @($certificate.AllSANs | Sort-Object)).Count) {
    throw 'The returned certificate names do not match Domain. Nothing was deployed.'
}

$exports = [ordered]@{
    'cert.pem' = $certificate.CertFile
    'chain.pem' = $certificate.ChainFile
    'fullchain.pem' = $certificate.FullChainFile
    'privkey.pem' = $certificate.KeyFile
    'fullchain.pfx' = $certificate.PfxFullChain
}
foreach ($source in $exports.Values) {
    if (-not (Test-Path -LiteralPath $source -PathType Leaf) -or (Get-Item -LiteralPath $source).Length -eq 0) {
        throw "Required certificate artifact is missing or empty: '$source'. Nothing was deployed."
    }
}
foreach ($fileName in $exports.Keys) {
    $destination = Join-Path $outputPath $fileName
    Copy-Item -LiteralPath $exports[$fileName] -Destination $destination -Force
    # Remove explicit permissions from pre-existing files as well as inheriting
    # the restricted directory permissions for newly exported private keys.
    $fileAcl = Get-Acl -LiteralPath $destination
    $fileAcl.SetAccessRuleProtection($false, $false)
    foreach ($rule in @($fileAcl.Access | Where-Object { -not $_.IsInherited })) {
        $null = $fileAcl.RemoveAccessRuleSpecific($rule)
    }
    if ($PSVersionTable.PSEdition -eq 'Desktop') {
        [IO.FileInfo]::new($destination).SetAccessControl($fileAcl)
    } else {
        [IO.FileSystemAclExtensions]::SetAccessControl([IO.FileInfo]::new($destination), $fileAcl)
    }
}

$result = [pscustomobject]@{
    Domains = $Domain
    Server = $server
    Thumbprint = $certificate.Thumbprint
    NotAfter = $certificate.NotAfter
    OutputDirectory = $outputPath
    CertificatePem = Join-Path $outputPath 'cert.pem'
    ChainPem = Join-Path $outputPath 'chain.pem'
    FullChainPem = Join-Path $outputPath 'fullchain.pem'
    PrivateKeyPem = Join-Path $outputPath 'privkey.pem'
    Pfx = Join-Path $outputPath 'fullchain.pfx'
    IisInstalled = $false
    NginxDeployed = $false
}
if ($InstallIis) {
    $null = Import-PfxCertificate -FilePath $result.Pfx -Password $PfxPassword -CertStoreLocation 'Cert:\LocalMachine\My'
    foreach ($binding in $iisBindings) {
        $binding.AddSslCertificate($result.Thumbprint, 'My')
    }
    $result.IisInstalled = $true
}
if ($NginxDeployScript) {
    $global:LASTEXITCODE = 0
    $null = & $NginxDeployScript -Certificate $result
    if ($global:LASTEXITCODE -ne 0) {
        throw "nginx deployment hook failed with exit code $global:LASTEXITCODE. Exports remain at '$outputPath'."
    }
    $result.NginxDeployed = $true
}
$result