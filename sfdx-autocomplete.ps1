<# file for storing sfdx commands for faster lookup#>
$sfdxCommandsFilepath = "$HOME/commands.sfdx"

<# The below script is executed in the background when a new ps session starts to pull all sfdx commands into a file#>
$sfdxCommandsFileCreateBlock = {
    param($filePath)
    sfdx commands | Out-File "$filePath"
}

<# executes the above script in the background so user is not waiting for the shell to start#>
Start-Job -ScriptBlock $sfdxCommandsFileCreateBlock -ArgumentList "$sfdxCommandsFilepath" | Out-Null

<# script block for autocomplete. looks up matching commands from the file created above#>
$scriptBlock = {
    param($CommandName, $wordToComplete, $cursorPosition)

    @($(Get-Content -Path $sfdxCommandsFilepath)) -match "$("$wordToComplete".replace('sfdx ','')).*"
}
<# register the above script to fire when tab is pressed following the sfdx command#>
Register-ArgumentCompleter -Native -CommandName sfdx -ScriptBlock $scriptBlock