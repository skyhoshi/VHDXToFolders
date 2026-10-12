Write-Host "Loading Docker Project Management Classes";
. "C:\Users\kernm\OneDrive - Farm Credit Services of America\Documents\PowerShell\Scripts\listmethodsinps1file.ps1"
class DockerProject{
    [int] $Index;
    [string] $Title;
    [string] $SourceLocation;
    [DockerProjectDetailInfo] $DockerInformation;
}
class DockerProjectDetailInfo{
    [string]$BuildLocation ;
    [string]$imageTag;
    [string]$dockerFilePath;
}
