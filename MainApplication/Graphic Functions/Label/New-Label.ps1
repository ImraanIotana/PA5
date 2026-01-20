####################################################################################################
<#
.SYNOPSIS
    This function creates a new Label.
.DESCRIPTION
    This function is self-contained and does not refer to functions, variables or classes, that are in other files.
.EXAMPLE
    New-Label -Parent $MyGroupBox -Text 'First Name:' -TextColor 'Green' -Location (100,75)
.INPUTS
    [System.Windows.Forms.Groupbox]
    [System.String]
    [System.Int32[]]
    [System.Drawing.Font]
.OUTPUTS
    [System.Windows.Forms.Label]
.NOTES
    Version         : 2.0
    Author          : Imraan Noormohamed
    Creation Date   : October 2023
    Last Updated    : October 2023
#>
####################################################################################################

function New-Label {
    [CmdletBinding()]
    param (
        # The Parent GroupBox to which this label will be added.
        [Parameter(Mandatory=$true)]
        [System.Windows.Forms.Groupbox]
        $ParentGroupbox,

        # The text of the label.
        [Parameter(Mandatory=$true)]
        [System.String]
        $Text,

        # The coordinates of the label.
        [Parameter(Mandatory=$true)]
        [System.Int32[]]
        $Location,

        # The font of the text.
        [Parameter(Mandatory=$false)]
        [System.Drawing.Font]
        $Font,

        # The color of the text.
        [Parameter(Mandatory=$false)]
        [System.String]
        $TextColor
    )

    begin {
        # Set the main object
        [PSCustomObject]$Local:MainObject = @{
            # Function
            FunctionDetails = [System.String[]]@($MyInvocation.MyCommand,$PSCmdlet.ParameterSetName,$PSBoundParameters.GetEnumerator())
            # Input
            Font                = $Font
            ParentGroupbox      = $ParentGroupbox
            # Label object
            Label               = New-Object System.Windows.Forms.Label
            # TextBox properties
            Properties          = @{
                Text            = $Text
                ForeColor       = $TextColor
                AutoSize        = $true
                Location        = New-Object System.Drawing.Point($Location)
            }
        }

        ####################################################################################################
        ### MAIN FUNCTION METHODS ###
    
        # Add the Process method
        Add-Member -InputObject $Local:MainObject -MemberType ScriptMethod -Name Process -Value {
            # Set the properties of the label
            $this.SetFont()
            # Add all properties to the label
            $this.AddAllProperties()
        }

        ####################################################################################################

        # Add the SetFont method
        Add-Member -InputObject $Local:MainObject -MemberType ScriptMethod -Name SetFont -Value {
            # Add the font to the properties
            if ($this.Font) { $this.Properties.Add('Font', $this.Font) }
        }

        ####################################################################################################

        # Add the AddAllProperties method
        Add-Member -InputObject $Local:MainObject -MemberType ScriptMethod -Name AddAllProperties -Value {
            # Add all properties to the label
            $this.Properties.GetEnumerator() | ForEach-Object {
                Write-Verbose ('Adding property ({0}) with value: {1}' -f $_.Name,$_.Value)
                $this.Label.($_.Name) = $_.Value
            }
            # Add the new textbox to the parent
            $this.ParentGroupbox.Controls.Add($this.Label)
        }

        ####################################################################################################

        # Write the Begin message
        #Write-Message -FunctionBegin -Details $Local:MainObject.FunctionDetails
    } 
    
    process {
        $Local:MainObject.Process()
    }

    end {
        # Write the End message
        #Write-Message -FunctionEnd -Details $Local:MainObject.FunctionDetails
    }
}



