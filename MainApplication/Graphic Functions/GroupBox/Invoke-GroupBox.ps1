####################################################################################################
<#
.SYNOPSIS
    This function invokes the creation of a new GroupBox, based on the Settings in the ApplicationObject and the ParentTabPage.
.DESCRIPTION
    This function is part of the Packaging Assistant. It contains references to functions and variables that are in other files.
.EXAMPLE
    Invoke-Groupbox -ParentTabPage $MyTabPage -Title 'Application Input' -NumberOfRows 6 -Color 'Black'
.EXAMPLE
    Invoke-Groupbox -ParentTabPage $MyTabPage -Title 'MECM Input' -NumberOfRows 8 -Color 'Green' -GroupBoxAbove $Groupbox
.INPUTS
    [PSCustomObject]
    [System.Windows.Forms.TabPage]
    [System.Windows.Forms.GroupBox]
    [System.String]
    [System.Int32]
.OUTPUTS
    [System.Windows.Forms.GroupBox]
.NOTES
    Version         : 5.0
    Author          : Imraan Iotana
    Creation Date   : October 2023
    Last Update     : February 2025
#>
####################################################################################################

function Invoke-GroupBox {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory=$false,HelpMessage='The ApplicationObject containing the Settings.')]
        [PSCustomObject]
        $ApplicationObject = $Global:ApplicationObject,

        [Parameter(Mandatory=$true,HelpMessage='The Parent TabPage to which this groupbox will be added.')]
        [System.Windows.Forms.TabPage]
        $ParentTabPage,

        [Parameter(Mandatory=$true,HelpMessage='The title of the Groupbox.')]
        [System.String]
        $Title,

        [Parameter(Mandatory=$false,HelpMessage='The height of the groupbox expressed in rownumbers.')]
        [System.Int32]
        $NumberOfRows = 1,

        [Parameter(Mandatory=$false,HelpMessage='The color of the text and border.')]
        [System.String]
        $Color = 'Black',

        [Parameter(Mandatory=$false,HelpMessage='The groupbox underneath which this new Groupbox will be placed.')]
        [System.Windows.Forms.GroupBox]
        $GroupBoxAbove,

        [Parameter(Mandatory=$false,HelpMessage='Switch for when the GroupBox is on a SubTab.')]
        [System.Management.Automation.SwitchParameter]
        $OnSubTab
    )

    begin {
        ####################################################################################################
        ### MAIN PROPERTIES ###

        # Input
        [System.Collections.Hashtable]$Settings = $ApplicationObject.Settings

        # Create the GroupBox
        [System.Windows.Forms.GroupBox]$NewGroupBox = New-Object System.Windows.Forms.GroupBox

        ####################################################################################################

        ####################################################################################################
        ### MAIN OBJECT ###

        # Set the main object
        [PSCustomObject]$Local:MainObject = @{
            # Input
            Settings        = $ApplicationObject.Settings
            ParentTabPage   = $ParentTabPage
            Title           = $Title
            Color           = $Color
            NumberOfRows    = $NumberOfRows
            GroupBoxAbove   = $GroupBoxAbove
            OnSubTab        = $OnSubTab
            # Output
            OutputObject    = New-Object System.Windows.Forms.GroupBox
        }

        ####################################################################################################
        ### MAIN FUNCTION METHODS ###

        # Add the Process method
        Add-Member -InputObject $Local:MainObject -MemberType ScriptMethod -Name Process -Value {
            # Add the Location to the main object
            $this.AddGroupBoxLocationToMainObject($this.Settings,$this.GroupBoxAbove)
            # Add the Size to the main object
            $this.AddGroupBoxSizeToMainObject($this.Settings,$this.NumberOfRows)
            # Create the GroupBox
            $this.CreateGroupbox($this.ParentTabPage,$this.Location,$this.Size,$this.Title,$this.Color)
        }

        ####################################################################################################
        ### CALCULATION METHODS

        # Add the AddGroupBoxLocationToMainObject method
        Add-Member -InputObject $Local:MainObject -MemberType ScriptMethod -Name AddGroupBoxLocationToMainObject -Value { param([System.Collections.Hashtable]$Settings,[System.Windows.Forms.GroupBox]$GroupBoxAbove)
            # Set the TopLeftX of the GroupBox
            [System.Int32]$GroupboxTopLeftX = $Settings.MainTabControl.TopLeftX
            # Set the TopLeftY of the GroupBox
            [System.Int32]$GroupboxTopLeftY = if ($GroupBoxAbove) { $GroupBoxAbove.Location.Y + $GroupBoxAbove.Height + $Settings.GroupBox.BetweenMargin } else { $Settings.MainTabControl.TopLeftY }
            # Add the result to the main object
            Add-Member -InputObject $this -NotePropertyName Location -NotePropertyValue @($GroupboxTopLeftX, $GroupboxTopLeftY)
        }
    
        # Add the AddGroupBoxSizeToMainObject method
        Add-Member -InputObject $Local:MainObject -MemberType ScriptMethod -Name AddGroupBoxSizeToMainObject -Value { param([System.Collections.Hashtable]$Settings,[System.Int32]$NumberOfRows)
            # Get the Width and Height of the GroupBox from the Global Settings
            [System.Int32]$Width    = if ($this.OnSubTab.IsPresent) { $Settings.GroupBox.SubTabGroupboxWidth } else { $Settings.GroupBox.Width }
            [System.Int32]$Height   = $Settings.GroupBox.HeightTable.($NumberOfRows)
            # Add the result to the main object
            Add-Member -InputObject $this -NotePropertyName Size -NotePropertyValue  @($Width, $Height)
        }

        ####################################################################################################
        ### CREATE METHODS
    
        # Add the CreateGroupbox method
        Add-Member -InputObject $Local:MainObject -MemberType ScriptMethod -Name CreateGroupbox -Value { param([System.Windows.Forms.TabPage]$ParentTabPage,[System.Int32[]]$Location,[System.Int32[]]$Size,[System.String]$Title,[System.String]$Color)
            # Create the GroupBox
            $this.OutputObject = New-GroupBox -ParentTabPage $ParentTabPage -Location $Location -Size $Size -Title $Title -Color $Color
        }

        ####################################################################################################

    }
    
    process {
        #$Local:MainObject.Process()
        
        # LOCATION
        # Set the Location of the GroupBox
        [System.Int32]$GroupboxTopLeftX = $Settings.MainTabControl.TopLeftX
        [System.Int32]$GroupboxTopLeftY = if ($GroupBoxAbove) { $GroupBoxAbove.Location.Y + $GroupBoxAbove.Height + $Settings.GroupBox.BetweenMargin } else { $Settings.MainTabControl.TopLeftY }
        [System.Int32[]]$Location = @($GroupboxTopLeftX, $GroupboxTopLeftY)

        # SIZE
        # Set the Size of the GroupBox
        [System.Int32]$Width = if ($OnSubTab.IsPresent) { $Settings.GroupBox.SubTabGroupboxWidth } else { $Settings.GroupBox.Width }
        [System.Int32]$Height = $Settings.GroupBox.HeightTable.($NumberOfRows)
        

    }

    end {
        # Return the output
        $Local:MainObject.OutputObject
    }
}

### END OF SCRIPT
####################################################################################################
