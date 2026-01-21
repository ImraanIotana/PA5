####################################################################################################
<#
.SYNOPSIS
    This feature performs maintenance on the Packaging Assistant.
.DESCRIPTION
    This function is part of the Packaging Assistant. It contains references to functions and variables that are in other files.
.EXAMPLE
    Import-FeatureMaintenance
.INPUTS
    [System.Windows.Forms.TabPage]
.OUTPUTS
    This function returns no stream output.
.NOTES
    Version         : 5.7.0
    Author          : Imraan Iotana
    Creation Date   : September 2025
    Last Update     : January 2026
#>
####################################################################################################

function Import-FeatureMaintenance {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory=$true,HelpMessage='The Parent TabPage to which this Feature will be added.')]
        [System.Windows.Forms.TabPage]
        $ParentTabPage
    )

    begin {
        ####################################################################################################
        ### MAIN PROPERTIES ###

        # GroupBox properties
        [PSCustomObject]$GroupBox = @{
            Title           = [System.String]'Maintenance'
            Color           = [System.String]'Blue'
            NumberOfRows    = [System.Int32]4
        }

        # Maintenance Action Handlers
        [System.Collections.Hashtable]$Script:ActionHashtable = @{
            #DownLoadScript  = 'GENERAL: Download the DeploymentScript'
            UpdatePA        = 'GENERAL: Update the Packaging Assistant'
            ShowFormsColors = 'GENERAL: Write Windows Forms Colors to Host'
            UpdateScript    = 'APPLICATION INTAKE: Update the DeploymentScript'
        }


        ####################################################################################################
        ### BUTTON PROPERTIES ###

        [System.Management.Automation.ScriptBlock]$Script:ExecuteActionScriptBlock = {
            # Get the selected key from the hashtable
            [System.String]$SelectedKey = $Script:ActionHashtable.Keys | Where-Object { $Script:ActionHashtable.$_ -eq $Global:FAMActionComboBox.Text }
            # Perform the action based on the selected key
            switch ($SelectedKey) {
                'UpdateScript'      { Update-InternalDeploymentScript }
                'ShowFormsColors'   { Write-WindowsFormsColors }
                Default             { Write-Line "This function has not been defined yet. No action has been taken." }
            }
        }

        [System.Collections.Hashtable[]]$ActionButtons = @(
           @{
                ColumnNumber    = 1
                Text            = 'Execute the Action'
                Image           = 'cog_go.png'
                SizeType        = 'Large'
                ToolTip         = 'Execute the selected Maintenance Action'
                Function        = { & $Script:ExecuteActionScriptBlock }
            }
        )

        <#[System.Collections.Hashtable[]]$ActionButtons = @(
           @{
                ColumnNumber    = 1
                Text            = 'Execute the Action'
                Image           = 'cog_go.png'
                SizeType        = 'Large'
                ToolTip         = 'Execute the selected Maintenance Action'
                Function        = {
                    [System.String]$SelectedKey = $Global:ActionHashtable.Keys | Where-Object { $Global:ActionHashtable.$_ -eq $Global:FAMActionComboBox.Text }
                    switch ($SelectedKey) {
                        #'DownLoadScript'    { Copy-ScriptToOutputFolder }
                        'UpdateScript'      { Update-InternalDeploymentScript }
                        'ShowFormsColors'   { Write-WindowsFormsColors }
                        Default             { Write-Line "This function has not been defined yet. No action has been taken." }
                    }
                }
            }
        )#>

        ####################################################################################################
    }

    process {
        # Create the GroupBox
        [System.Windows.Forms.GroupBox]$Global:FAMMaintenanceGroupBox = $ParentGroupBox = Invoke-Groupbox -ParentTabPage $ParentTabPage -Title $GroupBox.Title -NumberOfRows $GroupBox.NumberOfRows -Color $GroupBox.Color

        # Create the Audit ComboBox
        [System.Windows.Forms.ComboBox]$Global:FAMActionComboBox = Invoke-ComboBox -ParentGroupBox $ParentGroupBox -RowNumber 1 -SizeType Medium -Type Output -Label 'Select Action:' -ContentArray $Global:ActionHashtable.Values -PropertyName 'FAMActionComboBox'

        # Create the buttons
        Invoke-ButtonLine -ButtonPropertiesArray $ActionButtons -ParentGroupBox $ParentGroupBox -RowNumber 2 -AssetFolder $PSScriptRoot
    }

    end {
    }
}

### END OF SCRIPT
####################################################################################################
