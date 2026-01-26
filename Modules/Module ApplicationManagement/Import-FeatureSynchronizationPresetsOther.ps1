####################################################################################################
<#
.SYNOPSIS
    This function imports the Feature Synchronization Presets Other.
.DESCRIPTION
    This function is part of the Packaging Assistant. It may contain functions or variables, that are in other files.
.EXAMPLE
    Import-FeatureSynchronizationPresetsOther
.INPUTS
    [System.Windows.Forms.TabPage]
.OUTPUTS
    This function returns no stream output.
.NOTES
    Version         : 5.0
    Author          : Imraan Iotana
    Creation Date   : October 2023
    Last Update     : October 2025
#>
####################################################################################################

function Import-FeatureSynchronizationPresetsOther {
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
        [PSCustomObject]$GroupBox   = @{
            Title                   = [System.String]'Other Presets'
            Color                   = [System.String]'LightGreen'
            NumberOfRows            = [System.Int32]3
            GroupBoxAbove           = $Global:SPFolderGroupBox
        }

        ####################################################################################################
        ### BUTTON PROPERTIES ###


        ####################################################################################################
        ### MAIN OBJECT ###

        # Set the main object
        [PSCustomObject]$Local:MainObject = @{
            # Function
            FunctionDetails         = [System.String[]]@($MyInvocation.MyCommand,$PSCmdlet.ParameterSetName,$PSBoundParameters.GetEnumerator())
            # Groupbox Handlers
            GroupboxColor           = [System.String]'LightGreen'
            GroupBoxAbove           = $Global:SPFolderGroupBox
        }

        ####################################################################################################
        ### MAIN FUNCTION METHODS ###
        
        # Add the Process method
        $Local:MainObject | Add-Member -MemberType ScriptMethod -Name Process -Value {
            # Create the GroupBox
            [System.Windows.Forms.GroupBox]$Global:MDSLMFSPOGroupBox = $ParentGroupBox = Invoke-Groupbox -ParentTabPage $ParentTabPage -Title $Groupbox.Title -NumberOfRows $Groupbox.NumberOfRows -Color $this.GroupboxColor -GroupBoxAbove $this.GroupBoxAbove
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
                    Text            = 'FULL DOWNLOAD of Application Folder'
                    Image           = 'arrow_down.png'
                    SizeType        = 'Large'
                    ToolTip         = 'Download the FULL Application folder from DSL to your local output folder'
                    Function        = { Sync-DSLFolder -FromDSLToLocal -ApplicationID $Global:DSApplicationIDComboBox.Text -Full }
                }
                @{
                    ColumnNumber    = 2
                    Text            = 'Open Package Document'
                    Image           = 'page_word.png'
                    SizeType        = 'Large'
                    ToolTip         = 'Open the Word Documentation of the selected Application'
                    Function        = { Show-ApplicationDocument -ApplicationID $Global:DSApplicationIDComboBox.Text }
                }
                @{
                    ColumnNumber    = 5
                    Text            = 'Event Viewer'
                    SizeType        = 'Large'
                    Image           = 'book.png'
                    Function        = { Invoke-Item -Path "$ENV:windir\System32\eventvwr.msc" }
                }
            )
        )

        ####################################################################################################
    } 
    
    process {
        # Create the GroupBox, and add the extra properties
        #[System.Windows.Forms.GroupBox]$Global:SPFolderGroupBox = $ParentGroupBox = Invoke-Groupbox -ParentTabPage $ParentTabPage -Title $Groupbox.Title -NumberOfRows $Groupbox.NumberOfRows -Color $Groupbox.Color -GroupBoxAbove $GroupBox.GroupBoxAbove
        #$Global:OmissaDEMUserRegistryGroupbox | Add-Member -NotePropertyName CorrespondingRepository -NotePropertyValue $CorrespondingRepository
        # Create the action buttons
        #Invoke-ButtonLine -ButtonPropertiesArray $ActionButtons -ParentGroupBox $ParentGroupBox -RowNumber 1
        $Local:MainObject.Process()
    }

    end {
    }
}

### END OF SCRIPT
####################################################################################################
