# Install-module nuget

# Install-Package System.Data.SQLite -Source nuget.org #-Version 2.0.3
# ######################################################################################################################################################
# <#
# dotnet add package Microsoft.Data.Sqlite

# Add-Type -AssemblyName "Microsoft.Data.Sqlite"

# $connection = New-Object Microsoft.Data.Sqlite.SqliteConnection("Data Source=D:\TokenCache\mydb.sqlite")
# $connection.Open()
# $connection.Close()
# #>

$typeLocation =  "D:\TokenCache\Sqlite\system.data.sqlite.2.0.3\lib\net47\System.Data.SQLite.dll"
Add-Type -Path $typeLocation

$connString = "Data Source=D:\TokenCache\mydb.sqlite;"
$connection = New-Object System.Data.SQLite.SQLiteConnection($connString)
$connection.Open()
$connection.Close()
