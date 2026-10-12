. "C:\Users\kernm\OneDrive - Farm Credit Services of America\Documents\PowerShell\Scripts\listmethodsinps1file.ps1"

## Elastic Search and Kibana Docker Setup
#These instructions were pulled from https://www.elastic.co/guide/en/kibana/7.12/docker.html which is specific to the version required by patronange.
#
#Location of the cloned configuration repo (where you got this script.)
$elasticsearchrepoclonelocation = "C:\Source\FCSAmerica\ElasticConfig\config\";

. "C:\Source\FCSAmerica\ElasticConfig\ElasticSearchDockerSetup.ps1"
