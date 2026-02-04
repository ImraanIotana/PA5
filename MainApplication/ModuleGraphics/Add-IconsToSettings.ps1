####################################################################################################
<#
.SYNOPSIS
    This function adds the icons for the Graphic Objects to the Settings.
.DESCRIPTION
    This function is part of the Packaging Assistant. It contains references to functions and variables that are in other files.
.EXAMPLE
    Add-IconsToSettings
.INPUTS
    [PSCustomObject]
.OUTPUTS
    This function returns no stream output.
.NOTES
    Version         : 5.7.1
    Author          : Imraan Iotana
    Creation Date   : February 2026
    Last Update     : February 2026
#>
####################################################################################################

function Add-IconsToSettings {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory=$false,HelpMessage='The Global ApplicationObject containing the Settings.')]
        [PSCustomObject]$ApplicationObject = $Global:ApplicationObject
    )

    begin {
        ####################################################################################################
        ### MAIN PROPERTIES ###

        # Input
        [System.Collections.Hashtable]$Settings = $ApplicationObject.Settings

        # Testfile
        [System.String]$TestPNGFileName = 'Registry.b64'
        [System.String]$TestPNGFilePath = Get-ChildItem -Path $PSScriptRoot -Recurse -Filter $TestPNGFileName | Select-Object -First 1 | Select-Object -ExpandProperty FullName

        ####################################################################################################
    }
    
    process {

        try {
            # Write the message
            Write-Line "The TestPNGFilePath is: $TestPNGFilePath" -Type Success
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

