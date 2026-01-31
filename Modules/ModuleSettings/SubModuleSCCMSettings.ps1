####################################################################################################
<#
.SYNOPSIS
    This function imports the SCCM Settings SubModule.
.DESCRIPTION
    This function is part of the Packaging Assistant. It contains references to functions and variables that are in other files.
.EXAMPLE
    Import-SubModuleFolderSettings -ParentTabControl $MyTabControl
.INPUTS
    [System.Windows.Forms.TabControl]
.OUTPUTS
    This function returns no stream-output.
.NOTES
    Version         : 5.7.0
    Author          : Imraan Iotana
    Creation Date   : July 2025
    Last Update     : January 2026
#>
####################################################################################################

function Import-SubModuleSCCMSettings {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory=$true,HelpMessage='The TabControl to which this Module TabPage will be added.')]
        [System.Windows.Forms.TabControl]$ParentTabControl
    )

    begin {
        ####################################################################################################
        ### MAIN PROPERTIES ###

        # Handlers
        [System.String]$TabTitle        = 'SCCM Settings'
        [System.String]$ModuleVersion   = '5.7.0'
        [System.String]$BackGroundColor = 'YellowGreen'

        ####################################################################################################
        ####################################################################################################
        ### MAIN OBJECT ###

        # Set the main object
        [PSCustomObject]$Local:MainObject = @{
            # Input
            ParentTabControl    = $ParentTabControl
            # Handlers
            TabTitle            = [System.String]'SCCM Settings'
            ModuleVersion       = [System.String]'5.4.7'
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
            [System.Windows.Forms.TabPage]$ParentTabPage = $Global:SubModuleSCCMSettingsTabPage = New-TabPage -Parent $this.ParentTabControl -Title $this.TabTitle -BackGroundColor 'YellowGreen'
            # Import the Features
            Import-FeatureSCCMServerSettings -ParentTabPage $ParentTabPage
        }
    }
    
    process {
        #$Local:MainObject.Process()
        try {
            # Write the message
            Write-Line "Importing SubModule $TabTitle $ModuleVersion"
            # Create the SubModule TabPage
            [System.Windows.Forms.TabPage]$Global:SubModuleSCCMSettingsTabPage = $ParentTabPage = New-TabPage -Parent $ParentTabControl -Title $TabTitle -BackGroundColor $BackGroundColor
            # Import the Features
            Import-FeatureSCCMServerSettings -ParentTabPage $ParentTabPage
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