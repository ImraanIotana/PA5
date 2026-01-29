####################################################################################################
<#
.SYNOPSIS
    This function resets a TextBox/ComboBox to their Default Value.
.DESCRIPTION
    This function is part of the Packaging Assistant. It contains references to functions and variables that are in other files.
.EXAMPLE
    Reset-BoxToDefault
.INPUTS
    [System.Object]
.OUTPUTS
    This function returns no stream output.
.NOTES
    Version         : 5.7.0.0210
    Author          : Imraan Iotana
    Creation Date   : January 2026
    Last Update     : January 2026
.COPYRIGHT
    Copyright (C) Iotana. All rights reserved.
#>
####################################################################################################

function Reset-BoxToDefault {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory=$true,HelpMessage='The box that will be reset to their Defualt Value.')]
        [System.Object]$Box
    )

    begin {
        ####################################################################################################
        ### MAIN PROPERTIES ###

        # Handlers
        [System.String]$DefaultValue        = $Box.DefaultValue
        [System.String]$ConfirmationTitle   = 'Reset to default'
        [System.String]$ConfirmationBody    = "This will reset this field to the default value:`n`n({0})`n`nAre you sure?"

        ####################################################################################################
    }
    
    process {
        try {
            # VALIDATION
            if ([System.String]::IsNullOrEmpty($DefaultValue) ) { Write-Line "This box has no Default Value. No action has been taken." ; Return }
    
            # CONFIRMATION
            if ( -Not( Get-UserConfirmation -Title $ConfirmationTitle -Body ($ConfirmationBody -f $DefaultValue) ) ) { Return }
    
            # EXECUTION
            $Box.Text = $Box.DefaultValue
            Write-Line "The box has been reset to their Default Value: ($DefaultValue)"
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