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
    Version         : 5.3.1
    Author          : Imraan Iotana
    Creation Date   : October 2023
    Last Update     : May 2025
#>
####################################################################################################

function Import-SubModuleGeneralSettings {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory=$true,HelpMessage='The TabControl to which this Module TabPage will be added.')]
        [Alias('TabControl')]
        [System.Windows.Forms.TabControl]
        $ParentTabControl
    )

    begin {
        ####################################################################################################
        ### MAIN OBJECT ###

        # Set the main object
        [PSCustomObject]$Local:MainObject = @{
            # Input
            ParentTabControl    = $ParentTabControl
            # Handlers
            TabTitle            = [System.String]'General Settings'
            ModuleVersion       = [System.String]'5.3.1'
            # Message Handlers
            ImportMessage       = [System.String]('Importing SubModule {0} {1}')
        }

        ####################################################################################################
        ### MAIN FUNCTION METHODS ###

        # Add the Process method
        Add-Member -InputObject $Local:MainObject -MemberType ScriptMethod -Name Process -Value {
            # Write the message
            Write-Host ($this.ImportMessage -f $this.TabTitle,$this.ModuleVersion) -ForegroundColor DarkGray
            # Create the Module TabPage
            [System.Windows.Forms.TabPage]$ParentTabPage = $Global:SubModuleGeneralSettingsTabPage = New-TabPage -Parent $this.ParentTabControl -Title $this.TabTitle -BackGroundColor 'Cornsilk'
            # Import the Features
            Import-FeatureFolderSettings -ParentTabControl $this.ParentTabControl -ParentTabPage $ParentTabPage
            Import-FeaturePersonalSettings -ParentTabPage $ParentTabPage
            Import-FeatureHelp -ParentTabPage $ParentTabPage
        }
    }
    
    process {
        $Local:MainObject.Process()
    }

    end {
    }
}

### END OF SCRIPT
####################################################################################################