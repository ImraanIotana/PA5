####################################################################################################
<#
.SYNOPSIS
    This function imports the Module DSL Management.
.DESCRIPTION
    This function is part of the Packaging Assistant. It contains functions and variables that are in other files.
.EXAMPLE
    Import-ModuleDSLManagement
.INPUTS
    [System.Windows.Forms.TabControl]
.OUTPUTS
    This function returns no stream-output.
.NOTES
    Version         : 5.5.1
    Author          : Imraan Iotana
    Creation Date   : September 2024
    Last Update     : October 2025
#>
####################################################################################################

function Import-ModuleApplicationManagement {
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
        [System.String]$TabTitle        = 'Application Management'
        [System.String]$ModuleVersion   = '5.5.1'

        ####################################################################################################
    }
    
    process {
        try {
            # Write the message
            Write-ModuleImport -Title $TabTitle -Version $ModuleVersion
            # Create the Module TabPage
            [System.Windows.Forms.TabPage]$ParentTabPage = New-TabPage -Parent $ParentTabControl -Title $TabTitle -BackGroundColor 'Navy'
            # Import the Features
            Import-FeatureDSLManagement -ParentTabPage $ParentTabPage
            Import-FeatureSynchronizationPresetsDownload -ParentTabPage $ParentTabPage
            Import-FeatureSynchronizationPresetsUpload -ParentTabPage $ParentTabPage
            Import-FeatureSynchronizationPresetsOther -ParentTabPage $ParentTabPage
            Import-FeatureAuditing -ParentTabPage $ParentTabPage
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
