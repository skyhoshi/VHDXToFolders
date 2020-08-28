

function Write-DriveName {
    [CmdletBinding()]
    param (
        [string]$RootFolder,
        [System.Collections.ArrayList]$FolderList
    )
    
    begin {
        [System.Collections.ArrayList] $VHDXFolder = [System.Collections.ArrayList]::new();        
    }
    
    process {
        foreach ($folder in $FolderList) {
            $trimedFolderName = $folder.Replace(" ","").Replace(".","");
            $VHDXFolder.Add("$trimedFolderName$RootFolder") | Out-Null;
        }
    }
    
    end {
        return $VHDXFolder;
    }
}
$VisualStudioSources = $("Android", "Application Verifier", "Docker", "dotnet", "Git", "IIS", "IIS Express", "Microsoft SDKs", "Microsoft Update Health Tools", "Microsoft VS Code", "ModifiableWindowsApps", "MSBuild", "PackageManagement", "PowerShell", "Reference Assemblies", "VMware", "VS2010Schemas", "VS2012Schemas", "Walabot", "WindowsPowerShell");
Write-DriveName -RootFolder "ProgramFiles" -FolderList $VisualStudioSources;

$VisualStudioSources = $("Android", "Application Verifier", "dotnet", "IIS", "IIS Express", "Microsoft", "Microsoft IoT", "Microsoft SDKs", "Microsoft SQL Server", "Microsoft Visual Studio", "Microsoft Visual Studio Tools for Unity", "Microsoft Web Tools", "Microsoft.NET", "MSBuild", "NuGet", "Open XML SDK", "OpenAL", "PixyMon v2", "Reference Assemblies", "Teams Installer", "Windows Kits", "Windows Multimedia Platform", "Windows Portable Devices", "WindowsPowerShell", "WiX Toolset v3.11", "Workflow Manager Tools", "Xamarin");
Write-DriveName -RootFolder "ProgramFilesX86" -FolderList $VisualStudioSources;

