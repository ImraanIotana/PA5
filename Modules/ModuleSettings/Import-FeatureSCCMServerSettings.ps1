####################################################################################################
<#
.SYNOPSIS
    This function imports the feature SCCM Server Settings.
.DESCRIPTION
    This function is part of the Packaging Assistant. It contains references to functions and variables that are in other files.
.EXAMPLE
    Import-FeatureSCCMServerSettings -ParentTabPage $MyParentTabPage
.INPUTS
    [System.Windows.Forms.TabPage]
.OUTPUTS
    This function returns no stream-output.
.NOTES
    Version         : 5.7.0
    Author          : Imraan Iotana
    Creation Date   : October 2023
    Last Update     : January 2026
#>
####################################################################################################

function Import-FeatureSCCMServerSettings {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory=$false,HelpMessage='The ApplicationObject containing the Settings.')]
        [PSCustomObject]$ApplicationObject = $Global:ApplicationObject,

        [Parameter(Mandatory=$true,HelpMessage='The Parent TabPage to which this Feature will be added.')]
        [System.Windows.Forms.TabPage]$ParentTabPage
    )

    begin {
        ####################################################################################################
        ### MAIN PROPERTIES ###

        # GroupBox properties
        [PSCustomObject]$GroupBox = @{
            Title           = [System.String]'SCCM Settings'
            Color           = [System.String]'LightCyan'
            NumberOfRows    = [System.Int32]6
        }

        # Handlers
        [System.Collections.Hashtable]$SCCMDefaultValues = @{
            DefaultSiteCode             = $ApplicationObject.Settings.SCCMDefaultSiteCode
            DefaultProviderMachineName  = $ApplicationObject.Settings.SCCMDefaultProviderMachineName
            DefaultSCCMRepository       = $ApplicationObject.Settings.SCCMRepository
        }

        ####################################################################################################
        ### BUTTON PROPERTIES ###

        # Add the ASSSSiteCodeTextBox buttons
        [System.Collections.Hashtable[]]$ASSSSiteCodeTextBoxButtons = @(
            @{
                ColumnNumber    = 1
                Text            = 'Copy'
                Function        = { & $Global:ASSSSiteCodeTextBox.Tag.CopyToClipBoard }
            }
            @{
                ColumnNumber    = 2
                Text            = 'Paste'
                Function        = { & $Global:ASSSSiteCodeTextBox.Tag.PasteFromClipBoard }
            }
            @{
                ColumnNumber    = 3
                Text            = 'Clear'
                Function        = { & $Global:ASSSSiteCodeTextBox.Tag.ClearBox }
            }
            @{
                ColumnNumber    = 5
                Text            = 'Default'
                Function        = { & $Global:ASSSSiteCodeTextBox.Tag.ResetToDefaultValue }
            }
        )


        # Add the ASSSProviderMachineNameTextBox buttons
        [System.Collections.Hashtable[]]$ASSSProviderMachineNameTextBoxButtons = @(
            @{
                ColumnNumber    = 1
                Text            = 'Copy'
                Function        = { & $Global:ASSSProviderMachineNameTextBox.Tag.CopyToClipBoard }
            }
            @{
                ColumnNumber    = 2
                Text            = 'Paste'
                Function        = { & $Global:ASSSProviderMachineNameTextBox.Tag.PasteFromClipBoard }
            }
            @{
                ColumnNumber    = 3
                Text            = 'Clear'
                Function        = { & $Global:ASSSProviderMachineNameTextBox.Tag.ClearBox }
            }
            @{
                ColumnNumber    = 5
                Text            = 'Default'
                Function        = { & $Global:ASSSProviderMachineNameTextBox.Tag.ResetToDefaultValue }
            }
        )

        # Add the ASSSSCCMRepositoryTextBox buttons
        [System.Collections.Hashtable[]]$ASSSSCCMRepositoryTextBoxButtons = @(
            @{
                ColumnNumber    = 1
                Text            = 'Copy'
                Function        = { & $Global:ASSSSCCMRepositoryTextBox.Tag.CopyToClipBoard }
            }
            @{
                ColumnNumber    = 2
                Text            = 'Paste'
                Function        = { & $Global:ASSSSCCMRepositoryTextBox.Tag.PasteFromClipBoard }
            }
            @{
                ColumnNumber    = 3
                Text            = 'Clear'
                Function        = { & $Global:ASSSSCCMRepositoryTextBox.Tag.ClearBox }
            }
            @{
                ColumnNumber    = 5
                Text            = 'Default'
                Function        = { & $Global:ASSSSCCMRepositoryTextBox.Tag.ResetToDefaultValue }
            }
        )
    }
    
    process {
        # Create the GroupBox (This groupbox must be global to relate to the second groupbox)
        [System.Windows.Forms.GroupBox]$ParentGroupBox = $Global:SCCMSettingsGroupBox = Invoke-Groupbox -ParentTabPage $ParentTabPage -Title $GroupBox.Title -NumberOfRows $GroupBox.NumberOfRows -Color $GroupBox.Color -OnSubTab

        # Create the ASSSSiteCodeTextBox
        [System.Windows.Forms.TextBox]$Global:ASSSSiteCodeTextBox = Invoke-TextBox -ParentGroupBox $ParentGroupBox -RowNumber 1 -SizeType Large -Type Input -Label 'SCCM SiteCode:' -PropertyName 'ASSSSiteCodeTextBox' -DefaultValue $SCCMDefaultValues.DefaultSiteCode
        # Create the Buttons
        Invoke-ButtonLine -ButtonPropertiesArray $ASSSSiteCodeTextBoxButtons -ParentGroupBox $ParentGroupBox -RowNumber 2
        
        # Create the ASSSProviderMachineNameTextBox
        [System.Windows.Forms.TextBox]$Global:ASSSProviderMachineNameTextBox = Invoke-TextBox -ParentGroupBox $ParentGroupBox -RowNumber 3 -SizeType Large -Type Input -Label 'Provider Machine Name:' -PropertyName 'ASSSProviderMachineNameTextBox' -DefaultValue $SCCMDefaultValues.DefaultProviderMachineName
        # Create the Buttons
        Invoke-ButtonLine -ButtonPropertiesArray $ASSSProviderMachineNameTextBoxButtons -ParentGroupBox $ParentGroupBox -RowNumber 4

        # Create the ASSSSCCMRepositoryTextBox
        [System.Windows.Forms.TextBox]$Global:ASSSSCCMRepositoryTextBox = Invoke-TextBox -ParentGroupBox $ParentGroupBox -RowNumber 5 -SizeType Large -Type Input -Label 'SCCM Repository:' -PropertyName 'ASSSSCCMRepositoryTextBox' -DefaultValue $SCCMDefaultValues.DefaultSCCMRepository
        # Create the Buttons
        Invoke-ButtonLine -ButtonPropertiesArray $ASSSSCCMRepositoryTextBoxButtons -ParentGroupBox $ParentGroupBox -RowNumber 6
    }

    end {
    }
}

### END OF SCRIPT
####################################################################################################
