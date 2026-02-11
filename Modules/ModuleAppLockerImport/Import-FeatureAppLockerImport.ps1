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

        # Groupbox Handlers
        #[System.String]$GroupboxTitle           = 'AppLocker Policy Import'
        #[System.String]$GroupboxColor           = 'LightCyan'
        #[System.Int32]$GroupboxNumberOfRows     = 7

        # ComboBox Handlers
        [System.String[]]$DSLApplicationFolders = Get-DSLApplicationFolder -All -Basenames

        # LDAP Handlers
        [System.Collections.Hashtable]$Global:LDAPEnvironmentHashtable = @{
            TEST        = (Get-ApplicationSetting -Name 'AppLockerLDAPTEST')
            PRODUCTION  = (Get-ApplicationSetting -Name 'AppLockerLDAPPROD')
        }


        ####################################################################################################
        ### BUTTON PROPERTIES ###

        [System.Collections.Hashtable[]]$SmallButtons = @(
            @{
                ColumnNumber    = 5
                Text            = 'Open Folder'
                Image           = 'folder.png'
                SizeType        = 'Small'
                ToolTip         = 'Open the AppLocker folder'
                Function        = { Open-Folder -Path (Get-Path -ApplicationID $Global:ALAApplicationIDComboBox.Text -SubFolder AppLockerFolder) }
            }
            @{
                ColumnNumber    = 6
                Text            = 'Show Application Log'
                Image           = 'file_extension_log.png'
                SizeType        = 'Small'
                ToolTip         = 'Open the logfile of the selected Application'
                Function        = { Show-ApplicationLogFile -ApplicationID $Global:ALAApplicationIDComboBox.Text }
            }
        )

        [System.Collections.Hashtable[]]$SideButtons = @(
            @{
                RowNumber       = 1
                Text            = 'Open Folder'
                Image           = 'folder.png'
                SizeType        = 'Small'
                ToolTip         = 'Open the AppLocker folder'
                Function        = { Open-Folder -Path (Get-Path -ApplicationID $Global:ALAApplicationIDComboBox.Text -SubFolder AppLockerFolder) }
            }
            @{
                RowNumber       = 2
                Text            = 'Export Policy'
                Image           = 'table_export.png'
                SizeType        = 'Small'
                ToolTip         = 'Export the AppLocker Policy'
                Function        = { Export-AppLockerPolicy -AppLockerLDAP $Global:SelectedAppLockerLDAP }
            }
        )

        [System.Collections.Hashtable[]]$ActionButtons = @(
           @{
                ColumnNumber    = 1
                Text            = 'Check AppLocker Policy'
                TextColor       = 'LightCyan'
                Image           = 'shield.png'
                SizeType        = 'Large'
                ToolTip         = 'Check the AppLocker Policy'
                Function        = { Test-AppLockerPolicy -ApplicationID $Global:ALAApplicationIDComboBox.Text -AppLockerLDAP $Global:SelectedAppLockerLDAP }
            }
           @{
                ColumnNumber    = 3
                Text            = 'Import AppLocker Policy'
                TextColor       = 'LightGreen'
                Image           = 'shield_add.png'
                SizeType        = 'Large'
                ToolTip         = 'Import the AppLocker Policy'
                Function        = { Add-AppLockerPolicy -ApplicationID $Global:ALAApplicationIDComboBox.Text -AppLockerLDAP $Global:SelectedAppLockerLDAP }
            }
           @{
                ColumnNumber    = 5
                Text            = 'Remove AppLocker Policy'
                TextColor       = 'Orange'
                Image           = 'shield_delete.png'
                SizeType        = 'Large'
                ToolTip         = 'Remove the AppLocker Policy'
                Function        = { Remove-AppLockerPolicy -ApplicationID $Global:ALAApplicationIDComboBox.Text -AppLockerLDAP $Global:SelectedAppLockerLDAP }
            }
        )

        [System.Collections.Hashtable[]]$ExtraActionButtons = @(
            @{
                RowNumber       = 7
                Text            = 'Details in Host'
                Image           = 'shield.png'
                SizeType        = 'Medium'
                ToolTip         = 'Check the AppLocker Policy and show the result in a Gridview'
                Function        = { Test-AppLockerPolicy -ApplicationID $Global:ALAApplicationIDComboBox.Text -AppLockerLDAP $Global:SelectedAppLockerLDAP -OutHost }
            }
            @{
                RowNumber       = 8
                Text            = 'Details in Grid'
                Image           = 'shield.png'
                SizeType        = 'Medium'
                ToolTip         = 'Check the AppLocker Policy and show the result in a Gridview'
                Function        = { Test-AppLockerPolicy -ApplicationID $Global:ALAApplicationIDComboBox.Text -AppLockerLDAP $Global:SelectedAppLockerLDAP -OutGridView }
            }
        )

        ####################################################################################################
    } 
    
    process {
        # Create the GroupBox
        [System.Windows.Forms.GroupBox]$Global:AppLockerApplicationGroupBox = $ParentGroupBox = Invoke-Groupbox @GroupBoxProperties
        # Create the GroupBox
        #[System.Windows.Forms.GroupBox]$Global:AppLockerApplicationGroupBox = $ParentGroupBox = Invoke-Groupbox -ParentTabPage $ParentTabPage -Title $GroupboxTitle -NumberOfRows $GroupboxNumberOfRows -Color $GroupboxColor
        # Create the ALAApplicationIDComboBox
        [System.Windows.Forms.ComboBox]$Global:ALAApplicationIDComboBox = Invoke-ComboBox -ParentGroupBox $ParentGroupBox -RowNumber 1 -SizeType Medium -Type Output -Label 'Select Application:' -ContentArray $DSLApplicationFolders -PropertyName 'ALAApplicationIDComboBox'
        
        # Create the ALIEnvironmentComboBox
        [System.Windows.Forms.ComboBox]$Global:ALIEnvironmentComboBox = Invoke-ComboBox -ParentGroupBox $ParentGroupBox -RowNumber 2 -SizeType Medium -Type Output -Label 'Select Environment:' -ContentArray $Global:LDAPEnvironmentHashtable.Keys -PropertyName 'ALIEnvironmentComboBox'
        $Global:ALIEnvironmentComboBox | ForEach-Object {
            if (Test-Object -IsEmpty ($_.Text)) {
                Write-Verbose ('The ALIEnvironmentComboBox field is empty. It will be filled with the default value: (TEST)')
                $_.Text = 'TEST'
            }
        }
        # Add the EventHandler based on the selection
        [System.String]$Global:SelectedAppLockerLDAP = $Global:LDAPEnvironmentHashtable.$($Global:ALIEnvironmentComboBox.Text)
        $Global:ALIEnvironmentComboBox.Add_SelectedIndexChanged([System.EventHandler]{
            [System.String]$Environment     = $Global:ALIEnvironmentComboBox.Text
            $Global:SelectedAppLockerLDAP   = $Global:LDAPEnvironmentHashtable.$Environment
            Write-Yellow ('The AppLocker LDAP Environment has changed to: {0} - ({1})' -f $Environment,$Global:SelectedAppLockerLDAP)
        })

        # Create the buttons
        Invoke-ButtonLine -ButtonPropertiesArray $SmallButtons -ParentGroupBox $ParentGroupBox -RowNumber 1
        Invoke-ButtonLine -ButtonPropertiesArray $SideButtons -ParentGroupBox $ParentGroupBox -ColumnNumber 5
        Invoke-ButtonLine -ButtonPropertiesArray $ActionButtons -ParentGroupBox $ParentGroupBox -RowNumber 4
        Invoke-ButtonLine -ButtonPropertiesArray $ExtraActionButtons -ParentGroupBox $ParentGroupBox -ColumnNumber 1
    }

    end {
    }
}

### END OF SCRIPT
####################################################################################################
