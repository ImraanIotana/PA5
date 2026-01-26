####################################################################################################
<#
.SYNOPSIS
    This function get a dimension for a graphical object, from the global settings.
.DESCRIPTION
    This function is part of the Packaging Assistant. It contains references to classes, functions or variables, that are in other files.
    External classes    : -
    External functions  : Write-FullError
    External variables  : $Global:ApplicationObject
.EXAMPLE
    Get-GraphicalDimension -Button -Large -Width
.INPUTS
    [PSCustomObject]
    [System.Management.Automation.SwitchParameter]
.OUTPUTS
    [System.Int32]
.NOTES
    Version         : 5.0.3
    Author          : Imraan Iotana
    Creation Date   : April 2025
    Last Update     : April 2025
#>
####################################################################################################

function Get-GraphicalDimensionOLD {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory=$false,HelpMessage='The global ApplicationObject containing the Settings.')]
        [PSCustomObject]
        $ApplicationObject = $Global:ApplicationObject,

        [Parameter(Mandatory=$true,ParameterSetName='FormLocation',HelpMessage='Switch for the Form Location.')]
        [Parameter(Mandatory=$true,ParameterSetName='FormSize',HelpMessage='Switch for the Form Size.')]
        [System.Management.Automation.SwitchParameter]
        $Form,

        [Parameter(Mandatory=$true,ParameterSetName='MainTabControlLocation',HelpMessage='Switch for the MainTabControl Location.')]
        [Parameter(Mandatory=$true,ParameterSetName='MainTabControlSize',HelpMessage='Switch for the MainTabControl Size.')]
        [System.Management.Automation.SwitchParameter]
        $MainTabControl,

        [Parameter(Mandatory=$true,ParameterSetName='TextBoxWidthLarge',HelpMessage='Switch for the Large TextBox Width.')]
        [Parameter(Mandatory=$true,ParameterSetName='TextBoxWidthMedium',HelpMessage='Switch for the Medium TextBox Width.')]
        [Parameter(Mandatory=$true,ParameterSetName='TextBoxWidthSmall',HelpMessage='Switch for the Small TextBox Width.')]
        [System.Management.Automation.SwitchParameter]
        $TextBox,

        [Parameter(Mandatory=$true,ParameterSetName='ButtonSizeLarge',HelpMessage='Switch for the Large Button Size.')]
        [Parameter(Mandatory=$true,ParameterSetName='ButtonSizeMedium',HelpMessage='Switch for the Medium Button Size.')]
        [Parameter(Mandatory=$true,ParameterSetName='ButtonSizeSmall',HelpMessage='Switch for the Small Button Size.')]
        [System.Management.Automation.SwitchParameter]
        $Button,

        [Parameter(Mandatory=$true,ParameterSetName='FormLocation',HelpMessage='Switch for the Form Location.')]
        [Parameter(Mandatory=$true,ParameterSetName='MainTabControlLocation',HelpMessage='Switch for the MainTabControl Location.')]
        [System.Management.Automation.SwitchParameter]
        $Location,

        [Parameter(Mandatory=$true,ParameterSetName='FormSize',HelpMessage='Switch for the Form Size.')]
        [Parameter(Mandatory=$true,ParameterSetName='MainTabControlSize',HelpMessage='Switch for the MainTabControl Size.')]
        [Parameter(Mandatory=$true,ParameterSetName='ButtonSizeLarge',HelpMessage='Switch for the Large Button Size.')]
        [Parameter(Mandatory=$true,ParameterSetName='ButtonSizeMedium',HelpMessage='Switch for the Medium Button Size.')]
        [Parameter(Mandatory=$true,ParameterSetName='ButtonSizeSmall',HelpMessage='Switch for the Small Button Size.')]
        [System.Management.Automation.SwitchParameter]
        $Size,

        [Parameter(Mandatory=$true,ParameterSetName='TextBoxWidthLarge',HelpMessage='Switch for the Large TextBox Width.')]
        [Parameter(Mandatory=$true,ParameterSetName='TextBoxWidthMedium',HelpMessage='Switch for the Medium TextBox Width.')]
        [Parameter(Mandatory=$true,ParameterSetName='TextBoxWidthSmall',HelpMessage='Switch for the Small TextBox Width.')]
        [System.Management.Automation.SwitchParameter]
        $Width,

        [Parameter(Mandatory=$true,ParameterSetName='TextBoxWidthLarge',HelpMessage='Switch for the Large TextBox Width.')]
        [Parameter(Mandatory=$true,ParameterSetName='ButtonSizeLarge',HelpMessage='Switch for the Large Button Size.')]
        [System.Management.Automation.SwitchParameter]
        $Large,

        [Parameter(Mandatory=$true,ParameterSetName='TextBoxWidthMedium',HelpMessage='Switch for the Medium TextBox Width.')]
        [Parameter(Mandatory=$true,ParameterSetName='ButtonSizeMedium',HelpMessage='Switch for the Medium Button Size.')]
        [System.Management.Automation.SwitchParameter]
        $Medium,

        [Parameter(Mandatory=$true,ParameterSetName='TextBoxWidthSmall',HelpMessage='Switch for the Small TextBox Width.')]
        [Parameter(Mandatory=$true,ParameterSetName='ButtonSizeSmall',HelpMessage='Switch for the Small Button Size.')]
        [System.Management.Automation.SwitchParameter]
        $Small
    )

    begin {
        ####################################################################################################
        ### PROPERTIES ###

        # Set the Settings
        [System.Collections.Hashtable]$Settings = $ApplicationObject.Settings
    }
    
    process {
        try {
            # Switch on the ParameterSetName
            switch ($PSCmdlet.ParameterSetName) {
                # Form
                'FormLocation'              { Write-Host 'No function set for this ParameterSetName.' -ForegroundColor Red }
                'FormSize'                  { [System.Int32[]]$OutputObject = @($Settings.MainForm.Width,$Settings.MainForm.Height) }
                # MainTabControl
                'MainTabControlLocation'    { [System.Int32[]]$OutputObject = @($Settings.MainTabControl.TopLeftX, $Settings.MainTabControl.TopLeftY) }
                'MainTabControlSize'        { [System.Int32[]]$OutputObject = @($Settings.MainTabControl.Width, $Settings.MainTabControl.Height) }
                # TextBox
                'TextBoxWidthLarge'         { [System.Int32]$OutputObject   = $Settings.TextBox.LargeWidth }
                'TextBoxWidthMedium'        { [System.Int32]$OutputObject   = $Settings.TextBox.MediumWidth }
                'TextBoxWidthSmall'         { [System.Int32]$OutputObject   = $Settings.TextBox.SmallWidth }
                # Button
                'ButtonSizeLarge'           { [System.Int32[]]$OutputObject = @($Settings.Button.LargeWidth, $Settings.Button.LargeHeight) }
                'ButtonSizeMedium'          { [System.Int32[]]$OutputObject = @($Settings.Button.MediumWidth, $Settings.Button.MediumHeight) }
                'ButtonSizeSmall'           { [System.Int32[]]$OutputObject = @($Settings.Button.SmallWidth, $Settings.Button.SmallHeight) }
                # Default
                Default                     { Write-Red 'No function set for this ParameterSetName.' }
            }
        }
        catch {
            Write-FullError
        }
    }

    end {
        # Return the output object
        $OutputObject
    }
}

### END OF SCRIPT
####################################################################################################
