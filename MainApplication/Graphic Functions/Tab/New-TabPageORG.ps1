####################################################################################################
<#
.SYNOPSIS
    This function creates a new TabPage.
.DESCRIPTION
    This function is part of the Intune Assistant. It contains references to functions and variables, that may be in other files.
    External functions: -
    External variables: $Global:Messages
.EXAMPLE
    New-TabPage -Parent $MyTabControl -Title 'Administration'
.INPUTS
    This function has 2 mandatory input parameters:
    Parent(TabControl)  : The TabControl to which this TabPage will be added.
    Title(String)       : The title of the TabPage.
.OUTPUTS
    This function returns a form object of the type [System.Windows.Forms.TabPage].
.NOTES
    Version         : 0.3
    Author          : Imraan Noormohamed
    Creation Date   : May 2023
    Last Updated    : May 2023
#>
####################################################################################################

function New-TabPageORG {
    [CmdletBinding()]
    param (
        # The TabControl to which this TabPage will be added
        [Parameter(Mandatory=$true)]
        [System.Windows.Forms.TabControl]
        $ParentTabControl,

        # The title of the TabPage
        [Parameter(Mandatory=$false)]
        [System.String]
        $Title = 'Default Tab Title',

        [Parameter(Mandatory=$false,HelpMessage='The color of the TabPage.')]
        [System.String]
        $BackGroundColor
    )

    begin {
        # Set the main object
        [PSCustomObject]$Local:MainObject = @{
            # Function
            FunctionDetails     = [System.String[]]@($MyInvocation.MyCommand,$PSCmdlet.ParameterSetName,$PSBoundParameters.GetEnumerator())
            # TabPage object
            TabPage             = New-Object System.Windows.Forms.TabPage
            # Input
            ParentTabControl    = $ParentTabControl
            TabPageTitle        = $Title
            BackColor           = $BackGroundColor
        }

        ####################################################################################################
        ### MAIN FUNCTION METHODS ###
        
        # Add the Begin method
        Add-Member -InputObject $Local:MainObject -MemberType ScriptMethod -Name Begin -Value {
            # Write the Begin message
            #Write-Message -FunctionBegin -Details $this.FunctionDetails
        }
    
        # Add the End method
        Add-Member -InputObject $Local:MainObject -MemberType ScriptMethod -Name End -Value {
            # Write the End message
            #Write-Message -FunctionEnd -Details $this.FunctionDetails
        }
        
        # Add the Process method
        Add-Member -InputObject $Local:MainObject -MemberType ScriptMethod -Name Process -Value {
            # Add the properties to the TabPage object
            Write-Verbose 'Creating tabpage...'
            $this.TabPage.Text = $this.TabPageTitle
            if ($this.BackColor) { $this.TabPage.BackColor = $this.BackColor }
            # Add the TabPage the TabControl
            $this.ParentTabControl.Controls.Add($this.TabPage)
        }
    } 
    
    process {
        $Local:MainObject.Process()
    }

    end {
        # Return the output
        Return $Local:MainObject.TabPage
    }
}
