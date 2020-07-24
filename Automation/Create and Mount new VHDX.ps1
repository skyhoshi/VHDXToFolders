
$VHDXPath = "D:\User Account Data Storage\VHDXs\Marcus\"
$AccessPath = "C:\TestPath\"
$CleanUp = 1;

$Folders = Get-ChildItem -Directory | Sort-Object -Property {$_.Name -as [string]} | Where-Object {$_.Name.StartsWith(".arm")};

foreach($folder in $Folders){

    $VHDXFileName = $folder.Name.Replace(".", "");
    $VHDXFileName = $VHDXFileName + "_UserFolder.vhdx";
    #Write-Host $VHDXFileName;
    $VHDXPath = $VHDXPath + $VHDXFileName
    #Write-Host $VHDXPath;
    $folderTempName = $folder.Name + "_temp";
    $folderTemp = $folder.FullName.Substring(0, $folder.FullName.LastIndexOf("\")) + "\" + $folderTempName;
    #Write-Host $folderTemp;

    $AccessPath = $folder.FullName;

    Rename-Item -Path $folder -NewName $folderTemp

    ############################################################################
    $VHDX = New-VHD -Path ($VHDXPath) -SizeBytes 1099511627776 -Dynamic
    Mount-VHD -Path $VHDXPath
    $VHDX = Get-VHD -Path $VHDXPath
    if (![System.IO.Directory]::Exists($path)){
        $AccessPathObj = [System.IO.Directory]::CreateDirectory($AccessPath);
    }
    $NewVolume = New-Volume -DiskNumber $VHDX.DiskNumber  -FriendlyName "Test Volume" -AccessPath $AccessPath
    ############################################################################
    
    $SourceMoveLoc = $folderTemp + "\*";
    $DestinMoveLoc = $AccessPath + "\";

    Copy-Item -Path $SourceMoveLoc -Destination $DestinMoveLoc

    #Remove-Item -Path $folderTemp

    break;
}

if ($CleanUp -ieq 0)
{
    Dismount-VHD -Path $VHDXPath
    Remove-Item -Path $VHDXPath
    Remove-Item -Path $AccessPath -Force
}