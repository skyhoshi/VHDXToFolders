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
$expectedTitle = 'PowerShell KeePass integration test'
$expectedUsername = 'test.user@example.invalid'
$expectedPassword = 'Entry-Test-Only-Password-456!'

foreach ($path in @($databasePath, $keyFilePath)) {
	if (-not (Test-Path -LiteralPath $path -PathType Leaf)) {
		throw "Test fixture not found: $path. Run Test-CreatePwDatabase.ps1 and Test-UpdatePwDatabase.ps1 first."
	}
}

$compositeKey = [KeePassLib.Keys.CompositeKey]::new()
$compositeKey.AddUserKey([KeePassLib.Keys.KcpPassword]::new($masterPassword))
$compositeKey.AddUserKey([KeePassLib.Keys.KcpKeyFile]::new($keyFilePath))
$connection = [KeePassLib.Serialization.IOConnectionInfo]::FromPath($databasePath)
$database = [KeePassLib.PwDatabase]::new()

try {
	$database.Open($connection, $compositeKey, $null)
	$entry = $null
	foreach ($candidate in $database.RootGroup.Entries) {
		if ($candidate.Strings.ReadSafe([KeePassLib.PwDefs]::TitleField) -ceq $expectedTitle) {
			$entry = $candidate
			break
		}
	}

	if ($null -eq $entry) {
		throw "Saved entry '$expectedTitle' was not found in the database."
	}
	if ($entry.Strings.ReadSafe([KeePassLib.PwDefs]::UserNameField) -cne $expectedUsername) {
		throw 'The saved entry username did not match the expected value.'
	}
	if ($entry.Strings.ReadSafe([KeePassLib.PwDefs]::PasswordField) -cne $expectedPassword) {
		throw 'The saved entry password did not match the expected value.'
	}

	Write-Output 'PASS: Test-ReadPwDatabase'
}
finally {
	if ($database.IsOpen) {
		$database.Close()
	}
}
