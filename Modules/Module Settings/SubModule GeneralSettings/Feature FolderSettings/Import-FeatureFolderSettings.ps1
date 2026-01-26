####################################################################################################
<#
.SYNOPSIS
    This function imports the feature Folder Settings.
.DESCRIPTION
    This function is part of the Packaging Assistant. It contains references to classes, functions or variables, that are in other files.
.EXAMPLE
    Import-FeatureFolderSettings -ParentTabControl $MyGlobalTabControl -ParentTabPage $MyGlobalTabPage
.INPUTS
    [System.Windows.Forms.TabControl]
    [System.Windows.Forms.TabPage]
.OUTPUTS
    This function returns no stream output.
.NOTES
    Version         : 5.3.1
    Author          : Imraan Iotana
    Creation Date   : October 2023
    Last Update     : May 2025
#>
####################################################################################################

function Import-FeatureFolderSettings {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory=$false,HelpMessage='The Parent TabControl that will be used for the dimensions of the Groupbox and other graphical elements.')]
        [System.Windows.Forms.TabControl]
        $ParentTabControl,

        [Parameter(Mandatory=$true,HelpMessage='The Parent object to which this feature will be added.')]
        [System.Windows.Forms.TabPage]
        $ParentTabPage
    )

    begin {
        ####################################################################################################
        ### MAIN OBJECT ###

        # Set the main object
        [PSCustomObject]$Local:MainObject = @{
            # Input
            ParentTabControl    = $ParentTabControl
            ParentTabPage       = $ParentTabPage
            # Groupbox Handlers
            Title               = [System.String]'Folder Settings'
            Color               = [System.String]'Brown'
            NumberOfRows        = [System.Int32]4
            # Handlers
            DefaultOutputFolder = $Global:ApplicationObject.DefaultOutputFolder
            DefaultDSLFolder    = $Global:ApplicationObject.Settings.DefaultDSLFolder
        }

        ####################################################################################################
        ### MAIN FUNCTION METHODS ###

        # Add the Process method
        Add-Member -InputObject $Local:MainObject -MemberType ScriptMethod -Name Process -Value {
            # Create the GroupBox (This groupbox must be global to relate to the second groupbox)
            [System.Windows.Forms.GroupBox]$ParentGroupBox = $Global:FolderSettingsGroupBox = Invoke-Groupbox -ParentTabPage $this.ParentTabPage -Title $this.Title -NumberOfRows $this.NumberOfRows -Color $this.Color -OnSubTab

            # Create the ASFSOutputFolderTextBox
            [System.Windows.Forms.TextBox]$Global:ASFSOutputFolderTextBox = Invoke-TextBox -ParentGroupBox $ParentGroupBox -RowNumber 1 -SizeType Large -Type Output -Label 'My Output Folder:' -PropertyName 'ASFSOutputFolderTextBox'
            # Add the functions/properties
            $Global:ASFSOutputFolderTextBox | Add-Member -NotePropertyName DefaultOutputFolder -NotePropertyValue $this.DefaultOutputFolder
            $Global:ASFSOutputFolderTextBox | ForEach-Object { if (Test-Object -IsEmpty ($_.Text)) { $_.Text = $_.DefaultOutputFolder } }
            # Add the buttons
            $Global:ASFSOutputFolderTextBox | Add-Member -NotePropertyName ButtonPropertiesArray -NotePropertyValue @(
                @{
                    ColumnNumber    = 1
                    Text            = 'Browse'
                    SizeType        = 'Medium'
                    Function        = { [System.String]$FolderName = Select-Item -Folder ; if ($FolderName) { $Global:ASFSOutputFolderTextBox.Text = $FolderName } }
                }
                @{
                    ColumnNumber    = 2
                    Text            = 'Copy'
                    SizeType        = 'Medium'
                    Function        = { Invoke-ClipBoard -CopyFromBox $Global:ASFSOutputFolderTextBox }
                }
                @{
                    ColumnNumber    = 3
                    Text            = 'Paste'
                    SizeType        = 'Medium'
                    Function        = { Invoke-ClipBoard -PasteToBox $Global:ASFSOutputFolderTextBox }
                }
                @{
                    ColumnNumber    = 4
                    Text            = 'Open'
                    SizeType        = 'Medium'
                    Function        = { Open-Folder -Path $Global:ASFSOutputFolderTextBox.Text }
                }
                @{
                    ColumnNumber    = 5
                    Text            = 'Default'
                    SizeType        = 'Medium'
                    Function        = {
                        $Global:ASFSOutputFolderTextBox | ForEach-Object {
                            if (Get-UserConfirmation -Title 'Reset to default' -Body ('This will reset the output folder to the default value ({0}). Are you sure?' -f $_.DefaultOutputFolder)) { $_.Text = $_.DefaultOutputFolder }
                        }
                    }
                }
            )

            # Create the ASFSDSLFolderTextBox
            [System.Windows.Forms.TextBox]$Global:ASFSDSLFolderTextBox = Invoke-TextBox -ParentGroupBox $ParentGroupBox -RowNumber 3 -SizeType Large -Type Output -Label 'Software Library (DSL):' -PropertyName 'ASFSDSLFolderTextBox'
            # Add the functions/properties
            $Global:ASFSDSLFolderTextBox | Add-Member -NotePropertyName DefaultDSLFolder -NotePropertyValue $this.DefaultDSLFolder
            $Global:ASFSDSLFolderTextBox | ForEach-Object { if (Test-Object -IsEmpty ($_.Text)) { $_.Text = $_.DefaultDSLFolder } }
            # Add the buttons
            $Global:ASFSDSLFolderTextBox | Add-Member -NotePropertyName ButtonPropertiesArray -NotePropertyValue @(
                @{
                    ColumnNumber    = 1
                    Text            = 'Browse'
                    SizeType        = 'Medium'
                    Function        = { [System.String]$FileName = Select-Item -Folder ; if ($FileName) { $Global:ASFSDSLFolderTextBox.Text = $FileName } }
                }
                @{
                    ColumnNumber    = 2
                    Text            = 'Copy'
                    SizeType        = 'Medium'
                    Function        = { Invoke-ClipBoard -CopyFromBox $Global:ASFSDSLFolderTextBox }
                }
                @{
                    ColumnNumber    = 3
                    Text            = 'Paste'
                    SizeType        = 'Medium'
                    Function        = { Invoke-ClipBoard -PasteToBox $Global:ASFSDSLFolderTextBox }
                }
                @{
                    ColumnNumber    = 4
                    Text            = 'Open'
                    SizeType        = 'Medium'
                    Function        = { Open-Folder -Path $Global:ASFSDSLFolderTextBox.Text }
                }
                @{
                    ColumnNumber    = 5
                    Text            = 'Default'
                    SizeType        = 'Medium'
                    Function        = {
                        $Global:ASFSDSLFolderTextBox | ForEach-Object {
                            if (Get-UserConfirmation -Title 'Reset to default' -Body ('This will reset the output folder to the default value ({0}). Are you sure?' -f $_.DefaultDSLFolder)) { $_.Text = $_.DefaultDSLFolder }
                        }
                    }
                }
            )

            # Create the Buttons
            Invoke-ButtonLine -ButtonPropertiesArray $Global:ASFSOutputFolderTextBox.ButtonPropertiesArray -ParentGroupBox $ParentGroupBox -RowNumber 2
            Invoke-ButtonLine -ButtonPropertiesArray $Global:ASFSDSLFolderTextBox.ButtonPropertiesArray -ParentGroupBox $ParentGroupBox -RowNumber 4
        }
    } 
    
    process {
        $Local:MainObject.Process()
    }

    end {
    }
}

### END OF SCRIPT
####################################################################################################
