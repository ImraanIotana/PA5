####################################################################################################
<#
.SYNOPSIS
    This function creates a new TabPage.
.DESCRIPTION
    This function is part of the Packaging Assistant. It contains references to functions and variables that are in other files.
.EXAMPLE
    New-TabPage -ParentTabControl $Global:TabControl -Title 'Administration' -BackGroundColor 'Green'
.INPUTS
    [System.Windows.Forms.TabControl]
    [System.String]
.OUTPUTS
    [System.Windows.Forms.TabPage]
.NOTES
    Version         : 5.7.0
    Author          : Imraan Iotana
    Creation Date   : May 2023
    Last Update     : January 2026
#>
####################################################################################################

function New-TabPageNEW {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory=$true,HelpMessage='The TabControl to which this TabPage will be added.')]
        [System.Windows.Forms.TabControl]$ParentTabControl,

        [Parameter(Mandatory=$false,HelpMessage='The title of the TabPage.')]
        [System.String]$Title = 'Default Tab Title',

        [Parameter(Mandatory=$false,HelpMessage='The color of the TabPage.')]
        [System.String]$BackGroundColor
    )

    begin {
        ####################################################################################################
        ### MAIN PROPERTIES ###

        # Output
        [System.Windows.Forms.TabPage]$OutputObject = New-Object System.Windows.Forms.TabPage

        ####################################################################################################
    } 
    
    process {
        # Set the Title
        $OutputObject.Text = $Title
        # Set the BackGroundColor if provided
        if ($BackGroundColor) { $OutputObject.BackColor = $BackGroundColor }
        # Add the TabPage the Parent TabControl
        $ParentTabControl.Controls.Add($OutputObject)
    }

    end {
        # Return the output
        $OutputObject
    }
}

### END OF SCRIPT
####################################################################################################

