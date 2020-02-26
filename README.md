# Autocomplete script for sfdx on windows powershell

### Also works on powershell core

![](media/autocomplete.gif)

### Requirements
- sfdx
- powershell (regular or powershell core)

### Copy this script file (sfdx-autocomplete.ps1) to any directory on your machine. Add a reference to the script in your profile.ps1. Refer to the link below for instructions on how to create your custom powershell profile 
https://docs.microsoft.com/en-us/powershell/module/microsoft.powershell.core/about/about_profiles?view=powershell-7

### Working
### Type in 'sfdx' followed by any portion of the command you're looking for in part or full. It will cycle through all commands that contain the string, in alphabetical order


<sup><sub>The script creates a 'command.sfdx' file in your home directory each time a powershell session is started. This file contains all the sfdx commands. It is created in the background to avoid blocking the user. So, you might experience a slight delay in autocomplete to start working the very first time</sup></sub>