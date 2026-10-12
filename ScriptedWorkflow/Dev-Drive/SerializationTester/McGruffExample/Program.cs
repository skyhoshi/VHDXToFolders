using System.Net.Http.Headers;

const string defaultBaseUrl = "https://devfcsa.fcsamerica.net";
var baseUrl = Environment.GetEnvironmentVariable("MCGRUFF_BASE_URL") ?? defaultBaseUrl;
var testerName = Environment.GetEnvironmentVariable("MCGRUFF_TESTER") ?? "TesterL";
var cookie = Environment.GetEnvironmentVariable("MCGRUFF_COOKIE");

using var httpClient = new HttpClient
{
	BaseAddress = new Uri(baseUrl, UriKind.Absolute)
};

using var tokenRequest = new HttpRequestMessage(
	HttpMethod.Get,
	$"/mcgruff/reference/rest/api/token/{Uri.EscapeDataString(testerName)}");
tokenRequest.Headers.UserAgent.ParseAdd("McGruffExample/1.0");
tokenRequest.Headers.Accept.Add(new MediaTypeWithQualityHeaderValue("*/*"));
AddCookie(tokenRequest, cookie);

using var tokenResponse = await httpClient.SendAsync(tokenRequest);
var tokenResponseBody = await tokenResponse.Content.ReadAsStringAsync();
tokenResponse.EnsureSuccessStatusCode();

using var auditRequest = new HttpRequestMessage(
	HttpMethod.Get,
	"/mcgruff/v2/rest/api/auditinfo/fcsa");
auditRequest.Headers.TryAddWithoutValidation("Authorization", $"SAML {tokenResponseBody}");
auditRequest.Headers.UserAgent.ParseAdd("McGruffExample/1.0");
auditRequest.Headers.Accept.Add(new MediaTypeWithQualityHeaderValue("*/*"));
AddCookie(auditRequest, cookie);

using var auditResponse = await httpClient.SendAsync(auditRequest);
var auditResponseBody = await auditResponse.Content.ReadAsStringAsync();
auditResponse.EnsureSuccessStatusCode();

Console.WriteLine($"Token request: {(int)tokenResponse.StatusCode} {tokenResponse.ReasonPhrase}");
Console.WriteLine($"Audit request: {(int)auditResponse.StatusCode} {auditResponse.ReasonPhrase}");
Console.WriteLine(auditResponseBody);

static void AddCookie(HttpRequestMessage request, string? cookie)
{
	if (!string.IsNullOrWhiteSpace(cookie))
	{
		request.Headers.TryAddWithoutValidation("Cookie", cookie);
	}
}
