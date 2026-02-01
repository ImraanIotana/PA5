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

function Import-FeatureSCCMServerSettingsOLD {
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

        # Default Values for the SCCM Settings
        [System.String]$DefaultSiteCode             = $ApplicationObject.Settings.SCCMDefaultSiteCode
        [System.String]$DefaultProviderMachineName  = $ApplicationObject.Settings.SCCMDefaultProviderMachineName
        [System.String]$DefaultSCCMRepository       = $ApplicationObject.Settings.SCCMRepository
        
        # Set the Default Button Properties Array
        [System.Object[][]]$SCCMServerSettingsButtonsArray = @( @(@(1,'Copy'),(2,'Paste'),(3,'Clear'),(5,'Default')) )

        ####################################################################################################
    }
    
    process {
        # Create the GroupBox (This groupbox must be global to relate to the second groupbox)
        [System.Windows.Forms.GroupBox]$ParentGroupBox = $Global:SCCMSettingsGroupBox = Invoke-Groupbox -ParentTabPage $ParentTabPage -Title $GroupBox.Title -NumberOfRows $GroupBox.NumberOfRows -Color $GroupBox.Color -OnSubTab

        # Create the ASSSSiteCodeTextBox
        [System.Windows.Forms.TextBox]$Global:ASSSSiteCodeTextBox = Invoke-TextBox -ParentGroupBox $ParentGroupBox -RowNumber 1 -SizeType Large -Type Input -Label 'SCCM SiteCode:' -PropertyName 'ASSSSiteCodeTextBox' -DefaultValue $DefaultSiteCode -ButtonPropertiesArray $SCCMServerSettingsButtonsArray
        
        # Create the ASSSProviderMachineNameTextBox
        [System.Windows.Forms.TextBox]$Global:ASSSProviderMachineNameTextBox = Invoke-TextBox -ParentGroupBox $ParentGroupBox -RowNumber 3 -SizeType Large -Type Input -Label 'Provider Machine Name:' -PropertyName 'ASSSProviderMachineNameTextBox' -DefaultValue $DefaultProviderMachineName -ButtonPropertiesArray $SCCMServerSettingsButtonsArray

        # Create the ASSSSCCMRepositoryTextBox
        [System.Windows.Forms.TextBox]$Global:ASSSSCCMRepositoryTextBox = Invoke-TextBox -ParentGroupBox $ParentGroupBox -RowNumber 5 -SizeType Large -Type Input -Label 'SCCM Repository:' -PropertyName 'ASSSSCCMRepositoryTextBox' -DefaultValue $DefaultSCCMRepository -ButtonPropertiesArray $SCCMServerSettingsButtonsArray
    }

    end {
    }
}

### END OF SCRIPT
####################################################################################################
