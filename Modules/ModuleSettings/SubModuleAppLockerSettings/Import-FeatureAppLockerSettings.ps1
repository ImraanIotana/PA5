####################################################################################################
<#
.SYNOPSIS
    This function imports the feature AppLockerSettings.
.DESCRIPTION
    This function is part of the Packaging Assistant. It contains references to functions and variables that are in other files.
.EXAMPLE
    Import-AppLockerSettings -ParentTabPage $MyParentTabPage
.INPUTS
    [System.Windows.Forms.TabPage]
.OUTPUTS
    This function returns no stream-output.
.NOTES
    Version         : 5.7.0
    Author          : Imraan Iotana
    Creation Date   : August 2025
    Last Update     : January 2026
#>
####################################################################################################

function Import-FeatureAppLockerSettings {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory=$true,HelpMessage='The Parent TabPage to which this Feature will be added.')]
        [System.Windows.Forms.TabPage]$ParentTabPage
    )

    begin {
        ####################################################################################################
        ### MAIN PROPERTIES ###

        # GroupBox Handlers
        [System.String]$GroupBoxTitle   = 'AppLocker LDAP'
        [System.String]$Color           = 'LightCyan'
        [System.Int32]$NumberOfRows     = 5

        # Handlers
        [System.String]$DefaultAppLockerLDAPTEST = $Global:ApplicationObject.Settings.AppLockerLDAPTEST
        [System.String]$DefaultAppLockerLDAPPROD = $Global:ApplicationObject.Settings.AppLockerLDAPPROD

        ####################################################################################################
        ### BUTTON PROPERTIES ###param($TextBox=$NewTextBox)

        [System.Collections.Hashtable[]]$ActionButtonsTEST = @(
            @{
                ColumnNumber    = 1
                Text            = 'Copy'
                Image           = 'page_copy.png'
                SizeType        = 'Medium'
                ToolTip         = 'Copy the content of the textbox to your clipboard.'
                Function        = { Invoke-ClipBoard -CopyFromBox $Global:ALSAppLockerLDAPTESTTextBox }
            }
            @{
                ColumnNumber    = 2
                Text            = 'Paste'
                Image           = 'page_paste.png'
                SizeType        = 'Medium'
                ToolTip         = 'Paste the content of your clipboard to the textbox'
                Function        = { Invoke-ClipBoard -PasteToBox $Global:ALSAppLockerLDAPTESTTextBox }
            }
            @{
                ColumnNumber    = 3
                Text            = 'Clear'
                Image           = 'textfield_delete.png'
                SizeType        = 'Medium'
                ToolTip         = 'Clear the textbox.'
                Function        = { Invoke-ClipBoard -ClearBox $Global:ALSAppLockerLDAPTESTTextBox }
            }
            @{
                ColumnNumber    = 5
                Text            = 'Default'
                Image           = 'arrow_undo.png'
                SizeType        = 'Medium'
                ToolTip         = 'Reset the textbox to the default value.'
                Function        = { if (Get-UserConfirmation -Title 'Reset to default' -Body ("This will reset this field to the default value:`n`n({0})`n`nAre you sure?" -f $Global:ALSAppLockerLDAPTESTTextBox.DefaultValue)) { $Global:ALSAppLockerLDAPTESTTextBox.Text = $Global:ALSAppLockerLDAPTESTTextBox.DefaultValue } }
            }
        )

        [System.Collections.Hashtable[]]$ActionButtonsPROD = @(
            @{
                ColumnNumber    = 1
                Text            = 'Copy'
                Image           = 'page_copy.png'
                SizeType        = 'Medium'
                ToolTip         = 'Copy the content of the textbox to your clipboard.'
                Function        = { Invoke-ClipBoard -CopyFromBox $Global:ALSAppLockerLDAPPRODTextBox }
            }
            @{
                ColumnNumber    = 2
                Text            = 'Paste'
                Image           = 'page_paste.png'
                SizeType        = 'Medium'
                ToolTip         = 'Paste the content of your clipboard to the textbox'
                Function        = { Invoke-ClipBoard -PasteToBox $Global:ALSAppLockerLDAPPRODTextBox }
            }
            @{
                ColumnNumber    = 3
                Text            = 'Clear'
                Image           = 'textfield_delete.png'
                SizeType        = 'Medium'
                ToolTip         = 'Clear the textbox.'
                Function        = { Invoke-ClipBoard -ClearBox $Global:ALSAppLockerLDAPPRODTextBox }
            }
            @{
                ColumnNumber    = 5
                Text            = 'Default'
                Image           = 'arrow_undo.png'
                SizeType        = 'Medium'
                ToolTip         = 'Reset the textbox to the default value.'
                Function        = { if (Get-UserConfirmation -Title 'Reset to default' -Body ("This will reset this field to the default value:`n`n({0})`n`nAre you sure?" -f $Global:ALSAppLockerLDAPPRODTextBox.DefaultValue)) { $Global:ALSAppLockerLDAPPRODTextBox.Text = $Global:ALSAppLockerLDAPPRODTextBox.DefaultValue } }
            }
        )

        ####################################################################################################
    } 
    
    process {
        # Create the GroupBox
        [System.Windows.Forms.GroupBox]$ParentGroupBox = $Global:SCCMSettingsGroupBox = Invoke-Groupbox -ParentTabPage $ParentTabPage -Title $GroupBoxTitle -NumberOfRows $NumberOfRows -Color $Color -OnSubTab

        # Create the ALSAppLockerLDAPTESTTextBox
        [System.Windows.Forms.TextBox]$Global:ALSAppLockerLDAPTESTTextBox = Invoke-TextBox -ParentGroupBox $ParentGroupBox -RowNumber 1 -SizeType Large -Type Input -Label 'AppLocker LDAP - TEST:' -PropertyName 'ALSAppLockerLDAPTESTTextBox'
        # Add the functions/properties
        $Global:ALSAppLockerLDAPTESTTextBox | Add-Member -NotePropertyName DefaultValue -NotePropertyValue $DefaultAppLockerLDAPTEST
        $Global:ALSAppLockerLDAPTESTTextBox | ForEach-Object {
            if (Test-Object -IsEmpty ($_.Text)) {
                Write-Line ('The AppLocker LDAP TEST field is empty. It will be filled with the default value: ({0})' -f $_.DefaultValue)
                $_.Text = $_.DefaultValue
            }
        }
        # Create the Buttons
        Invoke-ButtonLine -ButtonPropertiesArray $ActionButtonsTEST -ParentGroupBox $ParentGroupBox -RowNumber 2

        # Create the ALSAppLockerLDAPPRODTextBox
        [System.Windows.Forms.TextBox]$Global:ALSAppLockerLDAPPRODTextBox = Invoke-TextBox -ParentGroupBox $ParentGroupBox -RowNumber 4 -SizeType Large -Type Input -Label 'AppLocker LDAP - PROD:' -PropertyName 'ALSAppLockerLDAPPRODTextBox'
        # Add the functions/properties
        $Global:ALSAppLockerLDAPPRODTextBox | Add-Member -NotePropertyName DefaultValue -NotePropertyValue $DefaultAppLockerLDAPPROD
        $Global:ALSAppLockerLDAPPRODTextBox | ForEach-Object {
            if (Test-Object -IsEmpty ($_.Text)) {
                Write-Line ('The AppLocker LDAP PROD field is empty. It will be filled with the default value: ({0})' -f $_.DefaultValue)
                $_.Text = $_.DefaultValue
            }
        }
        # Create the Buttons
        Invoke-ButtonLine -ButtonPropertiesArray $ActionButtonsPROD -ParentGroupBox $ParentGroupBox -RowNumber 5
    }

    end {
    }
}

### END OF SCRIPT
####################################################################################################
