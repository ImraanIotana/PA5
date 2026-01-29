####################################################################################################
<#
.SYNOPSIS
    This function imports the SubModule 'AppLocker Settings'.
.DESCRIPTION
    This function is part of the Packaging Assistant. It contains references to functions and variables that are in other files.
.EXAMPLE
    Import-SubModuleAppLockerSettings
.INPUTS
    [System.Windows.Forms.TabControl]
.OUTPUTS
    This function returns no stream output.
.NOTES
    Version         : 5.7.0
    Author          : Imraan Iotana
    Creation Date   : August 2025
    Last Update     : January 2026
#>
####################################################################################################

function Import-SubModuleAppLockerSettingsOLD {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory=$false,HelpMessage='The Parent TabControl to which this new TabPage will be added.')]
        [System.Windows.Forms.TabControl]$ParentTabControl
    )

    begin {
        ####################################################################################################
        ### MAIN PROPERTIES ###

        # Handlers
        [System.String]$TabTitle        = 'AppLocker Settings'
        [System.String]$ModuleVersion   = '5.7.0'
        [System.String]$BackGroundColor = 'RoyalBlue'

        ####################################################################################################
    }
    
    process {
        try {
            # Write the message
            Write-Line "Importing SubModule $TabTitle $ModuleVersion"
            # Create the SubModule TabPage
            [System.Windows.Forms.TabPage]$Global:SubModuleAppLockerSettingsTabPage = $ParentTabPage = New-TabPage -Parent $ParentTabControl -Title $TabTitle -BackGroundColor $BackGroundColor
            # Import the Features
            Import-FeatureAppLockerSettings -ParentTabPage $ParentTabPage
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