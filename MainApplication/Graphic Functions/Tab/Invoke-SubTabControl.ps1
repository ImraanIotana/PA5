####################################################################################################
<#
.SYNOPSIS
    This function creates the SubTabControl, which is added to a TabPage.
.DESCRIPTION
    This function is part of the Packaging Assistant. It contains references to functions and variables that are in other files.
.EXAMPLE
    Invoke-SubTabControl -ParentTabPage $Global:ParentTabPage
.INPUTS
    [System.Windows.Forms.TabPage]
    [PSCustomObject]
.OUTPUTS
    This function returns no stream output.
.NOTES
    Version         : 5.7.0
    Author          : Imraan Iotana
    Creation Date   : October 2023
    Last Update     : January 2026
#>
####################################################################################################

function Invoke-SubTabControl {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory=$true,HelpMessage='The Parent TabPage to which this tabcontrol will be added.')]
        [System.Windows.Forms.TabPage]$ParentTabPage,
        
        [Parameter(Mandatory=$false,HelpMessage='ApplicationObject containing the Settings.')]
        [PSCustomObject]$ApplicationObject = $Global:ApplicationObject
    )

    begin {
        <# Set the main object
        [PSCustomObject]$Local:MainObject = @{
            # Input
            ParentTabPage       = $ParentTabPage
            ApplicationObject   = $ApplicationObject
            # Output
            OutputObject        = New-Object System.Windows.Forms.TabControl
        }#>

        ####################################################################################################
        ### MAIN FUNCTION METHODS ###

        <# Add the Process method
        Add-Member -InputObject $Local:MainObject -MemberType ScriptMethod -Name Process -Value {
            # Create the sub tabcontrol
            $this.CreateSubTabControl()
        }#>

        ####################################################################################################
    
        <# Add the CreateSubTabControl method
        Add-Member -InputObject $Local:MainObject -MemberType ScriptMethod -Name CreateSubTabControl -Value {
            try {
                # Get the Settings
                [System.Collections.Hashtable]$Settings = $this.ApplicationObject.Settings
                # Write the message
                Write-Verbose 'Setting the TabControl location...'
                [System.Int32[]]$Location = @(0,0)
                # Write the message
                Write-Verbose 'Setting the TabControl size...'
                # Set the Width of the tabcontrol
                [System.Int32]$Width = $Settings.MainForm.Width - $Settings.MainTabControl.RightMargin
                # Set the Height of the groupbox
                [System.Int32]$Height = $Settings.MainForm.Height - $Settings.MainTabControl.BottomMargin
                # Set the Size
                [System.Int32[]]$Size = @($Width, $Height)
                # Create the sub tabcontrol
                Write-Verbose 'Creating Sub TabControl...'
                $this.OutputObject = New-TabControl -ParentTabPage $this.ParentTabPage -Location $Location -Size $Size
            }
            catch {
                Write-FullError
            }
        }#>
    }
    
    process {
        try {
            # Get the Settings
            [System.Collections.Hashtable]$Settings = $ApplicationObject.Settings
            # Set the location
            [System.Int32[]]$Location = @(0,0)
            # Set the Width of the tabcontrol
            [System.Int32]$Width = $Settings.MainForm.Width - $Settings.MainTabControl.RightMargin
            # Set the Height of the tabcontrol
            [System.Int32]$Height = $Settings.MainForm.Height - $Settings.MainTabControl.BottomMargin
            # Set the Size
            [System.Int32[]]$Size = @($Width, $Height)
            # Create the sub tabcontrol
            [System.Windows.Forms.TabControl]$OutputObject = New-TabControl -ParentTabPage $ParentTabPage -Location $Location -Size $Size
        }
        catch {
            Write-FullError
        }
    }

    end {
        # Return the output
        $OutputObject
    }
}
