####################################################################################################
<#
.SYNOPSIS
    This Feature creates AppLocker XML files and saves them in the Appliction Folder on the DSL.
.DESCRIPTION
    This function is part of the Packaging Assistant. It contains functions and variables that are in other files.
.EXAMPLE
    Import-FeatureAppLockerCreation
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

function Import-FeatureAppLockerCreation {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory=$true,HelpMessage='The Parent TabPage to which this Feature will be added.')]
        [System.Windows.Forms.TabPage]
        $ParentTabPage
    )

    begin {
        ####################################################################################################
        ### MAIN PROPERTIES ###

        # Function
        [System.String[]]$FunctionDetails   = @($MyInvocation.MyCommand,$PSCmdlet.ParameterSetName,$PSBoundParameters.GetEnumerator())

        # GroupBox properties
        [PSCustomObject]$GroupBox   = @{
            Title                   = [System.String]'Create AppLocker Policy'
            Color                   = [System.String]'Cyan'
            NumberOfRows            = [System.Int32]8
        }

        ####################################################################################################
        ### BUTTON PROPERTIES ###

        [System.Collections.Hashtable[]]$ALCApplicationIDComboBoxButtons = @(
            @{
                ColumnNumber    = 5
                Text            = 'Open'
                Image           = 'folder.png'
                SizeType        = 'Small'
                ToolTip         = 'Open the AppLocker folder'
                Function        = { Open-Folder -Path (Get-Path -ApplicationID $Global:ALCApplicationIDComboBox.Text -SubFolder AppLockerFolder) }
            }
        )

        [System.Collections.Hashtable[]]$ALCFolderToScanTextBoxButtons = @(
            @{
                ColumnNumber    = 1
                Text            = 'Browse'
                Image           = 'folders_explorer.png'
                SizeType        = 'Medium'
                Function        = { [System.String]$Folder = Select-Item -Folder ; if ($Folder) { $Global:ALCFolderToScanTextBox.Text = $Folder } }
            }
            @{
                ColumnNumber    = 2
                Text            = 'Copy'
                Image           = 'page_copy.png'
                SizeType        = 'Medium'
                Function        = { Invoke-ClipBoard -CopyFromBox $Global:ALCFolderToScanTextBox }
            }
            @{
                ColumnNumber    = 3
                Text            = 'Paste'
                Image           = 'page_paste.png'
                SizeType        = 'Medium'
                Function        = { Invoke-ClipBoard -PasteToBox $Global:ALCFolderToScanTextBox }
            }
            @{
                ColumnNumber    = 4
                Text            = 'Open'
                Image           = 'folder.png'
                SizeType        = 'Medium'
                Function        = { Open-Folder -Path $Global:ALCFolderToScanTextBox.Text }
            }
        )

        [System.Collections.Hashtable[]]$ALCADGroupSIDTextBoxButtons = @(
            @{
                ColumnNumber    = 1
                Text            = 'Copy'
                Image           = 'page_copy.png'
                SizeType        = 'Medium'
                Function        = { Invoke-ClipBoard -CopyFromBox $Global:ALCADGroupSIDTextBox }
            }
            @{
                ColumnNumber    = 2
                Text            = 'Paste'
                Image           = 'page_paste.png'
                SizeType        = 'Medium'
                Function        = { Invoke-ClipBoard -PasteToBox $Global:ALCADGroupSIDTextBox }
            }
        )

        [System.Collections.Hashtable[]]$ActionButtons = @(
           @{
                ColumnNumber    = 5
                Text            = 'Create AppLocker Policy Files'
                Image           = 'shield_add.png'
                SizeType        = 'Large'
                ToolTip         = 'Create AppLocker Policy Files from the selected folder'
                Function        = { Invoke-AppLockerFileCreation -ApplicationID $Global:ALCApplicationIDComboBox.Text -FolderToScan $Global:ALCFolderToScanTextBox.Text -ADGroupSID $Global:ALCADGroupSIDTextBox.Text }
            }
        )

        ####################################################################################################

        # Write the begin message
        Write-Function -Begin $FunctionDetails
    } 
    
    process {
        # Create the GroupBox
        [System.Windows.Forms.GroupBox]$Global:AppLockerCreationGroupbox = $ParentGroupBox = Invoke-Groupbox -ParentTabPage $ParentTabPage -Title $Groupbox.Title -NumberOfRows $Groupbox.NumberOfRows -Color $Groupbox.Color
        # Create the ApplicationID ComboBox
        [System.Windows.Forms.ComboBox]$Global:ALCApplicationIDComboBox = Invoke-ComboBox -ParentGroupBox $ParentGroupBox -RowNumber 1 -SizeType Medium -Type Output -Label 'Select Application:' -ContentArray (Get-DSLApplicationFolder -All -Basenames) -PropertyName 'ALCApplicationIDComboBox'
        Invoke-ButtonLine -ButtonPropertiesArray $ALCApplicationIDComboBoxButtons -ParentGroupBox $ParentGroupBox -RowNumber 1
        # Create the FolderToScan TextBox
        [System.Windows.Forms.TextBox]$Global:ALCFolderToScanTextBox = Invoke-TextBox -ParentGroupBox $ParentGroupBox -RowNumber 3 -SizeType Medium -Type Input -Label 'Select Folder to scan:' -PropertyName 'ALIFolder1ToScanTextBox'
        Invoke-ButtonLine -ButtonPropertiesArray $ALCFolderToScanTextBoxButtons -ParentGroupBox $ParentGroupBox -RowNumber 4
        # Create the ALIADGroupSIDTextBox
        [System.Windows.Forms.TextBox]$Global:ALCADGroupSIDTextBox = Invoke-TextBox -ParentGroupBox $ParentGroupBox -RowNumber 6 -SizeType Medium -Type Input -Label 'AD Group SID:' -PropertyName 'ALCADGroupSIDTextBox'
        Invoke-ButtonLine -ButtonPropertiesArray $ALCADGroupSIDTextBoxButtons -ParentGroupBox $ParentGroupBox -RowNumber 7
        # Create the action button
        Invoke-ButtonLine -ButtonPropertiesArray $ActionButtons -ParentGroupBox $ParentGroupBox -RowNumber 8
    }

    end {
        # Write the end message
        Write-Function -End $FunctionDetails
    }
}

### END OF SCRIPT
####################################################################################################
