$server = "localhost"
$port = 1433

$result = Test-NetConnection -ComputerName $server -Port $port

if ($result.TcpTestSucceeded) {
    Write-Output "SQL Server is running on port $port, please shut it down."
}
