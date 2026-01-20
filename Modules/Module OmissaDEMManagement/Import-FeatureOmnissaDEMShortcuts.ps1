####################################################################################################
<#
.SYNOPSIS
    This feature imports and exports Omissa DEM objects, from and to the Appliction Folder on the DSL.
.DESCRIPTION
    This function is part of the Packaging Assistant. It contains references to classes, functions or variables, that are in other files.
.EXAMPLE
    Import-FeatureOmissaDEMShortcuts
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

function Import-FeatureOmnissaDEMShortcuts {
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
        [System.String[]]$FunctionDetails       = @($MyInvocation.MyCommand,$PSCmdlet.ParameterSetName,$PSBoundParameters.GetEnumerator())
        # Handlers
        [System.String]$CorrespondingRepository = $Global:ApplicationObject.Settings.DEMShortcutRepository

        # GroupBox properties
        [PSCustomObject]$GroupBox   = @{
            Title                   = [System.String]'Omnissa DEM user SHORTCUTS'
            Color                   = [System.String]'Blue'
            NumberOfRows            = [System.Int32]2
            GroupBoxAbove           = $Global:OmissaDEMManagementGroupbox
        }

        ####################################################################################################
        ### BUTTON PROPERTIES ###

        [System.Collections.Hashtable[]]$ActionButtons = @(
            @{
                ColumnNumber    = 1
                Text            = 'IMPORT Shortcuts'
                Image           = 'table_add.png'
                SizeType        = 'Large'
                ToolTip         = 'Import the shortcuts of this application from the DSL into Omnissa DEM'
                Function        = { Import-DEMShortcuts -ApplicationID $Global:ODMApplicationIDComboBox.Text }
            }
            @{
                ColumnNumber    = 2
                Text            = 'EXPORT Shortcuts'
                Image           = 'table_go.png'
                SizeType        = 'Large'
                ToolTip         = 'Export the shortcuts of this application from Omnissa DEM to the DSL'
                Function        = { Export-OmnissaDEMObjects -ApplicationID $Global:ODMApplicationIDComboBox.Text -Shortcuts }
            }
            @{
                ColumnNumber    = 3
                Text            = 'Open Shortcut Repository'
                Image           = 'folder_table.png'
                SizeType        = 'Large'
                ToolTip         = 'Open the Repository containing the objects'
                Function        = { Open-Folder -Path $Global:OmissaDEMShortcutsGroupbox.CorrespondingRepository }
            }
            @{
                ColumnNumber    = 5
                Text            = 'REMOVE Shortcuts (*)'
                Image           = 'table_delete.png'
                SizeType        = 'Large'
                ToolTip         = 'Remove the shortcuts of this application from Omnissa DEM'
                Function        = { Write-NoAction }
            }
        )

        ####################################################################################################

        # Write the begin message
        Write-Function -Begin $FunctionDetails
    } 
    
    process {
        # Create the GroupBox, and add the extra properties
        [System.Windows.Forms.GroupBox]$Global:OmissaDEMShortcutsGroupbox = $ParentGroupBox = Invoke-Groupbox -ParentTabPage $ParentTabPage -Title $Groupbox.Title -NumberOfRows $Groupbox.NumberOfRows -Color $Groupbox.Color -GroupBoxAbove $GroupBox.GroupBoxAbove
        $Global:OmissaDEMShortcutsGroupbox | Add-Member -NotePropertyName CorrespondingRepository -NotePropertyValue $CorrespondingRepository
        # Create the action buttons
        Invoke-ButtonLine -ButtonPropertiesArray $ActionButtons -ParentGroupBox $ParentGroupBox -RowNumber 1 -AssetFolder $PSScriptRoot
    }

    end {
        # Write the end message
        Write-Function -End $FunctionDetails
    }
}

### END OF SCRIPT
####################################################################################################
