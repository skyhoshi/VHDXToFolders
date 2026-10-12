Write-Host "Loading Docker Methods... " 
. "C:\Users\kernm\OneDrive - Farm Credit Services of America\Documents\PowerShell\Scripts\listmethodsinps1file.ps1"
. "C:\Users\kernm\OneDrive - Farm Credit Services of America\Documents\PowerShell\Scripts\Docker Manager\ProjectInformationBuilding.ps1"

# $ProjectIndex =0;

$PAT = $env:AzureDevOpsNugetPat;
# $Projects = Get-DockerProjects;

# $imageTag="enterprisestatus-ui:latest";
# $CurrentSource = "C:\Users\kernm\source\EnterpriseStatus\Enterprise Status\";
# $dockerFilePath="C:\Users\kernm\source\EnterpriseStatus\Enterprise Status\Source\WebUI\Dockerfile";

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


function docker-composeUpBuildAll(){
    [CmdletBinding()]
    param (
        
    )    
    begin {
        if (!(Test-Path -Path "./.git/")){            
            Write-Error -Message "Invalid Run Location: You Docker Compose File is expected to be at the top level in your git repository. if it must be located elsewhere you cannot use this tool." -Category InvalidOperation
            return
        }
        if (!(Test-Path -Path ".env")){
            Write-Error -Message "Environment File for Docker does not exist. Please copy the '.env_TEMPLATE' and fill it out manually" -Category ReadError
            return
        }
    }
    process {        
        docker-compose --profile all-local up
    }
    
    end {
        
    }

}
function Docker-SetupBuild() {
    [CmdletBinding()]
    param (
        [Parameter()][string]$imageTag = "example/webapi:latest",
        [Parameter()][string]$dockerFilePath = "$PSScriptRoot\src\ExampleWebApi\Dockerfile"
    )
    
    begin {
        # PowerShell
        # Snippet from build.ps1 in Example.Apps
        $PAT = $env:AzurePAT;
        #$imageTag = "example/webapi:latest"
        $buildContext = $PSScriptRoot;
        SET-Location $CurrentSource;

    }
    
    process {
        docker build --progress=plain --build-arg PAT=$PAT --tag $imageTag --pull --file $dockerFilePath .
    }
    
    end {
        
    }

}
function Pull-Docker{
    <#
    Volumes
    C:\Source\FCSAmerica\CustomerBenchmark\Source\CustomerBenchmark\NightlySynchConsole.UI\appsettings.development.json:/app/appsettings.json
    C:\Source\FCSAmerica\CustomerBenchmark\Source\CustomerBenchmark\NightlySynchConsole.UI\appsettings.development.json:/app/appsettings.Development.json
    DOTNET_ENVIRONMENT
    Development
    #>
    
    
        # docker run --hostname=7bca1484064c --env=DOTNET_ENVIRONMENT=Development --env=PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin --env=ASPNETCORE_URLS=http://+:80 --env=DOTNET_RUNNING_IN_CONTAINER=true --env=DOTNET_SYSTEM_GLOBALIZATION_INVARIANT=false --env=DOTNET_VERSION=6.0.16 --env=ASPNET_VERSION=6.0.16 --volume=C:\Source\FCSAmerica\CustomerBenchmark\Source\CustomerBenchmark\NightlySynchConsole.UI\appsettings.development.json:/app/appsettings.json --workdir=/app --label='com.azure.dev.image.build.buildnumber=20230502.1' --label='com.azure.dev.image.build.builduri=vstfs:///Build/Build/910836' --label='com.azure.dev.image.build.definitionname=CustomerBenchmark' --label='com.azure.dev.image.build.repository.name=CustomerBenchmark' --label='com.azure.dev.image.build.repository.uri=https://fcsamerica@dev.azure.com/fcsamerica/CustomerBenchmark/_git/CustomerBenchmark' --label='com.azure.dev.image.build.sourcebranchname=119226-console-net6-upgrade' --label='com.azure.dev.image.build.sourceversion=875e3659f2ab5f10b70e1de2a06bed141070deb1' --label='com.azure.dev.image.system.teamfoundationcollectionuri=https://dev.azure.com/fcsamerica/' --label='com.azure.dev.image.system.teamproject=CustomerBenchmark' --label='com.fcsamerica.baseimagebuildtimestamp=1681311104' --label='com.fcsamerica.baseimagefullversion=6.0.16-alpine' --label='com.fcsamerica.owner=solutionsdelivery4@fcsamerica.com' --label='image.base.digest=sha256:4a424e7711fddeae612b72baa54fcf8c8d558e63693dc580ef8151bbf29764d4' --label='image.base.ref.name=hubpcontainersacr.azurecr.io/library/dotnet/aspnet:6.0-alpine' --runtime=runc -d hubpcontainersacr.azurecr.io/reportingandanalytics/csb/nightlysync/worker:1.6.23122.1
        # docker pull hubpcontainersacr.azurecr.io/enablement-utilities/tsm/webapi/api:latest
        # docker pull hubpcontainersacr.azurecr.io/enablement-utilities/tsm/web/ui:latest
    }
    