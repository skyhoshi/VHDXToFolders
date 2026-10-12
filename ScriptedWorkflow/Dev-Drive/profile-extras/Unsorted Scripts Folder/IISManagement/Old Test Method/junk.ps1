# Get-ItemProperty IIS:\AppPools\p-engapi | Select * 
# Get-ItemProperty IIS:\AppPools\p-engine | Select *
# Get-ItemProperty IIS:\AppPools\p-engapi -name workerprocesses
# Get-ItemProperty IIS:\AppPools\p-engine -name workerprocesses

# Get-ItemProperty iis:\AppPools\p-engine -Name managedRuntimeVersion
# Get-ItemProperty iis:\AppPools\p-engapi -Name managedRuntimeVersion

# Set-ItemProperty IIS:\AppPools\p-engapi -name managedRuntimeVersion -Value ""

. "C:\Users\kernm\OneDrive - Farm Credit Services of America\Documents\PowerShell\Scripts\listmethodsinps1file.ps1"
