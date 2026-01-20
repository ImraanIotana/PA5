####################################################################################################
<#
.SYNOPSIS
    This function imports the feature SCCM Audit Buttons.
.DESCRIPTION
    This function is part of the Packaging Assistant. It contains references to classes, functions or variables, that are in other files.
.EXAMPLE
    Import-FeatureSCCMAuditButtons
.INPUTS
    [System.Windows.Forms.TabPage]
.OUTPUTS
    This function returns no stream output.
.NOTES
    Version         : 5.5.1
    Author          : Imraan Iotana
    Creation Date   : September 2025
    Last Update     : September 2025
#>
####################################################################################################

function Import-FeatureSCCMOtherButtons {
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

        # GroupBox properties
        [PSCustomObject]$GroupBox = @{
            Title           = [System.String]'SCCM Other functions'
            Color           = [System.String]'Yellow'
            NumberOfRows    = [System.Int32]2
            GroupBoxAbove   = $Global:SCCMDeploymentButtonsGroupBox
        }

        ####################################################################################################
        ### BUTTON PROPERTIES ###

        [System.Collections.Hashtable[]]$Buttons = @(
            @{
                ColumnNumber    = 1
                Text            = 'Audit SCCM Content Location'
                Image           = 'database_lightning.png'
                SizeType        = 'Large'
                ToolTip         = 'Check if the Content Location of the application is correct'
                Function        = { Update-SCCMContentLocation -ApplicationID $Global:MSAApplicationComboBox.Text }
            }
            @{
                ColumnNumber    = 5
                Text            = 'Start SCCM Console'
                Image           = 'server_database.png'
                SizeType        = 'Large'
                ToolTip         = 'Start the SCCM Console'
                Function        = { Write-Busy "Starting the SCCM Console. One moment please..." ; Invoke-Item -Path $Global:ApplicationObject.Settings.SCCMExecutable }
            }
        )

        ####################################################################################################

        Write-Message -FunctionBegin -Details $FunctionDetails
    } 
    
    process {
        # Create the GroupBox
        [System.Windows.Forms.GroupBox]$Global:SCCMSingleFunctionButtonsGroupBox = $ParentGroupBox = Invoke-Groupbox -ParentTabPage $ParentTabPage -Title $GroupBox.Title -NumberOfRows $GroupBox.NumberOfRows -Color $GroupBox.Color -GroupBoxAbove $GroupBox.GroupBoxAbove
        # Create the Buttons
        Invoke-ButtonLine -ButtonPropertiesArray $Buttons -ParentGroupBox $ParentGroupBox -RowNumber 1 -AssetFolder $PSScriptRoot
    }

    end {
        Write-Message -FunctionEnd -Details $FunctionDetails
    }
}

### END OF SCRIPT
####################################################################################################
