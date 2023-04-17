New-Variable -Name sfdxCommands -Scope Script -Force
New-Variable -Name sfdxCommandsFile -Scope Global -Force

$global:sfdxCommandsFile = "$HOME/.sfdxcommands.json"

<# The below script is executed in the background when a new ps session starts to pull all sfdx commands into a variable #>
$sfdxCommandsFileCreateBlock = {
    Param($sfdxCommandsFile)
    $tempCommandsFile = "$HOME/.sfdxcommandsinit.json"
    sfdx commands --json | Out-File -FilePath $tempCommandsFile
    Move-Item -Path $tempCommandsFile -Destination $sfdxCommandsFile -Force
    return Get-Content $sfdxCommandsFile | ConvertFrom-Json
}

<# executes the above script in the background so user is not waiting for the shell to start #>
$sfdxCommandsFileCreateJob = Start-Job -ScriptBlock $sfdxCommandsFileCreateBlock -argumentlist $global:sfdxCommandsFile

$getFullCommand = {
    Param($commandAst)
    # We now have commands separated by spaces instead of colons. Need the loop to figure out where the command ends and the parameters begin
    [System.Collections.ArrayList]$commandParts = @() 
    for($i =1; $i -lt ($commandAst.CommandElements.Count);$i++) {
        if ($commandAst.CommandElements[$i].Value -clike "-*") {
            break
        }
        $commandParts.Add($commandAst.CommandElements[$i].Value) > $null
    }
    $commandToMatch = $commandParts -join " "
    return $commandToMatch.Trim()
}

<# script block for autocomplete. looks up matching commands from the file created above #>
$scriptBlock = {
    param($wordToComplete, $commandAst, $cursorPosition)

    if (!$script:sfdxCommands) {
        if (Test-Path $global:sfdxCommandsFile -PathType Leaf) {
            $script:sfdxCommands = Get-Content $global:sfdxCommandsFile | ConvertFrom-Json
        }
        else {
            $script:sfdxCommands = Receive-Job -Wait -Job $sfdxCommandsFileCreateJob
        }
    }
    if ($commandAst.CommandElements.Count -eq 1) {
        <# List all commands #>
        $script:sfdxCommands | ForEach-Object {
            [System.Management.Automation.CompletionResult]::new($_.id, $_.id, 'Method', $_.description??'No description available')
        }
    }
    elseif ($commandAst.CommandElements.Count -gt 1 -and -Not ($wordToComplete -clike "-*")) {
        $commandToMatch = (Invoke-Command -ScriptBlock $getFullCommand -ArgumentList $commandAst)
        <# Completing a command #>
        $commandPattern = ".*" + $commandToMatch + ".*" <# Complete if force: is not specified too #>
        $script:sfdxCommands | Where-Object id -match $commandPattern | ForEach-Object {
            [System.Management.Automation.CompletionResult]::new($_.id, $_.id, 'Method', $_.description??'No description available')
        }
    }
    elseif ($commandAst.CommandElements.Count -gt 2 -and $wordToComplete -clike "-*") {
        <# Completing a parameter #>
        $parameterToMatch = $wordToComplete.TrimStart("-") + "*";
        $commandToMatch = (Invoke-Command -ScriptBlock $getFullCommand -ArgumentList $commandAst)
        ($script:sfdxCommands | Where-Object id -eq $commandToMatch).flags.PsObject.Properties | Where-Object Name -like $parameterToMatch | ForEach-Object {
            [System.Management.Automation.CompletionResult]::new("--" + $_.Value.name, $_.Value.name, 'ParameterName', $_.Value.description??'No description available')
        }
    }
}

<# register the above script to fire when tab is pressed following the sfdx command#>
Register-ArgumentCompleter -Native -CommandName sfdx -ScriptBlock $scriptBlock
