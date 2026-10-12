using namespace System.Management.Automation.Language
if ($null -eq $ListedScripts) {
    $ListedScripts = @{}
}
$WriteToHost = $false;
$callStack = Get-PSCallStack
if ($callStack.Count -gt 1) {
    if ($WriteToHost) {
        Write-Host "Call chain:" -ForegroundColor Yellow
    }
    for ($i = 1; $i -lt $callStack.Count; $i++) {
        $caller = $callStack[$i]
        if ([string]::IsNullOrEmpty($caller.ScriptName) -or (-not (Test-Path $caller.ScriptName))) {
            continue;
        }
        if ($ListedScripts.ContainsKey($caller.ScriptName)) {
            continue;
        }
        else {
            if ($WriteToHost) {
                Write-Host "  [$i] $($caller.Command) - $($caller.ScriptName):$($caller.ScriptLineNumber)" -ForegroundColor Gray
            }
            $ListedScripts[$caller.ScriptName] = $true
            # Automatically discover and list all functions in this script
            $scriptPath = $caller.ScriptName
            $ast = [Parser]::ParseFile($scriptPath, [ref]$null, [ref]$null)

            
            $functions = $ast.FindAll({ $args[0] -is [FunctionDefinitionAst] }, $true)
            if ($functions.Count -eq 0) {
                #Write-Host "No functions found in: $scriptPath" -ForegroundColor DarkGray
                #continue;
            }
            $functionNames = $functions | ForEach-Object { $_.Name }
            if ($WriteToHost) {
                Write-Host "Loading functions from: $scriptPath" -ForegroundColor Cyan
            }
            foreach ($name in $functionNames) {
                if ($WriteToHost) {
                    Write-Host "  - $name" -ForegroundColor Gray
                }
            }
            $classes = $ast.FindAll({ $args[0] -is [TypeDefinitionAst] }, $true)
            if ($classes.Count -eq 0) {
                continue;
            }
            $classNames = $classes | ForEach-Object { $_.Name }
            if ($WriteToHost) {
                Write-Host "Loading classes from: $scriptPath" -ForegroundColor Cyan
            }
            foreach ($name in $classNames) {
                if ($WriteToHost) {
                    Write-Host "  -CLASS:  $name" -ForegroundColor Gray
                }
            }
        }
    }
}




function Output-FullListOfCustomMethods {
    param ()

    # Find all files referenced in this script    
    $scriptPath = (Get-PSCallStack | Select-Object -ExpandProperty ScriptName | Where-Object { Test-Path $_ })[1];
    $scriptPath = "C:\Users\kernm\OneDrive - Farm Credit Services of America\PowerShell\profile.ps1";
    if ($WriteToHost) {
        Write-Host "Analyzing script file: $scriptPath" -ForegroundColor Cyan
    }
    $ast = [Parser]::ParseFile($scriptPath, [ref]$null, [ref]$null)

    # Find dot-sourced files (. .\file.ps1)
    $dotSourced = $ast.FindAll({
            param($node)
            if ($node -is [CommandAst]) {
                if (($node.InvocationOperator -eq 'Dot' -or $node.InvocationOperator -eq 'Ampersand') -and $node.InvocationOperator -ne 'Unknown') {
                    return $true
                }
                # $node.CommandElements | Where-Object {
                #     $_.Extent.Text -match '\.ps1$'
                # }
            } }, $true);
    # # Find invoked scripts (& .\file.ps1 or Invoke-Expression)
    # $invoked = $ast.FindAll({ 
    #         $args[0] -is [InvokeMemberExpressionAst] #-and $args[0].Expression.TokenKind -eq 'Dot'
    #     }, $true)

    # # Find Import-Module commands
    # $imports = $ast.FindAll({ 
    #         $args[0] -is [System.Management.Automation.Language.CommandAst] -and 
    #         $args[0].GetCommandName() -in @('Import-Module', 'ipmo')
    #     }, $true)
    if ($WriteToHost) {
        Write-Host "Files referenced in this script:" -ForegroundColor Cyan
    }
    if ($dotSourced) {
        if ($WriteToHost) {
            Write-Host "  Dot-sourced files:" -ForegroundColor Yellow
        }
        $dotSourced | ForEach-Object { 
            $script = $_.CommandElements[0].Value;
            if ($null -eq $script) {
                $script = $_.CommandElements[0].Extent.Text;
                #Write-Host "    - $script" -ForegroundColor Yellow
            }
            if (-not $ListedScripts.ContainsKey($script)) {
                $ListedScripts[$script] = $true
            }
            if ($WriteToHost) {
                Write-Host "    - $($script)" -ForegroundColor Gray 
            }
        }
    }    
    # if ($invoked) {
    #     Write-Host "  Invoked scripts:" -ForegroundColor Yellow
    #     $invoked | ForEach-Object { Write-Host "    - $($_.Extent.Text)" -ForegroundColor Gray }
    # }
    # if ($imports) {
    #     Write-Host "  Imported modules:" -ForegroundColor Yellow
    #     $imports | ForEach-Object { Write-Host "    - $($_.CommandElements[1])" -ForegroundColor Gray }
    # }
    if ($WriteToHost) {
        $ListedScripts | Sort-Object Name | Format-Table -Autosize
    }

}
#if ($PSDebugContext
#$PSBoundParameters.ContainsKey('Debug') -and $PSBoundParameters['Debug']
#) 
if (($Host.Name -eq 'Visual Studio Code Host') -or 
    ($DebugPreference -ne 'SilentlyContinue') -or
    ($PSBoundParameters.ContainsKey('Debug')) -or
    ($PSDebugContext)
) {
    Output-FullListOfCustomMethods;
}