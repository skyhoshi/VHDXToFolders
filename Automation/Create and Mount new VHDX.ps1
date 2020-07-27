
$VHDXPath = "D:\User Account Data Storage\VHDXs\Marcus\"
$AccessPath = "C:\Program Files\" + "\Arduino"
$CleanUp = 1;

$Folders = Get-ChildItem -Directory | Sort-Object -Property {$_.Name -as [string]} | Where-Object {$_.Name.StartsWith(".arm")};

foreach($folder in $Folders){
    #Get the Folder name as the initial VHDX Filename
    $VHDXFileName = $folder.Name.Replace(".", "");
    #Provide a General Description to the Filename of the VHDX
    $VHDXFileName = $VHDXFileName + "_UserFolder.vhdx";
    Write-Debug $VHDXFileName;
    #Create the full path for the storage of the VHDX file.
    $VHDXPath = $VHDXPath + $VHDXFileName
    Write-Debug $VHDXPath;
    $folderTempName = $folder.Name + "_temp";
    $folderTemp = $folder.FullName.Substring(0, $folder.FullName.LastIndexOf("\")) + "\" + $folderTempName;
    Write-Debug $folderTemp;

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