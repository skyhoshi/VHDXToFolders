[CmdletBinding()]
param(
	[Parameter(Mandatory, Position = 0)]
	[string] $DatabasePath,

	[Parameter(Mandatory, Position = 1)]
	[string] $KeyFilePath,

	[Parameter()]
	[string] $KeePassLibPath = 'D:\Build\Debug\KeePassLib.dll'
)

foreach ($path in @($DatabasePath, $KeyFilePath, $KeePassLibPath)) {
	if (-not (Test-Path -LiteralPath $path -PathType Leaf)) {
		throw "File not found: $path"
	}
}

Add-Type -Path $KeePassLibPath

$securePassword = Read-Host 'KeePass master password' -AsSecureString
$passwordBstr = [IntPtr]::Zero
$passwordChars = $null
$passwordBytes = $null

try {
	if ($securePassword.Length -eq 0) {
		throw 'The master password cannot be empty.'
	}

	$passwordBstr = [Runtime.InteropServices.Marshal]::SecureStringToBSTR($securePassword)
	$passwordChars = New-Object char[] $securePassword.Length
	[Runtime.InteropServices.Marshal]::Copy(
		$passwordBstr,
		$passwordChars,
		0,
		$passwordChars.Length
	)
	$passwordBytes = [Text.Encoding]::UTF8.GetBytes($passwordChars)

	$compositeKey = [KeePassLib.Keys.CompositeKey]::new()
	$compositeKey.AddUserKey(
		[KeePassLib.Keys.KcpPassword]::new($passwordBytes, $false)
	)
	$compositeKey.AddUserKey([KeePassLib.Keys.KcpKeyFile]::new($KeyFilePath))

	$database = [KeePassLib.PwDatabase]::new()
	$source = [KeePassLib.Serialization.IOConnectionInfo]::FromPath($DatabasePath)
	$database.Open($source, $compositeKey, $null)

	return $database
}
finally {
	if ($passwordBstr -ne [IntPtr]::Zero) {
		[Runtime.InteropServices.Marshal]::ZeroFreeBSTR($passwordBstr)
	}
	if ($null -ne $passwordChars) {
		[Array]::Clear($passwordChars, 0, $passwordChars.Length)
	}
	if ($null -ne $passwordBytes) {
		[Array]::Clear($passwordBytes, 0, $passwordBytes.Length)
	}
	if ($null -ne $securePassword) {
		$securePassword.Dispose()
	}
}
