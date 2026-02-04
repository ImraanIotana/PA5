####################################################################################################
<#
.SYNOPSIS
    This Feature creates copies a folder with the Windows GUI.
.DESCRIPTION
    This function is part of the Packaging Assistant. It contains functions or variables, that are in other files.
.EXAMPLE
    Import-FeatureFolderCopy -ParentTabPage $MyTabPage
.INPUTS
    [System.Windows.Forms.TabPage]
.OUTPUTS
    This function returns no stream output.
.NOTES
    Version         : 5.7.1
    Author          : Imraan Iotana
    Creation Date   : February 2026
    Last Update     : February 2026
#>
####################################################################################################

function Import-FeatureFolderCopy {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory=$true,HelpMessage='The Parent TabPage to which this Feature will be added.')]
        [System.Windows.Forms.TabPage]$ParentTabPage
    )

    begin {
        ####################################################################################################
        ### MAIN PROPERTIES ###

        # GroupBox properties
        [PSCustomObject]$GroupBox   = @{
            Title                   = [System.String]'Folder Copy and Move'
            Color                   = [System.String]'Cyan'
            NumberOfRows            = [System.Int32]6
            GroupBoxAbove           = $Global:InnoSetupGroupbox
        }

        # Set the Button Properties Array
        [System.Object[][]]$FolderButtonsArray  = @( (1,'Browse') , (2,'Open') , (5,'Clear') ) 

        ####################################################################################################
        ### BUTTON PROPERTIES ###

        [System.Collections.Hashtable[]]$ActionButtons = @(
           @{
                ColumnNumber    = 1
                Text            = 'Copy Folder'
                DefaultIcon     = 'Copy'
                SizeType        = 'Large'
                ToolTip         = 'Copy the specified folder to the target location.'
                Function        = { Copy-WithGUI -ThisFolder $Global:FolderToCopyTextBox.Text -IntoThisFolder $Global:FolderToCopyIntoTextBox.Text } 
            }
           @{
                ColumnNumber    = 2
                Text            = 'Copy and Overwrite Folder'
                DefaultIcon     = 'Copy'
                SizeType        = 'Large'
                ToolTip         = 'Copy the specified folder to the target location, and overwrite the destination.'
                Function        = { Copy-WithGUI -ThisFolder $Global:FolderToCopyTextBox.Text -IntoThisFolder $Global:FolderToCopyIntoTextBox.Text -Overwrite } 
            }
           @{
                ColumnNumber    = 3
                Text            = 'Switch Folders'
                Image           = 'Update.png'
                SizeType        = 'Large'
                ToolTip         = 'Switch the source and destination folders.'
                Function        = { [System.String]$Temp = $Global:FolderToCopyTextBox.Text; $Global:FolderToCopyTextBox.Text = $Global:FolderToCopyIntoTextBox.Text; $Global:FolderToCopyIntoTextBox.Text = $Temp } 
            }
           @{
                ColumnNumber    = 4
                Text            = 'Move Folder'
                Image           = 'move_to_folder.png'
                SizeType        = 'Large'
                ToolTip         = 'Move the specified folder to the target location.'
                Function        = { Copy-WithGUI -ThisFolder $Global:FolderToCopyTextBox.Text -IntoThisFolder $Global:FolderToCopyIntoTextBox.Text -Move } 
            }
           @{
                ColumnNumber    = 5
                Text            = 'Move and Overwrite Folder'
                Image           = 'move_to_folder.png'
                SizeType        = 'Large'
                ToolTip         = 'Move the specified folder to the target location, and overwrite the destination.'
                Function        = { Copy-WithGUI -ThisFolder $Global:FolderToCopyTextBox.Text -IntoThisFolder $Global:FolderToCopyIntoTextBox.Text -Move -Overwrite } 
            }
        )

        ####################################################################################################
    } 
    
    process {
        # Create the GroupBox
        [System.Windows.Forms.GroupBox]$Global:InnoSetupGroupbox = $ParentGroupBox = Invoke-Groupbox -ParentTabPage $ParentTabPage -Title $Groupbox.Title -NumberOfRows $Groupbox.NumberOfRows -Color $Groupbox.Color -GroupBoxAbove $GroupBox.GroupBoxAbove

        # Create the FolderToCopyTextBox
        [System.Windows.Forms.TextBox]$Global:FolderToCopyTextBox = Invoke-TextBox -ParentGroupBox $ParentGroupBox -RowNumber 1 -SizeType Large -Type Input -Label 'Folder to Copy:' -PropertyName 'FolderToCopyTextBox' -ButtonPropertiesArray $FolderButtonsArray

        # Create the FolderToCopyIntoTextBox
        [System.Windows.Forms.TextBox]$Global:FolderToCopyIntoTextBox = Invoke-TextBox -ParentGroupBox $ParentGroupBox -RowNumber 3 -SizeType Large -Type Input -Label 'Folder to Copy Into:' -PropertyName 'FolderToCopyIntoTextBox' -ButtonPropertiesArray $FolderButtonsArray

        # Create the action button
        Invoke-ButtonLine -ButtonPropertiesArray $ActionButtons -ParentGroupBox $ParentGroupBox -RowNumber 6
    }

    end {
    }
}

### END OF SCRIPT
####################################################################################################
