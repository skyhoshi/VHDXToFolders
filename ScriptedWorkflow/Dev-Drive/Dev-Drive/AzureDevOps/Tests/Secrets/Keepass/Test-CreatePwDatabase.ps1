[CmdletBinding()]
param(
	[string] $TestDirectory = 'D:\ScriptDataCache\KeePassPwDatabaseTests',
	[string] $KeePassLibPath = 'D:\Build\Debug\KeePassLib.dll'
)

$ErrorActionPreference = 'Stop'

if (-not (Test-Path -LiteralPath $KeePassLibPath -PathType Leaf)) {
	throw "KeePassLib.dll not found: $KeePassLibPath"
}
if ($null -eq ('KeePassLib.PwDatabase' -as [type])) {
	Add-Type -Path $KeePassLibPath
}

$databasePath = Join-Path $TestDirectory 'PwDatabase.Test.kdbx'
$keyFilePath = Join-Path $TestDirectory 'PwDatabase.Test.key'
$masterPassword = 'KeePass-Test-Only-Password-123!'
$random = [Security.Cryptography.RandomNumberGenerator]::Create()
$keyFileBytes = New-Object byte[] 32
$database = $null

try {
	$null = New-Item -ItemType Directory -Path $TestDirectory -Force
	Remove-Item -LiteralPath $databasePath, $keyFilePath -Force -ErrorAction SilentlyContinue

	$random.GetBytes($keyFileBytes)
	[IO.File]::WriteAllBytes($keyFilePath, $keyFileBytes)

	$compositeKey = [KeePassLib.Keys.CompositeKey]::new()
	$compositeKey.AddUserKey([KeePassLib.Keys.KcpPassword]::new($masterPassword))
	$compositeKey.AddUserKey([KeePassLib.Keys.KcpKeyFile]::new($keyFilePath))

	$database = [KeePassLib.PwDatabase]::new()
	$connection = [KeePassLib.Serialization.IOConnectionInfo]::FromPath($databasePath)
	$database.New($connection, $compositeKey)
	$database.Save($null)
	$database.Close()

	if (-not (Test-Path -LiteralPath $databasePath -PathType Leaf)) {
		throw 'KeePass did not create the database file.'
	}
	if ((Get-Item -LiteralPath $databasePath).Length -eq 0) {
		throw 'KeePass created an empty database file.'
	}
	if ((Get-Item -LiteralPath $keyFilePath).Length -ne 32) {
		throw 'The generated key file must contain exactly 32 bytes.'
	}

	$database = [KeePassLib.PwDatabase]::new()
	$database.Open($connection, $compositeKey, $null)
	if (-not $database.IsOpen) {
		throw 'The newly created database could not be reopened.'
	}

	Write-Output 'PASS: Test-CreatePwDatabase'
}
finally {
	if (($null -ne $database) -and $database.IsOpen) {
		$database.Close()
	}
	$random.Dispose()
	[Array]::Clear($keyFileBytes, 0, $keyFileBytes.Length)
}
