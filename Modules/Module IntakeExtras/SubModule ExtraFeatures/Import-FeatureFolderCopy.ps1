####################################################################################################
<#
.SYNOPSIS
    This Feature creates copies a folder with the Windows GUI.
.DESCRIPTION
    This function is part of the Packaging Assistant. It contains functions or variables, that are in other files.
.EXAMPLE
    Import-FeatureINNOSetup
.INPUTS
    [System.Windows.Forms.TabPage]
.OUTPUTS
    This function returns no stream output.
.NOTES
    Version         : 4.8
    Author          : Imraan Iotana
    Creation Date   : June 2024
    Last Updated    : September 2024
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

        ####################################################################################################
        ### BUTTON PROPERTIES ###

        [System.Collections.Hashtable[]]$InnoSetupFileTextBoxButtons = @(
            @{
                ColumnNumber    = 1
                Text            = 'Browse'
                TextColor       = 'LightCyan'
                Image           = 'folders_explorer.png'
                SizeType        = 'Medium'
                Function        = { }
            }
            @{
                ColumnNumber    = 2
                Text            = 'Paste'
                TextColor       = 'LightCyan'
                Image           = 'page_paste.png'
                SizeType        = 'Medium'
                Function        = { }
            }
        )

        [System.Collections.Hashtable[]]$ActionButtons = @(
           @{
                ColumnNumber    = 1
                Text            = 'Copy Folder'
                Image           = 'Copy.png'
                SizeType        = 'Large'
                ToolTip         = 'Copy the specified folder to the target location.'
                Function        = { Copy-WithGUI -ThisFolder $Global:FolderToCopyTextBox.Text -IntoThisFolder $Global:FolderToCopyIntoTextBox.Text -OpenFolder } 
            }
           @{
                ColumnNumber    = 3
                Text            = 'Copy and Overwrite Folder'
                Image           = 'Copy.png'
                SizeType        = 'Large'
                ToolTip         = 'Copy the specified folder to the target location, and overwrite the destination.'
                Function        = { Copy-WithGUI -ThisFolder $Global:FolderToCopyTextBox.Text -IntoThisFolder $Global:FolderToCopyIntoTextBox.Text -Overwrite -OpenFolder } 
            }
        )

        ####################################################################################################
    } 
    
    process {
        # Create the GroupBox
        [System.Windows.Forms.GroupBox]$Global:InnoSetupGroupbox = $ParentGroupBox = Invoke-Groupbox -ParentTabPage $ParentTabPage -Title $Groupbox.Title -NumberOfRows $Groupbox.NumberOfRows -Color $Groupbox.Color -GroupBoxAbove $GroupBox.GroupBoxAbove
        # Create the FolderToCopyTextBox
        [System.Windows.Forms.TextBox]$Global:FolderToCopyTextBox = Invoke-TextBox -ParentGroupBox $ParentGroupBox -RowNumber 1 -SizeType Large -Type Input -Label 'Folder to Copy:' -PropertyName 'FolderToCopyTextBox'
        # Create the FolderToCopyIntoTextBox
        [System.Windows.Forms.TextBox]$Global:FolderToCopyIntoTextBox = Invoke-TextBox -ParentGroupBox $ParentGroupBox -RowNumber 3 -SizeType Large -Type Input -Label 'Folder to Copy Into:' -PropertyName 'FolderToCopyIntoTextBox'
        Invoke-ButtonLine -ButtonPropertiesArray $InnoSetupFileTextBoxButtons -ParentGroupBox $ParentGroupBox -RowNumber 2
        # Create the action button
        Invoke-ButtonLine -ButtonPropertiesArray $ActionButtons -ParentGroupBox $ParentGroupBox -RowNumber 5
    }

    end {
    }
}

### END OF SCRIPT
####################################################################################################
