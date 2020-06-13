<# file for storing sfdx commands for faster lookup#>
$sfdxCommandsFilepath = "$ENV:temp/commands.sfdx"

<# The below script is executed in the background when a new ps session starts to pull all sfdx commands into a file#>
$sfdxCommandsFileCreateBlock = {
    param($filePath)
    sfdx commands | Out-File "$filePath"
    $sfdxCommands = @($(Get-Content -Path $filePath))
    Remove-Item $filePath
    return $sfdxCommands
}

<# executes the above script in the background so user is not waiting for the shell to start#>
$sfdxCommandsFileCreateJob = Start-Job -ScriptBlock $sfdxCommandsFileCreateBlock -ArgumentList "$sfdxCommandsFilepath"

<# script block for autocomplete. looks up matching commands from the file created above#>
$scriptBlock = {
    param($CommandName, $wordToComplete, $cursorPosition)

    if (!$sfdxCommands)
    {
        $sfdxCommands = Receive-Job -Wait -Job $sfdxCommandsFileCreateJob
        Remove-Job $sfdxCommandsFileCreateJob
    }

    $sfdxCommands -match "$("$wordToComplete".replace('sfdx ','')).*"
}
<# register the above script to fire when tab is pressed following the sfdx command#>
Register-ArgumentCompleter -Native -CommandName sfdx -ScriptBlock $scriptBlock