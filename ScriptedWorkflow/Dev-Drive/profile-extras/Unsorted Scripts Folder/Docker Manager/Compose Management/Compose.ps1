Write-Host "Loading Compose Methods"
. "C:\Users\kernm\OneDrive - Farm Credit Services of America\Documents\PowerShell\Scripts\listmethodsinps1file.ps1"
function Compose-SpecificProfileBuild{
    [CmdletBinding()]
    param (
        [Parameter()]
        [string]
        $profile = "all"
    )
    #docker compose --progress plain --profile console build --no-cache
    docker compose --profile $profile build
}
function Compose-SpecificProfileUp
{
   [CmdletBinding()]
   param (
       [Parameter()]
       [string]
       $profile = "all"
   )
   docker compose --profile $profile up
}

function Compose-Cycle {
   docker compose down
   docker compose build
   docker compose up

}

new-alias -name dcc -value Compose-cycle
function compose-update{
   docker compose down
   docker compose up
}

#