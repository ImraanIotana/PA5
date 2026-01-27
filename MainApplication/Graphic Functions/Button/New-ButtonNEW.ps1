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

function New-ButtonNEW {
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
        [System.Windows.Forms.Button]$NewButton = New-Object System.Windows.Forms.Button

        ####################################################################################################
    } 
    
    process {
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

### END OF SCRIPT
####################################################################################################
