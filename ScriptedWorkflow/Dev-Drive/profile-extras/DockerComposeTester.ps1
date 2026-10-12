. "C:\Users\kernm\OneDrive - Farm Credit Services of America\Documents\PowerShell\Scripts\listmethodsinps1file.ps1"
# Write-Host "Loading Docker Compose Run Function for simplification of execution of Docker Compose"
function Start-DockerComposeWithArgs {
    param (
        [string]$dockerComposeFile,
        [string]$buildArgs
    )

    if (-Not (Test-Path $dockerComposeFile)) {
        Write-Host "The specified docker-compose file does not exist: $dockerComposeFile"
        #exit 1
    }

    Write-Host "Starting docker-compose build with file: $dockerComposeFile"
    Write-Host "Build arguments: $buildArgs"


    # if ($dockerComposeFile -like "\") {
    #     $directoryArray = $dockerComposeFile -split "\"
    #     $numberofSlashes = $directoryArray.Count
    #     if ($numberofSlashes -gt 1) {
    #         $directoryArray = $directoryArray[0..($numberofSlashes - 2)]
    #         $directory = $directoryArray -join "/"
    #         Write-Host "Navigating to directory: $directory" -ForegroundColor Green
    #         Set-Location $directory
    #     }
    # }
    # else{
    #     Write-Host "Did not contain \" -ForegroundColor Green
    # }
    if ($dockerComposeFile -match "[\\/]+") {
        $HasSubDirectories = $true
        $directoryArray = $dockerComposeFile -split "[\\/]"
        $numberofSlashes = $directoryArray.Count
        if ($numberofSlashes -gt 1) {
            $directoryArray = $directoryArray[0..($numberofSlashes - 3)]
            $directory = $directoryArray -join "/"
            Write-Host "Navigating to directory: $directory" -ForegroundColor Green
            Set-Location $directory
        }
        $dockerComposeFileToUse = $dockerComposeFile -replace "[\\/]+", "\"
        $dockerComposeFileToUse = "./$(($dockerComposeFile -split "[\\/]" | Select-Object -Last 2) -join "\")"
        Write-Host "Using Docker File $dockerComposeFileToUse" -ForegroundColor Green
    }
    else {
        Write-Host "Did not contain any directory separators" -ForegroundColor Green
        $dockerComposeFileToUse = $dockerComposeFile
    }


    try {
        <#         $processInfo = New-Object System.Diagnostics.ProcessStartInfo
        $processInfo.FileName = "docker-compose"
        #  up 
        $processInfo.Arguments = " --progress plain -f `"$dockerComposeFile`" build $buildArgs loanmonitoringinternalwebui"
        $processInfo.RedirectStandardOutput = $true
        $processInfo.RedirectStandardError = $true
        $processInfo.UseShellExecute = $false
        $processInfo.CreateNoWindow = $true

        $process = New-Object System.Diagnostics.Process
        $process.StartInfo = $processInfo
        $process.Start() | Out-Null

        $output = $process.StandardOutput.ReadToEnd()
        $errorOutput = $process.StandardError.ReadToEnd()

        $process.WaitForExit()

        Write-Host $output #>


        docker-compose --progress plain -f $dockerComposeFileToUse build $buildArgs loanmonitoringinternalwebui
        if ($errorOutput) {
            Write-Host "Errors encountered during build:"
            Write-Host $errorOutput
        }

        if ($process.ExitCode -ne 0) {
            Write-Host "docker-compose build failed with exit code $($process.ExitCode)"
            #exit $process.ExitCode
        }

        Write-Host "docker-compose build completed successfully."
    }
    catch {
        Write-Host "An error occurred: $_"
    }
}
<#
docker compose build --help

Usage:  docker compose build [OPTIONS] [SERVICE...]

Build or rebuild services

Options:
      --build-arg stringArray   Set build-time variables for services
      --builder string          Set builder to use
      --dry-run                 Execute command in dry run mode
  -m, --memory bytes            Set memory limit for the build container.
                                Not supported by BuildKit.
      --no-cache                Do not use cache when building the image
      --pull                    Always attempt to pull a newer version of
                                the image
      --push                    Push service images
  -q, --quiet                   Don't print anything to STDOUT
      --ssh string              Set SSH authentications used when
                                building service images. (use 'default'
                                for using your default SSH Agent)
      --with-dependencies       Also build dependencies (transitively)
##############################################################################################
 docker build --help
Start a build

Usage:  docker buildx build [OPTIONS] PATH | URL | -

Start a build

Aliases:
  docker build, docker builder build, docker image build, docker buildx b

Options:
      --add-host strings              Add a custom host-to-IP mapping
                                      (format: "host:ip")
      --allow strings                 Allow extra privileged entitlement
                                      (e.g., "network.host",
                                      "security.insecure")
      --annotation stringArray        Add annotation to the image
      --attest stringArray            Attestation parameters (format:
                                      "type=sbom,generator=image")
      --build-arg stringArray         Set build-time variables
      --build-context stringArray     Additional build contexts (e.g.,
                                      name=path)
      --builder string                Override the configured builder
                                      instance (default "desktop-linux")
      --cache-from stringArray        External cache sources (e.g.,
                                      "user/app:cache",
                                      "type=local,src=path/to/dir")
      --cache-to stringArray          Cache export destinations (e.g.,
                                      "user/app:cache",
                                      "type=local,dest=path/to/dir")
      --call string                   Set method for evaluating build
                                      ("check", "outline", "targets")
                                      (default "build")
      --cgroup-parent string          Set the parent cgroup for the "RUN"
                                      instructions during build
      --check                         Shorthand for "--call=check" (default )
  -D, --debug                         Enable debug logging
  -f, --file string                   Name of the Dockerfile (default:
                                      "PATH/Dockerfile")
      --iidfile string                Write the image ID to a file
      --label stringArray             Set metadata for an image
      --load                          Shorthand for "--output=type=docker"
      --metadata-file string          Write build result metadata to a file
      --network string                Set the networking mode for the
                                      "RUN" instructions during build
                                      (default "default")
      --no-cache                      Do not use cache when building the image
      --no-cache-filter stringArray   Do not cache specified stages
  -o, --output stringArray            Output destination (format:
                                      "type=local,dest=path")
      --platform stringArray          Set target platform for build
      --progress string               Set type of progress output
                                      ("auto", "quiet", "plain", "tty",
                                      "rawjson"). Use plain to show
                                      container output (default "auto")
      --provenance string             Shorthand for "--attest=type=provenance"
      --pull                          Always attempt to pull all
                                      referenced images
      --push                          Shorthand for "--output=type=registry"
  -q, --quiet                         Suppress the build output and print
                                      image ID on success
      --sbom string                   Shorthand for "--attest=type=sbom"
      --secret stringArray            Secret to expose to the build
                                      (format:
                                      "id=mysecret[,src=/local/secret]")
      --shm-size bytes                Shared memory size for build containers
      --ssh stringArray               SSH agent socket or keys to expose
                                      to the build (format:
                                      "default|<id>[=<socket>|<key>[,<key>]]")
  -t, --tag stringArray               Name and optionally a tag (format:
                                      "name:tag")
      --target string                 Set the target build stage to build
      --ulimit ulimit                 Ulimit options (default [])

Experimental commands and flags are hidden. Set BUILDX_EXPERIMENTAL=1 to show them.

What's next:
    View a summary of image vulnerabilities and recommendations → docker scout quickview
#>

if (!(test-path "Alias:\sdc")) {
    New-Alias -Name "sdc" -Value "Start-DockerComposeWithArgs"
}


#Start-DockerComposeWithArgs -dockerComposeFile "Q:\LoanMonitoringWeb\src\docker-compose.yml" -buildArgs "--no-cache"

function Reload-sdc {
    . "K:\kernm.devcontainer.envsetup\profile-extras\DockerComposeTester.ps1"
}
