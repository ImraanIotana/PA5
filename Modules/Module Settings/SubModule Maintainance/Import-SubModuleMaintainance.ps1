####################################################################################################
<#
.SYNOPSIS
    This function imports the Module 'Maintainance'.
.DESCRIPTION
    This function is part of the Packaging Assistant. It contains references to functions and variables that are in other files.
.EXAMPLE
    Import-SubModuleMaintainance
.INPUTS
    [System.Windows.Forms.TabControl]
.OUTPUTS
    This function returns no stream output.
.NOTES
    Version         : 5.7.0
    Author          : Imraan Iotana
    Creation Date   : September 2025
    Last Update     : January 2026
#>
####################################################################################################

function Import-SubModuleMaintainance {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory=$false,HelpMessage='The Parent TabControl to which this new TabPage will be added.')]
        [System.Windows.Forms.TabControl]
        $ParentTabControl = $Global:MainTabControl
    )

    begin {
        ####################################################################################################
        ### MAIN PROPERTIES ###

        # Handlers
        [System.String]$TabTitle        = 'Maintainance'
        [System.String]$ModuleVersion   = '5.7.0'
        [System.String]$BackGroundColor = 'Cornsilk'

        ####################################################################################################
    }
    
    process {
        try {
            # Write the message
            Write-Line "Importing Module $TabTitle $ModuleVersion"
            # Create the Module TabPage
            [System.Windows.Forms.TabPage]$ParentTabPage = New-TabPage -Parent $ParentTabControl -Title $TabTitle -BackGroundColor $BackGroundColor
            # Import the Features
            Import-FeatureMaintainance -ParentTabPage $ParentTabPage
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