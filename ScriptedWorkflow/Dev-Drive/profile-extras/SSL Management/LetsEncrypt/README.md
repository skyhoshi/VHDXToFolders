# Let's Encrypt for sorafamily.com

`Get-LetsEncryptCertificate.ps1` requests a certificate for **sorafamily.com**
and **\*.sorafamily.com** using Posh-ACME's Namecheap DNS-01 plugin. It exports
both PEM and password-protected PFX files. Installation is opt-in.

## Prerequisites

- Windows PowerShell 5.1 or PowerShell 7 on Windows. Local IIS installation
  specifically requires **elevated Windows PowerShell 5.1**.
- Honor your execution policy. If it requires signed scripts, have this script
  and any deployment hook signed through your approved code-signing workflow.
- Namecheap must actually host the authoritative DNS, not just be the registrar.
  Enable API access in Namecheap's **Profile > Tools > Business & Dev Tools**.
  Namecheap may require account eligibility or support approval.
- Allowlist the issuing machine's **public IPv4** in Namecheap API settings.
  Recheck after changing networks or public IP addresses.
- Obtain the Namecheap username and API key. Do not put the API key or PFX
  password in the script, shell history, source control, or deployment hook.
- Review the [Let's Encrypt terms](https://letsencrypt.org/repository/) before
  using `-AcceptTOS`.
- Install the dependency explicitly (the script never installs software):

  ```powershell
  Install-Module Posh-ACME -Scope CurrentUser -MaximumVersion '4.999.999'
  ```

No inbound port 80 or 443 is required for DNS validation. Outbound HTTPS and
working DNS resolution are required. The plugin also queries api.ipify.org to
discover the public IP supplied to Namecheap.

**Back up the DNS zone before first use.** Namecheap's API/plugin updates the
whole record set when adding/removing the ACME TXT record. Do not edit the zone
or run other DNS automation concurrently. A staging test still changes real DNS.
After an interrupted attempt, check for leftover `_acme-challenge` TXT records.

## First test, then production

Run from this directory:

```powershell
.\Get-LetsEncryptCertificate.ps1 -NamecheapUsername 'YOUR_NAMECHEAP_USERNAME' `
    -AcceptTOS -Staging

.\Get-LetsEncryptCertificate.ps1 -NamecheapUsername 'YOUR_NAMECHEAP_USERNAME' `
    -AcceptTOS
```

Both commands securely prompt for the API key and a nonempty PFX password.
For multiple invocations in one session, supply SecureStrings:

```powershell
$options = @{
    NamecheapUsername = 'YOUR_NAMECHEAP_USERNAME'
    NamecheapApiKey = Read-Host 'Namecheap API key' -AsSecureString
    PfxPassword = Read-Host 'PFX password' -AsSecureString
    AcceptTOS = $true
}
.\Get-LetsEncryptCertificate.ps1 @options
```

The account email defaults to `skyacem@hotmail.com`; override with `-Email`.
Override names with `-Domain 'sorafamily.com','*.sorafamily.com'`. A wildcard
does not cover the apex or multi-level names such as `a.b.sorafamily.com`.
Use a different `-OrderName` for a distinct certificate configuration.

`-WhatIf` previews intent without importing modules, prompting for secrets,
contacting services, writing files, or deploying.

## Exports and repeat runs

Production defaults to `$HOME\.certs\letsencrypt\sorafamily.com`; override with
`-OutputDirectory`. Staging uses a `staging` subdirectory and cannot be deployed
by the script. Staging certificates are **not trusted**.

| File | Contents/use |
| --- | --- |
| `cert.pem` | Leaf certificate |
| `chain.pem` | Issuer chain |
| `fullchain.pem` | Leaf plus issuer chain; nginx `ssl_certificate` |
| `privkey.pem` | **Unencrypted private key**; nginx `ssl_certificate_key` |
| `fullchain.pfx` | Password-protected certificate, key, and chain; IIS/import |

The script restricts the output directory and exported files to the current
Windows user, SYSTEM, and local Administrators. Use a dedicated output directory:
its existing access rules are replaced. Non-NTFS/ACL-incompatible destinations
will fail rather than silently export an exposed private key.

Posh-ACME separately persists accounts, private keys, orders, and protected DNS
credentials in its user-profile state (normally `%LOCALAPPDATA%\Posh-ACME` on
Windows, unless `POSHACME_HOME` is set). Protect and back up that directory too.
Do not place either directory in source control or unprotected cloud storage.

Rerun the same production command **as the same Windows user**, with the same
order name and domain list, regularly (preferably daily). Posh-ACME reuses the
existing certificate before its renewal window and issues a replacement when
due; exports and opted-in deployments run either way. The supplied PFX password
also applies when re-exporting an existing certificate. Do not rely on email
expiration reminders. No scheduler is created.

Avoid `-Force` except for deliberate recovery/testing: it requests reissuance
even when not due and can consume Let's Encrypt rate limits. If DNS propagation
is slow, increase `-DnsSleepSeconds` (default 120).

The script selects the current/default Posh-ACME account for the chosen
production or staging server; Posh-ACME can select/create an account matching
the supplied email. Use a dedicated user/profile if other ACME automation
shares this machine. Do not run this script concurrently.

## Optional local IIS installation

First create the desired website and HTTPS port 443 bindings in IIS. Each
target binding must have a **concrete hostname**, **SNI enabled**, and
**Central Certificate Store disabled**. The script intentionally does not
create bindings or change routing.

From elevated **Windows PowerShell 5.1** with WebAdministration installed:

```powershell
.\Get-LetsEncryptCertificate.ps1 @options -InstallIis `
    -IisSiteName 'Family' -IisHostName 'sorafamily.com','www.sorafamily.com'
```

The script imports the PFX into `LocalMachine\My`, then attaches it only to those
bindings. It leaves old certificates in place for other consumers/rollback and
does not restart IIS. Repeat separately for other sites. Remote IIS is not
modified. Importing requires the same PFX password used for export.

## Optional nginx deployment

Provide an existing PowerShell hook using `-NginxDeployScript 'C:\Deploy\Update-Nginx.ps1'`.
The hook receives one parameter:

```powershell
param([Parameter(Mandatory)][psobject]$Certificate)
$ErrorActionPreference = 'Stop'
# Use $Certificate.FullChainPem and $Certificate.PrivateKeyPem as sources.
# Copy securely to your nginx host, test configuration, then reload.
# Throw on every failed operation; check $LASTEXITCODE after native commands.
```

The hook is intentionally user-configured because local Windows, WSL, and remote
Linux require different destinations, permissions, credentials, and service
commands. Configure nginx's `ssl_certificate` with the full chain and
`ssl_certificate_key` with the key. For a remote host, use authenticated SSH/SFTP;
stage both files, set restrictive key permissions (for example root-owned 0600),
install them together, run `nginx -t`, and only then reload nginx. Retain a
rollback copy. A service account reading local Windows exports must be granted
access in a separate deployment directory by the hook.

The hook runs even when the certificate was reused, permitting deployment
retries without forcing issuance. PowerShell errors or a final nonzero native
exit code fail the invocation. If both IIS and nginx are selected, IIS is updated
first; there is no cross-service rollback. Exports remain available on deployment
failure. Never treat successful export as proof that a service is serving the
certificate: verify the live TLS endpoint after deployment.

## References

- [Posh-ACME Namecheap setup](https://poshac.me/docs/v4/Plugins/Namecheap/)
- [New-PACertificate reuse and issuance](https://poshac.me/docs/v4/Functions/New-PACertificate/)
- [Namecheap API introduction](https://www.namecheap.com/support/api/intro/)

## Offline validation

The accompanying `Get-LetsEncryptCertificate.Tests.ps1` requires Pester 4.10.1
(4.x syntax). Run in PowerShell 7 after loading that version:

```powershell
Import-Module Pester -RequiredVersion 4.10.1
Invoke-Pester -Script .\Get-LetsEncryptCertificate.Tests.ps1
```

The tests mock ACME and DNS calls and use temporary fixture files. They verify
export contents, reuse, staging separation, ACL restriction, parameter/error
handling, and nginx hook invocation/failures without issuing a real certificate.
They do not prove Namecheap account eligibility, live DNS validation, PFX
cryptography, or installation into a running IIS/nginx service. Use the staging
command to validate real issuance, then verify live endpoints after deployment.
