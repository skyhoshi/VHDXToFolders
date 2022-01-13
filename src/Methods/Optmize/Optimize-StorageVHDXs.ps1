Set-Location -Path $env:VHDXStorage;
(Get-ChildItem -Path . -Include "*.vhdx" -Recurse | Select FullName).Foreach({
    Optimize-VHD -Mode Full -Path $_.FullName
});