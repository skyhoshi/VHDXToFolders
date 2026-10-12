
$env:FIND_REFS_CACHE_DIR = "D:\kernm.devcontainer.envsetup\Research\McGruff\FindRefsCache"
$env:FIND_REFS_CACHE_ENABLED = "true"
$env:FIND_REFS_CACHE_CLEAR = "false"

if ("true" -eq $env:FIND_REFS_CACHE_CLEAR) {
    if (Test-Path $env:FIND_REFS_CACHE_DIR) {
        Remove-Item -Path $env:FIND_REFS_CACHE_DIR -Recurse -Force
    }
}

$excludePatterns = @(
    ".vs/",    
    "*.UnitTests/", 
    "*.TestingCore.csproj", 
    "*.Testing.Core.csproj", 
    "*.IntegrationTests.csproj", 
    "WebAPI.External/source/External.WebApi.IntegrationTests", 
    "FakeEcsConfigMaker.cs", 
    "FCSAmerica.McGruff.Core.xml",
    "*.dtbcache.json",    
    "readme.txt",
    "Changes.txt")
# $RepoMap = ([ordered]@{
#         'Forms'           = 'Forms'
#         'Renewal.WebAPI'  = 'Renewal.WebAPI'
#         'WebAPI.External' = 'WebAPI.External'
#         'WebAPI'          = 'WebAPI'
#         'WebUI'           = 'WebUI'
#         'SecureImageCapture' = 'SecureImageCapture'
#         'UniversalMobilePlatform_XP_API' = 'UniversalMobilePlatform_XP_API'
#         'Equipment.API' = 'Equipment.API'
#         'Fraud.API' = 'Fraud.API'
#     })

$excludeLinePatterns = @(
    "using FCSAmerica.IdentityAccessManagement.McGruffCompatibility;",
    "<FCSAmerica.McGruff.Core.Properties.McGruffSettings>",
    "</FCSAmerica.McGruff.Core.Properties.McGruffSettings>",
    "<FCSAmerica.IdentityAccessManagement.McGruffCompatibility.Properties.Settings>",
    "</FCSAmerica.IdentityAccessManagement.McGruffCompatibility.Properties.Settings>",
    "<!-- TraceSource for the internals of the McGruff compatibility code -->",
    "<!-- McGruff Settings Start -->",
    "<!-- McGruff Settings End -->",
    # "<section name=`"FCSAmerica.McGruff.Core.Properties.McGruffSettings`" type=`"System.Configuration.ClientSettingsSection, System, Version=4.0.0.0, Culture=neutral, PublicKeyToken=b77a5c561934e089`" requirePermission=`"false`" />",
    # "<section name=`"FCSAmerica.IdentityAccessManagement.McGruffCompatibility.Properties.Settings`" type=`"System.Configuration.ClientSettingsSection, System, Version=4.0.0.0, Culture=neutral, PublicKeyToken=b77a5c561934e089`" requirePermission=`"false`" />",
    # "<section name=`"FCSAmerica.IdentityAccessManagement.McGruffCompatibility.Properties.Settings`" type=`"System.Configuration.ClientSettingsSection, System, Version=4.0.0.0, Culture=neutral, PublicKeyToken=b77a5c561934e089`" requirePermission=`"false`" />",
    "<section name=",
    "<PackageReference Include=",
    "<HintPath>..\packages\FCSAmerica.McGruff.TokenGenerator.4.0.1\lib\net472\McGruff.TokenGenerator.dll</HintPath>",
    "<HintPath>*</HintPath>"
    # "<PackageReference Include=`"FCSAmerica.IdentityAccessManagement.McGruffCompatibility`" />"
)

#-ExcludeFileLines "McGruffSettings.cs:42",               # bare filename
#                  "Source/McGruffSettings.cs:42",         # partial forward-slash path
#                  "WebAPI\Source\McGruffSettings.cs:42"   # backslashes normalised automatically
$ExcludeFileLines = @(
    "Forms/Source/FormGeneration/app.config:6",
    "Forms/Source/WebAPI/Web.config:11",
    "Forms/Source/Common/Common.csproj:74"
)

$SearchTerms = @('McGruff', 'IMcGruff', 'McGruffClient', 'CreateMcGruffGateway', 'SecurityContext.GetInstance', 'ServiceToken', 'McGruffProxyHandler', 'ISecurityContext, SecurityContext')
# Exclude by filename/extension

$ProjectName = "CIVSubArchive"


$outputDirectory = "D:\ProjectInventoryReports"

if (!(Test-Path (Join-Path "$outputDirectory" $ProjectName))) {
    New-Item -ItemType Directory -Path (Join-Path "$outputDirectory" $ProjectName) -Force | Out-Null
}
else {
    Remove-Item -Path (Join-Path "$outputDirectory" $ProjectName *.*) -Recurse -Force
}
;

$AzureDevOpsProject = "CIVSubArchive"

$includeOnlyDrives = @("A", "B", "F", "G", "H", "I", "J", "K", "L", "M", "N", "Q", "R", "S", "T", "U", "V", "X", "Y", "Z" )

.\Research\Run-ProjectInventory_MARKDOWN.ps1 -OutputDir "$(Join-Path "$outputDirectory" $ProjectName "inventory")" -IncludeOnlyDrives $includeOnlyDrives

foreach ($drive in $includeOnlyDrives) {
    $workspaceRoot = "$($drive):\"
    #$outputFile = (Join-Path "$outputDirectory" $ProjectName "Search-References-$($drive)-$(Get-Date -Format 'yyyyMMddHHmmss').md")
    $outputDir = $(Join-Path "$outputDirectory" $ProjectName $drive);
    if (!(Test-Path $outputDir)) {
        New-Item -ItemType Directory -Path $outputDir -Force | Out-Null
    }
    .\Research\Find-McGruffReferences.ps1 -WorkspaceRoot $workspaceRoot -OutputDir $outputDir -SearchTerms $SearchTerms -ExcludePatterns $excludePatterns -ExcludeLinePatterns $excludeLinePatterns -ExcludeFileLines $ExcludeFileLines
}
#.\Research\Find-McGruffReferences.ps1 -WorkspaceRoot 'R:\' -OutputFile $outputFile -ExcludePatterns $excludePatterns -ExcludeLinePatterns $excludeLinePatterns -SearchTerms $SearchTerms -ExcludeFileLines $ExcludeFileLines  <#-RepoMap $RepoMap#> #-AzureDevOpsProject $AzureDevOpsProject 
#.\Research\Find-McGruffReferences.ps1 -WorkspaceRoot 'M:\' -OutputFile $outputFile -ExcludePatterns $excludePatterns -ExcludeLinePatterns $excludeLinePatterns -SearchTerms $SearchTerms -ExcludeFileLines $ExcludeFileLines #-RepoMap $RepoMap
#.\Research\Find-McGruffReferences.ps1 -WorkspaceRoot 'N:\' -OutputFile $outputFile -ExcludePatterns $excludePatterns -ExcludeLinePatterns $excludeLinePatterns -SearchTerms $SearchTerms -ExcludeFileLines $ExcludeFileLines #-RepoMap $RepoMap
#.\Research\Find-McGruffReferences.ps1 -WorkspaceRoot 'Q:\' -OutputFile $outputFile -ExcludePatterns $excludePatterns -ExcludeLinePatterns $excludeLinePatterns -SearchTerms $SearchTerms -ExcludeFileLines $ExcludeFileLines #-RepoMap $RepoMap



