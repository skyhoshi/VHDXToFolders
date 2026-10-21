$previousLocation = Get-Location;
Set-Location $PSScriptRoot
./Test-CreatePwDatabase.ps1
./Test-UpdatePwDatabase.ps1
./Test-ReadPwDatabase.ps1
Set-Location $previousLocation
