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
$sampleTitle = 'PowerShell KeePass integration test'
$sampleUsername = 'test.user@example.invalid'
$samplePassword = 'Entry-Test-Only-Password-456!'

foreach ($path in @($databasePath, $keyFilePath)) {
	if (-not (Test-Path -LiteralPath $path -PathType Leaf)) {
		throw "Test fixture not found: $path. Run Test-CreatePwDatabase.ps1 first."
	}
}

$compositeKey = [KeePassLib.Keys.CompositeKey]::new()
$compositeKey.AddUserKey([KeePassLib.Keys.KcpPassword]::new($masterPassword))
$compositeKey.AddUserKey([KeePassLib.Keys.KcpKeyFile]::new($keyFilePath))
$connection = [KeePassLib.Serialization.IOConnectionInfo]::FromPath($databasePath)
$database = [KeePassLib.PwDatabase]::new()

try {
	$database.Open($connection, $compositeKey, $null)
	$entry = [KeePassLib.PwEntry]::new($true, $true)
	$entry.Strings.Set(
		[KeePassLib.PwDefs]::TitleField,
		[KeePassLib.Security.ProtectedString]::new($true, $sampleTitle)
	)
	$entry.Strings.Set(
		[KeePassLib.PwDefs]::UserNameField,
		[KeePassLib.Security.ProtectedString]::new($true, $sampleUsername)
	)
	$entry.Strings.Set(
		[KeePassLib.PwDefs]::PasswordField,
		[KeePassLib.Security.ProtectedString]::new($true, $samplePassword)
	)

	$database.RootGroup.AddEntry($entry, $true)
	$database.Save($null)
	Write-Output 'PASS: Test-UpdatePwDatabase'
}
finally {
	if ($database.IsOpen) {
		$database.Close()
	}
}
