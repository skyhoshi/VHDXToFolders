Write-Host "Loading Current Project Navigation Script(s)";
. "C:\Users\kernm\OneDrive - Farm Credit Services of America\Documents\PowerShell\Scripts\listmethodsinps1file.ps1"

##Import-Module "C:\Applications\kernm\modules\scoop-completion";
#. "C:\Users\kernm\source\SolutionsEnablementRepos\Hybrid-Cloud.Utilities\KARI.Reporter\src\PowerShell\DatabaseMigrationShortcuts.ps1" 
 $previousBackgroundColor =  $host.UI.RawUI.BackgroundColor;
 $previousForegroundColor = $host.UI.RawUI.ForegroundColor;
 $host.UI.RawUI.BackgroundColor = 'DarkRed';
##############################################################################################################################
#Load your script here:
##############################################################################################################################
$host.UI.RawUI.BackgroundColor = $previousBackgroundColor;