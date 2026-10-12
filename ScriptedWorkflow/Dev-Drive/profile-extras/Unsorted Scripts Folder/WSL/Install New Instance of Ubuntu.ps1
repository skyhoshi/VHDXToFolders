Invoke-WebRequest -Uri https://aka.ms/wsl-ubuntu -OutFile Ubuntu.appx -UseBasicParsing
Add-AppxPackage .\Ubuntu.appx