# Create Folder
sudo mkdir /usr/share/PowerShell
# Change Working Dir
cd /usr/share/PowerShell


sudo wget https://github.com/PowerShell/PowerShell/releases/download/v7.3.6/powershell-7.3.6-linux-x64.tar.gz
sudo tar xzvf powershell-7.3.6-linux-x64.tar.gz
# Navigate to home directory
cd ~
# Edit the .profile file
# nano .profile
echo .profile >> PATH="$PATH:/usr/share/PowerShell"

sudo rm /usr/share/PowerShell/powershell-7.0.0-rc.2-linux-x64.tar.gz