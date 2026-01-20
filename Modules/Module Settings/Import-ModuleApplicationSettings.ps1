####################################################################################################
<#
.SYNOPSIS
    This function imports the Application Settings Module.
.DESCRIPTION
    This function is part of the Packaging Assistant. It contains references to classes, functions and variables, that may be in other files.
.EXAMPLE
    Import-ModuleApplicationSettings
.INPUTS
    [System.Windows.Forms.TabControl]
.OUTPUTS
    This function returns no stream output.
.NOTES
    Version         : 5.5.1
    Author          : Imraan Iotana
    Creation Date   : October 2023
    Last Update     : May 2025
#>
####################################################################################################

function Import-ModuleApplicationSettings {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory=$false,HelpMessage='The Parent TabControl to which this new TabPage will be added.')]
        [Alias('TabControl')]
        [System.Windows.Forms.TabControl]
        $ParentTabControl = $Global:MainTabControl
    )

    begin {
        ####################################################################################################
        ### MAIN OBJECT ###

        # Set the main object
        [PSCustomObject]$Local:MainObject = @{
            # Input
            ParentTabControl    = $ParentTabControl
            # Handlers
            TabTitle            = [System.String]'Settings'
            ModuleVersion       = [System.String]'5.5.1'
        }

        ####################################################################################################
        ### MAIN FUNCTION METHODS ###

        # Add the Process method
        Add-Member -InputObject $Local:MainObject -MemberType ScriptMethod -Name Process -Value {
            # Write the message
            $this.ParentTabControl.WriteImportMessage($this)
            # Create the Module TabPage
            [System.Windows.Forms.TabPage]$Global:ApplicationSettingsTabPage = New-TabPage -Parent $this.ParentTabControl -Title $this.TabTitle
            # Create a SubTabControl
            [System.Windows.Forms.TabControl]$Global:ModuleApplicationSettingsTabControl = Invoke-SubTabControl -ParentTabPage $Global:ApplicationSettingsTabPage
            # Load the SCCM/MECM module only on an SCCM server
            [System.Boolean]$IsSCCMServer = $Global:ApplicationObject.IsSCCMServer
            if ($IsSCCMServer) { Import-SubModuleSCCMSettings -ParentTabControl $Global:ModuleApplicationSettingsTabControl }
            # Import the SubModules
            Import-SubModuleGeneralSettings -ParentTabControl $Global:ModuleApplicationSettingsTabControl
            if (-Not($IsSCCMServer)) { Import-SubModuleAppLockerSettings -ParentTabControl $Global:ModuleApplicationSettingsTabControl }
            Import-SubModuleMaintainance -ParentTabControl $Global:ModuleApplicationSettingsTabControl
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
