. "C:\Users\kernm\OneDrive - Farm Credit Services of America\Documents\PowerShell\Scripts\listmethodsinps1file.ps1"

$nodeModules = @(
    "@nguniversal/express-engine@10.1.0",
    ""
)


foreach ($nodeModules in $nodeModules) {
    if ($nodeModules){
        npm info $nodeModules peerDependencies
    }
}