New-Variable -Name sfdxCommands -Scope Script -Force

<# The below script is executed in the background when a new ps session starts to pull all sfdx commands into a variable #>
$sfdxCommandsFileCreateBlock = {
	return sfdx commands --json | ConvertFrom-Json
}

<# executes the above script in the background so user is not waiting for the shell to start #>
$sfdxCommandsFileCreateJob = Start-Job -ScriptBlock $sfdxCommandsFileCreateBlock

<# script block for autocomplete. looks up matching commands from the file created above #>
$scriptBlock = {
    param($wordToComplete, $commandAst, $cursorPosition)

    if (!$script:sfdxCommands)
    {
        $script:sfdxCommands = Receive-Job -Wait -Job $sfdxCommandsFileCreateJob
        Remove-Job $sfdxCommandsFileCreateJob
    }

    if ($commandAst.CommandElements.Count -eq 1) <# List all commands #>
    {
        $script:sfdxCommands | ForEach-Object {
            [System.Management.Automation.CompletionResult]::new($_.id, $_.id, 'Method', $_.description)
        }
    }
    elseif ($commandAst.CommandElements.Count -eq 2 -and $wordToComplete -ne "") <# Completing a command #>
    {
        $commandPattern = "^(force:)?" + $commandAst.CommandElements[1].Value + ".+" <# Complete if force: is not specified too #>
        $script:sfdxCommands | Where-Object id -match $commandPattern | ForEach-Object {
            [System.Management.Automation.CompletionResult]::new($_.id, $_.id, 'Method', $_.description)
        }
    }
    elseif ($commandAst.CommandElements.Count -gt 2) <# Completing a parameter #>
    {
        $parameterToMatch = $commandAst.CommandElements[-1].ToString().TrimStart("-") + "*";
        
        ($script:sfdxCommands | Where-Object id -eq $commandAst.CommandElements[1].Value).flags.PsObject.Properties | Where-Object Name -like $parameterToMatch | ForEach-Object {
            [System.Management.Automation.CompletionResult]::new("--" + $_.Value.name, $_.Value.name, 'ParameterName', $_.Value.description)
        }
    }
}
<# register the above script to fire when tab is pressed following the sfdx command#>
Register-ArgumentCompleter -Native -CommandName sfdx -ScriptBlock $scriptBlock