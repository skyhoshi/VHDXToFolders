function BindingUpdate($site, $bindingUrl)
{
    Write-Host "name $bindingUrl"
    $guid = [guid]::NewGuid().ToString("B")
    try{
        $ErrorActionPreference = "Stop";
        Remove-WebBinding -name $site -Protocol https -HostHeader $bindingUrl -Port 443
    }
    catch{
        "Failed to Remove-WebBinding $_. Binding does not exist."
    }
    finally{
        $ErrorActionPreference = "Continue";
    }
    netsh http delete sslcert hostnameport=$($bindingUrl):443
    netsh http add sslcert hostnameport=$($bindingUrl):443 certhash=$thumbprint certstorename=MY appid="$guid"
    New-WebBinding -name $site -Protocol https -HostHeader $bindingUrl -Port 443 -SSlFlags 1
}
function ProcessBinding($site, $binding)
{
    Write-Host "binding $binding"
    $bindingInformation = $($binding.bindingInformation)
    
    $parts = $bindingInformation.split(':')
    $url = $parts[2]
    if ($url)
    {
        BindingUpdate $site $url
    }
    else
    {
        Write-Host "Not updating $bindingInformation"
    }
}
function ProcessSite($site)
{
    Write-Host "Site $site"
    $bindings = Get-IISSiteBinding $site.Name -Protocol "https"
    $bindings | ForEach-Object { ProcessBinding $site $_ }
}
$subject="*.fcsamerica.com"
$subjectAlternateNames="*.fcsamerica.com", "fcsamerica.com", "*.fcsamerica.net", "fcsamerica.net"
$friendlyName="Local Development FCSAmerica Wildcard 2024"
$exportImportPath="C:\certificate.rotation.cer"
$cert = New-SelfSignedCertificate -Subject $subject -DnsName $subjectAlternateNames -CertStoreLocation Cert:\LocalMachine\My -NotAfter $([datetime]::now.AddYears(5)) -FriendlyName $friendlyName
Export-Certificate -FilePath $exportImportPath -Cert $cert
Import-Certificate -CertStoreLocation 'Cert:\LocalMachine\Root' -FilePath $exportImportPath
$thumbprint = $cert.Thumbprint
$sites = get-iissite
$sites | ForEach-Object { ProcessSite $_ }