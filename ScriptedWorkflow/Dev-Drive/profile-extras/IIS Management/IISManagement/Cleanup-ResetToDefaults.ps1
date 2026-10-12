$AppPoolsToRemain = @(
    ".NET v2.0",
    ".NET v2.0 Classic",
    ".NET v4.5",
    ".NET v4.5 Classic",
    "Classic .NET AppPool",
    "Default Web Site",
    "DefaultAppPool"
)
$PhysicalPathsToIgnoreViaNotLike = @("Q:\Loan*")


# function Clear-PatronageIISSites {
#     [CmdletBinding()]
#     param (
#         [Parameter()][string]$IISAppPoolName,
#         [Parameter()][string]$IISAppPoolRootLocation,
#         [Parameter()][string]$IISVirtualDirectory = $null
#     )
#
#     # if (Test-Path "IIS:\Site\Default Web Site\$($IISAppPoolRootLocation)") {
#     #     Remove-WebApplication -Site "Default Web Site" -Name $IISAppPoolRootLocation
#     #     if ($null -eq $IISVirtualDirectory) {
#     #         Remove-WebVirtualDirectory -Site "Default Web Site" -Name $IISVirtualDirectory -Application .
#     #     }
#     # }
#     # if (Test-Path "IIS:\AppPools\$($IISAppPoolName)") {
#     #     Remove-WebAppPool -Name $IISAppPoolName
#     # }
# }

# # if ($DebugMode) {
# #     Clear-PatronageIISSites -IISAppPoolName "p-elaapi" -IISAppPoolRootLocation "patronage/elastic/v1" -IISVirtualDirectory "patronage/elastic"
# #     #This should return 0 if you want to start completely over.
# #     Get-ChildItem -Path "IIS:\Sites\Default Web Site\" | Where-Object { $_.NodeType -eq "application" -or $_.NodeType -eq "virtualDirectory" }
# # }
<#
AppPools not to remove / Delete
Name  : .NET v2.0
Name  : .NET v2.0 Classic
Name  : .NET v4.5
Name  : .NET v4.5 Classic
Name  : Classic .NET AppPool
Name  : Default Web Site
Name  : DefaultAppPool
#>


function Get-IISTypesToCleanUp() {
    $SiteItemsToClean = Get-ChildItem -Path 'IIS:\Sites\Default Web Site\' | Where-Object { <#$PhysicalPathsToIgnoreViaNotLike -notcontains $_.PhysicalPath #> $excludePatternFound = $false; foreach ($pattern in $PhysicalPathsToIgnoreViaNotLike) { if ($_.PhysicalPath -like $pattern) { $excludePatternFound = $true; break;}} -not $excludePatternFound -and $_.NodeType -ne "file" -and $_.NodeType -ne "directory" } | Sort-Object -Property NodeType
    foreach ($item in $SiteItemsToClean) {
        if ($item.NodeType -ne "application" -and $item.NodeType -ne "virtualDirectory") { throw "you have no items to clean"; }
        if ($item.NodeType -eq "application") {
            Remove-WebApplication -Site "Default Web Site" -Name $item.name
        }
        if ($item.NodeType -eq "virtualDirectory") {
            Remove-WebVirtualDirectory -Site "Default Web Site" -Name $item.Name -Application .
        }
    }
    $AppPoolItemsToClean = Get-ChildItem -Path 'IIS:\AppPools\' | Where-Object { $AppPoolsToRemain -notcontains $_.name }
    foreach ($appPool in $AppPoolItemsToClean) {
        Remove-WebAppPool -Name $appPool.Name
    }
}

#Get-IISTypesToCleanUp;