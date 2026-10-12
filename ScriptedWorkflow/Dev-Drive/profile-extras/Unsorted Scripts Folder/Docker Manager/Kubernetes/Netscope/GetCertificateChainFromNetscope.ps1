Write-Host "Loading MiniCube NetScope Certificate Methods... " 
. "C:\Users\kernm\OneDrive - Farm Credit Services of America\Documents\PowerShell\Scripts\listmethodsinps1file.ps1"
function New-MinicubeNetScopeCerts {
    $netscopeCertStore = "~/.fcsamerica/k8s/certificates/netscope"
    New-Item -Path "$netscopeCertStore" -ItemType Directory -ErrorAction Ignore
    Set-Location $netscopeCertStore
    ######################################################################################################################################
    $uri = 'google.com'
    $tcpClient = [Net.Sockets.TcpClient]::new($uri, 443)
    $sslStream = [Net.Security.SslStream]::new($tcpClient.GetStream())

    try {
        $sslStream.AuthenticateAsClient($uri)
        $certificate = $sslStream.RemoteCertificate
    }
    finally {
        $sslStream.Close()
    }

    $chain = [Security.Cryptography.X509Certificates.X509Chain]::new()
    $chain.Build($certificate)

    $chain.ChainElements.Certificate | ForEach-Object {
        [System.Security.Cryptography.X509Certificates.X509Certificate2] $x509Cert = $_
        if ( $x509Cert.Subject -ne "CN=google.com") {
            $exportedCert = $x509Cert.Export([System.Security.Cryptography.X509Certificates.X509ContentType]::Cert)
            $exportedCertValue = $($exportedCert)
            $base64CertValue = "-----BEGIN CERTIFICATE----`n"
            $base64CertValue += [System.Convert]::ToBase64String($exportedCertValue, [System.Base64FormattingOptions]::InsertLineBreaks)
            $base64CertValue += "`n-----END CERTIFICATE-----"
        
            $certFileName = "$($x509Cert.Thumbprint).crt"
            $locationStoreOfCert = "$pwd\$certFileName"
            set-content -value $base64CertValue  -path $locationStoreOfCert
            New-Item -Target $locationStoreOfCert -ItemType SymbolicLink -Path"~\.minikube\certs\$certFileName" -ErrorAction Ignore
        }
    }
}