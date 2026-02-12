####################################################################################################
<#
.SYNOPSIS
    This function imports the feature SCCM Deployment Buttons.
.DESCRIPTION
    This function is part of the Packaging Assistant. It contains functions and variables that are in other files.
.EXAMPLE
    Import-FeatureSCCMDeploymentButtons
.INPUTS
    [System.Windows.Forms.TabPage]
.OUTPUTS
    This function returns no stream output.
.NOTES
    Version         : 5.5.1
    Author          : Imraan Iotana
    Creation Date   : October 2023
    Last Update     : September 2025
#>
####################################################################################################

function Import-FeatureSCCMDeploymentButtons {
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
        #[System.String[]]$FunctionDetails   = @($MyInvocation.MyCommand,$PSCmdlet.ParameterSetName,$PSBoundParameters.GetEnumerator())
        # GroupBox properties
        [PSCustomObject]$GroupBox = @{
            Title           = [System.String]'SCCM Deployment buttons'
            Color           = [System.String]'PowderBlue'
            NumberOfRows    = [System.Int32]2
            GroupBoxAbove   = $Global:MSAFSSFFGroupBox
        }

        ####################################################################################################
        ### BUTTON PROPERTIES ###

        [System.Collections.Hashtable[]]$ActionButtons = @(
            @{
                ColumnNumber    = 1
                Text            = 'Check Deployment to Test VDI'
                TextColor       = 'Yellow'
                Image           = 'magnifier.png'
                SizeType        = 'Large'
                ToolTip         = 'Check if the application is deployed to your Test/Packaging VDI'
                Function        = { Test-SCCMApplicationDeployment -ApplicationID $Global:MSAApplicationComboBox.Text -CollectionName $Global:ApplicationObject.Settings.SCCMTestVDICollection -PassThru -OutHost }
            }
            @{
                ColumnNumber    = 3
                Text            = 'Deploy to Test VDI'
                TextColor       = 'LawnGreen'
                Image           = 'computer_add.png'
                SizeType        = 'Large'
                ToolTip         = 'Deploy the application to your Test/Packaging VDI for testing'
                Function        = { New-MECMApplicationDeployment -ApplicationID $Global:MSAApplicationComboBox.Text }
            }
            @{
                ColumnNumber    = 5
                Text            = 'Remove Test VDI Deployment'
                TextColor       = 'OrangeRed'
                Image           = 'computer_delete.png'
                SizeType        = 'Large'
                ToolTip         = 'Remove the Deployment'
                Function        = { Remove-MECMApplicationDeployment -ApplicationID $Global:MSAApplicationComboBox.Text }
            }
        )

        ####################################################################################################

        # Write the Begin message
        #Write-Function -Begin $FunctionDetails
    } 
    
    process {
        # Create the GroupBox
        [System.Windows.Forms.GroupBox]$Global:SCCMDeploymentButtonsGroupBox = $ParentGroupBox = Invoke-Groupbox -ParentTabPage $ParentTabPage -Title $GroupBox.Title -NumberOfRows $GroupBox.NumberOfRows -Color $GroupBox.Color -GroupBoxAbove $GroupBox.GroupBoxAbove
        # Create the Buttons
        Invoke-ButtonLine -ButtonPropertiesArray $ActionButtons -ParentGroupBox $ParentGroupBox -RowNumber 1
    }

    end {
        # Write the End message
        #Write-Function -End $FunctionDetails
    }
}

### END OF SCRIPT
####################################################################################################
