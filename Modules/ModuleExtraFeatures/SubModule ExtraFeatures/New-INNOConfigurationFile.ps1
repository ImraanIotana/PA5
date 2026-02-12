####################################################################################################
<#
.SYNOPSIS
    This function ...
.DESCRIPTION
    This function is self-contained and does not refer to functions, variables or classes, that are in other files.
    This function is part of the Packaging Assistant. It contains functions and variables that are in other files.
.EXAMPLE
    Function-Template -Initialize
.EXAMPLE
    Function-Template -Write -PropertyName OutputFolder -PropertyValue 'C:\Demo\WorkFolder'
.EXAMPLE
    Function-Template -Read -PropertyName OutputFolder
.EXAMPLE
    Function-Template -Remove -PropertyName OutputFolder
.INPUTS
    [System.String]
    [System.Management.Automation.SwitchParameter]
.OUTPUTS
    This function returns no stream output.
    [System.Boolean]
    [System.String]
.NOTES
    Version         : 5.5.1
    Author          : Imraan Iotana
    Creation Date   : October 2025
    Last Update     : October 2025
.COPYRIGHT
    Copyright (C) Iotana. All rights reserved.
#>
####################################################################################################

function New-INNOConfigurationFile {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory=$true,HelpMessage='The executable for which an INF file will be made.')]
        [System.String]
        $Path,

        [Parameter(Mandatory=$false,HelpMessage='The folder where the INF file will be placed.')]
        [System.String]
        $OutputFolder = (Get-Path -OutputFolder)
    )

    begin {
        ####################################################################################################
        ### MAIN PROPERTIES ###

        # Input
        [System.String]$ExecutablePath  = $Path
        # Output
        [System.String]$OutputFileName  = "Install.inf"

        ####################################################################################################
    }
    
    process {
        # VALIDATION
        # Validate the input
        if (-Not(Test-Path -Path $ExecutablePath)) { Write-Red "The executable file could not be found: ($ExecutablePath)" ; Return }
        if (-Not(Test-Path -Path $OutputFolder)) { Write-Red "The Output Folder could not be found: ($OutputFolder)" ; Return }

        # CONFIRMATION
        [System.Boolean]$UserConfirmedCreation = Get-UserConfirmation -Title 'Confirm INF Creation' -Body ("This will INSTALL the application, and CREATE a new INF file for the application:`n`n$ExecutablePath`n`nAre you sure?")
        if (-Not($UserConfirmedCreation)) { Return }

        # PREPARATION
        # Set the output file path
        [System.String]$OutputFilePath = Join-Path -Path $OutputFolder -ChildPath $OutputFileName
        if (Test-Path -Path $OutputFilePath) {
            [System.Boolean]$UserConfirmedOverWrite = Get-UserConfirmation -Title 'Confirm Overwrite' -Body ("The output file already exists. This will OVERWRITE the existing file:`n`n$ExecutablePath`n`nAre you sure?")
            if (-Not($UserConfirmedOverWrite)) { Return } else { Write-Line "Removing the existing INF file... ($OutputFilePath)" ; Remove-Item -Path $OutputFilePath -Force | Out-Null }
        }

        # EXECUTION
        Write-Busy "Installing the application ($ExecutablePath), to create the INF file ($OutputFilePath)..."
        try {
            Start-Process -FilePath $ExecutablePath -ArgumentList ("/SAVEINF=$OutputFilePath") -Wait
            Write-Success "The INF file has been created: ($OutputFilePath)"
            Open-Folder -Path $OutputFolder
        }
        catch {
            Write-FullError
        }
    }
    
    end {
    }
}

### END OF SCRIPT
####################################################################################################
