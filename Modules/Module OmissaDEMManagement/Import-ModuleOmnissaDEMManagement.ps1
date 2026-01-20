####################################################################################################
<#
.SYNOPSIS
    This function imports the Module 'Omissa DEM Management'.
.DESCRIPTION
    This function is part of the Packaging Assistant. It contains references to classes, functions and variables, that may be in other files.
.EXAMPLE
    Import-ModuleOmissaDEMManagement
.INPUTS
    [System.Windows.Forms.TabControl]
.OUTPUTS
    This function returns no stream output.
.NOTES
    Version         : 5.5.1
    Author          : Imraan Iotana
    Creation Date   : September 2025
    Last Update     : September 2025
#>
####################################################################################################

function Import-ModuleOmnissaDEMManagement {
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
        [System.String]$TabTitle        = 'OMNISSA DEM Management'
        [System.String]$ModuleVersion   = '5.5.1'

        ####################################################################################################
    }
    
    process {
        try {
            # Write the message
            Write-ModuleImport -Title $TabTitle -Version $ModuleVersion
            # Create the Module TabPage
            [System.Windows.Forms.TabPage]$ParentTabPage = New-TabPage -Parent $ParentTabControl -Title $TabTitle -BackGroundColor 'Salmon'
            # Import the Features
            Import-FeatureOmnissaDEMManagement -ParentTabPage $ParentTabPage
            Import-FeatureOmnissaDEMShortcuts -ParentTabPage $ParentTabPage
            Import-FeatureOmnissaDEMUserFiles -ParentTabPage $ParentTabPage
            Import-FeatureOmnissaDEMUserRegistry -ParentTabPage $ParentTabPage
            Import-FeatureOmnissaDEMAllObjects -ParentTabPage $ParentTabPage
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