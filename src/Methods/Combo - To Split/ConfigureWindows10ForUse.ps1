<#
Alias           Add-WindowsFeature                                 2.0.0.0    ServerManager
Alias           Remove-WindowsFeature                              2.0.0.0    ServerManager
Function        Disable-NetworkSwitchFeature                       1.0.0.0    NetworkSwitchManager
Function        Enable-NetworkSwitchFeature                        1.0.0.0    NetworkSwitchManager
Function        Get-NetworkSwitchFeature                           1.0.0.0    NetworkSwitchManager
Function        Get-ServerFeature                                  1.0.0.0    ServerManagerTasks
Cmdlet          Disable-ADOptionalFeature                          1.0.1.0    ActiveDirectory
Cmdlet          Disable-ExperimentalFeature                        7.0.0.0    Microsoft.PowerShell.Core
Cmdlet          Disable-WindowsOptionalFeature                     3.0        Dism
Cmdlet          Enable-ADOptionalFeature                           1.0.1.0    ActiveDirectory
Cmdlet          Enable-ExperimentalFeature                         7.0.0.0    Microsoft.PowerShell.Core
Cmdlet          Enable-WindowsOptionalFeature                      3.0        Dism
Cmdlet          Get-ADOptionalFeature                              1.0.1.0    ActiveDirectory
Cmdlet          Get-AzureRmProviderFeature                         5.5.2      AzureRM.Resources
Cmdlet          Get-ExperimentalFeature                            7.0.0.0    Microsoft.PowerShell.Core
Cmdlet          Get-TpmSupportedFeature                            2.0.0.0    TrustedPlatformModule
Cmdlet          Get-WindowsFeature                                 2.0.0.0    ServerManager
Cmdlet          Get-WindowsOptionalFeature                         3.0        Dism
Cmdlet          Install-WindowsFeature                             2.0.0.0    ServerManager
Cmdlet          Register-AzureRmProviderFeature                    5.5.2      AzureRM.Resources
Cmdlet          Uninstall-WindowsFeature                           2.0.0.0    ServerManager
Application     OptionalFeatures.exe                               10.0.1836… C:\WINDOWS\system32\OptionalFeatures.exe
#>

<#
Get-WindowsOptionalFeature -online -FeatureName Microsoft-Hyper-V-Tools-All

FeatureName      : Microsoft-Hyper-V-Tools-All
DisplayName      : Hyper-V Management Tools
Description      : Includes GUI and command-line tools for managing Hyper-V.
RestartRequired  : Possible
State            : Disabled
CustomProperties :
#>
# Get-WindowsOptionalFeature -Online
# Get-WindowsOptionalFeature -Online | Where {$_.State -eq "Enabled"} | Format-Table
# Get-WindowsOptionalFeature -Online | Where {$_.State -eq "Disabled"} | Format-Table
#Enable-WindowsOptionalFeature -FeatureName Microsoft-Hyper-V-Tools-All -Online


<#
Cmdlet          Add-VMDvdDrive                                     2.0.0.0    Hyper-V
Cmdlet          Add-VMRemoteFx3dVideoAdapter                       2.0.0.0    Hyper-V
Cmdlet          Convert-VHD                                        2.0.0.0    Hyper-V
Cmdlet          Disable-VMRemoteFXPhysicalVideoAdapter             2.0.0.0    Hyper-V
Cmdlet          Dismount-VHD                                       2.0.0.0    Hyper-V
Cmdlet          Enable-VMRemoteFXPhysicalVideoAdapter              2.0.0.0    Hyper-V
Cmdlet          Get-VHD                                            2.0.0.0    Hyper-V
Cmdlet          Get-VHDSet                                         2.0.0.0    Hyper-V
Cmdlet          Get-VHDSnapshot                                    2.0.0.0    Hyper-V
Cmdlet          Get-VMDvdDrive                                     2.0.0.0    Hyper-V
Cmdlet          Get-VMRemoteFx3dVideoAdapter                       2.0.0.0    Hyper-V
Cmdlet          Get-VMRemoteFXPhysicalVideoAdapter                 2.0.0.0    Hyper-V
Cmdlet          Get-VMVideo                                        2.0.0.0    Hyper-V
Cmdlet          Merge-VHD                                          2.0.0.0    Hyper-V
Cmdlet          Mount-VHD                                          2.0.0.0    Hyper-V
Cmdlet          New-VFD                                            2.0.0.0    Hyper-V
Cmdlet          New-VHD                                            2.0.0.0    Hyper-V
Cmdlet          Optimize-VHD                                       2.0.0.0    Hyper-V
Cmdlet          Optimize-VHDSet                                    2.0.0.0    Hyper-V
Cmdlet          Remove-VHDSnapshot                                 2.0.0.0    Hyper-V
Cmdlet          Remove-VMDvdDrive                                  2.0.0.0    Hyper-V
Cmdlet          Remove-VMRemoteFx3dVideoAdapter                    2.0.0.0    Hyper-V
Cmdlet          Remove-VMSavedState                                2.0.0.0    Hyper-V
Cmdlet          Resize-VHD                                         2.0.0.0    Hyper-V
Cmdlet          Set-VHD                                            2.0.0.0    Hyper-V
Cmdlet          Set-VMDvdDrive                                     2.0.0.0    Hyper-V
Cmdlet          Set-VMRemoteFx3dVideoAdapter                       2.0.0.0    Hyper-V
Cmdlet          Set-VMVideo                                        2.0.0.0    Hyper-V
Cmdlet          Test-VHD                                           2.0.0.0    Hyper-V
#>
enum DirectoryState {
    File
    Directory
    SymbolicLink
    Junction
    VHD
}



function Rename-VHDXDirectory(){
    
}