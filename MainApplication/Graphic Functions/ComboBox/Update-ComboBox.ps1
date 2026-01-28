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
        # Set the main object
        [PSCustomObject]$Local:MainObject = @{
            # Input
            ComboBoxToupdate        = $ComboBox
            NewContent              = $NewContent
            SortContent             = $SortContent
        }

        ####################################################################################################
        ### MAIN FUNCTION METHODS ###

        # Add the Process method
        Add-Member -InputObject $Local:MainObject -MemberType ScriptMethod -Name Process -Value {
            # Sort the content if requested
            if ($this.SortContent.IsPresent) { $this.NewContent | Sort-Object } else { $this.NewContent }
            # Clear the ComboBox items
            $this.ClearComboBoxItems($this.ComboBoxToupdate)
            # Update the ComboBox
            $this.UpdateComboBoxContent($this.ComboBoxToupdate, $this.NewContent)
        }

        ####################################################################################################
        ### MAIN PROCESSING METHODS ###
    
        # Add the ClearComboBoxItems method
        Add-Member -InputObject $Local:MainObject -MemberType ScriptMethod -Name ClearComboBoxItems -Value { param([System.Windows.Forms.ComboBox]$ComboBoxToClear)
            # Clear the ComboBox items
            $ComboBoxToClear.Items.Clear()
        }

        # Add the UpdateComboBoxContent method
        Add-Member -InputObject $Local:MainObject -MemberType ScriptMethod -Name UpdateComboBoxContent -Value { param([System.Windows.Forms.ComboBox]$ComboBoxToUpdate,[System.String[]]$NewContent)
            try {
                # Update the ComboBox content
                foreach ($Item in $NewContent) { $ComboBoxToUpdate.Items.Add($Item) }
                # Clear the text
                Invoke-ClipBoard -ClearBox $ComboBoxToUpdate -HideConfirmation
                # Write the message
                Write-Host 'UpdateComboBoxContent: The content has been refreshed.' -ForegroundColor DarkGray
            }
            catch {
                Write-FullError
            }
        }
    }
    
    process {
        #$Local:MainObject.Process()

        try {
            # SORTING
            # Sort the content
            [System.String[]]$ContentToUse = if ($SortContent.IsPresent) { $NewContent | Sort-Object } else { $NewContent }

            # CLEAR
            # Clear the ComboBox items
            $ComboBox.Items.Clear()

            # UPDATE
            # Update the ComboBox content
            #$ContentToUse.ForEach({ $ComboBox.Items.Add($_) | Out-Null })

            # Clear the text
            #Invoke-ClipBoard -ClearBox $ComboBox -HideConfirmation
            #$ComboBox.SelectedIndex = -1
            # Write the message
            Write-Line 'process: The content has been refreshed.'
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
