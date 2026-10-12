Import-Module SQLServer

$result = .\Check-SqlServer.ps1
if ($result.Length -gt 0) {
    Write-Host $result
    exit
}

$name='bld-lightningproxy'
$target='lightningproxy:v1'
$sqlServerInstance = "localhost,1433"
$password = ConvertTo-SecureString -String $env:SA_PASSWORD -AsPlainText -Force

Write-Host "Using container $name to build $target"

docker run --rm `
           --name $name `
           -e "ACCEPT_EULA=Y" `
           -e "SA_PASSWORD=$env:SA_PASSWORD" `
           -p 1433:1433 `
           -d `
           mcr.microsoft.com/mssql/server:2019-CU24-ubuntu-20.04

try {

Write-Host 'Running db create script'
Start-Sleep -seconds 5
osql -U sa -P $env:SA_PASSWORD -S . -d master -i create-lightning-proxy-db.sql > build.log



& docker commit $name $target
}
catch {
    Write-Host 'Error encountered: '$_.Exception.Message $Error[0]
}
finally {
    & docker stop $name
}