####################################################################################################
<#
.SYNOPSIS
    This function imports the feature Shorcut Info.
.DESCRIPTION
    This function is part of the Packaging Assistant. It contains references to classes, functions or variables, that are in other files.
.EXAMPLE
    Import-FeatureShortcutInfo -ParentTabPage $MyGlobalParentTabPage
.INPUTS
    [System.Windows.Forms.TabPage]
.OUTPUTS
    This function returns no stream output.
.NOTES
    Version         : 5.5.1
    Author          : Imraan Iotana
    Creation Date   : March 2025
    Last Update     : August 2025
#>
####################################################################################################

function Import-FeatureExtraFeatures {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory=$true,HelpMessage='The Parent object to which this feature will be added.')]
        [System.Windows.Forms.TabPage]
        $ParentTabPage
    )

    begin {
        ####################################################################################################
        ### MAIN PROPERTIES ###

        # Function
        [System.String[]]$FunctionDetails   = @($MyInvocation.MyCommand,$PSCmdlet.ParameterSetName,$PSBoundParameters.GetEnumerator())
        # Groupbox Handlers
        [System.String]$GroupboxTitle       = 'Export Shortcut Information'
        [System.String]$GroupboxColor       = 'Cyan'
        [System.Int32]$GroupboxNumberOfRows = 2

        ####################################################################################################
        ### BUTTON PROPERTIES ###

        [System.Collections.Hashtable[]]$ComboBoxButtons = @(
            @{
                ColumnNumber    = 1
                Text            = 'Open Folder'
                TextColor       = 'LightCyan'
                SizeType        = 'Medium'
                Image           = 'folder.png'
                ToolTip         = 'Open the Folder'
                Function        = {
                    if (-Not(Confirm-Object -MandatoryBox $Global:SIStartMenuItemsComboBox)) { Return }
                    [System.String]$ConvertedPath = Convert-ShortcutPath -Path $Global:SIStartMenuItemsComboBox.Text
                    [System.String]$FolderToOpen = if (Test-Path -Path $ConvertedPath -PathType Container) { $ConvertedPath } else { Split-Path -Path $ConvertedPath -Parent }
                    Open-Folder -Path $FolderToOpen
                }
            }
            @{
                ColumnNumber    = 2
                Text            = 'Refresh'
                TextColor       = 'LightCyan'
                SizeType        = 'Medium'
                Image           = 'arrow_refresh.png'
                ToolTip         = 'Refresh the content of this field'
                Function        = { Update-ComboBox -ComboBox $Global:SIStartMenuItemsComboBox -NewContent (Get-StartMenuItems -AsComboboxList) }
            }
        )

        [System.Collections.Hashtable[]]$LargeButtons = @(
            @{
                ColumnNumber    = 5
                Text            = 'Export Shortcut Details'
                SizeType        = 'Large'
                Image           = 'layer_export.png'
                ToolTip         = 'Export the details of the shortcut(s) to a file'
                Function        = {
                    if (-Not(Confirm-Object -MandatoryBox $Global:SIStartMenuItemsComboBox)) { Return }
                    [System.String]$ConvertedPath = Convert-ShortcutPath -Path $Global:SIStartMenuItemsComboBox.Text
                    Export-ShortcutInformation -Path $ConvertedPath -OpenOutputFolder
                }
            }
        )

        ####################################################################################################

        # Write the Begin message
        Write-Function -Begin $FunctionDetails
    } 
    
    process {
        # Create the GroupBox
        [System.Windows.Forms.GroupBox]$Global:SIShorcutExportGroupbox = $ParentGroupBox = Invoke-Groupbox -ParentTabPage $ParentTabPage -Title $GroupboxTitle -NumberOfRows $GroupboxNumberOfRows -Color $GroupboxColor
        # Create the ComboBox
        [System.Windows.Forms.ComboBox]$Global:SIStartMenuItemsComboBox = Invoke-ComboBox -ParentGroupBox $ParentGroupBox -RowNumber 1 -SizeType Medium -Type Output -Label 'Select Folder or Shortcut:' -ContentArray (Get-StartMenuItems -AsComboboxList) -PropertyName 'SIStartMenuItemsComboBox'
        # Create the Buttons
        Invoke-ButtonLine -ButtonPropertiesArray $ComboBoxButtons -ParentGroupBox $ParentGroupBox -RowNumber 2 -AssetFolder $PSScriptRoot
        Invoke-ButtonLine -ButtonPropertiesArray $LargeButtons -ParentGroupBox $ParentGroupBox -RowNumber 1 -AssetFolder $PSScriptRoot
    }

    end {
        # Write the End message
        Write-Function -End $FunctionDetails
    }
}

### END OF SCRIPT
####################################################################################################
