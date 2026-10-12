using System.Net.Http.Headers;
using System.Text.Json;
using System.Text.Json.Serialization;

internal sealed class Program
{
    private static readonly HttpClient HttpClient = new();
    private static string? accessToken;
    private static DateTimeOffset accessTokenExpiration;

    public static async Task Main(string[] args)
    {
        var token = await GetAccessTokenAsync();
        Console.WriteLine("Successfully retrieved an Okta access token.");

        if (args.Length == 0)
        {
            return;
        }

        using var request = new HttpRequestMessage(HttpMethod.Get, args[0]);
        request.Headers.Authorization = new AuthenticationHeaderValue("Bearer", token);

        using var response = await HttpClient.SendAsync(request);
        Console.WriteLine($"{(int)response.StatusCode} {response.ReasonPhrase}");
        Console.WriteLine(await response.Content.ReadAsStringAsync());
        response.EnsureSuccessStatusCode();
    }

    private static async Task<string> GetAccessTokenAsync()
    {
        if (!string.IsNullOrEmpty(accessToken) && DateTimeOffset.UtcNow < accessTokenExpiration)
        {
            return accessToken;
        }

        var clientId = GetRequiredEnvironmentVariable("APPLICATION_CLIENTID");
        var clientSecret = GetRequiredEnvironmentVariable("APPLICATION_CLIENTSECRET");
        var authorizationServerIssuer = GetRequiredEnvironmentVariable("AUTHSERVER_ISSUER").TrimEnd('/');
        var scopes = Environment.GetEnvironmentVariable("APPLICATION_SCOPES");

        using var content = new FormUrlEncodedContent(new Dictionary<string, string>
        {
            ["grant_type"] = "client_credentials",
            ["client_id"] = clientId,
            ["client_secret"] = clientSecret,
            ["scope"] = scopes ?? string.Empty
        });
        using var response = await HttpClient.PostAsync($"{authorizationServerIssuer}/v1/token", content);
        var responseBody = await response.Content.ReadAsStringAsync();
        response.EnsureSuccessStatusCode();

        var tokenResponse = JsonSerializer.Deserialize<TokenResponse>(responseBody)
            ?? throw new InvalidOperationException("Okta returned an empty token response.");

        if (string.IsNullOrWhiteSpace(tokenResponse.AccessToken))
        {
            throw new InvalidOperationException("Okta did not return an access token.");
        }

        accessToken = tokenResponse.AccessToken;
        accessTokenExpiration = DateTimeOffset.UtcNow.AddSeconds(Math.Max(0, tokenResponse.ExpiresIn - 60));
        return accessToken;
    }

    private static string GetRequiredEnvironmentVariable(string name) =>
        Environment.GetEnvironmentVariable(name) is { Length: > 0 } value
            ? value
            : throw new InvalidOperationException($"The {name} environment variable is required.");

    private sealed record TokenResponse(
        [property: JsonPropertyName("access_token")] string AccessToken,
        [property: JsonPropertyName("expires_in")] int ExpiresIn);
}