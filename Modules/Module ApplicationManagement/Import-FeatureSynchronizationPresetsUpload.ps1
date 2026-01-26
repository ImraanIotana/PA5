####################################################################################################
<#
.SYNOPSIS
    This function imports the feature Settings.
.DESCRIPTION
    This function is part of the Packaging Assistant. It contains references to classes, functions or variables, that are in other files.
    External classes    : -
    External functions  : Invoke-Groupbox, Invoke-TextBox, Invoke-Label, Invoke-ButtonLine, Invoke-RegistrySettings, Select-Item, Invoke-ClipBoard, Get-UserConfirmation
    External variables  : $Global:SettingsTabPage, $Global:GeneralSettingsGroupBox, $Global:OutputFolderTextBox, $Global:DSLFolderTextBox
.EXAMPLE
    Import-FeatureTEMP
.INPUTS
    [System.Windows.Forms.TabPage]
.OUTPUTS
    This function returns no stream output.
.NOTES
    Version         : 5.0
    Author          : Imraan Iotana
    Creation Date   : October 2023
    Last Update     : February 2025
#>
####################################################################################################

function Import-FeatureSynchronizationPresetsUpload {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory=$true,HelpMessage='The Parent object to which this feature will be added.')]
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
            GroupboxTitle           = [System.String]'Upload Presets'
            GroupboxColor           = [System.String]'Orange'
            GroupboxNumberOfRows    = [System.Int32]2
            GroupBoxAbove           = $Global:SPDownloadGroupBox
        }

        ####################################################################################################
        ### MAIN FUNCTION METHODS ###
        
        # Add the Begin method
        $Local:MainObject | Add-Member -MemberType ScriptMethod -Name Begin -Value { Write-Message -FunctionBegin -Details $this.FunctionDetails }
    
        # Add the End method
        $Local:MainObject | Add-Member -MemberType ScriptMethod -Name End -Value { Write-Message -FunctionEnd -Details $this.FunctionDetails }

        # Add the Process method
        $Local:MainObject | Add-Member -MemberType ScriptMethod -Name Process -Value {
            # Create the GroupBox
            [System.Windows.Forms.GroupBox]$Global:SPFolderGroupBox = $ParentGroupBox = Invoke-Groupbox -ParentTabPage $this.ParentTabPage -Title $this.GroupboxTitle -NumberOfRows $this.GroupboxNumberOfRows -Color $this.GroupboxColor -GroupBoxAbove $this.GroupBoxAbove
            # Create the Buttons
            Invoke-ButtonLine -ButtonPropertiesArray $this.PresetButtons -ParentGroupBox $ParentGroupBox -RowNumber 1
        }

        ####################################################################################################

        # Add the PresetButtons method
        $Local:MainObject | Add-Member -NotePropertyName PresetButtons -NotePropertyValue (
            # Return the button properties
            @(
                @{
                    ColumnNumber    = 1
                    Text            = 'UPLOAD APPLOCKER files to the DSL'
                    Image           = 'lock_go.png'
                    SizeType        = 'Large'
                    ToolTip         = 'Upload your local Applocker Policy File to the DSL'
                    Function        = { Sync-DSLFolder -FromLocalToDSL -ApplicationID $Global:DSApplicationIDComboBox.Text -AppLocker }
                }
                @{ #catch error when AppID is empty
                    ColumnNumber    = 2
                    Text            = 'UPLOAD OMNISSA DEM SHORTCUTS to the DSL'
                    Image           = 'table_go.png'
                    SizeType        = 'Large'
                    ToolTip         = 'Upload your local Omnissa DEM File to the DSL'
                    Function        = { Sync-ApplicationSubfolder -FromLocalToDSL -ApplicationID $Global:DSApplicationIDComboBox.Text -Subfolder ShortcutsFolder }
                }
                @{
                    ColumnNumber    = 3
                    Text            = 'UPLOAD new SCREENSHOTS to the DSL'
                    Image           = 'picture_go.png'
                    SizeType        = 'Large'
                    ToolTip         = 'Upload your local screenshots to the DSL'
                    Function        = { Move-ScreenShotsToDSL -ApplicationID $Global:DSApplicationIDComboBox.Text }
                }
                @{
                    ColumnNumber    = 5
                    Text            = 'MERGE METADATA with the DSL'
                    Image           = 'arrow_merge.png'
                    SizeType        = 'Large'
                    ToolTip         = 'Merge the properties of the LOCAL METADATA FILE with the one on the DSL'
                    Function        = { Sync-Metadata -ApplicationID $Global:DSApplicationIDComboBox.Text }
                }
            )
        )

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
