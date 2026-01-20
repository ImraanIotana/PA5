####################################################################################################
<#
.SYNOPSIS
    This function creates a new Button.
.DESCRIPTION
    This function is self-contained and does not refer to functions, variables or classes, that are in other files.
.EXAMPLE
    New-Button -ParentGroupBox $MyGroupBox -Location (100,75) -Text 'Browse' -Size (50,50) -PNGImagePath 'C:\Work\Image.png'
.INPUTS
    [System.Windows.Forms.Groupbox]
    [System.String]
    [System.Int32[]]
    [System.EventHandler]
.OUTPUTS
    This function returns no stream output.
.NOTES
    Version         : 2.0
    Author          : Imraan Noormohamed
    Creation Date   : October 2023
    Last Updated    : October 2023
#>
####################################################################################################

function New-Button {
    [CmdletBinding()]
    param (
        # The Parent GroupBox to which this button will be added.
        [Parameter(Mandatory=$true)]
        [System.Windows.Forms.Groupbox]
        $ParentGroupbox,

        # The coordinates of the button.
        [Parameter(Mandatory=$true)]
        [System.Int32[]]
        $Location,

        # The size of the button.
        [Parameter(Mandatory = $true)]
        [System.Int32[]]
        $Size,

        # The text of the button.
        [Parameter(Mandatory=$false)]
        [System.String]
        $Text,

        # The color of the text.
        [Parameter(Mandatory=$false)]
        [AllowEmptyString()]
        [System.String]
        $TextColor,

        # The path of the image file in png format.
        [Parameter(Mandatory = $false)]
        [AllowEmptyString()]
        [System.String]
        $PNGImagePath,

        # Function
        [Parameter(Mandatory = $false)]
        [System.EventHandler]
        $Function,

        # ToolTip
        [Parameter(Mandatory = $false)]
        [System.String]
        $ToolTip
    )

    begin {
        # Set the main object
        [PSCustomObject]$Local:MainObject = @{
            # Function
            FunctionDetails     = [System.String[]]@($MyInvocation.MyCommand,$PSCmdlet.ParameterSetName,$PSBoundParameters.GetEnumerator())
            # Input
            ParentGroupbox      = $ParentGroupbox
            TextColor           = $TextColor
            PNGImagePath        = $PNGImagePath
            ToolTip             = $ToolTip
            Function            = $Function
            # Button object
            Button              = New-Object System.Windows.Forms.Button
            # Button properties
            Properties              = @{
                Text                = $Text
                Location            = New-Object System.Drawing.Point($Location)
                Size                = New-Object System.Drawing.Point($Size)
                TextImageRelation   = 'ImageBeforeText'
                Cursor              = [System.Windows.Forms.Cursors]::Hand
            }
        }

        ####################################################################################################
        ### MAIN FUNCTION METHODS ###
    
        # Add the Process method
        Add-Member -InputObject $Local:MainObject -MemberType ScriptMethod -Name Process -Value {
            # Add the textcolor
            $this.AddTextColorToProperties()
            # Add the image
            $this.AddImageToProperties()
            # Add all properties to the button
            $this.AddAllProperties()
            # Add the tooltip
            $this.AddToolTipToButton()
            # Add the function
            $this.AddFunctionToButton()
        }

        ####################################################################################################

        # Add the AddTextColorToProperties method
        Add-Member -InputObject $Local:MainObject -MemberType ScriptMethod -Name AddTextColorToProperties -Value {
            # Add the textcolor to the properties
            if ($this.TextColor) { $this.Properties.Add('ForeColor', $this.TextColor) }
        }

        # Add the AddImageToProperties method
        Add-Member -InputObject $Local:MainObject -MemberType ScriptMethod -Name AddImageToProperties -Value {
            # Add the image to the properties
            if ($this.PNGImagePath) {
                $ButtonImage = [System.Drawing.Image]::FromFile($this.PNGImagePath)
                $this.Properties.Add('Image', $ButtonImage)
            }
            # If both an image and text are passed thru, add a space before the text for better spacing
            if ($this.PNGImagePath -and $this.Properties.Text) { $this.Properties.Text = (' {0}' -f $this.Properties.Text) }
        }

        ####################################################################################################

        # Add the AddToolTipToButton method
        Add-Member -InputObject $Local:MainObject -MemberType ScriptMethod -Name AddToolTipToButton -Value {
            # Add the tooltip to the button object
            if ($this.ToolTip) {
                # Create a new ToolTip object
                #Write-Verbose ('Adding the tooltip to the button:' -f $this.ToolTip)
                $NewToolTipObject = New-Object System.Windows.Forms.ToolTip
                $NewToolTipObject.SetToolTip($this.Button,$this.ToolTip)
                # Add the ToolTip object to the Mouse Over action
                $this.Button.Add_MouseEnter({ $NewToolTipObject })
            }
        }

        # Add the AddFunctionToButton method
        Add-Member -InputObject $Local:MainObject -MemberType ScriptMethod -Name AddFunctionToButton -Value {
            # Add the function to the properties
            if ($this.Function) { $this.Button.Add_Click($this.Function) }
        }

        ####################################################################################################

        # Add the AddAllProperties method
        Add-Member -InputObject $Local:MainObject -MemberType ScriptMethod -Name AddAllProperties -Value {
            # Add all properties to the button
            $this.Properties.GetEnumerator() | ForEach-Object {
                #Write-Verbose ('Adding property ({0}) with value: {1}' -f $_.Name,$_.Value)
                $this.Button.($_.Name) = $_.Value
            }
            # Add the new button to the parent
            $this.ParentGroupbox.Controls.Add($this.Button)
        }
    } 
    
    process {
        $Local:MainObject.Process()
    }

    end {
    }
}



