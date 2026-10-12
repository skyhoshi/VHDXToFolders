function Get-DockerWSLProcesses {
    $Processes = @();
    $Processes += Get-Process com.docker.backend;
    $Processes += get-process com.docker.build;
    $Processes += get-process 'Docker Desktop';

    # get-process wslservice; is Service. May orphan other processes if restarted improperly.
    $Processes;
}

function Get-DockerWSLServices {
    $Processes = @();
    $Processes += get-process wsl;
    $Processes += get-process wslhost;
    $Processes += get-process wslrelay;
     
    ############################
    Get-Service WSLService;
    Restart-Service WSLService;
}
function Clear-Docker {
    
}

function Clear-WSL {
    
    
}

function Restart-Docker {
    
    
}
function Restart-Wsl {

}


