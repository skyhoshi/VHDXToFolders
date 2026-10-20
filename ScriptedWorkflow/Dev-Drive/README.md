# Introduction 
This repo is intended to help shortcut the setup time of work involving the following
1. Workspace Storage (where on my disk should I store my project's code)
2. Database Storage
3. Consistant Configuration Across any development machine. 
    0. the data files created can be stored anywhere. and when mounted code storage is uniform across machines (Code is rooted to a VHD)

# Getting Started
All Scripts have been created with and tested against Powershell 7.4. There are features missing that may cause the scripts to fail in uncertain ways in Powershell 5. Scripts are NOT compatable with Powershell 2 or below.

If you have never run these scripts you are going to want to setup your [Powershell Profile](https://learn.microsoft.com/en-us/powershell/module/microsoft.powershell.core/about/about_profiles?view=powershell-7.4)

NOTE: i have a profile shortcut in the "GoToCurrentProjectScript.ps1" : you can access it by following the step below.

Running the [GoToCurrentProjectScript.ps1](https://dev.azure.com/fcsamerica/Sandbox/_git/kernm.devcontainer.envsetup?path=/GoToCurrentProjectScript.ps1) will allow you to execute the following commands which will help you setup your powershell profile scripts. 

```powershell
 Current-Scripts
```
This method is intended to take you to the ~\Documents\Powershell folder which is the starting point for your Current User All Hosts Script. (will run exclusively for you on any host you start on your computer. in and outside visual studio included.)

Once completed you can go on to the Dev-Drive Setup

1. Open your Current User All Hosts Profile 
```powershell
code $Profile.CurrentUserAllHosts
```
2. Obtain the path of the "setup-new-project.ps1" file
3. add to the script file the following that mimics the location of your stored setup-new-project.ps1 file.
```
. "K:\kernm.devcontainer.envsetup\Dev-Drive\Setup\setup-new-project.ps1" 
```
Note the dot leading the script string. this tells powershell that during the execution of this script the following file should be executed as if inline with the currently executing script. 

4. Open a new instance of powershell. (I recommend closing all other powershell hosts once the new one has opened. )

You can now run the New-DevelopmentStorageEnvironment 

Project Id is intended to be the Work Item Number. 

    --- hopefully in the future I'll be able to tie the work item number to the repo's listed in a userstory to allow you to populate that field. once populated you can run this script that will then clone all repos associated on the work item. 
```powershell
New-DevelopmentStorageEnvironment -ProjectId 161799 -ProjectName "My Very Short Detail Describing The Contents" -ProjectRootDriveLetter 'L' -GitRepoUrl "<Comma delimited List of Repos you want to have auto cloned inside the drive>"  -GitRepoBranchName "<Pre-existing Branch Name to switch to>"
```

### VERSION 5 Powershell profile

You can do nearly the same thing as above but instead. the profile object is a single string. 

it points to
```
C:\Users\<USERNAME>\OneDrive - Farm Credit Services of America\WindowsPowerShell\Microsoft.PowerShell_profile.ps1
```

Other than syntax this is the largest difference between the two powershell profiles.  

# Custom VHDX drive settings

[Mount-CustomVHDX.ps1](./Dev-Drive/Mount%20Vhdx/Mount-CustomVHDX.ps1)
uses `Export-Clixml` / `Import-Clixml` for this small PowerShell-only configuration.
CLIXML preserves `IsEnabled` as a Boolean without a database or extra dependency.
JSON is a better choice when other languages need to consume the same settings;
CSV is less suitable here because imported values are strings.

Run these commands from the script's directory:

```powershell
# Open the Windows checkbox editor (also the default action).
.\Mount-CustomVHDX.ps1 -Action Edit

# Read the saved list without changing mounted drives.
.\Mount-CustomVHDX.ps1 -Action List

# Preview changes; then apply them from an elevated PowerShell session.
.\Mount-CustomVHDX.ps1 -Action Sync -WhatIf
.\Mount-CustomVHDX.ps1 -Action Sync
```

Settings default to `%LOCALAPPDATA%\VHDXToFolders\Drives.clixml`. The first load
creates the seven original entries with `IsEnabled = $true`. Specify `-ConfigPath`
to use another file. Invalid or corrupt settings raise an error rather than
silently resetting your choices. Saving replaces a complete export, not a partial
write. This is a single-user configuration, not a concurrent database.

The editor saves checkbox changes only; Cancel discards them. Saving never mounts
or dismounts drives. Sync requires Windows, the Hyper-V PowerShell module, and
Administrator rights. It mounts enabled detached drives, dismounts disabled
attached drives, and leaves matching states alone. It prompts before each change;
use `-Confirm:$false` only for trusted automation. Dismounting can interrupt apps
using the drive: close those apps and files first. Sync checks that every configured
image exists before changing anything, and stops on errors; it does not roll back
earlier successful changes. It never formats disks or changes Windows services.

The functions are packaged in the
[CustomVhdx module](./Dev-Drive/Mount%20Vhdx/CustomVhdx/CustomVhdx.psd1).
Each function has its own file under `Public` or `Private`; validation is private,
and the manifest exports only the five user-facing commands. Importing the module
does not create settings, open the editor, or mount/dismount anything. Hyper-V and
Windows Forms are needed only when you invoke their respective commands.

For programmatic edits, import the module and explicitly load `$Drives`:

```powershell
Import-Module .\CustomVhdx\CustomVhdx.psd1
$ConfigPath = Join-Path $env:LOCALAPPDATA 'VHDXToFolders\Drives.clixml'
$Drives = @(Import-CustomVhdxDrive -ConfigPath $ConfigPath)
$Drives | Format-Table Path, IsEnabled
$Drives[0].IsEnabled = $false
Save-CustomVhdxDrive -Drives $Drives -ConfigPath $ConfigPath

# Add/remove entries by updating the array and saving it the same way.
# Every entry requires an absolute .vhd/.vhdx path and a real Boolean.
$Drives = @($Drives) + [pscustomobject]@{
    Path = 'E:\Shared Virtual Hard Drive Storage\Another drive.vhdx'
    IsEnabled = $false
}
Save-CustomVhdxDrive -Drives $Drives -ConfigPath $ConfigPath
Sync-CustomVhdxDrive -Drives $Drives -WhatIf
```

`Get-DefaultCustomVhdxDrive` returns the seven original entries without saving them.
`Show-CustomVhdxDriveEditor -Drives $Drives -ConfigPath $ConfigPath` opens the editor;
capture its output in `$Drives` to retain the saved changes in memory.
The original script remains a wrapper for `Edit`, `List`, and `Sync`, forwarding
`-WhatIf` and `-Confirm` to the module's sync command. Existing dot-sourced usage
(`. .\Mount-CustomVHDX.ps1`) still imports the module and loads `$Drives` without
opening the editor or applying changes.

The separate `Import-MountCustomVhdx.ps1` helper still targets the external
`E:\Shared Virtual Hard Drive Storage\Mount-CommonVHDx.ps1`; use the script above
directly for this configuration workflow.

# Database

## Database Creation
TODO

## User Account Setup
Once your Database is setup you can make a copy of `./dataase.scripts/Local Database Setup/UserSetup-Template.sql` into the `./dataase.scripts/Local Database Setup/By Project/` Folder and name it after the database used.

This script when populated will create 2 logins and assign those users to the database specified. 
1. < DatabaseName >_local
2. < MSA_AccountName >_msa_O

This script also produces a cleanup script that will remove the users created from both the database and server logins. 

# Contribute
Please Seek a PR for changes. 

Any suggestions and help is welcome.