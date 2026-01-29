####################################################################################################
<#
.SYNOPSIS
    This function imports the Folder Settings Module.
.DESCRIPTION
    This function is part of the Packaging Assistant. It contains references to classes, functions and variables, that may be in other files.
    External classes    : -
    External functions  : -
    External variables  : $Global:TabControl, $Global:SettingsTabPage
.EXAMPLE
    Import-SubModuleFolderSettings
.INPUTS
    This function has no input parameters.
.OUTPUTS
    This function returns no stream-output.
.NOTES
    Version         : 5.5.1
    Author          : Imraan Iotana
    Creation Date   : August 2025
    Last Update     : August 2025
#>
####################################################################################################

function Import-SubModuleAppLockerSettings {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory=$true,HelpMessage='The TabControl to which this Module TabPage will be added.')]
        [Alias('TabControl')]
        [System.Windows.Forms.TabControl]
        $ParentTabControl
    )

    begin {
        ####################################################################################################
        ### MAIN PROPERTIES ###

        # Handlers
        [System.String]$TabTitle        = 'AppLocker Settings'
        [System.String]$ModuleVersion   = '5.5.1'
    }
    
    process {
            # Write the message
            Write-Line ('Importing SubModule {0} {1}' -f $TabTitle,$ModuleVersion)
            # Create the Module TabPage
            [System.Windows.Forms.TabPage]$Global:SubModuleAppLockerSettingsTabPage = $ParentTabPage = New-TabPage -Parent $ParentTabControl -Title $TabTitle -BackGroundColor 'RoyalBlue'
            # Import the Features
            Import-FeatureAppLockerSettings -ParentTabPage $ParentTabPage
    }

    end {
    }
}

### END OF SCRIPT
####################################################################################################