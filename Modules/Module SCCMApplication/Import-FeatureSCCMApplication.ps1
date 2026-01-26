####################################################################################################
<#
.SYNOPSIS
    This feature performs maintaince on the Packaging Assistant.
.DESCRIPTION
    This function is part of the Packaging Assistant. It contains references to classes, functions or variables, that are in other files.
.EXAMPLE
    Import-FeatureMaintainance
.INPUTS
    [System.Windows.Forms.TabPage]
.OUTPUTS
    This function returns no stream output.
.NOTES
    Version         : 5.5.1
    Author          : Imraan Iotana
    Creation Date   : September 2025
    Last Updated    : September 2025
#>
####################################################################################################

function Import-FeatureSCCMApplication {
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
        [System.String[]]$FunctionDetails = @($MyInvocation.MyCommand,$PSCmdlet.ParameterSetName,$PSBoundParameters.GetEnumerator())
        # GroupBox properties
        [PSCustomObject]$GroupBox = @{
            Title           = [System.String]'Manage SCCM Application'
            Color           = [System.String]'LightCyan'
            NumberOfRows    = [System.Int32]4
        }
        # Handlers
        [System.String[]]$DSLApplicationFolders = Get-SharedAssetPath -ApplicationFolders


        ####################################################################################################
        ### BUTTON PROPERTIES ###

        [System.Collections.Hashtable[]]$RightButtons = @(
            @{
                ColumnNumber   = 5
                Text            = 'Open Folder'
                Image           = 'folder.png'
                SizeType        = 'Small'
                ToolTip         = 'Open the SCCM folder of this application'
                Function        = { Open-Folder -Path (Get-Path -ApplicationID $Global:MSAApplicationComboBox.Text -SubFolder SCCMFolder) }
            }
            @{
                ColumnNumber    = 6
                Text            = 'Show Application Log'
                Image           = 'file_extension_log.png'
                SizeType        = 'Small'
                ToolTip         = 'Open the logfile of the selected Application'
                Function        = { Show-ApplicationLogFile -ApplicationID $Global:MSAApplicationComboBox.Text }
            }
        )

        [System.Collections.Hashtable[]]$ActionButtons = @(
            @{
                ColumnNumber    = 1
                Text            = 'Check Application'
                TextColor       = 'Yellow'
                Image           = 'magnifier.png'
                SizeType        = 'Large'
                ToolTip         = 'Check if the application exists in SCCM'
                Function        = { Show-SCCMApplicationInfo -ApplicationID $Global:MSAApplicationComboBox.Text }
            }
            @{
                ColumnNumber    = 3
                Text            = 'Create New Application'
                TextColor       = 'LawnGreen'
                Image           = 'package_add.png'
                SizeType        = 'Large'
                ToolTip         = 'Create a new SCCM Application'
                Function        = { New-SCCMApplication -ApplicationID $Global:MSAApplicationComboBox.Text }
            }
            @{
                ColumnNumber    = 5
                Text            = 'Remove Application'
                TextColor       = 'OrangeRed'
                Image           = 'package_delete.png'
                SizeType        = 'Large'
                ToolTip         = 'Remove the selected SCCM Application'
                Function        = { Remove-SCCMApplication -ApplicationID $Global:MSAApplicationComboBox.Text }
            }
        )

        ####################################################################################################

        # Write the begin message
        Write-Function -Begin $FunctionDetails
    } 
    
    process {
        # Create the GroupBox
        [System.Windows.Forms.GroupBox]$Global:SCCMApplicationGroupBox = $ParentGroupBox = Invoke-Groupbox -ParentTabPage $ParentTabPage -Title $Groupbox.Title -NumberOfRows $Groupbox.NumberOfRows -Color $Groupbox.Color
        # Create the Audit ComboBox
        [System.Windows.Forms.ComboBox]$Global:MSAApplicationComboBox = Invoke-ComboBox -ParentGroupBox $ParentGroupBox -RowNumber 1 -SizeType Medium -Type Output -Label 'Select Application:' -ContentArray $DSLApplicationFolders -PropertyName 'MSAApplicationComboBox'
        # Create the buttons
        Invoke-ButtonLine -ButtonPropertiesArray $RightButtons -ParentGroupBox $ParentGroupBox -RowNumber 1
        Invoke-ButtonLine -ButtonPropertiesArray $ActionButtons -ParentGroupBox $ParentGroupBox -RowNumber 3
    }

    end {
        # Write the end message
        Write-Function -End $FunctionDetails
    }
}

### END OF SCRIPT
####################################################################################################
