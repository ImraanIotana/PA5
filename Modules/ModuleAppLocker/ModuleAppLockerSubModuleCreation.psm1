####################################################################################################
<#
.SYNOPSIS
    This function imports the Module AppLocker Creation.
.DESCRIPTION
    This function is part of the Packaging Assistant. It contains references to classes, functions and variables, that may be in other files.
.EXAMPLE
    Import-ModuleAppLockerCreation
.INPUTS
    [System.Windows.Forms.TabControl]
.OUTPUTS
    This function returns no stream output.
.NOTES
    Version         : 5.5.1
    Author          : Imraan Iotana
    Creation Date   : September 2025
    Last Update     : September 2025
#>
####################################################################################################

function Import-SubModuleAppLockerCreation {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory=$false,HelpMessage='The Parent TabControl to which this new TabPage will be added.')]
        [Alias('TabControl')]
        [System.Windows.Forms.TabControl]
        $ParentTabControl = $Global:MainTabControl
    )

    begin {
        ####################################################################################################
        ### MAIN PROPERTIES ###

        # Handlers
        [System.String]$TabTitle        = 'AppLocker CREATION'
        [System.String]$ModuleVersion   = '5.5.1'

        ####################################################################################################
    }
    
    process {
        try {
            # Write the message
            Write-ModuleImport -Title $TabTitle -Version $ModuleVersion
            # Create the Module TabPage
            [System.Windows.Forms.TabPage]$ParentTabPage = New-TabPage -Parent $ParentTabControl -Title $TabTitle -BackGroundColor 'RoyalBlue'
            # Import the Features
            Import-FeatureAppLockerCreation -ParentTabPage $ParentTabPage
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
        [System.Windows.Forms.TabPage]$ParentTabPage
    )

    begin {
        ####################################################################################################
        ### MAIN PROPERTIES ###

        # GroupBox properties
        [PSCustomObject]$GroupBox   = @{
            Title                   = [System.String]'Create AppLocker Policy'
            Color                   = [System.String]'Cyan'
            NumberOfRows            = [System.Int32]8
        }

        # Set the Button Properties Array
        [System.Object[][]]$MAppLock_SCreate_FolderToScan_TextBox_Buttons  = @( (1,'Browse') , (3,'Copy') , (4,'Paste') , (5,'Open') )
        [System.Object[][]]$MAppLock_SCreate_ADGroupSID_TextBox_Buttons  = @( (1,'Browse') , (3,'Copy') , (4,'Paste') , (5,'Open') )

        ####################################################################################################
        ### TEXTBOX PROPERTIES ###

        # Set the MAppLock_SCreate_FolderToScan_TextBox properties
        [System.Collections.Hashtable]$MAppLock_SCreate_FolderToScan_TextBox_Properties = @{
            RowNumber               = 3
            Label                   = 'Select Folder to scan:'
            ToolTip                 = 'Select the folder that contains the files to be scanned for AppLocker rules creation.'
            PropertyName            = 'MAppLock_SCreate_FolderToScan_TextBox'
            ButtonPropertiesArray   = $MAppLock_SCreate_FolderToScan_TextBox_Buttons
        }

        # Set the MAppLock_SCreate_ADGroupSID_TextBox properties
        [System.Collections.Hashtable]$MAppLock_SCreate_ADGroupSID_TextBox_Properties = @{
            RowNumber               = 6
            Label                   = 'AD Group SID:'
            ToolTip                 = 'Enter the AD Group SID for the AppLocker policy.'
            PropertyName            = 'MAppLock_SCreate_ADGroupSID_TextBox'
            ButtonPropertiesArray   = $MAppLock_SCreate_ADGroupSID_TextBox_Buttons
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
                DefaultIcon     = 'Shield'
                SizeType        = 'Large'
                ToolTip         = 'Create AppLocker Policy Files from the selected folder'
                Function        = { Invoke-AppLockerFileCreation -ApplicationID $Global:ALCApplicationIDComboBox.Text -FolderToScan $Script:MAppLock_SCreate_FolderToScan_TextBox.Text -ADGroupSID $Global:ALCADGroupSIDTextBox.Text }
            }
        )

        ####################################################################################################
    } 
    
    process {
        # Create the GroupBox
        [System.Windows.Forms.GroupBox]$Global:AppLockerCreationGroupbox = $ParentGroupBox = Invoke-Groupbox -ParentTabPage $ParentTabPage -Title $Groupbox.Title -NumberOfRows $Groupbox.NumberOfRows -Color $Groupbox.Color

        # Create the ApplicationID ComboBox
        [System.Windows.Forms.ComboBox]$Global:ALCApplicationIDComboBox = Invoke-ComboBox -ParentGroupBox $ParentGroupBox -RowNumber 1 -SizeType Medium -Type Output -Label 'Select Application:' -ContentArray (Get-DSLApplicationFolder -All -Basenames) -PropertyName 'ALCApplicationIDComboBox'
        Invoke-ButtonLine -ButtonPropertiesArray $ALCApplicationIDComboBoxButtons -ParentGroupBox $ParentGroupBox -RowNumber 1

        # Create the MAppLock_SCreate_FolderToScan_TextBox
        [System.Windows.Forms.TextBox]$Script:MAppLock_SCreate_FolderToScan_TextBox = Invoke-TextBox @MAppLock_SCreate_FolderToScan_TextBox_Properties -ParentGroupBox $ParentGroupBox

        # Create the MAppLock_SCreate_ADGroupSID_TextBox
        [System.Windows.Forms.TextBox]$Script:MAppLock_SCreate_ADGroupSID_TextBox = Invoke-TextBox @MAppLock_SCreate_ADGroupSID_TextBox_Properties -ParentGroupBox $ParentGroupBox
        #Invoke-ButtonLine -ButtonPropertiesArray $MAppLock_SCreate_ADGroupSID_TextBox_Buttons -ParentGroupBox $ParentGroupBox -RowNumber 7

        # Create the action button
        Invoke-ButtonLine -ButtonPropertiesArray $ActionButtons -ParentGroupBox $ParentGroupBox -RowNumber 8
    }

    end {
    }
}

### END OF SCRIPT
####################################################################################################


