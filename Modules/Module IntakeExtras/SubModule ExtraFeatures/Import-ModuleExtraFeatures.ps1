####################################################################################################
<#
.SYNOPSIS
    This function imports the Extra Features Module.
.DESCRIPTION
    This function is part of the Packaging Assistant. It contains references to classes, functions and variables, that may be in other files.
.EXAMPLE
    Import-ModuleExtraFeatures
.INPUTS
    [System.Windows.Forms.TabControl]
.OUTPUTS
    This function returns no stream output.
.NOTES
    Version         : 5.5.1
    Author          : Imraan Iotana
    Creation Date   : April 2025
    Last Update     : October 2025
#>
####################################################################################################

function Import-ModuleExtraFeatures {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory=$false,HelpMessage='The Parent TabControl to which this new TabPage will be added.')]
        [Alias('TabControl')]
        [System.Windows.Forms.TabControl]
        $ParentTabControl = $Global:MainTabControl
    )

    begin {
        ####################################################################################################
        ### MAIN PROPERTIES ###

        # Handlers
        [System.String]$TabTitle        = 'Extra Features'
        [System.String]$ModuleVersion   = '5.5.1'
    }
    
    process {
        # Write the message
        Write-ModuleImport -Title $TabTitle -Version $ModuleVersion
        # Create the Module TabPage
        [System.Windows.Forms.TabPage]$Global:ShortcutInfoTabPage = $ParentTabPage = New-TabPage -Parent $ParentTabControl -Title $TabTitle -BackGroundColor 'RoyalBlue'
        # Import the Features
        Import-FeatureExtraFeatures -ParentTabPage $ParentTabPage
        Import-FeatureINNOSetup -ParentTabPage $ParentTabPage
    }

    end {
    }
}

### END OF SCRIPT
####################################################################################################
