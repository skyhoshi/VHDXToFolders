Push-Location

Set-Location C:\source\LightningProxy\database

$CMD="& 'C:\Program Files (x86)\Red Gate\SQL Compare 15\SQLCompare.exe' /scripts1:'C:\source\LightningProxy\database\schema-model' /server2:localhost /database2:LightningProxy /username2:sa /password2:1very!secure-password /exclude:role:SQLAutoDeploy_Role /exclude:role:db_.* /exclude:user:FCSAMERICA\\.* /logLevel:Verbose /sync"
Invoke-Expression $CMD

Pop-Location
	   
