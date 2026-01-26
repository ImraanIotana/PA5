####################################################################################################
<#
.SYNOPSIS
    This feature imports and exports Omissa DEM objects, from and to the Appliction Folder on the DSL.
.DESCRIPTION
    This function is part of the Packaging Assistant. It contains references to classes, functions or variables, that are in other files.
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

function Import-FeatureOmnissaDEMAllObjects {
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
        [System.String]$CorrespondingRepository = $Global:ApplicationObject.Settings.DEMUserRegistryRepository

        # GroupBox properties
        [PSCustomObject]$GroupBox   = @{
            Title                   = [System.String]'Omnissa DEM ALL USER OBJECTS'
            Color                   = [System.String]'Blue'
            NumberOfRows            = [System.Int32]2
            GroupBoxAbove           = $Global:OmissaDEMUserRegistryGroupbox
        }

        ####################################################################################################
        ### BUTTON PROPERTIES ###

        [System.Collections.Hashtable[]]$ActionButtons = @(
            @{
                ColumnNumber    = 1
                Text            = 'IMPORT ALL Objects (*)'
                Image           = 'table_add.png'
                SizeType        = 'Large'
                ToolTip         = 'Import the User Registry Objects of this application from the DSL into Omnissa DEM'
                Function        = { Write-NoAction }
            }
            @{
                ColumnNumber    = 2
                Text            = 'EXPORT ALL Objects'
                Image           = 'table_go.png'
                SizeType        = 'Large'
                ToolTip         = 'Export the User Registry Objects of this application from Omnissa DEM to the DSL'
                Function        = {
                    Export-OmnissaDEMObjects -ApplicationID $Global:ODMApplicationIDComboBox.Text -Shortcuts
                    Export-OmnissaDEMObjects -ApplicationID $Global:ODMApplicationIDComboBox.Text -UserFiles
                    Export-OmnissaDEMObjects -ApplicationID $Global:ODMApplicationIDComboBox.Text -UserRegistry
                }
            }
            @{
                ColumnNumber    = 5
                Text            = 'REMOVE ALL Objects (*)'
                Image           = 'table_delete.png'
                SizeType        = 'Large'
                ToolTip         = 'Remove the User Registry Objects of this application from Omnissa DEM'
                Function        = { Write-NoAction }
            }
        )

        ####################################################################################################

        # Write the begin message
        Write-Function -Begin $FunctionDetails
    } 
    
    process {
        # Create the GroupBox, and add the extra properties
        [System.Windows.Forms.GroupBox]$Global:OmissaDEMUserRegistryGroupbox = $ParentGroupBox = Invoke-Groupbox -ParentTabPage $ParentTabPage -Title $Groupbox.Title -NumberOfRows $Groupbox.NumberOfRows -Color $Groupbox.Color -GroupBoxAbove $GroupBox.GroupBoxAbove
        $Global:OmissaDEMUserRegistryGroupbox | Add-Member -NotePropertyName CorrespondingRepository -NotePropertyValue $CorrespondingRepository
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
