####################################################################################################
<#
.SYNOPSIS
    This function creates a new GroupBox.
.DESCRIPTION
    This function is self-contained and does not refer to functions, variables or classes, that are in other files.
.EXAMPLE
    New-GroupBox -ParentTabPage $MyTabPage -Location (100,75) -Size (50,50)
.INPUTS
    [System.Windows.Forms.TabPage]
    [System.Int32[]]
    [System.String]
.OUTPUTS
    [System.Windows.Forms.GroupBox]
.NOTES
    Version         : 5.0
    Author          : Imraan Iotana
    Creation Date   : October 2023
    Last Update     : October 2024
#>
####################################################################################################

function New-GroupBox {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory=$true,HelpMessage='The Parent object to which this groupbox will be added.')]
        [System.Windows.Forms.TabPage]
        $ParentTabPage,

        [Parameter(Mandatory=$true,HelpMessage='The coordinates of the topleft corner.')]
        [System.Int32[]]
        $Location,

        [Parameter(Mandatory=$true,HelpMessage='The size of the groupbox.')]
        [System.Int32[]]
        $Size,

        [Parameter(Mandatory=$false,HelpMessage='The title of the groupbox.')]
        [System.String]
        $Title = 'Default Groupbox Title',

        [Parameter(Mandatory=$false,HelpMessage='The color of the text and border.')]
        [System.String]
        $Color = 'Black'
    )

    begin {
        ####################################################################################################
        ### MAIN OBJECT ###

        # Set the main object
        [PSCustomObject]$Local:MainObject = @{
            # Function
            FunctionDetails = [System.String[]]@($MyInvocation.MyCommand,$PSCmdlet.ParameterSetName,$PSBoundParameters.GetEnumerator())
            # Input
            ParentTabPage   = $ParentTabPage
            Properties      = @{
                Text        = $Title
                ForeColor   = $Color
                Location    = New-Object System.Drawing.Point($Location)
                Size        = New-Object System.Drawing.Size($Size)
            }
            # Output
            OutputObject    = New-Object System.Windows.Forms.GroupBox
        }

        ####################################################################################################
        ### MAIN FUNCTION METHODS ###
    
        # Add the Process method
        Add-Member -InputObject $Local:MainObject -MemberType ScriptMethod -Name Process -Value {
            # Add all properties to the groupbox
            $this.Properties.GetEnumerator() | ForEach-Object {
                #Write-Verbose ('Adding property ({0}) with value: {1}' -f $_.Name,$_.Value)
                $this.OutputObject.($_.Name) = $_.Value
            }
            # Add the new groupbox to the parent
            $this.ParentTabPage.Controls.Add($this.OutputObject)
        }

        ####################################################################################################

        # Write the Begin message
        #Write-Message -FunctionBegin -Details $Local:MainObject.FunctionDetails
    } 
    
    process {
        $Local:MainObject.Process()
    }

    end {
        # Return the output
        $Local:MainObject.OutputObject
        # Write the End message
        #Write-Message -FunctionEnd -Details $Local:MainObject.FunctionDetails
    }
}

### END OF SCRIPT
####################################################################################################
