####################################################################################################
<#
.SYNOPSIS
    This function imports the feature AppLocker Settings.
.DESCRIPTION
    This function is part of the Packaging Assistant. It contains references to functions and variables that are in other files.
.EXAMPLE
    Import-AppLockerSettings -ParentTabPage $MyParentTabPage
.INPUTS
    [System.Windows.Forms.TabPage]
.OUTPUTS
    This function returns no stream-output.
.NOTES
    Version         : 5.7.0.0204
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

        # GroupBox properties
        [PSCustomObject]$GroupBox = @{
            Title           = [System.String]'AppLocker LDAP'
            Color           = [System.String]'LightCyan'
            NumberOfRows    = [System.Int32]5
        }

        # Handlers
        [System.String]$DefaultAppLockerLDAPTEST = $Global:ApplicationObject.Settings.AppLockerLDAPTEST
        [System.String]$DefaultAppLockerLDAPPROD = $Global:ApplicationObject.Settings.AppLockerLDAPPROD

        ####################################################################################################
        ### BUTTON PROPERTIES ###

        [System.Collections.Hashtable[]]$ActionButtonsTEST = @(
            @{
                ColumnNumber    = 1
                Text            = 'Copy'
                Function        = { Invoke-ClipBoard -CopyFromBox $Global:ALSAppLockerLDAPTESTTextBox }
            }
            @{
                ColumnNumber    = 2
                Text            = 'Paste'
                Function        = { Invoke-ClipBoard -PasteToBox $Global:ALSAppLockerLDAPTESTTextBox }
            }
            @{
                ColumnNumber    = 3
                Text            = 'Clear'
                Function        = { Invoke-ClipBoard -ClearBox $Global:ALSAppLockerLDAPTESTTextBox }
            }
            @{
                ColumnNumber    = 5
                Text            = 'Default'
                Function        = { if (Get-UserConfirmation -Title 'Reset to default' -Body ("This will reset this field to the default value:`n`n({0})`n`nAre you sure?" -f $Global:ALSAppLockerLDAPTESTTextBox.DefaultValue)) { $Global:ALSAppLockerLDAPTESTTextBox.Text = $Global:ALSAppLockerLDAPTESTTextBox.DefaultValue } }
            }
        )

        [System.Collections.Hashtable[]]$ActionButtonsPROD = @(
            @{
                ColumnNumber    = 1
                Text            = 'Copy'
                Function        = { Invoke-ClipBoard -CopyFromBox $Global:ALSAppLockerLDAPPRODTextBox }
            }
            @{
                ColumnNumber    = 2
                Text            = 'Paste'
                Function        = { Invoke-ClipBoard -PasteToBox $Global:ALSAppLockerLDAPPRODTextBox }
            }
            @{
                ColumnNumber    = 3
                Text            = 'Clear'
                Function        = { Invoke-ClipBoard -ClearBox $Global:ALSAppLockerLDAPPRODTextBox }
            }
            @{
                ColumnNumber    = 5
                Text            = 'Default'
                Function        = { if (Get-UserConfirmation -Title 'Reset to default' -Body ("This will reset this field to the default value:`n`n({0})`n`nAre you sure?" -f $Global:ALSAppLockerLDAPPRODTextBox.DefaultValue)) { $Global:ALSAppLockerLDAPPRODTextBox.Text = $Global:ALSAppLockerLDAPPRODTextBox.DefaultValue } }
            }
        )

        ####################################################################################################
    } 
    
    process {
        try {
            # Create the GroupBox
            [System.Windows.Forms.GroupBox]$Global:SCCMSettingsGroupBox = $ParentGroupBox = Invoke-Groupbox -ParentTabPage $ParentTabPage -Title $GroupBox.Title -NumberOfRows $GroupBox.NumberOfRows -Color $GroupBox.Color -OnSubTab

            # Create the ALSAppLockerLDAPTESTTextBox
            [System.Windows.Forms.TextBox]$Global:ALSAppLockerLDAPTESTTextBox = Invoke-TextBox -ParentGroupBox $ParentGroupBox -RowNumber 1 -SizeType Large -Type Input -Label 'AppLocker LDAP - TEST:' -PropertyName 'ALSAppLockerLDAPTESTTextBox' -DefaultValue $DefaultAppLockerLDAPTEST
            # Add the functions/properties
            #$Global:ALSAppLockerLDAPTESTTextBox | Add-Member -NotePropertyName DefaultValue -NotePropertyValue $DefaultAppLockerLDAPTEST
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
        catch {
            Write-FullError
        }
    }

    end {
    }
}

### END OF SCRIPT
####################################################################################################
