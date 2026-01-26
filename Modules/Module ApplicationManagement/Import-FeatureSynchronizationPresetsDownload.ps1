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

function Import-FeatureSynchronizationPresetsDownload {
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
            GroupboxTitle           = [System.String]'WorkCopy Presets'
            GroupboxColor           = [System.String]'LightCyan'
            GroupboxNumberOfRows    = [System.Int32]2
            GroupBoxAbove           = $Global:DSLSynchronizationGroupBox
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
            [System.Windows.Forms.GroupBox]$Global:SPDownloadGroupBox = $ParentGroupBox = Invoke-Groupbox -ParentTabPage $this.ParentTabPage -Title $this.GroupboxTitle -NumberOfRows $this.GroupboxNumberOfRows -Color $this.GroupboxColor -GroupBoxAbove $this.GroupBoxAbove
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
                    Text            = 'DOWNLOAD SCCM Package'
                    Image           = 'inbox_download.png'
                    SizeType        = 'Large'
                    ToolTip         = 'Download the SCCM Package to your local output folder'
                    Function        = { Copy-PackageToOutputFolder -ApplicationID $Global:DSApplicationIDComboBox.Text -SCCMPackage -OpenPowerShell }
                }
                @{
                    ColumnNumber    = 2
                    Text            = 'MAKE WORKCOPY of SCCM Package'
                    Image           = 'arrow_divide.png'
                    SizeType        = 'Large'
                    ToolTip         = 'Copy the Package from the SCCM folder to WORK folder'
                    Function        = { Copy-PackageToWorkFolder -ApplicationID $Global:DSApplicationIDComboBox.Text -Confirm }
                }
                @{
                    ColumnNumber    = 3
                    Text            = 'MOVE WORKCOPY to SCCM folder'
                    Image           = 'arrow_join.png'
                    SizeType        = 'Large'
                    ToolTip         = 'Move the Package from the WORK folder to SCCM folder'
                    Function        = { Move-PackageFromWorkToSCCMFolder -ApplicationID $Global:DSApplicationIDComboBox.Text }
                }
                @{
                    ColumnNumber    = 4
                    Text            = 'UPDATE SCRIPT of the WORKCOPY'
                    Image           = 'page_refresh.png'
                    SizeType        = 'Large'
                    ToolTip         = 'Copy the Package from the SCCM folder to WORK folder'
                    Function        = { Update-ScriptInWorkFolder -ApplicationID $Global:DSApplicationIDComboBox.Text -Confirm -Force }
                }
                @{
                    ColumnNumber    = 5
                    Text            = 'DOWNLOAD WORKCOPY'
                    Image           = 'inbox_download.png'
                    SizeType        = 'Large'
                    ToolTip         = 'Download the WorkCopy to your local output folder'
                    Function        = { Copy-PackageToOutputFolder -ApplicationID $Global:DSApplicationIDComboBox.Text -WorkCopy -OpenPowerShell }
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
