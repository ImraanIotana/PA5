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

function New-TabControl {
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
        [System.Windows.Forms.TabControl]$OutputObject = $null


        ####################################################################################################
        <# Set the main object
        [PSCustomObject]$Local:MainObject = @{
            # Function
            FunctionDetails     = [System.String[]]@($MyInvocation.MyCommand,$PSCmdlet.ParameterSetName,$PSBoundParameters.GetEnumerator())
            # Input
            ParentForm          = $ParentForm
            ParentTabPage       = $ParentTabPage
            Properties          = [System.Collections.Hashtable]@{
                Location        = New-Object System.Drawing.Point($Location)
                Size            = New-Object System.Drawing.Size($Size)
            }
            # TabControl object
            TabControl          = New-Object System.Windows.Forms.TabControl
        }

        ####################################################################################################
        ### MAIN FUNCTION METHODS ###
        
        # Add the Process method
        Add-Member -InputObject $Local:MainObject -MemberType ScriptMethod -Name Process -Value {
            # Set the Parent object
            $ParentObject = switch ($this.FunctionDetails[1]) {
                'TabControlForParentForm'       { $this.ParentForm }
                'TabControlForParentTabPage'    { $this.ParentTabPage }
            }
            # Add the properties to the tabcobtrol object
            Write-Verbose 'Creating new tabcontrol...'
            $this.Properties.GetEnumerator() | ForEach-Object {
                Write-Verbose ('Adding property ({0}) with value: {1}' -f $_.Name,$_.Value)
                $this.TabControl.($_.Name) = $_.Value
            }
            # Add the tabcontrol to the parent object
            Write-Verbose 'Adding the new tabcontrol to the parent form...'
            $ParentObject.Controls.Add($this.TabControl)
        }#>
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



