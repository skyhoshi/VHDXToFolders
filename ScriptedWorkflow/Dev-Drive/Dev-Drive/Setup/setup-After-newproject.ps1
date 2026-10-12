<# if (!(Test-Path jobtemplatedefault)) {
    #
    mkdir jobtemplatedefault
    Set-Location jobtemplatedefault
    #
    dotnet new update
    dotnet new fcsajob -n CreditAndResolutionsTool
}
#
$driveLetter = "I"
Set-Location "$($driveLetter):\CreditAndResolutionsTool\src"
if (!(Test-Path .env)) {
    Copy-Item .env_template .env
}
Set-Location /
 #>
function Create-DotNetTemplatesForMigration {

    param (
        #This ProjectId Represents the ticket # your working on. 
        [Parameter(HelpMessage = "Long ID Usually Story Id from AzureDevOps")]
        [Int64]$ProjectId,
        #This ProjectName Represents the Description of the work you doing. (should be short and no more than 3 words [keep it short as it's apart of the path])
        [Parameter(HelpMessage = "String Representation of the work for this env.")]
        [string]$ProjectName,
        #Choose a Drive Letter can be A-ZZZ (AA, AAA or combos therof can be used.)
        [Parameter(Mandatory, HelpMessage = "Drive Letter for Project Defaults to L")]
        [Char]$ProjectRootDriveLetter = "L",
        [Switch]$API, 
        [Switch]$UI,
        [Switch]$JOB
    )

    Set-Location "$($ProjectRootDriveLetter):\"
    Write-Host "Starting Dotnet Template Update(s)"
    dotnet new update

    #$templateFolder = "templates"
    Write-Host "Creating Job Template Default Project to copy from"
    if (!(Test-Path templateFolder)) {
        mkdir templateFolder
    }
    Set-Location "$($ProjectRootDriveLetter):\templateFolder"
   
    if ($JOB) { $IncludeJob = $true; } else { $IncludeJob = $false; }
    if ($API) { $IncludeApi = $true; } else { $IncludeApi = $false; }
    if ($UI) { $IncludeUI = $true; } else { $IncludeUI = $false; }
    if (-not $JOB -and -not $API -and -not $UI) {
        #
        Write-Host "No Swithces Set: Update your script"
        $IncludeJob = $true
        $IncludeApi = $true
        $IncludeUI = $true
    }

    $SelectedTemplateCount = @($IncludeJob, $IncludeApi, $IncludeUI | Where-Object { $_ }).Count
    $CreateCombined = $SelectedTemplateCount -ge 2

    if ($IncludeJob) {
        if (!(Test-Path jobtemplatedefault) -or !(Test-Path "$($ProjectRootDriveLetter):\templateFolder\jobtemplatedefault\$ProjectName")) {
            #
            if (!(Test-Path jobtemplatedefault)) {
                mkdir jobtemplatedefault
            }
            Set-Location jobtemplatedefault
            if ($CreateCombined -and !(Test-Path combined)) {
                mkdir combined
            }
            #
            dotnet new fcsajob -n $projectName

            Set-Location "$($ProjectRootDriveLetter):\templateFolder\jobtemplatedefault\$ProjectName\src"
            if (!(Test-Path .env)) {
                Copy-Item .env_template .env
            }
        }
    }
    Set-Location "$($ProjectRootDriveLetter):\templateFolder"
    if ($IncludeApi) {
        Write-Host "Creating WebApi Template Default Project to copy from"
        if (!(Test-Path apitemplatedefault) -or !(Test-Path "$($ProjectRootDriveLetter):\templateFolder\apitemplatedefault\$ProjectName")) {
            #
            if (!(Test-Path apitemplatedefault)) {
                mkdir apitemplatedefault
            }

            Set-Location apitemplatedefault
            if ($CreateCombined -and !(Test-Path combined)) {
                mkdir combined
            }
            #
            dotnet new fcsaaspnetapi -n $projectName

            Set-Location "$($ProjectRootDriveLetter):\templateFolder\apitemplatedefault\$ProjectName\src"
            if (!(Test-Path .env)) {
                Copy-Item .env_template .env
            }
        }
    }

    Set-Location "$($ProjectRootDriveLetter):\templateFolder"
    if ($IncludeUI) {
        Write-Host "Creating WebUI Template Default Project to copy from"
        if (!(Test-Path webtemplatedefault) -or !(Test-Path "$($ProjectRootDriveLetter):\templateFolder\webtemplatedefault\$ProjectName")) {
            #
            if (!(Test-Path webtemplatedefault)) {
                mkdir webtemplatedefault
            }
            Set-Location webtemplatedefault
            if ($CreateCombined -and !(Test-Path combined)) {
                mkdir combined
            }
            #
            dotnet new fcsaaspnetwebui -n $projectName

            Set-Location "$($ProjectRootDriveLetter):\templateFolder\webtemplatedefault\$ProjectName\src"
            if (!(Test-Path .env)) {
                Copy-Item .env_template .env
            }
        }
    }
    #
    Set-Location "$($ProjectRootDriveLetter):\"
}