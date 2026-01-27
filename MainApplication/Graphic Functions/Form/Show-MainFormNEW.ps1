####################################################################################################
<#
.SYNOPSIS
    This function shows the Main Form.
.DESCRIPTION
    This function is part of the Packaging Assistant. It contains references to functions and variables that are in other files.
.EXAMPLE
    Show-MainForm -FormToShow $MyForm
.INPUTS
    [System.Windows.Forms.Form]
.OUTPUTS
    This function returns no stream output.
.NOTES
    Version         : 5.7.0
    Author          : Imraan Iotana
    Creation Date   : October 2024
    Last Update     : January 2026
#>
####################################################################################################

function Show-MainFormNEW {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory=$false,HelpMessage='Form to show.')]
        [System.Windows.Forms.Form]$FormToShow = $Global:MainForm
    )
    
    begin {
    }
    
    process {
        try {
            # Show the form
            $FormToShow.Add_Shown({ $FormToShow.Activate() })
            $FormToShow.ShowDialog() | Out-Null
        }
        catch {
            Write-FullError
        }
    }
    
    end {
    }
}
