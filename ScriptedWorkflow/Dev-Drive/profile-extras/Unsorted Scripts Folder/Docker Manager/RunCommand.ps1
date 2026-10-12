. "C:\Users\kernm\OneDrive - Farm Credit Services of America\Documents\PowerShell\Scripts\listmethodsinps1file.ps1"
#docker exec --privileged -it sql-service2 bash chmod -R 777 /root/datadrive
. "C:\Users\kernm\OneDrive - Farm Credit Services of America\PowerShell\Scripts\ProjectSetupScripts\Management\setup-new-project.ps1"
#. "K:\kernm.devcontainer.envsetup\Setup\setup-new-project.ps1"
# 
New-DevelopmentStorageEnvironment -ProjectId 161799 -ProjectName "Dev Containers" -ProjectRootDriveLetter 'L' -GitRepoUrl git@ssh.dev.azure.com:v3/fcsamerica/SolutionsEnablement/LightningProxy -GitRepoBranchName "feature/implement-problem-details"

#"git@ssh.dev.azure.com:v3/fcsamerica/SolutionsEnablement/LightningProxy", "git@ssh.dev.azure.com:v3/fcsamerica/SolutionsEnablement/Canary.Web.API"  -GitRepoBranchName "experimental/dev-container"