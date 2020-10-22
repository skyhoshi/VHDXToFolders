function Get-VirtaulHardDriveListFromGist {
    <#     [CmdletBinding()]
        param (
            
        ) #>
        
        begin {
            $gistId = "aa7a0bd55cf0672c9cc3bc8a04176747";
            $gistFileName = "VirtualHardDriveList.xml";
            # $MasterDriveListUrl = "https://gist.githubusercontent.com/skyhoshi/aa7a0bd55cf0672c9cc3bc8a04176747/raw/03495e70583ea32061e1e89fafe7f98b03439eee/VirtualHardDriveList.xml";
            # $MasterDriveListUrl = "https://gist.githubusercontent.com/skyhoshi/aa7a0bd55cf0672c9cc3bc8a04176747/raw/f0585916e173d6ea77e819d99e9b13717bbc338e/VirtualHardDriveList.xml"; 
        }
        
        process {
            $urlEndpoint = "gists/$gistId"
            $GistInfo = ConvertFrom-Json (hub api $urlEndpoint);
            
        }
        
        end {
            return $GistInfo.files.$gistFileName.content;   
        }
    }