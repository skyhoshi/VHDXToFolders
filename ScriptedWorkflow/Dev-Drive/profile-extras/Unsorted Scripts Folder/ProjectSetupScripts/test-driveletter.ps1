. "C:\Users\kernm\OneDrive - Farm Credit Services of America\Documents\PowerShell\Scripts\listmethodsinps1file.ps1"
Write-Host "Loading Drive Letter Testing Method"
function Test-DriveLetter {
    param (
        [string]$DriveLetterToTest
    )
    $patterns = "O|P|W"
    [bool]$IsDriveLetterAvailable = $null;
    if ($DriveLetterToTest.Length -gt 1) {
        if (($DriveLetterToTest -like "*:\" || $DriveLetterToTest -like "*:*") -and $DriveLetterToTest.Length -lt 4) {
            Write-Debug "Updating Drive Letter to test to: $($DriveLetterToTest.Substring(0,1))"
            $DriveLetterToTest = $DriveLetterToTest.Substring(0, 1)
        }
        else {
            Write-Error "Invalid Drive Letter: $($DriveLetterToTest.Length)"
            #return
        }
        # Write-Error "Invalid Drive Letter: $($DriveLetterToTest.Length)"
        # return
    }
    if ($DriveLetterToTest -imatch $patterns) {
        Write-Error "Match found!"
        $IsDriveLetterAvailable = $false
    }
    else {
        
        if (Get-PSDrive -Name $DriveLetterToTest.Substring(0,1) -ErrorAction SilentlyContinue) {
            # Write-Error "Drive letter $driveLetter is in use."
            $IsDriveLetterAvailable = $false
        }
        else {
            # Write-Output "Drive Letter $($DriveLetterToTest) is good: No match found."
            $IsDriveLetterAvailable = $true
        }
    }
    return $IsDriveLetterAvailable
}
<# Test-DriveLetter -DriveLetterToTest "K"
Test-DriveLetter -DriveLetterToTest "S"
Test-DriveLetter -DriveLetterToTest "K:\"
Test-DriveLetter -DriveLetterToTest "S:\"
Test-DriveLetter -DriveLetterToTest "C:\"
Test-DriveLetter "K:\"
#These Don't work for some reason
Test-DriveLetter -DriveLetterToTest "S:`/"
Test-DriveLetter -DriveLetterToTest "K:`/" #>

#$Error.Clear() && . "C:\Users\kernm\OneDrive - Farm Credit Services of America\PowerShell\Scripts\ProjectSetupScripts\test-driveletter.ps1" && $Error.Count