$path = "F:\293813-DigitalServices\"

# SSH (default)
. $PSScriptRoot\Export-RepositoryOrigins.ps1 -RootPath $path

# HTTPS
#. $PSScriptRoot\Export-RepositoryOrigins.ps1 -UrlProtocol Https -RootPath $path