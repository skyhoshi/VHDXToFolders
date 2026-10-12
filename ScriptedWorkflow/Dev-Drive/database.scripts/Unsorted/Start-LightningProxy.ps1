$result = .\Check-SqlServer.ps1
if ($result.Length -gt 0) {
    Write-Host $result
    exit
}

docker run --rm `
           --name lightningproxy `
           -e "ACCEPT_EULA=Y" `
           -e "SA_PASSWORD=$env:SA_PASSWORD" `
           -p 1433:1433 `
           -d lightningproxy:v1
