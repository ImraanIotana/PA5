####################################################################################################
<#
.SYNOPSIS
    This function imports the Module 'AppLocker Import'.
.DESCRIPTION
    This function is part of the Packaging Assistant. It contains references to classes, functions and variables, that may be in other files.
.EXAMPLE
    Import-ModuleAppLockerImport
.INPUTS
    [System.Windows.Forms.TabControl]
.OUTPUTS
    This function returns no stream output.
.NOTES
    Version         : 5.5.1
    Author          : Imraan Iotana
    Creation Date   : August 2025
    Last Update     : August 2025
#>
####################################################################################################

function Import-ModuleAppLockerImport {
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
        [System.String]$TabTitle        = 'APPLOCKER Import'
        [System.String]$ModuleVersion   = '5.5.1'

        ####################################################################################################
    }
    
    process {
        try {
            # Write the message
            Write-ModuleImport -Title $TabTitle -Version $ModuleVersion
            # Create the Module TabPage
            [System.Windows.Forms.TabPage]$ParentTabPage = New-TabPage -Parent $ParentTabControl -Title $TabTitle -BackGroundColor 'RoyalBlue'
            # Import the Features
            Import-FeatureAppLockerImport -ParentTabPage $ParentTabPage
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