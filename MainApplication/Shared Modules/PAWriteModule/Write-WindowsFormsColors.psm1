####################################################################################################
<#
.SYNOPSIS
    This function write the Windows Forms Colors to the host.
.DESCRIPTION
    This function is part of the Packaging Assistant. It contains references to classes, functions or variables, that are in other files.
.EXAMPLE
    Write-WindowsFormsColors
.INPUTS
    -
.OUTPUTS
    This function returns no stream output.
.NOTES
    Version         : 5.5.1
    Author          : Imraan Iotana
    Creation Date   : September 2025
    Last Update     : September 2025
.COPYRIGHT
    Copyright (C) Iotana. All rights reserved.
#>
####################################################################################################

function Write-WindowsFormsColors {
    [CmdletBinding()]
    param (
    )

    begin {
    }
    
    process {
        # EXECUTION
        Write-Line "Executing Maintainance: [$($Global:FAMActionComboBox.Text)]"
        [PSCustomObject[]]$Colors = [System.Drawing.Color] | Get-Member -Static | Where-Object { $_.MemberType -eq 'Property' } | Select-Object Name | Sort-Object Name
        $Colors | Out-Host
    }
    
    end {
    }
}

### END OF SCRIPT
####################################################################################################
