# Autocomplete script for sfdx on windows powershell

### Also works in powershell core

![](media/autocomplete.gif)

### Requirements

- sfdx (the `npm` version installed using `npm i -g sfdx-cli`)
- powershell (regular or powershell core)

### Installation

Copy this script file ([sfdx-autocomplete.ps1](./sfdx-autocomplete.ps1)) to any directory on your machine. Add a reference to the script in your Powershell User Profile file. Refer to the link below for instructions on how to set up your Powershell Profile.

https://docs.microsoft.com/en-us/powershell/module/microsoft.powershell.core/about/about_profiles?view=powershell-7

### Usage

- Type in 'sfdx' followed by any portion of the command you're looking for. For eg: Type in `sfdx` followed by a space and `lightning` to see all `force:lightning` commands, or `test` to see all commands associated with running tests.
- After you type in a command, add double hyphens (`--`) followed by `<TAB><TAB>` to see the list of flags associated with the command, that you can then tab through.

### Note:

- For the autocomplete effect seen in the gif above, add the following line to your powershell profile
  ```js
  Set-PSReadLineKeyHandler -Key Tab -Function MenuComplete
  ```
- The script creates a '.sfdxcommands.json' file in your home directory each time a powershell session is started. This file contains all the sfdx commands. It is created in the background to avoid blocking the user. So, you might experience a slight delay in autocomplete to start working the very first time you install this script.
