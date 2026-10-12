Write-Host "Loading (Un)Install FCSA Service Account Functions"
. "C:\Users\kernm\OneDrive - Farm Credit Services of America\Documents\PowerShell\Scripts\listmethodsinps1file.ps1"

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
    Write-Host "===================================================="
    Install-adserviceaccount $UserName

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