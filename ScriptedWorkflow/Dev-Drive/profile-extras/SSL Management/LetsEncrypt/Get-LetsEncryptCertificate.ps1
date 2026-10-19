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
# SupportsShouldProcess provides -WhatIf/-Confirm; the explicit approval gate is below.
[CmdletBinding(SupportsShouldProcess, ConfirmImpact = 'Medium')]
param(
    [Parameter(Mandatory)]
    [ValidateNotNullOrEmpty()]
    [string]$NamecheapUsername,

    # SecureString avoids plaintext arguments; downstream consumers still need the secrets.
    [Security.SecureString]$NamecheapApiKey,
    [Security.SecureString]$PfxPassword,

    [ValidateNotNullOrEmpty()]
    # A wildcard covers one subdomain level, not the apex, so request both names.
    [string[]]$Domain = @('sorafamily.com', '*.sorafamily.com'),

    # This checks basic email syntax, not mailbox existence or deliverability.
    [ValidatePattern('^[^@\s]+@[^@\s]+\.[^@\s]+$')]
    [string]$Email = 'skyacem@hotmail.com',

    [ValidateNotNullOrEmpty()]
    [string]$OutputDirectory = (Join-Path $HOME '.certs\letsencrypt\sorafamily.com'),

    # Keep the persisted order identifier free of path separators and wildcard syntax.
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

# Fail on uninitialized variables and missing properties instead of silently using null.
Set-StrictMode -Version Latest
# Make normally nonterminating PowerShell errors abort this script as well.
$ErrorActionPreference = 'Stop'

function Test-CertificateHostName {
    param([string]$HostName, [string[]]$CertificateNames)

    foreach ($name in $CertificateNames) {
        if ($HostName -ieq $name) { return $true }
        if ($name.StartsWith('*.')) {
            # Retain the leading dot to prevent matching unrelated domain suffixes.
            $suffix = $name.Substring(1)
            if ($HostName.EndsWith($suffix, [StringComparison]::OrdinalIgnoreCase)) {
                $label = $HostName.Substring(0, $HostName.Length - $suffix.Length)
                # Only one nonempty label may replace '*'; nested subdomains do not match.
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
    # Allow an optional leftmost wildcard and ASCII DNS labels without edge hyphens.
    # This pattern checks label structure, not DNS ownership or actual resolution.
    if ($name -notmatch '^(?:\*\.)?(?:[A-Za-z0-9](?:[A-Za-z0-9-]{0,61}[A-Za-z0-9])?\.)+[A-Za-z]{2,63}$') {
        throw "Invalid DNS certificate name: '$name'. Use ASCII DNS names or punycode."
    }
}
# Array wrapping makes Count reliable even when only one unique name remains.
if (@($Domain | Sort-Object -Unique).Count -ne $Domain.Count) {
    throw 'Domain must not contain duplicate names.'
}
if ($Staging -and ($InstallIis -or $NginxDeployScript)) {
    # Test certificates must never replace trusted service certificates through this script.
    throw 'Staging certificates are untrusted and cannot be deployed by this script.'
}
if (-not $InstallIis -and ($IisSiteName -or $IisHostName)) {
    throw 'IIS site/hostname parameters require -InstallIis.'
}
if ($InstallIis -and (-not $IisSiteName -or -not $IisHostName)) {
    throw '-InstallIis requires -IisSiteName and at least one -IisHostName.'
}
if ($NginxDeployScript) {
    # Resolve the hook literally so wildcard characters cannot select a different script.
    $hook = Get-Item -LiteralPath $NginxDeployScript
    if ($hook.PSIsContainer -or $hook.Extension -ine '.ps1') {
        throw '-NginxDeployScript must identify an existing .ps1 file.'
    }
    $NginxDeployScript = $hook.FullName
}

# Resolve PowerShell-relative paths without requiring the output directory to exist yet.
$outputPath = $ExecutionContext.SessionState.Path.GetUnresolvedProviderPathFromPSPath($OutputDirectory)
if ($Staging) { $outputPath = Join-Path $outputPath 'staging' }
$server = if ($Staging) { 'LE_STAGE' } else { 'LE_PROD' }
# Declining approval or using -WhatIf returns before module loading, secrets, or writes.
# Input validation and deployment-hook path inspection above still occur.
if (-not $PSCmdlet.ShouldProcess(
    "$($Domain -join ', ') [$server]",
    "Issue/reuse/renew via Namecheap, export to '$outputPath', and run opted-in deployments"
)) { return }

$iisBindings = @()
if ($InstallIis) {
    # WebAdministration's binding objects are used directly, not through PS7 remoting proxies.
    if ($PSVersionTable.PSEdition -ne 'Desktop') {
        throw 'For IIS installation, rerun using elevated Windows PowerShell 5.1 (powershell.exe).'
    }
    $identity = [Security.Principal.WindowsIdentity]::GetCurrent()
    $principal = [Security.Principal.WindowsPrincipal]::new($identity)
    # Check the active security token; unelevated administrator membership is insufficient.
    if (-not $principal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
        throw '-InstallIis requires an elevated Windows PowerShell session.'
    }
    Import-Module WebAdministration -ErrorAction Stop
    $sites = @(Get-Website | Where-Object { $_.Name -eq $IisSiteName })
    if ($sites.Count -ne 1) { throw "IIS site '$IisSiteName' was not found." }
    foreach ($hostName in @($IisHostName | Sort-Object -Unique)) {
        # Require concrete covered hostnames rather than binding IIS to the certificate wildcard.
        if ($hostName -notmatch '^(?:[A-Za-z0-9](?:[A-Za-z0-9-]{0,61}[A-Za-z0-9])?\.)+[A-Za-z]{2,63}$' -or
            -not (Test-CertificateHostName $hostName $Domain)) {
            throw "IIS hostname '$hostName' must be a concrete hostname covered by Domain."
        }
        $matches = @($sites[0].Bindings.Collection | Where-Object {
            # Match any IP address, but only this hostname's HTTPS port 443 binding.
            $_.protocol -eq 'https' -and $_.bindingInformation -like "*:443:$hostName"
        })
        if ($matches.Count -ne 1) {
            throw "Expected exactly one existing HTTPS port 443 binding for '$hostName' on '$IisSiteName'."
        }
        # sslFlags is a bitmask: bit 1 enables SNI; bit 2 enables Central Certificate Store.
        # Require SNI and reject CCS without rejecting unrelated flag bits.
        if (([int]$matches[0].sslFlags -band 1) -eq 0 -or ([int]$matches[0].sslFlags -band 2) -ne 0) {
            throw "Binding '$hostName' must use SNI without Central Certificate Store."
        }
        $iisBindings += $matches[0]
    }
}

# Select the newest installed 4.x implementation; do not assume a future major is compatible.
$module = Get-Module -ListAvailable -Name Posh-ACME |
    Where-Object { $_.Version.Major -eq 4 } |
    Sort-Object Version -Descending | Select-Object -First 1
if (-not $module) {
    throw "Posh-ACME 4.x is required. Install it explicitly: Install-Module Posh-ACME -Scope CurrentUser -MaximumVersion '4.999.999'"
}
Import-Module -Name $module.Path -ErrorAction Stop

# Prompt only for omitted values, then reject empty secrets before contacting the CA.
if (-not $NamecheapApiKey) { $NamecheapApiKey = Read-Host 'Namecheap API key' -AsSecureString }
if (-not $PfxPassword) { $PfxPassword = Read-Host 'Password for exported PFX (nonempty)' -AsSecureString }
if ($NamecheapApiKey.Length -eq 0 -or $PfxPassword.Length -eq 0) {
    throw 'NamecheapApiKey and PfxPassword must be nonempty SecureStrings.'
}

$null = New-Item -ItemType Directory -Path $outputPath -Force
$acl = Get-Acl -LiteralPath $outputPath
# Disable parent-directory permission inheritance without copying inherited access rules.
$acl.SetAccessRuleProtection($true, $false)
# Remove remaining explicit rules so an existing output folder cannot retain broad access.
foreach ($rule in @($acl.Access)) {
    $null = $acl.RemoveAccessRuleSpecific($rule)
}
# Use stable SIDs rather than localized account/group display names.
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
    # Apply full control to the directory and propagate it to child folders and files.
    # These rules identify allowed principals; they do not grant other services key access.
    $rule = [Security.AccessControl.FileSystemAccessRule]::new(
        $sid, 'FullControl', 'ContainerInherit, ObjectInherit', 'None', 'Allow'
    )
    $acl.AddAccessRule($rule)
}
# Persist only modified access-control sections, not audit policy.
# .NET Framework exposes instance methods; modern .NET uses FileSystemAclExtensions.
if ($PSVersionTable.PSEdition -eq 'Desktop') {
    [IO.DirectoryInfo]::new($outputPath).SetAccessControl($acl)
} else {
    [IO.FileSystemAclExtensions]::SetAccessControl([IO.DirectoryInfo]::new($outputPath), $acl)
}

Write-Warning 'Namecheap must host authoritative DNS, have API access enabled, and allowlist your public IPv4. Back up DNS records; avoid concurrent runs or zone edits.'
# Select the staging/production ACME server while retaining Posh-ACME's persisted state.
Set-PAServer -DirectoryUrl $server | Out-Null
$request = @{
    Domain = $Domain
    Name = $OrderName
    Contact = $Email
    AcceptTOS = $true
    Plugin = 'Namecheap'
    # These key names are defined by Posh-ACME's Namecheap DNS plugin.
    PluginArgs = @{ NCUsername = $NamecheapUsername; NCApiKey = $NamecheapApiKey }
    PfxPassSecure = $PfxPassword
    # Keep issuance/export separate from the explicitly opted-in IIS deployment below.
    Install = $false
    DnsSleep = $DnsSleepSeconds
    Force = $Force.IsPresent
    ErrorAction = 'Stop'
}
# New-PACertificate reuses completed orders before their renewal window and resumes
# pending orders; explicitly retrieve the certificate even when no new one is issued.
# Invalid/expired orders or changed request settings may also require a new order.
# Hashtable splatting passes each request entry as a named cmdlet parameter.
$null = New-PACertificate @request
$certificate = Get-PACertificate -Name $OrderName
if (-not $certificate -or $certificate.NotAfter -le (Get-Date)) {
    throw 'ACME did not produce a usable, unexpired certificate. Nothing was deployed.'
}
# Compare the complete SAN sets, independent of order; any missing/extra name is an error.
if (@(Compare-Object -ReferenceObject @($Domain | Sort-Object) -DifferenceObject @($certificate.AllSANs | Sort-Object)).Count) {
    throw 'The returned certificate names do not match Domain. Nothing was deployed.'
}

# Posh-ACME's .cer files here are PEM-encoded; export conventional nginx-friendly names.
# The full-chain PFX includes the private key, leaf certificate, and issuer chain.
$exports = [ordered]@{
    'cert.pem' = $certificate.CertFile
    'chain.pem' = $certificate.ChainFile
    'fullchain.pem' = $certificate.FullChainFile
    'privkey.pem' = $certificate.KeyFile
    'fullchain.pfx' = $certificate.PfxFullChain
}
foreach ($source in $exports.Values) {
    # Validate every source before copying; existence/size checks are not cryptographic validation.
    if (-not (Test-Path -LiteralPath $source -PathType Leaf) -or (Get-Item -LiteralPath $source).Length -eq 0) {
        throw "Required certificate artifact is missing or empty: '$source'. Nothing was deployed."
    }
}
foreach ($fileName in $exports.Keys) {
    # Files are replaced individually, not as an atomic certificate/key transaction.
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

# Expose metadata and paths, not passwords or key contents; the referenced key is sensitive.
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
    # Import into the machine Personal store, then update only the validated bindings.
    $null = Import-PfxCertificate -FilePath $result.Pfx -Password $PfxPassword -CertStoreLocation 'Cert:\LocalMachine\My'
    foreach ($binding in $iisBindings) {
        $binding.AddSslCertificate($result.Thumbprint, 'My')
    }
    $result.IisInstalled = $true
}
if ($NginxDeployScript) {
    # Native programs report through LASTEXITCODE; reset it to avoid stale failures.
    # The hook must still check intermediate native commands, not just its final command.
    $global:LASTEXITCODE = 0
    # Execute the configured hook even for reused certificates to support deployment retries.
    $null = & $NginxDeployScript -Certificate $result
    if ($global:LASTEXITCODE -ne 0) {
        throw "nginx deployment hook failed with exit code $global:LASTEXITCODE. Exports remain at '$outputPath'."
    }
    $result.NginxDeployed = $true
}
# Emit one structured result only after all requested deployments have succeeded.
$result