This folder contains small snippets that are useful in feedback and function. 

## Announce-Admin-Privilages.ps1
This script will display if you are in a host that currently has admin privilages.

By adding this to the start of your profile script you can tell each time you start a new host if you have admin privilages. 
I even have scripts that run if I do have admin and some that run if I don't have admin. 

## Reload-Profile.ps1
This method allows you to call to your Current User All Hosts Script to reload any changes
NOTE: This can have negative side effects based on what you may have previously loaded.
I've also noticed that in some respects this doesn't work as expected. 
Most Notably: when you have classes that are loaded as apart of a chained script (a large ". "script.ps1"" chain) those classes are not reinialized with changes you may have made due to type references not being treated the same as functions or alias'. An Example of this is if you are using classes or dotnet code in your powershell scripts you will likely have to close and reopen your host to ensure changes are propigated properly. 

## Find-LastWritten.ps1
Shortcut to run on finding files that were written to last. 
NOTE: hasn't been tested in years. syntax or function not garrenteed.

## Open-EnvironmentVaribleEditor.ps1
I'm opening this window alot. 
so I shortcuted it to a command in powershell. 
(No alias included. please make your own.)

## Docker-Login.ps1
this shortcut allows you to type docker-login and it will handle the login from opening of the webpage to re-login after you've completed your login previously. 
NOTE: This is NOT Tenant specific. this will need be modified if you need a tenant specific login. 

Try it. Load the script in your profile and then type
```powershell
docker-login
```
if you haven't logged in, it will open your default browser and ask you to login, once completed it will complete the docker login for you.


## IIS Management Scripts
These scripts are used to manage service accounts, app pools and permissions based on the needs of the project. 
There are cleanup scripts included. 
