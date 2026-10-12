function Docker-Login() {
    # Used PowerShell Core 7.2.*
    #      Azure CLI 2.38.*
    # Snippet from build.ps1 in Example.Apps
    #az login --tenant fcsamericaonline.onmicrosoft.com
    #az account set --subscription 8dd86e70-a434-461b-b044-35ab2882cdf1
    #az acr login --name hubpcontainersacr
    $DOCKER_TOKEN = (az acr login --name hubpcontainersacr --expose-token --output tsv --query accessToken)
    if ($null -eq $DOCKER_TOKEN){
        $tenants = (az login --scope https://management.core.windows.net//.default)
        $DOCKER_TOKEN = (az acr login --name hubpcontainersacr --expose-token --output tsv --query accessToken)
    }
    docker login hubpcontainersacr.azurecr.io --username 00000000-0000-0000-0000-000000000000 --password $DOCKER_TOKEN
    # if on error run :  az login --scope https://management.core.windows.net//.default
}