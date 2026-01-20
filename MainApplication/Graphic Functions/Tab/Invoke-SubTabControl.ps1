####################################################################################################
<#
.SYNOPSIS
    This function creates the main tabcontrol.
.DESCRIPTION
    This function is part of the Packaging Assistant. It contains references to classes, functions or variables, that are in other files.
    External classes    : -
    External functions  : -
    External variables  : $Global:ApplicationObject, $Global:Form, $Global:TabControl
.EXAMPLE
    Invoke-TabControl
.INPUTS
    -
.OUTPUTS
    This function returns no output.
.NOTES
    Version         : 2.0
    Author          : Imraan Noormohamed
    Creation Date   : October 2023
    Last Updated    : October 2023
#>
####################################################################################################

function Invoke-SubTabControl {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory=$true,HelpMessage='The Parent object to which this tabcontrol will be added.')]
        [System.Windows.Forms.TabPage]
        $ParentTabPage,
        
        [Parameter(Mandatory=$false,HelpMessage='ApplicationObject containing the Settings.')]
        [PSCustomObject]
        $ApplicationObject = $Global:ApplicationObject
    )

    begin {
        # Set the main object
        [PSCustomObject]$Local:MainObject = @{
            # Function
            FunctionDetails     = [System.String[]]@($MyInvocation.MyCommand,$PSCmdlet.ParameterSetName,$PSBoundParameters.GetEnumerator())
            # Input
            ParentTabPage       = $ParentTabPage
            ApplicationObject   = $ApplicationObject
            # Output
            OutputObject        = New-Object System.Windows.Forms.TabControl
        }

        ####################################################################################################
        ### MAIN FUNCTION METHODS ###

        # Add the Process method
        Add-Member -InputObject $Local:MainObject -MemberType ScriptMethod -Name Process -Value {
            # Create the sub tabcontrol
            $this.CreateSubTabControl()
        }

        ####################################################################################################
    
        # Add the CreateSubTabControl method
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
        }
    }
    
    process {
        $Local:MainObject.Process()
    }

    end {
        # Return the output
        $Local:MainObject.OutputObject
    }
}
