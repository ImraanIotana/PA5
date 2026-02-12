####################################################################################################
<#
.SYNOPSIS
    This function imports the Module MECM Application.
.DESCRIPTION
    This function is part of the Packaging Assistant. It contains functions and variables that are in other files.
.EXAMPLE
    Import-ModuleMECMApplication
.INPUTS
    [System.Windows.Forms.TabControl]
.OUTPUTS
    This function returns no stream-output.
.NOTES
    Version         : 5.5.1
    Author          : Imraan Iotana
    Creation Date   : September 2024
    Last Update     : September 2025
#>
####################################################################################################

function Import-ModuleSCCMApplication {
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
        [System.String]$TabTitle        = 'SCCM Application'
        [System.String]$ModuleVersion   = '5.5.1'

        ####################################################################################################
    }
    
    process {
        try {
            # Write the message
            Write-ModuleImport -Title $TabTitle -Version $ModuleVersion
            # Create the Module TabPage
            [System.Windows.Forms.TabPage]$ModuleTabPage = New-TabPage -Parent $ParentTabControl -Title $TabTitle -BackGroundColor 'DarkGreen'
            # Import the SCCM PowerShell module and mount the SCCM drive
            Import-SCCMPowerShellModule
            Mount-SCCMDrive
            # Import the Features
            Import-FeatureSCCMApplication -ParentTabPage $ModuleTabPage
            Import-FeatureSCCMSourceFileFunctions -ParentTabPage $ModuleTabPage
            Import-FeatureSCCMDeploymentButtons -ParentTabPage $ModuleTabPage
            Import-FeatureSCCMOtherButtons -ParentTabPage $ModuleTabPage
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
