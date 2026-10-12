if (-NOT ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) {
    Write-Host "Insufficient permissions to run the entirety of this script." -ForegroundColor Red
    Write-Host "YOU MAY ENCOUNTER ERRORS : IF YOU DO PLEASE OPEN UP A RUN AS ADMINISTRATORS PROMPT." -ForegroundColor Red
    return
}
else {
    Write-Host "YOU ARE RUNNING AS ADMINISTRATOR" -ForegroundColor Green
}
Write-Host "Loading (Un)Install FCSA Service Account Functions"

function Install-FCSAServiceAccount {
    [CmdletBinding()]
    param (
        [Parameter()]
        [string]
        $UserName
    )
    #Install the Acitve Directory Service Account: 
    Write-Host "===================================================="
    Write-host "Installing $($UserName) Service Account on $(hostname)."
    $value = Install-ADServiceAccount $UserName
    Write-Host $value
    Write-Host "===================================================="
}

function Uninstall-FCSAServiceAccount {

    [CmdletBinding()]
    param (
        [Parameter()]
        [string]
        $UserName
    )
    #Install the Acitve Directory Service Account: 
    Write-Host "===================================================="
    Write-host "Uninstall $($UserName) Service Account on $(hostname)."
    Write-Host "===================================================="

    Uninstall-ADServiceAccount -Identity $UserName
}

    
if ($DebugMode) {
    Write-Host "This is where we would attempt to add the Patronage Elastic Search GSA (MSA) Accounts to the system for use."
    # Uninstall-FCSAServiceAccount "PT_ElaApi_msa_o"
    # Install-FCSAServiceAccount "PT_ElaApi_msa_o"
}