####################################################################################################
<#
.SYNOPSIS
    This Feature imports the AppLocker XML files into the AppLocker Policy.
.DESCRIPTION
    This function is part of the Packaging Assistant. It contains functions and variables that are in other files.
.EXAMPLE
    Import-FeatureAppLockerImport
.INPUTS
    [System.Windows.Forms.TabPage]
.OUTPUTS
    This function returns no stream output.
.NOTES
    Version         : 5.7.1
    Author          : Imraan Iotana
    Creation Date   : August 2025
    Last Updated    : February 2026
#>
####################################################################################################

function Import-FeatureAppLockerImport {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory=$true,HelpMessage='The Parent TabPage to which this Feature will be added.')]
        [System.Windows.Forms.TabPage]$ParentTabPage
    )

    begin {
        ####################################################################################################
        ### MAIN PROPERTIES ###

        # GroupBox properties
        [System.Collections.Hashtable]$GroupBoxProperties = @{
            ParentTabPage   = $ParentTabPage
            Title           = 'AppLocker Policy Import'
            Color           = 'LightCyan'
            NumberOfRows    = 7
        }

        # ComboBox Handlers
        [System.String[]]$DSLApplicationFolders = Get-DSLApplicationFolder -All -Basenames

        # LDAP Handlers
        [System.Collections.Hashtable]$Script:MApplock_LDAPEnvironmentHashtable = @{
            TEST        = (Get-ApplicationSetting -Name 'AppLockerLDAPTEST')
            PRODUCTION  = (Get-ApplicationSetting -Name 'AppLockerLDAPPROD')
        }

        ####################################################################################################
        ### COMBOBOX PROPERTIES ###

        # Set the parameters for the MApplock_FApplock_ApplicationComboBox
        [System.Collections.Hashtable]$MApplock_FApplock_ApplicationComboBoxParameters = @{
            RowNumber       = 1
            SizeType        = 'Medium'
            Type            = 'Output'
            Label           = 'Select Application:'
            ContentArray    = $DSLApplicationFolders
            PropertyName    = 'MApplock_FApplock_ApplicationComboBox'
            ToolTip         = 'Select the Application for which you want to import the AppLocker Policy'
        }

         # Set the parameters for the MApplock_FApplock_EnvironmentComboBox
        [System.Collections.Hashtable]$MApplock_FApplock_EnvironmentComboBoxParameters = @{
            RowNumber       = 2
            SizeType        = 'Medium'
            Type            = 'Output'
            Label           = 'Select Environment:'
            ContentArray    = $Script:MApplock_LDAPEnvironmentHashtable.Keys
            DefaultValue    = 'TEST'
            PropertyName    = 'MApplock_FApplock_EnvironmentComboBox'
            ToolTip         = 'Select the Environment for which you want to import the AppLocker Policy'
        }

        ####################################################################################################
        ### BUTTON PROPERTIES ###

        # Set the buttons for the MApplock_FApplock_ApplicationComboBox
        [System.Collections.Hashtable[]]$MApplock_FApplock_ApplicationComboBoxButtons = @(
            @{
                ColumnNumber    = 5
                Text            = 'Open AppLocker Folder'
                Image           = 'folder.png'
                SizeType        = 'Small'
                ToolTip         = 'Open the AppLocker folder of the selected Application'
                Function        = { Open-Folder -Path (Get-Path -ApplicationID $Script:MApplock_FApplock_ApplicationComboBox.Text -SubFolder AppLockerFolder) }
            }
            @{
                ColumnNumber    = 6
                Text            = 'Show Application Log'
                Image           = 'file_extension_log.png'
                SizeType        = 'Small'
                ToolTip         = 'Open the logfile of the selected Application'
                Function        = { Show-ApplicationLogFile -ApplicationID $Script:MApplock_FApplock_ApplicationComboBox.Text }
            }
        )

        # Set the buttons for the MApplock_FApplock_EnvironmentComboBox
        [System.Collections.Hashtable[]]$MApplock_FApplock_EnvironmentComboBoxButtons = @(
            @{
                ColumnNumber    = 5
                Text            = 'Export Policy'
                Image           = 'table_export.png'
                SizeType        = 'Small'
                ToolTip         = 'Export the AppLocker Policy'
                Function        = { Export-AppLockerPolicy -AppLockerLDAP $Script:MApplock_LDAPEnvironmentHashtable }
            }
        )

        # Set the buttons for the Actions
        [System.Collections.Hashtable[]]$ActionButtons = @(
           @{
                ColumnNumber    = 1
                Text            = 'Check AppLocker Policy'
                TextColor       = 'LightCyan'
                DefaultIcon     = 'Shield'
                SizeType        = 'Large'
                ToolTip         = 'Check the AppLocker Policy'
                Function        = { Test-AppLockerPolicy -ApplicationID $Script:MApplock_FApplock_ApplicationComboBox.Text -AppLockerLDAP $Script:MApplock_SelectedAppLockerLDAP }
            }
           @{
                ColumnNumber    = 3
                Text            = 'Import AppLocker Policy'
                TextColor       = 'LightGreen'
                DefaultIcon     = 'Shield_Add'
                SizeType        = 'Large'
                ToolTip         = 'Import the AppLocker Policy'
                Function        = { Add-AppLockerPolicy -ApplicationID $Script:MApplock_FApplock_ApplicationComboBox.Text -AppLockerLDAP $Script:MApplock_SelectedAppLockerLDAP }
            }
           @{
                ColumnNumber    = 5
                Text            = 'Remove AppLocker Policy'
                TextColor       = 'Orange'
                DefaultIcon     = 'Shield_Delete'
                SizeType        = 'Large'
                ToolTip         = 'Remove the AppLocker Policy'
                Function        = { Remove-AppLockerPolicy -ApplicationID $Script:MApplock_FApplock_ApplicationComboBox.Text -AppLockerLDAP $Script:MApplock_SelectedAppLockerLDAP }
            }
        )

        # Set the buttons for the Extra Actions
        [System.Collections.Hashtable[]]$ExtraActionButtons = @(
            @{
                RowNumber       = 7
                Text            = 'Details in Host'
                DefaultIcon     = 'Shield'
                SizeType        = 'Medium'
                ToolTip         = 'Check the AppLocker Policy and show the result in a Gridview'
                Function        = { Test-AppLockerPolicy -ApplicationID $Script:MApplock_FApplock_ApplicationComboBox.Text -AppLockerLDAP $Script:MApplock_SelectedAppLockerLDAP -OutHost }
            }
            @{
                RowNumber       = 8
                Text            = 'Details in Grid'
                DefaultIcon     = 'Shield'
                SizeType        = 'Medium'
                ToolTip         = 'Check the AppLocker Policy and show the result in a Gridview'
                Function        = { Test-AppLockerPolicy -ApplicationID $Script:MApplock_FApplock_ApplicationComboBox.Text -AppLockerLDAP $Script:MApplock_SelectedAppLockerLDAP -OutGridView }
            }
        )

        ####################################################################################################
    } 
    
    process {
        # Create the GroupBox
        [System.Windows.Forms.GroupBox]$Global:MApplock_FApplock_GroupBox = $ParentGroupBox = Invoke-Groupbox @GroupBoxProperties

        # Create the MApplock_FApplock_ApplicationComboBox
        [System.Windows.Forms.ComboBox]$Script:MApplock_FApplock_ApplicationComboBox = Invoke-ComboBox @MApplock_FApplock_ApplicationComboBoxParameters -ParentGroupBox $ParentGroupBox
        
        # Create the MApplock_FApplock_EnvironmentComboBox
        [System.Windows.Forms.ComboBox]$Script:MApplock_FApplock_EnvironmentComboBox = Invoke-ComboBox @MApplock_FApplock_EnvironmentComboBoxParameters -ParentGroupBox $ParentGroupBox
        # Set the initial selection and the initial AppLocker LDAP value
        [System.String]$InitialSelectedEnvironment              = $Script:MApplock_FApplock_EnvironmentComboBox.Text
        [System.String]$Script:MApplock_SelectedAppLockerLDAP   = $Script:MApplock_LDAPEnvironmentHashtable.$InitialSelectedEnvironment
        # Add the event handler for the MApplock_FApplock_EnvironmentComboBox to update the selected AppLocker LDAP value, when the selection changes
        $Script:MApplock_FApplock_EnvironmentComboBox.Add_SelectedIndexChanged([System.EventHandler]{
            [System.String]$SelectedEnvironment                     = $Script:MApplock_FApplock_EnvironmentComboBox.Text
            [System.String]$Script:MApplock_SelectedAppLockerLDAP   = $Script:MApplock_LDAPEnvironmentHashtable.$SelectedEnvironment
            Write-Line ("The AppLocker LDAP Environment has changed to: $SelectedEnvironment") -Type Busy
            Write-Line ("($Script:MApplock_SelectedAppLockerLDAP)")
        })

        # Create the buttons
        Invoke-ButtonLine -ButtonPropertiesArray $MApplock_FApplock_ApplicationComboBoxButtons -ParentGroupBox $ParentGroupBox -RowNumber 1
        Invoke-ButtonLine -ButtonPropertiesArray $MApplock_FApplock_EnvironmentComboBoxButtons -ParentGroupBox $ParentGroupBox -RowNumber 2
        Invoke-ButtonLine -ButtonPropertiesArray $ActionButtons -ParentGroupBox $ParentGroupBox -RowNumber 4
        Invoke-ButtonLine -ButtonPropertiesArray $ExtraActionButtons -ParentGroupBox $ParentGroupBox -ColumnNumber 1
    }

    end {
    }
}

### END OF SCRIPT
####################################################################################################
