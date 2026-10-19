Write-Host "Executing: $PSScriptRoot\Mount-CommonVHDx.ps1"
Write-Host "Running Mount Common VHDX Drives" -ForegroundColor DarkYellow;

<# function LoadKnownDrives {
  [CmdletBinding()]
  param(
    [parameter(ValueFromPipeline)]$pipelinevalues
  )

  begin {
    [Collections.ArrayList]$inputObjects = @()
  }
  process {
    [void]$inputObjects.Add($pipelinevalues);
  }
  end {
    $inputObjects | Foreach -Parallel {
      
    }
  }
}
 #>
$CurrentlyAttachedVirtualDisks = @();

$RunMounting = $true;
$Drives = [System.Collections.ArrayList]::new()

function LoadCurrentlyAttachedVirtualDisks {
    $CurrentlyAttachedVirtualDisks = Get-Disk | Where-Object { $_.Model -like "*Virtual Disk*" } | Select-Object -ExpandProperty Location -Property location
    $CurrentlyAttachedVirtualDisks | ForEach-Object { Write-Debug $_ }
}

if ($CurrentlyAttachedVirtualDisks.Count -eq 0) {
    LoadCurrentlyAttachedVirtualDisks;
}
function LoadMountableDrives {
    #if ($RunMounting) {

    $Drives = [System.Collections.ArrayList]::new()
    $Drives.Add("E:\Shared Virtual Hard Drive Storage\Profile\OneDrive\Sky-M4-OneDrive.vhdx") | Out-Null
    $Drives.Add("E:\Shared Virtual Hard Drive Storage\Application Drives\Scoop\Sky-M4-Scoop.vhdx") | Out-Null
    $Drives.Add("E:\Shared Virtual Hard Drive Storage\Application Drives\Unity\Unity Edtior Storage.vhdx") | Out-Null
    $Drives.Add("E:\Shared Virtual Hard Drive Storage\Development Drives\Personal Source Code.vhdx") | Out-Null
    $Drives.Add("E:\Shared Virtual Hard Drive Storage\Application Drives\JetBrains\Jetbrains-Application-StorageDrive.vhdx") | Out-Null
    $Drives.Add("E:\Shared Virtual Hard Drive Storage\Creator Storage Drives\VST-Plugins-32-64.vhdx") | Out-Null
    $Drives.Add("E:\Shared Virtual Hard Drive Storage\Application Drives\Winamp\Winamp.vhdx") | Out-Null
    # $Drives.Add("E:\Shared Virtual Hard Drive Storage\Application Drives\ProgramFile-Drives\ProgramFiles-Adobe-CreativeCloud.vhdx") | Out-Null
    # $Drives.Add("E:\Shared Virtual Hard Drive Storage\Application Drives\VSCode\Sky-M4-AppData-Roaming-VsCode.vhdx") | Out-Null    
    #$Drives.Add("E:\Shared Virtual Hard Drive Storage\Application Drives\Winamp\Winamp.vhdx") | Out-Null
    #$Drives.Add("E:\Shared Virtual Hard Drive Storage\Application Drives\Steam\Final Fantasy 15.vhdx") | Out-Null
    #}
}
LoadMountableDrives;
function DismountTestDrive {
    LoadCurrentlyAttachedVirtualDisks;
    $testDrive = $Drives[$Drives.Count - 1];
    $testDrive = "E:\Shared Virtual Hard Drive Storage\Application Drives\Winamp\Winamp.vhdx";
    Dismount-VHD -Path $testDrive;
}
DismountTestDrive;
<#
E:\Shared Virtual Hard Drive Storage\Application Drives\JetBrains\Jetbrains-Application-StorageDrive.vhdx
E:\Shared Virtual Hard Drive Storage\Application Drives\RubyDevKit\Ruby Including DevKit.vhdx
E:\Shared Virtual Hard Drive Storage\Application Drives\Scoop\Sky-M4-Scoop.vhdx
E:\Shared Virtual Hard Drive Storage\Application Drives\Unity\Unity Edtior Storage.vhdx
E:\Shared Virtual Hard Drive Storage\Creator Storage Drives\VST-Plugins-32-64.vhdx
E:\Shared Virtual Hard Drive Storage\Development Drives\dev.azure.com-skyhoshi.vhdx
E:\Shared Virtual Hard Drive Storage\Development Drives\General Drawings and Shared Parts.vhdx
E:\Shared Virtual Hard Drive Storage\Development Drives\Home Management Resources.vhdx
E:\Shared Virtual Hard Drive Storage\Development Drives\Mister FPGA.vhdx
E:\Shared Virtual Hard Drive Storage\Development Drives\Personal Source Code.vhdx
E:\Shared Virtual Hard Drive Storage\Development Drives\Qt Development SDK.vhdx
E:\Shared Virtual Hard Drive Storage\Game Development\LilysGameProjects.vhdx
E:\Shared Virtual Hard Drive Storage\Profile\OneDrive\Sky-M4-OneDrive.vhdx
E:\Shared Virtual Hard Drive Storage\Profile\Rose\Roses StudyDeck Insurance License.vhdx
E:\Shared Virtual Hard Drive Storage\Robot Part Software and OSs.vhdx
#>

# $Drives.Add("") | Out-Null
# $Drives.Add("") | Out-Null
# $Drives.Add("") | Out-Null
# $Drives.Add("") | Out-Null
# $Drives.Add("") | Out-Null
# $Drives.Add("") | Out-Null

#$vhdpath = "$($ProjectStorageLocation)$($VirtualHardDiskFileName)"
#Get-Disk | Where {$_.Model -eq "Virtual Disk"}



#Create, Mount, Init, Partition and Format New Disk.
# New-VHD -Path $vhdpath -Dynamic -SizeBytes $vhdsize | Mount-VHD -Passthru | Initialize-Disk -PartitionStyle GPT -Passthru | New-Partition -DriveLetter $ProjectRootDriveLetter -UseMaximumSize | Format-Volume -NewFileSystemLabel "$ProjectId$ProjectName" -FileSystem ReFS -Confirm:$false -Force | Out-Null
#if ($RunMounting) 
#{
foreach ($drive in $Drives) {
    Write-host "Searching for $drive in: "
    #if (!(Test-Path $drive) -and $CurrentlyAttachedVirtualDisks -notcontains $drive) {
    #We shutdown the Shell Detection Service for a bit due to a popup that is display'd to format the hard disk.
    #We are already formating this so the popup is not needed and should be avoided. this avoids it. 
    Stop-Service -Name ShellHWDetection
    Write-Host "Mounting VHD: $drive"
    Mount-VHD -Path $drive -ErrorAction SilentlyContinue;     
    #Restart the service we stopped.
    Start-Service -Name ShellHWDetection
    # }
}
$Error;
#}
#else {
#    Write-Host "Dry Run of Mounting complete";
#}


<#
PowerShell Extension v2025.4.0
Copyright (c) Microsoft Corporation.

https://aka.ms/vscode-powershell
Type 'help' to get help.


Do you want to run software from this untrusted publisher?
File 
S:\Applications\Global\persist\vscode\data\extensions\ms-vscode.powershell-2025.4.0\modules\PowerShellEditorServices\Commands\PowerShellEditorServices.Com
mands.types.ps1xml is published by CN=Microsoft Corporation, O=Microsoft Corporation, L=Redmond, S=Washington, C=US and is not trusted on your system. 
Only run scripts from trusted publishers.
[V] Never run  [D] Do not run  [R] Run once  [A] Always run  [?] Help (default is "D"): Import-Module 'S:\Applications\Global\apps\vscode\1.141.2\data\extensions\ironmansoftware.powershellprotools-2024.12.0\Modules\PowerShellProTools.VSCode\PowerShellProTools.VSCode.psd1'
[V] Never run  [D] Do not run  [R] Run once  [A] Always run  [?] Help (default is "D"): Import-Module 'S:\Applications\Global\apps\vscode\1.141.2\data\extensions\ironmansoftware.powershellprotools-2024.12.0\Modules\PowerShellProTools\PowerShellProTools.psd1'
[V] Never run  [D] Do not run  [R] Run once  [A] Always run  [?] Help (default is "D"): Start-PoshToolsServer -PipeName 'dsziinlgqjnf'
[V] Never run  [D] Do not run  [R] Run once  [A] Always run  [?] Help (default is "D"): Clear-Host
[V] Never run  [D] Do not run  [R] Run once  [A] Always run  [?] Help (default is "D"): AImport-Module 'S:\Applications\Global\apps\vscode\1.141.2\data\extensions\ironmansoftware.powershellprotools-2024.12.0\Modules\PowerShellProTools.VSCode\PowerShellProTools.VSCode.psd1'
[V] Never run  [D] Do not run  [R] Run once  [A] Always run  [?] Help (default is "D"): Import-Module 'S:\Applications\Global\apps\vscode\1.141.2\data\extensions\ironmansoftware.powershellprotools-2024.12.0\Modules\PowerShellProTools\PowerShellProTools.psd1'
[V] Never run  [D] Do not run  [R] Run once  [A] Always run  [?] Help (default is "D"): Start-PoshToolsServer -PipeName 'dsziinlgqjnf'
[V] Never run  [D] Do not run  [R] Run once  [A] Always run  [?] Help (default is "D"): Clear-Host
[V] Never run  [D] Do not run  [R] Run once  [A] Always run  [?] Help (default is "D"): 









PowerShell Extension v2025.4.0
Copyright (c) Microsoft Corporation.

https://aka.ms/vscode-powershell
Type 'help' to get help.


Do you want to run software from this untrusted publisher?
File 
S:\Applications\Global\persist\vscode\data\extensions\ms-vscode.powershell-2025.4.0\modules\PowerShellEditorServices\Commands\PowerShellE
ditorServices.Commands.types.ps1xml is published by CN=Microsoft Corporation, O=Microsoft Corporation, L=Redmond, S=Washington, C=US and 
is not trusted on your system. Only run scripts from trusted publishers.
[V] Never run  [D] Do not run  [R] Run once  [A] Always run  [?] Help (default is "D"): A

Do you want to run software from this untrusted publisher?
File 
S:\Applications\Global\persist\vscode\data\extensions\ms-vscode.powershell-2025.4.0\modules\PowerShellEditorServices\Commands\Public\Clea
r-Host.ps1 is published by CN=Microsoft Corporation, O=Microsoft Corporation, L=Redmond, S=Washington, C=US and is not trusted on your 
system. Only run scripts from trusted publishers.
[V] Never run  [D] Do not run  [R] Run once  [A] Always run  [?] Help (default is "D"): A

Do you want to run software from this untrusted publisher?
File 
S:\Applications\Global\apps\vscode\1.141.2\16507d91be\resources\app\out\vs\workbench\contrib\terminal\common\scripts\shellIntegration.ps1
 is published by CN=Microsoft Corporation, O=Microsoft Corporation, L=Redmond, S=Washington, C=US and is not trusted on your system. Only
 run scripts from trusted publishers.
[V] Never run  [D] Do not run  [R] Run once  [A] Always run  [?] Help (default is "D"): A
PS K:\By\github\Skyhoshi\VHDXToFolders\ScriptedWorkflow\Dev-Drive> 

#>