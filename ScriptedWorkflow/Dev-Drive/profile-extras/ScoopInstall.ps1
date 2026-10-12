Set-ExecutionPolicy -ExecutionPolicy Unrestricted;
#powershell.exe -NoLogo -NoProfile -Command 'Install-Module -Name PackageManagement -Force -MinimumVersion 2.8.5.201 -Scope CurrentUser -AllowClobber'  
$ScoopGlobalRoot = "C:\Applications";
$Installers = "$ScoopGlobalRoot\Installers"
$env:SCOOP = "$ScoopGlobalRoot\$env:USERNAME\";
$env:SCOOP_GLOBAL = "$ScoopGlobalRoot\Global";

if (!(Test-Path -Path $env:SCOOP)) {
    New-Item -ItemType Directory $env:SCOOP;
}
if (!(Test-Path -Path $env:SCOOP_GLOBAL)) {
    New-Item -ItemType Directory $env:SCOOP_GLOBAL;
}
if(!(Test-Path -Path $Installers)){
    New-Item -ItemType Directory $Installers;
}

[Environment]::SetEnvironmentVariable('SCOOP', $env:SCOOP, 'User')
[Environment]::SetEnvironmentVariable('SCOOP_GLOBAL', $env:SCOOP_GLOBAL, 'Machine')
# run the installer

#iwr -useb get.scoop.sh | iex

iwr -useb get.scoop.sh -outfile 'install.ps1'
.\install.ps1 -RunAsAdmin #[-OtherParameters ...]

scoop install 7zip -g
scoop install git-with-openssh -g
scoop install hub -g

Add-MpPreference -ExclusionPath $ScoopGlobalRoot
Add-MpPreference -ExclusionPath $Installers
Add-MpPreference -ExclusionPath $env:SCOOP
Add-MpPreference -ExclusionPath $env:SCOOP_GLOBAL
Set-ItemProperty 'HKLM:\SYSTEM\CurrentControlSet\Control\FileSystem' -Name 'LongPathsEnabled' -Value 1