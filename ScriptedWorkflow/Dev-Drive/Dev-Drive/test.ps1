#$ProjectRootDriveLetter = "k"


function Test-DriveLetter {
    param (
        [string]$ProjectRootDriveLetter
    )
    $patterns = "A|B|C|K|O|P|W"

    if ($ProjectRootDriveLetter.Length -gt 1){
        Write-Output "Invalid Drive Letter"
        return;
    }
    if ($ProjectRootDriveLetter -imatch $patterns) {
        Write-Output "Match found!"
    }
    else {
        Write-Output "No match found."
    }
}

Test-DriveLetter "k"
Test-DriveLetter "aA"
Test-DriveLetter "k"
Test-DriveLetter "e"
