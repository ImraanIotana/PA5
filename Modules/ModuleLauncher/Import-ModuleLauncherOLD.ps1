####################################################################################################
<#
.SYNOPSIS
    This function imports the Module Launcher.
.DESCRIPTION
    This function is part of the Packaging Assistant. It contains references to classes, functions and variables, that may be in other files.
.EXAMPLE
    Import-ModuleLauncher
.INPUTS
    [System.Windows.Forms.TabControl]
.OUTPUTS
    This function returns no stream output.
.NOTES
    Version         : 5.3.3
    Author          : Imraan Iotana
    Creation Date   : October 2023
    Last Update     : May 2025
#>
####################################################################################################

function Import-ModuleLauncherOLD {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory=$false,HelpMessage='The Parent TabControl to which this new TabPage will be added.')]
        [Alias('TabControl')]
        [System.Windows.Forms.TabControl]
        $ParentTabControl = $Global:MainTabControl
    )

    begin {
        ####################################################################################################
        ### PROPERTIES ###

        # Set the Properties
        [System.String]$TabTitle        = 'Launcher'
        [System.String]$ModuleVersion   = '5.3.3'
        [System.String]$BackGroundColor = 'LightSalmon'

        ####################################################################################################
    }
    
    process {
        # Write the message
        $ParentTabControl.WriteImportMessageOLD($TabTitle,$ModuleVersion)
        # Create the Module TabPage
        [System.Windows.Forms.TabPage]$ParentTabPage = $Global:LauncherTabPage = New-TabPage -Parent $ParentTabControl -Title $TabTitle -BackGroundColor $BackGroundColor
        #[System.Windows.Forms.TabPage]$ParentTabPage = $Global:LauncherTabPage
        # Import the Features
        Import-FeatureSystemFolderLauncher -ParentTabPage $ParentTabPage
        Import-FeatureUserFolderLauncher -ParentTabPage $ParentTabPage
        Import-FeatureAppLauncher -ParentTabPage $ParentTabPage
    }

    end {
    }
}

### END OF SCRIPT
####################################################################################################