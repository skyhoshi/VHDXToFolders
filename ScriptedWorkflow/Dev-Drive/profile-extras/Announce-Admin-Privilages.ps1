if (-NOT ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) {
    Write-Host "Insufficient permissions to run the entirety of this script." -ForegroundColor Red
    Write-Host "YOU MAY ENCOUNTER ERRORS : IF YOU DO PLEASE OPEN UP A RUN AS ADMINISTRATORS PROMPT." -ForegroundColor Red

}
else {
    Write-Host "YOU ARE RUNNING AS ADMINISTRATOR" -ForegroundColor Green
}