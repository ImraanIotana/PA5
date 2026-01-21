####################################################################################################
<#
.SYNOPSIS
    This function writes the Windows Forms Colors to the host.
.DESCRIPTION
    This function is part of the Packaging Assistant. It contains references to functions and variables that are in other files.
.EXAMPLE
    Write-WindowsFormsColors
.INPUTS
    -
.OUTPUTS
    This function returns no stream output.
.NOTES
    Version         : 5.7.0
    Author          : Imraan Iotana
    Creation Date   : September 2025
    Last Update     : January 2026
.COPYRIGHT
    Copyright (C) Iotana. All rights reserved.
#>
####################################################################################################

function Write-WindowsFormsColors {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $false,HelpMessage = "The TextBox to get text from.")]
        [System.Object]$BoxToGetTextFrom
    )

    begin {
    }
    
    process {
        # EXECUTION
        #Write-Line "Executing Maintainance: [$($Global:FAMActionComboBox.Text)]"
        [PSCustomObject[]]$Colors = [System.Drawing.Color] | Get-Member -Static | Where-Object { $_.MemberType -eq 'Property' } | Select-Object Name | Sort-Object Name
        $Colors | Out-Host
    }
    
    end {
    }
}

### END OF SCRIPT
####################################################################################################
