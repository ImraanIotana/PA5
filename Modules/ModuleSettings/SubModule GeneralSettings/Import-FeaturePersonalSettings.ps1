####################################################################################################
<#
.SYNOPSIS
    This function imports the Feature Personal Settings.
.DESCRIPTION
    This function is part of the Packaging Assistant. It contains references to functions and variables that are in other files.
.EXAMPLE
    Import-FeaturePersonalSettings -ParentTabPage $MyParentTabPage
.INPUTS
    [System.Windows.Forms.TabPage]
.OUTPUTS
    This function returns no stream-output.
.NOTES
    Version         : 5.7.0
    Author          : Imraan Iotana
    Creation Date   : October 2023
    Last Update     : January 2026
#>
####################################################################################################

function Import-FeaturePersonalSettings {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory=$true,HelpMessage='The Parent TabPage to which this Feature will be added.')]
        [System.Windows.Forms.TabPage]$ParentTabPage
    )

    begin {
        ####################################################################################################
        ### MAIN PROPERTIES ###

        # GroupBox properties
        [PSCustomObject]$GroupBox = @{
            Title           = [System.String]'Personal Settings'
            Color           = [System.String]'Brown'
            NumberOfRows    = [System.Int32]4
            GroupBoxAbove   = [System.Windows.Forms.GroupBox]$Global:FolderSettingsGroupBox
        }
        
        # Set the Button Properties Array
        [System.Object[][]]$ButtonPropertiesArray = @( (1,'Copy') , (2,'Paste') , (5,'Clear') )
        #[System.Object[][]]$ButtonPropertiesArray = @( (1,'Copy') , (2,'Paste') , (3,'Clear') , (5,'Default') ) 

        ####################################################################################################


        <# Set the main object
        [PSCustomObject]$Local:MainObject = @{
            # Input
            ParentTabPage           = $ParentTabPage
            # Handlers
            GroupBoxTitle           = [System.String]'Personal Settings'
            Color                   = [System.String]'Brown'
            NumberOfRows            = [System.Int32]4
            GroupBoxAbove           = [System.Windows.Forms.GroupBox]$Global:FolderSettingsGroupBox
            AssetFolder             = [System.String](Join-Path -Path $PSScriptRoot -ChildPath 'Assets')
            #PDFManualFileName       = [System.String]'HelpFile Settings.pdf'
            VersionHistoryFileName  = [System.String]'Version History.txt'
        }#>

        ####################################################################################################
        ### MAIN FUNCTION METHODS ###

        <# Add the Process method
        Add-Member -InputObject $Local:MainObject -MemberType ScriptMethod -Name Process -Value {
            # Create the GroupBox (This groupbox must be global to relate to the second groupbox)
            [System.Windows.Forms.GroupBox]$ParentGroupBox = $Global:PersonalSettingsGroupBox #= Invoke-Groupbox -ParentTabPage $this.ParentTabPage -Title $this.GroupBoxTitle -NumberOfRows $this.NumberOfRows -Color $this.Color -GroupBoxAbove $this.GroupBoxAbove -OnSubTab


            # Create the ASPSUserFullNameTextBox
            [System.Windows.Forms.TextBox]$Global:ASPSUserFullNameTextBox = Invoke-TextBox -ParentGroupBox $ParentGroupBox -RowNumber 1 -SizeType Large -Type Input -Label 'My Full Name:' -PropertyName 'ASPSUserFullNameTextBox'
            # Add the buttons
            $Global:ASPSUserFullNameTextBox | Add-Member -NotePropertyName ButtonPropertiesArray -NotePropertyValue @(
                @{
                    ColumnNumber    = 1
                    Text            = 'Copy'
                    Image           = 'page_copy.png'
                    SizeType        = 'Medium'
                    Function        = { Invoke-ClipBoard -CopyFromBox $Global:ASPSUserFullNameTextBox }
                }
                @{
                    ColumnNumber    = 2
                    Text            = 'Paste'
                    Image           = 'page_paste.png'
                    SizeType        = 'Medium'
                    Function        = { Invoke-ClipBoard -PasteToBox $Global:ASPSUserFullNameTextBox }
                }
                @{
                    ColumnNumber    = 3
                    Text            = 'Clear'
                    Image           = 'textfield_delete.png'
                    SizeType        = 'Medium'
                    Function        = { Invoke-ClipBoard -ClearBox $Global:ASPSUserFullNameTextBox }
                }
            )


            # Create the ASPSUserEmailTextBox
            [System.Windows.Forms.TextBox]$Global:ASPSUserEmailTextBox = Invoke-TextBox -ParentGroupBox $ParentGroupBox -RowNumber 3 -SizeType Large -Type Input -Label 'My Email Address:' -PropertyName 'ASPSUserEmailTextBox'
            # Add the buttons
            $Global:ASPSUserEmailTextBox | Add-Member -NotePropertyName ButtonPropertiesArray -NotePropertyValue @(
                @{
                    ColumnNumber    = 1
                    Text            = 'Copy'
                    Image           = 'page_copy.png'
                    SizeType        = 'Medium'
                    Function        = { Invoke-ClipBoard -CopyFromBox $Global:ASPSUserEmailTextBox }
                }
                @{
                    ColumnNumber    = 2
                    Text            = 'Paste'
                    Image           = 'page_paste.png'
                    SizeType        = 'Medium'
                    Function        = { Invoke-ClipBoard -PasteToBox $Global:ASPSUserEmailTextBox }
                }
                @{
                    ColumnNumber    = 3
                    Text            = 'Clear'
                    Image           = 'textfield_delete.png'
                    SizeType        = 'Medium'
                    Function        = { Invoke-ClipBoard -ClearBox $Global:ASPSUserEmailTextBox }
                }
            )
                     
            # Create the Buttons
            Invoke-ButtonLine -ButtonPropertiesArray $Global:ASPSUserFullNameTextBox.ButtonPropertiesArray -ParentGroupBox $ParentGroupBox -RowNumber 2 -AssetFolder $this.AssetFolder
            Invoke-ButtonLine -ButtonPropertiesArray $Global:ASPSUserEmailTextBox.ButtonPropertiesArray -ParentGroupBox $ParentGroupBox -RowNumber 4 -AssetFolder $this.AssetFolder
        }#>
    } 
    
    process {
        try {
            # Create the GroupBox (This groupbox must be global to relate to groupboxes in other features)
            [System.Windows.Forms.GroupBox]$Global:PersonalSettingsGroupBox = $ParentGroupBox = Invoke-Groupbox -ParentTabPage $ParentTabPage -Title $GroupBox.Title -NumberOfRows $GroupBox.NumberOfRows -Color $GroupBox.Color -GroupBoxAbove $GroupBox.GroupBoxAbove -OnSubTab

            # Create the ASPSUserFullNameTextBox
            [System.Windows.Forms.TextBox]$Global:ASPSUserFullNameTextBox = Invoke-TextBox -ParentGroupBox $ParentGroupBox -RowNumber 1 -SizeType Large -Type Input -Label 'My Full Name:' -PropertyName 'ASPSUserFullNameTextBox' -ButtonPropertiesArray $ButtonPropertiesArray

            # Create the ASPSUserEmailTextBox
            [System.Windows.Forms.TextBox]$Global:ASPSUserEmailTextBox = Invoke-TextBox -ParentGroupBox $ParentGroupBox -RowNumber 3 -SizeType Large -Type Input -Label 'My Email Address:' -PropertyName 'ASPSUserEmailTextBox' -ButtonPropertiesArray $ButtonPropertiesArray
        }
        catch {
            Write-FullError
        }


        #$Local:MainObject.Process()
    }

    end {
    }
}

### END OF SCRIPT
####################################################################################################
