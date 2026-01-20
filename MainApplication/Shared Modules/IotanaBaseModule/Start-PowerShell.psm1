####################################################################################################
<#
.SYNOPSIS
    This function starts the powershell console, and opens a file.
.DESCRIPTION
    This function is part of the Iotana Base Module. It contains functions or variables, that are in other files.
.EXAMPLE
    Start-PowerShell
.EXAMPLE
    Start-PowerShell -Path 'C:\Demo\FMyScript.ps1'
.EXAMPLE
    Start-PowerShell -Path 'C:\Demo\FMyScript.ps1' -NoISE
.INPUTS
    [System.String]
    [System.Management.Automation.SwitchParameter]
.OUTPUTS
    This function returns no stream output.
.NOTES
    Version         : 5.6
    Author          : Imraan Iotana
    Creation Date   : December 2025
    Last Update     : December 2025
.COPYRIGHT
    Copyright (C) Iotana. All rights reserved.
#>
####################################################################################################

function Start-PowerShell {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory=$false,HelpMessage='The path of the script that will be opened.')]
        [Alias('OpenScript','OpenFile')]
        [System.String]
        $Path,

        [Parameter(Mandatory=$false,HelpMessage='Switch for opening the basic console instead of ISE.')]
        [System.Management.Automation.SwitchParameter]
        $NoISE
    )

    begin {
        ####################################################################################################
        ### MAIN PROPERTIES ###

        # Handlers
        [System.String]$PowerShellExecutable    = if ($NoISE.IsPresent) { 'powershell.exe'} else { 'powershell_ise.exe' }
        [System.String]$PowerShellExePath       = Join-Path -Path $ENV:windir -ChildPath "System32\WindowsPowerShell\v1.0\$PowerShellExecutable"


        ####################################################################################################
    }
    
    process {
        # EXECUTION
        if ($Path) {
            Write-Line "Starting Powershell, and opening file ($Path)..."
            Start-Process -FilePath $PowerShellExePath -ArgumentList $Path
        } else {
            Write-Line "Starting Powershell..."
            Start-Process -FilePath $PowerShellExePath
        }
    }
    
    end {
    }
}

### END OF SCRIPT
####################################################################################################
