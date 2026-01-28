####################################################################################################
<#
.SYNOPSIS
    This function updates a ComboBox with a new array of strings.
.DESCRIPTION
    This function is part of the Packaging Assistant. It contains references to functions and variables that are in other files.
.EXAMPLE
    Update-ComboBox -ComboBox $MyComboBox -NewContent @('NewValue1','NewValue2','NewValue3')
.INPUTS
    [System.Windows.Forms.ComboBox]
    [System.String[]]
    [System.Management.Automation.SwitchParameter]
.OUTPUTS
    This function returns no stream output.
.NOTES
    Version         : 5.7.0
    Author          : Imraan Iotana
    Creation Date   : September 2024
    Last Update     : January 2026
#>
####################################################################################################

function Update-ComboBox {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory=$true,HelpMessage='The ComboBox to update.')]
        [System.Windows.Forms.ComboBox]$ComboBox,

        [Parameter(Mandatory=$true,HelpMessage='The new content of the ComboBox.')]
        [System.String[]]$NewContent,

        [Parameter(Mandatory=$false,HelpMessage='Switch for sorting the content.')]
        [System.Management.Automation.SwitchParameter]$SortContent
    )
    
    begin {
    }
    
    process {
        try {
            # SORTING
            # Sort the content
            [System.String[]]$ContentToUse = if ($SortContent.IsPresent) { $NewContent | Sort-Object } else { $NewContent }

            # CLEAR
            # Clear the ComboBox items
            $ComboBox.Items.Clear()

            # UPDATE
            # Update the ComboBox content
            $ContentToUse.ForEach({ $ComboBox.Items.Add($_) | Out-Null })
            # Clear the text
            Invoke-ClipBoard -ClearBox $ComboBox -HideConfirmation
            $ComboBox.SelectedIndex = -1
            # Write the message
            Write-Line 'The content has been refreshed.'
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
