####################################################################################################
<#
.SYNOPSIS
    This function imports the Feature Personal Settings.
.DESCRIPTION
    This function is part of the Packaging Assistant. It contains references to functions and variables that are in other files.
.EXAMPLE
    Import-FeaturePersonalSettings -ParentTabPage $MyParentTabPage
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

function Import-FeaturePersonalSettingsOLD {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory=$true,HelpMessage='The Parent TabPage to which this Feature will be added.')]
        [System.Windows.Forms.TabPage]$ParentTabPage
    )

    begin {
        ####################################################################################################
        ### MAIN PROPERTIES ###

        # GroupBox properties
        [PSCustomObject]$GroupBox = @{
            Title           = [System.String]'Personal Settings'
            Color           = [System.String]'Brown'
            NumberOfRows    = [System.Int32]4
            GroupBoxAbove   = [System.Windows.Forms.GroupBox]$Global:FolderSettingsGroupBox
        }
        
        # Set the Button Properties Array
        [System.Object[][]]$ButtonPropertiesArray = @( (1,'Copy') , (2,'Paste') , (5,'Clear') )

        ####################################################################################################
    } 
    
    process {
        try {
            # Create the GroupBox (This groupbox must be global to relate to groupboxes in other features)
            [System.Windows.Forms.GroupBox]$Global:PersonalSettingsGroupBox = $ParentGroupBox = Invoke-Groupbox -ParentTabPage $ParentTabPage -Title $GroupBox.Title -NumberOfRows $GroupBox.NumberOfRows -Color $GroupBox.Color -GroupBoxAbove $GroupBox.GroupBoxAbove -OnSubTab

            # Create the ASPSUserFullNameTextBox
            [System.Windows.Forms.TextBox]$Global:ASPSUserFullNameTextBox = Invoke-TextBox -ParentGroupBox $ParentGroupBox -RowNumber 1 -SizeType Large -Type Input -Label 'My Full Name:' -PropertyName 'ASPSUserFullNameTextBox' -ButtonPropertiesArray $ButtonPropertiesArray

            # Create the ASPSUserEmailTextBox
            [System.Windows.Forms.TextBox]$Global:ASPSUserEmailTextBox = Invoke-TextBox -ParentGroupBox $ParentGroupBox -RowNumber 3 -SizeType Large -Type Input -Label 'My Email Address:' -PropertyName 'ASPSUserEmailTextBox' -ButtonPropertiesArray $ButtonPropertiesArray
        }
        catch {
            Write-FullError
        }
    }

    end {
    }
}

### END OF SCRIPT
####################################################################################################
