# McGruffExample

This console application performs the two requests in sequence:

1. `GET /mcgruff/reference/rest/api/token/{tester}`
2. `GET /mcgruff/v2/rest/api/auditinfo/fcsa`

The first response body is retained in `tokenResponseBody` and sent as the
second request's `Authorization: SAML ...` value. The audit response body is
retained in `auditResponseBody` and written to the console.

Set these environment variables before running:

```powershell
$env:MCGRUFF_BASE_URL = "https://devfcsa.fcsamerica.net"
$env:MCGRUFF_TESTER = "TesterL"
$env:MCGRUFF_COOKIE = "NodeSelection=..." # optional
dotnet run --project .\McGruffExample.csproj
```

The program does not persist either response to disk.