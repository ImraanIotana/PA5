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
                Function        = { Invoke-ClipBoard -CopyFromBox $Global:ASSSProviderMachineNameTextBox }
            }
            @{
                ColumnNumber    = 2
                Text            = 'Paste'
                Function        = { Invoke-ClipBoard -PasteToBox $Global:ASSSProviderMachineNameTextBox }
            }
            @{
                ColumnNumber    = 3
                Text            = 'Clear'
                Function        = { Invoke-ClipBoard -ClearBox $Global:ASSSProviderMachineNameTextBox }
            }
            @{
                ColumnNumber    = 5
                Text            = 'Default'
                Function        = { $Global:ASSSProviderMachineNameTextBox.ResetToDefaultValue() }
            }
        )





        # Set the main object
        [PSCustomObject]$Local:MainObject = @{
            # Input
            ParentTabPage               = $ParentTabPage
            # Handlers
            GroupBoxTitle               = [System.String]'SCCM Settings'
            Color                       = [System.String]'LightCyan'
            NumberOfRows                = [System.Int32]6
            AssetFolder                 = [System.String]$PSScriptRoot
            #PDFManualFileName          = [System.String]'HelpFile Settings.pdf'
            # Handlers
            DefaultSiteCode             = $Global:ApplicationObject.Settings.SCCMDefaultSiteCode
            DefaultProviderMachineName  = $Global:ApplicationObject.Settings.SCCMDefaultProviderMachineName
            DefaultSCCMRepository       = $Global:ApplicationObject.Settings.SCCMRepository
        }

        ####################################################################################################
        ### MAIN FUNCTION METHODS ###

        # Add the Process method
        Add-Member -InputObject $Local:MainObject -MemberType ScriptMethod -Name Process -Value {
            # Create the ASSSProviderMachineNameTextBox
            [System.Windows.Forms.TextBox]$Global:ASSSProviderMachineNameTextBox = Invoke-TextBox -ParentGroupBox $ParentGroupBox -RowNumber 3 -SizeType Large -Type Input -Label 'Provider Machine Name:' -PropertyName 'ASSSProviderMachineNameTextBox'
            # Add the functions/properties
            $Global:ASSSProviderMachineNameTextBox | Add-Member -NotePropertyName DefaultValue -NotePropertyValue $this.DefaultProviderMachineName
            $Global:ASSSProviderMachineNameTextBox | ForEach-Object { if (Test-Object -IsEmpty ($_.Text)) { $_.Text = $_.DefaultValue } }
            # Add the buttons
            $Global:ASSSProviderMachineNameTextBox | Add-Member -NotePropertyName ButtonPropertiesArray -NotePropertyValue @(
                @{
                    ColumnNumber    = 1
                    Text            = 'Copy'
                    Image           = 'page_copy.png'
                    SizeType        = 'Medium'
                    Function        = { Invoke-ClipBoard -CopyFromBox $Global:ASSSProviderMachineNameTextBox }
                }
                @{
                    ColumnNumber    = 2
                    Text            = 'Paste'
                    Image           = 'page_paste.png'
                    SizeType        = 'Medium'
                    Function        = { Invoke-ClipBoard -PasteToBox $Global:ASSSProviderMachineNameTextBox }
                }
                @{
                    ColumnNumber    = 3
                    Text            = 'Clear'
                    Image           = 'textfield_delete.png'
                    SizeType        = 'Medium'
                    Function        = { Invoke-ClipBoard -ClearBox $Global:ASSSProviderMachineNameTextBox }
                }
            )
            # Create the Buttons
            Invoke-ButtonLine -ButtonPropertiesArray $Global:ASSSProviderMachineNameTextBox.ButtonPropertiesArray -ParentGroupBox $ParentGroupBox -RowNumber 4 -AssetFolder $this.AssetFolder

            # Create the ASSSSCCMRepositoryTextBox
            [System.Windows.Forms.TextBox]$Global:ASSSSCCMRepositoryTextBox = Invoke-TextBox -ParentGroupBox $ParentGroupBox -RowNumber 5 -SizeType Large -Type Input -Label 'SCCM Repository:' -PropertyName 'ASSSSCCMRepositoryTextBox'
            # Add the functions/properties
            $Global:ASSSSCCMRepositoryTextBox | Add-Member -NotePropertyName DefaultValue -NotePropertyValue $this.DefaultSCCMRepository
            $Global:ASSSSCCMRepositoryTextBox | ForEach-Object { if (Test-Object -IsEmpty ($_.Text)) { $_.Text = $_.DefaultValue } }
            # Add the buttons
            $Global:ASSSSCCMRepositoryTextBox | Add-Member -NotePropertyName ButtonPropertiesArray -NotePropertyValue @(
                @{
                    ColumnNumber    = 1
                    Text            = 'Copy'
                    Image           = 'page_copy.png'
                    SizeType        = 'Medium'
                    Function        = { Invoke-ClipBoard -CopyFromBox $Global:ASSSSCCMRepositoryTextBox }
                }
                @{
                    ColumnNumber    = 2
                    Text            = 'Paste'
                    Image           = 'page_paste.png'
                    SizeType        = 'Medium'
                    Function        = { Invoke-ClipBoard -PasteToBox $Global:ASSSSCCMRepositoryTextBox }
                }
                @{
                    ColumnNumber    = 3
                    Text            = 'Clear'
                    Image           = 'textfield_delete.png'
                    SizeType        = 'Medium'
                    Function        = { Invoke-ClipBoard -ClearBox $Global:ASSSSCCMRepositoryTextBox }
                }
            )
            # Create the Buttons
            Invoke-ButtonLine -ButtonPropertiesArray $Global:ASSSSCCMRepositoryTextBox.ButtonPropertiesArray -ParentGroupBox $ParentGroupBox -RowNumber 6 -AssetFolder $this.AssetFolder
        }
    } 
    
    process {
        # Create the GroupBox (This groupbox must be global to relate to the second groupbox)
        [System.Windows.Forms.GroupBox]$ParentGroupBox = $Global:SCCMSettingsGroupBox = Invoke-Groupbox -ParentTabPage $ParentTabPage -Title $GroupBox.Title -NumberOfRows $GroupBox.NumberOfRows -Color $GroupBox.Color -OnSubTab
        # Create the ASSSSiteCodeTextBox
        [System.Windows.Forms.TextBox]$Global:ASSSSiteCodeTextBox = Invoke-TextBox -ParentGroupBox $ParentGroupBox -RowNumber 1 -SizeType Large -Type Input -Label 'SCCM SiteCode:' -PropertyName 'ASSSSiteCodeTextBox' -DefaultValue $SCCMDefaultValues.DefaultSiteCode
        # Create the Buttons
        Invoke-ButtonLine -ButtonPropertiesArray $ASSSSiteCodeTextBoxButtons -ParentGroupBox $ParentGroupBox -RowNumber 2
        
        
        $Local:MainObject.Process()
    }

    end {
    }
}

### END OF SCRIPT
####################################################################################################
