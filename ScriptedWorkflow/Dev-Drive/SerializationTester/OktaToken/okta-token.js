//pm.request.headers.add("Authorization: Bearer " + postman.getGlobalVariable("OKTA_TOKEN"));

if (!pm.environment.get("OKTA_TOKEN")
    || !pm.environment.get("OKTA_TOKEN_EXPIRATION")
    || new Date() > new Date(pm.environment.get("OKTA_TOKEN_EXPIRATION"))) {
    //Access token is null or it has expired
    console.log('Access token is null or it has expired.  Retrieving new token.');

    getClientCredentialsAccessToken().then(response => setAuthorizationHeader());

} else {
    console.log('Access token is good to go.');
    setAuthorizationHeader();
}

//Set the auth header for the actual call to the api
function setAuthorizationHeader() {
    console.log('Setting authorization header');
    pm.request.headers.add("Authorization: Bearer " + pm.environment.get("OKTA_TOKEN"));
}

//Get the client credential access token to amake the actual call to the api
function getClientCredentialsAccessToken() {
    console.log('Calling getClientCredentialsAccessToken');

    if (!pm.environment.get('APPLICATION_CLIENTID')
        || !pm.environment.get('APPLICATION_SECRET')
        || !pm.environment.get('AUTHSERVER_ISSUER')) {
            // If WE don't already have the application security information look it up then get and populate the access token
        return populateAccessTokenAsync();

    } else {
        // get and populate the access token
      
         console.error('You must provide APPLICATION_CLIENTID, APPLICATION_SECRET, and AUTHSERVER_ISSUER');
         //reject(err);
    }
}

function populateAccessTokenAsync() {
    var apiUrl = pm.environment.get('AUTHSERVER_ISSUER') + '/v1/token';  

    var clientCredentialRequest = {
        url: apiUrl,
        method: 'POST',
        header: {
            'Content-Type': 'application/x-www-form-urlencoded'
        },
        body: {
            mode: 'urlencoded',
            urlencoded: [
                { key: "scope", value: pm.environment.get('APPLICATION_SCOPES') },
                { key: "grant_type", value: "client_credentials" },
                { key: "client_id", value: pm.environment.get('APPLICATION_CLIENTID') },
                { key: "client_secret", value: pm.environment.get('APPLICATION_CLIENTSECRET') }
            ]
        }
    };

    return new Promise((resolve, reject) => {
        pm.sendRequest(clientCredentialRequest, function (err, response) {

            if (response.code === 200) {
                var responseData = JSON.parse(response.text());
                //Set the token to be used later
                pm.environment.set("OKTA_TOKEN", responseData.access_token)

                var currentDate = new Date();
                var expiration = currentDate.setSeconds(currentDate.getSeconds() + (responseData.expires_in - 60)); //60 second buffer

                //set the expiration of the token
                pm.environment.set("OKTA_TOKEN_EXPIRATION", expiration)
                console.log('Successfully set client credential auth token.');

                resolve(response);

            } else {

                console.error('Failed to fetch client credentials token:', response.code, response.text());
                reject(err);
            }
        });
    });

}