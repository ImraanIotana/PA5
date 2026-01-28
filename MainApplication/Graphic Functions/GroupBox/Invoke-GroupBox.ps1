####################################################################################################
<#
.SYNOPSIS
    This function creates a new GroupBox.
.DESCRIPTION
    This function is part of the Packaging Assistant. It contains references to functions and variables that are in other files.
.EXAMPLE
    Invoke-Groupbox -ParentTabPage $MyTabPage -Title 'Application Input' -NumberOfRows 6 -Color 'Black'
.EXAMPLE
    Invoke-Groupbox -ParentTabPage $MyTabPage -Title 'MECM Input' -NumberOfRows 8 -Color 'Green' -GroupBoxAbove $Groupbox
.INPUTS
    [PSCustomObject]
    [System.Windows.Forms.TabPage]
    [System.String]
    [System.Int32]
    [System.Windows.Forms.GroupBox]
    [System.Management.Automation.SwitchParameter]
.OUTPUTS
    [System.Windows.Forms.GroupBox]
.NOTES
    Version         : 5.7.0
    Author          : Imraan Iotana
    Creation Date   : October 2023
    Last Update     : January 2026
#>
####################################################################################################

function Invoke-GroupBox {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory=$false,HelpMessage='The ApplicationObject containing the Settings.')]
        [PSCustomObject]$ApplicationObject = $Global:ApplicationObject,

        [Parameter(Mandatory=$true,HelpMessage='The Parent TabPage to which this groupbox will be added.')]
        [System.Windows.Forms.TabPage]$ParentTabPage,

        [Parameter(Mandatory=$true,HelpMessage='The title of the Groupbox.')]
        [System.String]$Title,

        [Parameter(Mandatory=$false,HelpMessage='The height of the groupbox expressed in rownumbers.')]
        [System.Int32]$NumberOfRows = 1,

        [Parameter(Mandatory=$false,HelpMessage='The color of the text and border.')]
        [System.String]$Color = 'Black',

        [Parameter(Mandatory=$false,HelpMessage='The groupbox underneath which this new Groupbox will be placed.')]
        [System.Windows.Forms.GroupBox]$GroupBoxAbove,

        [Parameter(Mandatory=$false,HelpMessage='Switch for when the GroupBox is on a SubTab.')]
        [System.Management.Automation.SwitchParameter]$OnSubTab
    )

    begin {
        ####################################################################################################
        ### MAIN PROPERTIES ###

        # Input
        [System.Collections.Hashtable]$Settings = $ApplicationObject.Settings

        # Create the GroupBox
        [System.Windows.Forms.GroupBox]$NewGroupBox = New-Object System.Windows.Forms.GroupBox

        ####################################################################################################
    }
    
    process {
        # LOCATION
        # Set the Location of the GroupBox
        [System.Int32]$GroupboxTopLeftX = $Settings.MainTabControl.TopLeftX
        [System.Int32]$GroupboxTopLeftY = if ($GroupBoxAbove) { $GroupBoxAbove.Location.Y + $GroupBoxAbove.Height + $Settings.GroupBox.BetweenMargin } else { $Settings.MainTabControl.TopLeftY }
        [System.Int32[]]$Location = @($GroupboxTopLeftX, $GroupboxTopLeftY)

        # SIZE
        # Set the Size of the GroupBox
        [System.Int32]$Width = if ($OnSubTab.IsPresent) { $Settings.GroupBox.SubTabGroupboxWidth } else { $Settings.GroupBox.Width }
        [System.Int32]$Height = $Settings.GroupBox.HeightTable.($NumberOfRows)
        [System.Int32[]]$Size = @($Width, $Height)

        # ADD PROPERTIES



        # CREATION
        # Create the GroupBox
        $NewGroupBox = New-GroupBox -ParentTabPage $ParentTabPage -Location $Location -Size $Size -Title $Title -Color $Color
    }

    end {
        # Return the output
        $NewGroupBox
    }
}

### END OF SCRIPT
####################################################################################################
