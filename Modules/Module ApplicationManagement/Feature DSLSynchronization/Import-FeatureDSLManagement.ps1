####################################################################################################
<#
.SYNOPSIS
    This function imports the feature DSL Synchronization. This function synchronizes and moves an Application from the DSL to your OutputFolder.
.DESCRIPTION
    This function is part of the Packaging Assistant. It contains functions and variables that are in other files.
.EXAMPLE
    Import-FeatureDSLSynchronization
.INPUTS
    [System.Windows.Forms.TabPage]
.OUTPUTS
    This function returns no output.
.NOTES
    Version         : 5.5
    Author          : Imraan Iotana
    Creation Date   : July 2025
    Last Updated    : August 2025
#>
####################################################################################################

function Import-FeatureDSLManagement {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory=$true,HelpMessage='The Parent TabPage to which this Feature will be added.')]
        [System.Windows.Forms.TabPage]
        $ParentTabPage
    )

    begin {
        ####################################################################################################
        ### MAIN OBJECT ###

        # Set the main object
        [PSCustomObject]$Local:MainObject = @{
            # Function
            FunctionDetails         = [System.String[]]@($MyInvocation.MyCommand,$PSCmdlet.ParameterSetName,$PSBoundParameters.GetEnumerator())
            # Input
            ParentTabPage           = $ParentTabPage
            # Groupbox Handlers
            GroupboxTitle           = [System.String]'DSL Folder Management'
            GroupboxColor           = [System.String]'LightCyan'
            GroupboxNumberOfRows    = [System.Int32]2
            # Handlers
            AssetFolder             = [System.String]$PSScriptRoot
        }

        ####################################################################################################
        ### MAIN FUNCTION METHODS ###

        # Add the Begin method
        $Local:MainObject | Add-Member -MemberType ScriptMethod -Name Begin -Value { Write-Message -Begin $this.FunctionDetails }

        # Add the End method
        $Local:MainObject | Add-Member -MemberType ScriptMethod -Name End -Value { Write-Message -End $this.FunctionDetails }

        # Add the Process method
        Add-Member -InputObject $Local:MainObject -MemberType ScriptMethod -Name Process -Value {
            # Create the GroupBox
            [System.Windows.Forms.GroupBox]$Global:DSLSynchronizationGroupBox = $ParentGroupBox = Invoke-Groupbox -ParentTabPage $this.ParentTabPage -Title $this.GroupboxTitle -NumberOfRows $this.GroupboxNumberOfRows -Color $this.GroupboxColor

            ####################################################################################################

            # Create the DSApplicationIDComboBox
            [System.Int32]$DSApplicationIDComboBoxRow = 1
            [System.Windows.Forms.ComboBox]$Global:DSApplicationIDComboBox = Invoke-ComboBox -ParentGroupBox $ParentGroupBox -RowNumber $DSApplicationIDComboBoxRow -SizeType Medium -Type Output -Label 'Select Application:' -ContentArray (Get-DSLApplicationFolder -All -Basenames) -PropertyName 'DSApplicationIDComboBox'
            # Add the buttons to the box
            $Global:DSApplicationIDComboBox | Add-Member -NotePropertyName ButtonPropertiesArray -NotePropertyValue @(
                @{
                    ColumnNumber    = 5
                    Text            = 'Open'
                    Image           = 'folder.png'
                    SizeType        = 'Small'
                    ToolTip         = 'Open the Applicationfolder on the DSL'
                    Function        = { Open-Folder -Path (Get-DSLApplicationFolder -FromBox $Global:DSApplicationIDComboBox) }
                }
                @{
                    ColumnNumber    = 6
                    Text            = 'Show Application Log'
                    Image           = 'file_extension_log.png'
                    SizeType        = 'Small'
                    ToolTip         = 'Open the logfile of the selected Application'
                    Function        = { Show-ApplicationLogFile -ApplicationID $Global:DSApplicationIDComboBox.Text }
                }
            )
            # Create the buttons
            Invoke-ButtonLine -ButtonPropertiesArray $Global:DSApplicationIDComboBox.ButtonPropertiesArray -ParentGroupBox $ParentGroupBox -RowNumber $DSApplicationIDComboBoxRow

        }

        ####################################################################################################


        $Local:MainObject.Begin()
    } 
    
    process {
        $Local:MainObject.Process()
    }

    end {
        $Local:MainObject.End()
    }
}

### END OF SCRIPT
####################################################################################################
