####################################################################################################
<#
.SYNOPSIS
    This function creates a new TabControl, and adds it to a Parent Form or Parent TabPage.
.DESCRIPTION
    This function is part of the Packaging Assistant. It contains references to functions and variables that are in other files.
.EXAMPLE
    New-TabControl -ParentForm $Global:MyForm -Location (50,50) -Size (100,100)
.INPUTS
    [System.Windows.Forms.Form]
    [System.Int32[]]
.OUTPUTS
    [System.Windows.Forms.TabControl]
.NOTES
    Version         : 5.7.0
    Author          : Imraan Iotana
    Creation Date   : October 2023
    Last Update     : January 2026
#>
####################################################################################################

function New-TabControlNEW {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory=$true,ParameterSetName='TabControlForParentForm',HelpMessage='The Parent Form to which this tabcontrol will be added.')]
        [System.Windows.Forms.Form]$ParentForm,

        [Parameter(Mandatory=$true,ParameterSetName='TabControlForParentTabPage',HelpMessage='The Parent TabPage to which this tabcontrol will be added.')]
        [System.Windows.Forms.TabPage]$ParentTabPage,

        [Parameter(Mandatory=$true,ParameterSetName='TabControlForParentForm',HelpMessage='The coordinates of the topleft corner.')]
        [Parameter(Mandatory=$true,ParameterSetName='TabControlForParentTabPage',HelpMessage='The coordinates of the topleft corner.')]
        [ValidateCount(2,2)]
        [System.Int32[]]$Location,        

        [Parameter(Mandatory=$true,ParameterSetName='TabControlForParentForm',HelpMessage='The coordinates of the bottom right corner.')]
        [Parameter(Mandatory=$true,ParameterSetName='TabControlForParentTabPage',HelpMessage='The coordinates of the bottom right corner.')]
        [ValidateCount(2,2)]
        [System.Int32[]]$Size
    )

    begin {
        ####################################################################################################
        ### MAIN PROPERTIES ###

        # Set the Location and Size of the TabControl
        [System.Drawing.Point]$TabControlLocation   = [System.Drawing.Point]::new($Location[0], $Location[1])
        [System.Drawing.Size]$TabControlSize       = [System.Drawing.Size]::new($Size[0], $Size[1])

        # Set the Parent object to which the TabControl will be added
        [System.Object]$ParentObject = switch ($PSCmdlet.ParameterSetName) {
            'TabControlForParentForm'       { $ParentForm }
            'TabControlForParentTabPage'    { $ParentTabPage }
        }
        
        # Output
        [System.Windows.Forms.TabControl]$OutputObject = New-Object System.Windows.Forms.TabControl

        ####################################################################################################
    } 
    
    process {
        # Set the Location property
        $OutputObject.Location  = $TabControlLocation
        # Set the Size property
        $OutputObject.Size      = $TabControlSize
        # Add the TabControl to the Parent object
        $ParentObject.Controls.Add($OutputObject)
    }

    end {
        # Return the output
        $OutputObject
    }
}



