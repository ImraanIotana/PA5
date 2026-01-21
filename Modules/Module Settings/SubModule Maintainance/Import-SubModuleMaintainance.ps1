####################################################################################################
<#
.SYNOPSIS
    This function imports the Module 'Maintainance'.
.DESCRIPTION
    This function is part of the Packaging Assistant. It contains references to functions and variables that are in other files.
.EXAMPLE
    Import-ModuleMaintainance
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

function Import-SubModuleMaintainance {
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
        [System.String]$TabTitle        = 'Maintainance'
        [System.String]$ModuleVersion   = '5.5.1'

        ####################################################################################################
    }
    
    process {
        try {
            # Write the message
            Write-ModuleImport -Title $TabTitle -Version $ModuleVersion
            # Create the Module TabPage
            [System.Windows.Forms.TabPage]$ParentTabPage = New-TabPage -Parent $ParentTabControl -Title $TabTitle -BackGroundColor 'Cornsilk'
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