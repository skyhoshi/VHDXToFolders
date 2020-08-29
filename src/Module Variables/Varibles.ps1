$WindowsAppStorage = "O:\VHDX Storage";
$BaseVHDXStorage = "D:\VHDX Storage";
$CompoundVHDXStorage = "D:\VHDX Storage\Compound Drives";
$ProgramFilesX64 = "D:\VHDX Storage\ProgramFile-Drives";
$ProgramFilesX86 = "D:\VHDX Storage\ProgramFileX86-Drives";
$WorkRelated = "D:\VHDX Storage\WorkRelated";
$SystemUserProfiles = "D:\VHDX Storage\$Env:COMPUTERNAME-Profiles";

function Write-DebugVariables {
    
    begin {
        
    }
    
    process {
        $WindowsAppStorage;
        $BaseVHDXStorage;
        $CompoundVHDXStorage;
        $ProgramFilesX64;
        $ProgramFilesX86;
        $WorkRelated;
        $SystemUserProfiles;
    }
    
    end {
        
    }
}