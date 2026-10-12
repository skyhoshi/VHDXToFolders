# https://aspire.dev/reference/cli/install-script/
# Remove previous versions
Remove-Item -Recurse -Force "$HOME\.aspire\bin"
# Install latest version
Invoke-RestMethod -Uri "https://aspire.dev/install.ps1" | Invoke-Expression
# Verify installation
aspire --version