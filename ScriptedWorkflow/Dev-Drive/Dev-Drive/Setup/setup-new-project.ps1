<#This will open git kraken at either the specified location or at the current directory.#>


<#
.SYNOPSIS
Creates a Mounted VHDX drive for compartmentalization of dev work.

.DESCRIPTION
Long description

.PARAMETER ProjectId
Integer: Should be the Work Item Number be it a User Story or Task

.PARAMETER ProjectName
Short Descriptor that represents the body of work or apps worked on. (can be anything, SHOULD BE LIMITED)

.PARAMETER ProjectRootDriveLetter
Drive Letter Not Already in use on System 

.PARAMETER VirtualHardDiskFileName
Customize the Hard drive File Name.

.PARAMETER vhdsize
DEFAULTS to 1 TB (Should not change unless directed to)

.PARAMETER GitRepoUrl
List of Git Repo URI's that should be put in this container. 

.EXAMPLE
New-DevelopmentStorageEnvironment -ProjectId 161799 -ProjectName "Dev Containers" -ProjectRootDriveLetter 'L' -GitRepoUrl "git@ssh.dev.azure.com:v3/fcsamerica/SolutionsEnablement/LightningProxy", "git@ssh.dev.azure.com:v3/fcsamerica/SolutionsEnablement/Canary.Web.API"


.NOTES
General notes
#>
function New-DevelopmentStorageEnvironment {
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
        #Name your dirve Accordingly, We Recomment using the ProjectId and Project Name but you can name it as you like.
        [Parameter(HelpMessage = "Allows you to override the name of the VHDx File Created. (will be ProjectID and ProjectName with all spaces removed.)")]
        [string]$VirtualHardDiskFileName,
        #We Recommend Leaving this as is, Disk is Dynamically size (takes space when needed) and setting it smaller could cause issues if you reach it's limit. (fill a 20GB drive and having to expand it is dangerious)
        [Parameter(HelpMessage = "Suggession: DO NOT edit this. can be lowered but can cause problems if you reach the size limit and need to expand/resize the drive. (RISKY to Edit)")]
        [Int64]$vhdsize = 1TB,
        #This could be expanded to be an array of repos for the body of work in question but as of now it's single. 
        [Parameter(Mandatory, HelpMessage = "Azure DevOps Repo to run Git Clone Command against.")]
        [string[]]$GitRepoUrl,
        # if given the branch name will be switched to: Will fail if branch doesn't exist.
        [Parameter(HelpMessage = "When Present and repo successfully cloned, the repo will switch to this branch")]
        [string]$GitRepoBranchName = "",
        [Parameter(DontShow = $true)]        
        $SkipGitOperations = $false
        
    )

    $error.clear()
    $PrimaryProjectStorageLocation = "C:\Projects"

    ### DANGER EDITING BELOW ###
    #Store Previous location to allow this to be run from anywhere.
    $previousLocation = $PWD
    <#Setup Location and Naming of items for VHD File#>
    if (!$VirtualHardDiskFileName) {
        $projectNamePart = $ProjectName.Replace(" ", "")
        $VirtualHardDiskFileName = "$ProjectId$projectNamePart.vhdx"
    }
    #This ProjectStorageLocation Represents where the VHDX will be stored. for future reference and easy management.
    $ProjectStorageLocation = "$($PrimaryProjectStorageLocation)\$ProjectName\$ProjectId$ProjectName\"
    Write-Host "Creating Env for $ProjectStorageLocation"


    if (!(Test-Path $ProjectStorageLocation)) {
        #Creating the directory for write (VHDX Storage Location)
        New-Item -ItemType Directory -Path $ProjectStorageLocation | Out-Null
    }
    #Move current to the new folder created.
    Set-Location $ProjectStorageLocation
    
    Test-DriveLetter $ProjectRootDriveLetter
    if ($Error.Count -ne 0) {
        return
    }

    $vhdpath = "$($ProjectStorageLocation)$($VirtualHardDiskFileName)"
    #Get-Disk | Where {$_.Model -eq "Virtual Disk"}
    $CurrentlyAttachedVirtualDisks = @("")
    $CurrentlyAttachedVirtualDisks = Get-Disk | Where-Object { $_.Model -like "*Virtual Disk*" } | Select-Object -ExpandProperty Location -Property location
    Write-Host "Searching for $vhdPath in: "
    $CurrentlyAttachedVirtualDisks | ForEach-Object { Write-Host $_ }
    if (!(Test-Path $vhdpath) -and $CurrentlyAttachedVirtualDisks -notcontains $vhdpath) {
        #We shutdown the Shell Detection Service for a bit due to a popup that is display'd to format the hard disk.
        #We are already formating this so the popup is not needed and should be avoided. this avoids it. 
        Stop-Service -Name ShellHWDetection
        #Create, Mount, Init, Partition and Format New Disk.
        New-VHD -Path $vhdpath -Dynamic -SizeBytes $vhdsize | Mount-VHD -Passthru | Initialize-Disk -PartitionStyle GPT -Passthru | New-Partition -DriveLetter $ProjectRootDriveLetter -UseMaximumSize | Format-Volume -NewFileSystemLabel "$ProjectId$ProjectName" -FileSystem ReFS -Confirm:$false -Force | Out-Null
    
        #Restart the service we stopped.
        Start-Service -Name ShellHWDetection
    }
    elseif ($CurrentlyAttachedVirtualDisks -notcontains $vhdpath) {
        Write-Warning "Drive Already Exists. Not Recreating. Attempting to Mount"
        Mount-VHD -Path $vhdpath
    }
    else {
        Write-Warning "Drive Already Exists. Not Recreating. Already Mounted"
        $SkipGitOperations = $true;
    }
    if ($error.Count -gt 0) {
        return
    }
    $ProjectRootDir = "$($ProjectRootDriveLetter):\"

    #Start-Process .

    Set-Location $ProjectRootDir
#    if (!$SkipGitOperations) 
    #{
        #Git Clone and maybe run docker compose build? 
        foreach ($repoUrl in $GitRepoUrl) {
            $RepoDirectoryName = GetRepoDirectoryFromGitRepoUri -GitRepoUri $repoUrl
            git clone $repoUrl $RepoDirectoryName
            git config --global --add safe.directory "$($ProjectRootDir)$($RepoDirectoryName)"
            Open-GitKraken "$ProjectRootDir\$RepoDirectoryName"
            Set-Location "$ProjectRootDir\$RepoDirectoryName"
            Write-Host "> > > Pulling Default Branch"
            git pull
        
            if ($GitRepoBranchName -ne "") {
                Write-Host "> > > Switching Branches"
                git switch $GitRepoBranchName
                Write-Host "> > > Pulling $GitRepoBranchName"
                git pull
            }
            Set-Location $ProjectRootDir
        }

        if ($error.Count -gt 0) {
            Write-Error "You messed up... but that's ok. i'm sure you can figure it out from here."
            Set-Location $previousLocation
        }
   # }

}

function Test-DriveLetter {
    param (
        [string]$ProjectRootDriveLetter
    )

    $drives = Get-PSDrive -PSProvider FileSystem | Select-Object -ExpandProperty Name
    $patterns = "K|O|P|S|W"

    if ($ProjectRootDriveLetter.Length -gt 1) {
        Write-Error "Invalid Drive Letter"
        return
    }
    if ($ProjectRootDriveLetter -imatch $patterns) {
        Write-Error "Match found!"
    }
    else {
        
        if ($drives -icontains $ProjectRootDriveLetter) {
            Write-Error "Drive letter $ProjectRootDriveLetter is in use."
        }
        else {
            Write-Output "Drive Letter $ProjectRootDriveLetter is good: No match found."
        }
    }
}
#Test-DriveLetter -ProjectRootDriveLetter 'C'
#Test-DriveLetter -ProjectRootDriveLetter 'L'

function New-DevelopmentStorageEnvironmentForMultipleProjects {
    param (
        #This ProjectId Represents the ticket # your working on. 
        [Parameter(HelpMessage = "Long ID Usually Story Id from AzureDevOps")]
        [Int64[]]$ProjectIds,
        #This ProjectName Represents the Description of the work you doing. (should be short and no more than 3 words [keep it short as it's apart of the path])
        [Parameter(HelpMessage = "String Representation of the work for this env.")]
        [string]$ProjectName,
        #Choose a Drive Letter can be A-ZZZ (AA, AAA or combos therof can be used.)
        [Parameter(Mandatory, HelpMessage = "Drive Letter for Project Defaults to L")]
        [Char]$ProjectRootDriveLetter = "L",
        #Name your dirve Accordingly, We Recomment using the ProjectId and Project Name but you can name it as you like.
        [Parameter(HelpMessage = "Allows you to override the name of the VHDx File Created. (will be ProjectID and ProjectName with all spaces removed.)")]
        [string]$VirtualHardDiskFileName,
        #We Recommend Leaving this as is, Disk is Dynamically size (takes space when needed) and setting it smaller could cause issues if you reach it's limit. (fill a 20GB drive and having to expand it is dangerious)
        [Parameter(HelpMessage = "Suggession: DO NOT edit this. can be lowered but can cause problems if you reach the size limit and need to expand/resize the drive. (RISKY to Edit)")]
        [Int64]$vhdsize = 1TB,
        #This could be expanded to be an array of repos for the body of work in question but as of now it's single. 
        [Parameter(Mandatory, HelpMessage = "Azure DevOps Repo to run Git Clone Command against.")]
        [string[]]$GitRepoUrl,
        # if given the branch name will be switched to: Will fail if branch doesn't exist.
        [Parameter(HelpMessage = "When Present and repo successfully cloned, the repo will switch to this branch")]
        [string]$GitRepoBranchName = "",
        [Parameter(DontShow = $true)]        
        $SkipGitOperations = $false
        
    )

    $error.clear()
    $PrimaryProjectStorageLocation = "C:\Projects"
}


<#
.SYNOPSIS
Takes a Repository URI and pulls the last path element and returns it. 

.DESCRIPTION
Long description

.PARAMETER GitRepoUri
Parameter description

.EXAMPLE
An example

.NOTES
General notes
#>
function GetRepoDirectoryFromGitRepoUri {
    param (
        [Parameter(Mandatory)]
        [string] $GitRepoUri
    )
    
    $splitChar = "/"
    [string[]]  $uriParts = $GitRepoUri.Split($splitChar)
    $LastPart = $uriParts[$uriParts.Length - 1]
    return $LastPart
}

<#
.SYNOPSIS
Take the given path, opens it in GitKraken  DOES NOT CHECK if valid repo.

.DESCRIPTION
Long description

.PARAMETER ProjectPath
Parameter description

.EXAMPLE
An example

.NOTES
General notes
#>
function Open-GitKraken {
    [CmdletBinding()]
    param (
        [string]$ProjectPath
    )
    
    begin {
        
    }
    
    process {
        if ($ProjectPath) { 
            if ((Test-Path $ProjectPath)) {
                $curpath = $ProjectPath
            }
        }
        if (!$curPath) {
            $curpath = (get-location).ProviderPath
        }
        $lapd = $env:localappdata
        $logf = "$env:temp\krakstart.log"
        $newestExe = Get-Item "$lapd\gitkraken\app-*\gitkraken.exe" | Select-Object -Last 1
        start-process -filepath   $newestExe -ArgumentList "--path $curpath" -redirectstandardoutput $logf
    }
    
    end {
        
    }
}
<#
.SYNOPSIS
Check to see if Git Kraken CLI is available and if not install it. 

.DESCRIPTION
We want to use GitKraken to manage the repo. there's direct ways and indirect. the purpose is to keep authentication and authorization all in one place. 

.EXAMPLE
An example

.NOTES
General notes
#>
function CheckIfGitKrakenCLIisInstalled {
    param (
        
    )
    #winget install gitkraken.cli
}


function Remove-DevelopmentStorageEnvironment {
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
        #Name your dirve Accordingly, We Recomment using the ProjectId and Project Name but you can name it as you like.
        [Parameter(HelpMessage = "Allows you to override the name of the VHDx File Created. (will be ProjectID and ProjectName with all spaces removed.)")]
        [string]$VirtualHardDiskFileName,
        #We Recommend Leaving this as is, Disk is Dynamically size (takes space when needed) and setting it smaller could cause issues if you reach it's limit. (fill a 20GB drive and having to expand it is dangerious)
        [Parameter(HelpMessage = "Suggession: DO NOT edit this. can be lowered but can cause problems if you reach the size limit and need to expand/resize the drive. (RISKY to Edit)")]
        [Int64]$vhdsize = 1TB,
        #This could be expanded to be an array of repos for the body of work in question but as of now it's single. 
        [Parameter(Mandatory, HelpMessage = "Azure DevOps Repo to run Git Clone Command against.")]
        [string[]]$GitRepoUrl,
        # if given the branch name will be switched to: Will fail if branch doesn't exist.
        [Parameter(HelpMessage = "When Present and repo successfully cloned, the repo will switch to this branch")]
        [string]$GitRepoBranchName = ""
    )

    $error.clear()
    $PrimaryProjectStorageLocation = "C:\Projects\"

    ### DANGER EDITING BELOW ###
    #Store Previous location to allow this to be run from anywhere.
    $previousLocation = $PWD
    <#Setup Location and Naming of items for VHD File#>
    if (!$VirtualHardDiskFileName) {
        $projectNamePart = $ProjectName.Replace(" ", "")
        $VirtualHardDiskFileName = "$ProjectId$projectNamePart.vhdx"
    }
    #This ProjectStorageLocation Represents where the VHDX will be stored. for future reference and easy management.
    $ProjectStorageLocation = "$PrimaryProjectStorageLocation\$ProjectName\$ProjectId $ProjectName\"

    #Move current to the new folder created.
    #Set-Location $ProjectStorageLocation
    
    $vhdpath = "$($ProjectStorageLocation)$($VirtualHardDiskFileName)"
    if ((Test-Path $vhdpath)) {
        #Write-Warning "Drive Already Exists. Not Recreating. Attempting to dismount"
        Dismount-VHD -Path $vhdpath
    }
    if ($error.Count -gt 0) {
        write-error $error
    }
    Remove-Item $vhdpath -ErrorAction Continue
    Set-Location $PrimaryProjectStorageLocation
    Remove-Item "$PrimaryProjectStorageLocation\$ProjectName\$ProjectId $ProjectName\"
}

#############################################################################################################################################################################################################################################################################################
### Test Run of Development Environment creator:
#############################################################################################################################################################################################################################################################################################

# New-DevelopmentStorageEnvironment -ProjectId 161799 -ProjectName "Dev Containers" -ProjectRootDriveLetter 'L' -GitRepoUrl "git@ssh.dev.azure.com:v3/fcsamerica/SolutionsEnablement/LightningProxy", "git@ssh.dev.azure.com:v3/fcsamerica/SolutionsEnablement/Canary.Web.API"  -GitRepoBranchName "experimental/dev-container"

# GetRepoDirectoryFromGitRepoUri "git@ssh.dev.azure.com:v3/fcsamerica/SolutionsEnablement/LightningProxy"

#############################################################################################################################################################################################################################################################################################
### Personal work and setup following Might add it to the main script but i'm leaving it here for future reference.
#############################################################################################################################################################################################################################################################################################
#function Post-CreationAcions { 
<#
write-host "====================================="
$ProjectRootDir = "L:\"

$ProjectDirectories = "LightningProxy", "Canary.Web.API"

$foreachBeforePathLocation = $PWD
# Build Docker Compose if exists
foreach ($projDir in $ProjectDirectories) {
    # $projDir is the current item 
    $currentProjectDirectory = "$ProjectRootDir\$projDir"
    
    if ((Test-Path "$currentProjectDirectory\compose.yml") -or (Test-Path "$currentProjectDirectory\compose.yaml")) {
        set-location $currentProjectDirectory
        Write-Host "> > > Attempting Docker Compose Build on $projDir"
        docker compose build
    }
}
set-location $foreachBeforePathLocation
#>
#}
#Post-CreationAcions
