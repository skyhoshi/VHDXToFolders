$gitRepoPath = 'F:\UccFiling' # should contain the .git folder
if (-not (Test-Path -Path $gitRepoPath -PathType Container)) {
    Write-Host "The specified git repository path does not exist: $gitRepoPath" -ForegroundColor Red
    exit 1
}
Set-Location $gitRepoPath
New-Item -Path '.\src\libraries' -ItemType Directory -Force | Out-Null
$folders = @('AdaAdapter','BusinessLogic','Common','Contracts','DataAccess','LoadTests','Mocks','UccFilingTimer','UnitTests')
foreach ($f in $folders) {
    git mv ('.\Source\' + $f) ('.\src\libraries\' + $f)
}
git status --short