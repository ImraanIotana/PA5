####################################################################################################
<#
.SYNOPSIS
    This feature imports and exports Omissa DEM objects, from and to the Appliction Folder on the DSL.
.DESCRIPTION
    This function is part of the Packaging Assistant. It contains functions and variables that are in other files.
.EXAMPLE
    Import-FeatureOmissaDEMUserFiles
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

function Import-FeatureOmnissaDEMUserFiles {
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
        [System.String]$CorrespondingRepository = $Global:ApplicationObject.Settings.DEMUserFilesRepository

        # GroupBox properties
        [PSCustomObject]$GroupBox   = @{
            Title                   = [System.String]'Omnissa DEM USER FILES'
            Color                   = [System.String]'Blue'
            NumberOfRows            = [System.Int32]2
            GroupBoxAbove           = $Global:OmissaDEMShortcutsGroupbox
        }

        ####################################################################################################
        ### BUTTON PROPERTIES ###

        [System.Collections.Hashtable[]]$ActionButtons = @(
            @{
                ColumnNumber    = 1
                Text            = 'IMPORT UserFile Objects (*)'
                Image           = 'table_add.png'
                SizeType        = 'Large'
                ToolTip         = 'Import the User File Objects of this application from the DSL into Omnissa DEM'
                Function        = { Write-NoAction }
            }
            @{
                ColumnNumber    = 2
                Text            = 'EXPORT UserFile Objects'
                Image           = 'table_go.png'
                SizeType        = 'Large'
                ToolTip         = 'Export the User File Objects of this application from Omnissa DEM to the DSL'
                Function        = { Export-OmnissaDEMObjects -ApplicationID $Global:ODMApplicationIDComboBox.Text -UserFiles }
            }
            @{
                ColumnNumber    = 3
                Text            = 'Open UserFile Repository'
                Image           = 'folder_table.png'
                SizeType        = 'Large'
                ToolTip         = 'Open the Repository containing the objects'
                Function        = { Open-Folder -Path $Global:OmissaDEMUserFilesGroupbox.CorrespondingRepository }
            }
            @{
                ColumnNumber    = 5
                Text            = 'REMOVE UserFile Objects (*)'
                Image           = 'table_delete.png'
                SizeType        = 'Large'
                ToolTip         = 'Remove the User File Objects of this application from Omnissa DEM'
                Function        = { Write-NoAction }
            }
        )

        ####################################################################################################

        # Write the begin message
        Write-Function -Begin $FunctionDetails
    } 
    
    process {
        # Create the GroupBox, and add the extra properties
        [System.Windows.Forms.GroupBox]$Global:OmissaDEMUserFilesGroupbox = $ParentGroupBox = Invoke-Groupbox -ParentTabPage $ParentTabPage -Title $Groupbox.Title -NumberOfRows $Groupbox.NumberOfRows -Color $Groupbox.Color -GroupBoxAbove $GroupBox.GroupBoxAbove
        $Global:OmissaDEMUserFilesGroupbox | Add-Member -NotePropertyName CorrespondingRepository -NotePropertyValue $CorrespondingRepository
        # Create the action buttons
        Invoke-ButtonLine -ButtonPropertiesArray $ActionButtons -ParentGroupBox $ParentGroupBox -RowNumber 1
    }

    end {
        # Write the end message
        Write-Function -End $FunctionDetails
    }
}

### END OF SCRIPT
####################################################################################################
