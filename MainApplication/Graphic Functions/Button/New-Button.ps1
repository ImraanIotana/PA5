####################################################################################################
<#
.SYNOPSIS
    This function creates a new Button.
.DESCRIPTION
    This function is part of the Packaging Assistant. However, it is self-contained and does not refer to functions or variables that are in other files.
.EXAMPLE
    New-Button -ParentGroupBox $MyGroupBox -Location (100,75) -Text 'Browse' -Size (50,50) -PNGImagePath 'C:\Demo\Star.png'
.INPUTS
    [System.Windows.Forms.Groupbox]
    [System.Int32[]]
    [System.String]
    [System.EventHandler]
.OUTPUTS
    This function returns no stream output.
.NOTES
    Version         : 5.7.0
    Author          : Imraan Iotana
    Creation Date   : October 2023
    Last Update     : January 2026
#>
####################################################################################################

function New-Button {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory=$true,HelpMessage='The Parent GroupBox to which this button will be added.')]
        [System.Windows.Forms.Groupbox]$ParentGroupbox,

        [Parameter(Mandatory=$true,HelpMessage='The location of the button in X,Y coordinates.')]
        [System.Int32[]]$Location,

        [Parameter(Mandatory = $true,HelpMessage='The size of the button in Width,Height format.')]
        [System.Int32[]]$Size,

        [Parameter(Mandatory=$false,HelpMessage='The text to be displayed on the button.')]
        [System.String]$Text,

        [Parameter(Mandatory=$false,HelpMessage='The color of the text on the button.')]
        [AllowEmptyString()]
        [System.String]$TextColor,

        [Parameter(Mandatory = $false,HelpMessage='The path of the PNG image to be displayed on the button.')]
        [AllowEmptyString()]
        [System.String]$PNGImagePath,

        [Parameter(Mandatory = $false,HelpMessage='The tooltip text to be displayed when hovering over the button.')]
        [System.String]$ToolTip,

        [Parameter(Mandatory = $false,HelpMessage='The function to be executed when the button is clicked.')]
        [System.EventHandler]$Function
    )

    begin {
        ####################################################################################################
        ### MAIN PROPERTIES ###

        # Create a New Button
        [SSystem.Windows.Forms.Button]$NewButton = New-Object System.Windows.Forms.Button

        ####################################################################################################
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
        #$Local:MainObject.Process()

        # DIMENSIONS
        # Add the Location
        $NewButton.Location = New-Object System.Drawing.Point($Location)
        # Add the Size
        $NewButton.Size = New-Object System.Drawing.Point($Size)

        # TEXT
        # Add the Text
        $NewButton.Text = $Text
        # Add the Text Color
        if ($TextColor) { $NewButton.ForeColor = $TextColor }
        # Add the ToolTip
        if ($ToolTip) {
            $NewToolTipObject = New-Object System.Windows.Forms.ToolTip
            $NewToolTipObject.SetToolTip($NewButton,$ToolTip)
            # Add the ToolTip object to the Mouse Over action
            $NewButton.Add_MouseEnter({ $NewToolTipObject })
        }

        # IMAGE
        # Add the PNG Image
        if ($PNGImagePath) {
            $ButtonImage = [System.Drawing.Image]::FromFile($PNGImagePath)
            $NewButton.Image = $ButtonImage
            # If both an image and text are passed thru, add a space before the text for better spacing. And set the TextImageRelation
            if ($Text) { $NewButton.Text = " $Text" ; $NewButton.TextImageRelation = 'ImageBeforeText' }
        }

        # CURSOR
        # Change the cursor to a hand when hovering over the button
        $NewButton.Cursor = [System.Windows.Forms.Cursors]::Hand

        # FUNCTION
        # Add the function to the button
        if ($Function) { $NewButton.Add_Click($Function) }

        # ADD BUTTON TO PARENT
        $ParentGroupbox.Controls.Add($NewButton)
    }

    end {
    }
}



