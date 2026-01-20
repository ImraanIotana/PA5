####################################################################################################
<#
.SYNOPSIS
    This function imports the Feature SCCM SourceFile Functions.
.DESCRIPTION
    This function is part of the Packaging Assistant. It may contain functions or variables, that are in other files.
.EXAMPLE
    Import-FeatureSCCMSourceFileFunctions
.INPUTS
    [System.Windows.Forms.TabPage]
.OUTPUTS
    This function returns no stream output.
.NOTES
    Version         : 5.5.2
    Author          : Imraan Iotana
    Creation Date   : October 2023
    Last Update     : October 2025
#>
####################################################################################################

function Import-FeatureSCCMSourceFileFunctions {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory=$true,HelpMessage='The Parent object to which this feature will be added.')]
        [System.Windows.Forms.TabPage]
        $ParentTabPage
    )

    begin {
        ####################################################################################################
        ### MAIN PROPERTIES ###

        # GroupBox properties
        [PSCustomObject]$GroupBox = @{
            Title           = [System.String]'SCCM Sourcefiles Functions'
            Color           = [System.String]'LightCyan'
            NumberOfRows    = [System.Int32]2
            GroupBoxAbove   = $Global:SCCMApplicationGroupBox
        }

        ####################################################################################################
        ### BUTTON PROPERTIES ###

        [System.Collections.Hashtable[]]$ActionButtons = @(
            <#@{
                ColumnNumber    = 1
                Text            = 'UPLOAD Sources to SCCM Repository (*)'
                Image           = 'inbox_upload.png'
                SizeType        = 'Large'
                ToolTip         = 'Upload the source files of the selected application'
                Function        = { Write-NoAction }
            }#>
            @{
                ColumnNumber    = 1
                Text            = 'MOVE WORKCOPY to SCCM folder'
                Image           = 'arrow_join.png'
                SizeType        = 'Large'
                ToolTip         = 'Move the Package from the WORK folder to SCCM folder'
                Function        = { Move-PackageFromWorkToSCCMFolder -ApplicationID $Global:MSAApplicationComboBox.Text }
            }
            @{
                ColumnNumber    = 2
                Text            = 'UPDATE Sources on SCCM Repository'
                Image           = 'update.png'
                SizeType        = 'Large'
                ToolTip         = 'Update the source files of the selected application'
                Function        = { Update-SCCMApplicationSourceFiles -ApplicationID $Global:MSAApplicationComboBox.Text }
            }
            @{
                ColumnNumber    = 3
                Text            = 'Update Distribution Points'
                Image           = 'database_refresh.png'
                SizeType        = 'Large'
                ToolTip         = 'Update the SCCM Distribution Points of the selected application'
                Function        = { Update-SCCMDistributionPoints -ApplicationID $Global:MSAApplicationComboBox.Text }
            }
            @{
                ColumnNumber    = 4
                Text            = 'Open Software Library (DSL)'
                SizeType        = 'Large'
                Image           = 'CD.png'
                Function        = { Open-Folder -Path (Get-Path -DSLFolder) }
            }
            @{
                ColumnNumber    = 5
                Text            = 'Open SCCM Repository'
                Image           = 'folder_database.png'
                SizeType        = 'Large'
                ToolTip         = 'Open the SCCM Repository'
                Function        = { Open-Folder -Path $Global:ApplicationObject.Settings.SCCMRepository }
            }
        )

        ####################################################################################################

        # Write the Begin message
        #Write-Function -Begin $FunctionDetails
    } 
    
    process {
        # Create the GroupBox
        [System.Windows.Forms.GroupBox]$Global:MSAFSSFFGroupBox = $ParentGroupBox = Invoke-Groupbox -ParentTabPage $ParentTabPage -Title $GroupBox.Title -NumberOfRows $GroupBox.NumberOfRows -Color $GroupBox.Color -GroupBoxAbove $GroupBox.GroupBoxAbove
        # Create the Buttons
        Invoke-ButtonLine -ButtonPropertiesArray $ActionButtons -ParentGroupBox $ParentGroupBox -RowNumber 1 -AssetFolder $PSScriptRoot
    }

    end {
        # Write the End message
        #Write-Function -End $FunctionDetails
    }
}

### END OF SCRIPT
####################################################################################################
