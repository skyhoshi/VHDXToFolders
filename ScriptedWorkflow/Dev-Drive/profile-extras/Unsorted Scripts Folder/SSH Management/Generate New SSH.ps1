. "C:\Users\kernm\OneDrive - Farm Credit Services of America\Documents\PowerShell\Scripts\listmethodsinps1file.ps1"

$RootProfileStore = "$($env.USERPROFILE)\.ssh";
$StoreLocation = "\";
$Filename = "FCSAMerica.AzDO.Primary"
$PrefixFilename = "$($Filename).ssh"
$PathOnly = "$RootProfileStore$StoreLocation"
if (!(Test-Path -Path $PathOnly)){
    New-Item -Path $PathOnly -ItemType Directory;
}
$Extension = "Id_rsa";
$FileName = "$($PrefixFilename).$($Extension)";
$FullPath = "$($PathOnly)$($FileName)"
ssh-keygen -f $FullPath ;