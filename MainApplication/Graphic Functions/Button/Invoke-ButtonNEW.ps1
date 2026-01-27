####################################################################################################
<#
.SYNOPSIS
    This function creates a new Button.
.DESCRIPTION
    This function is part of the Packaging Assistant. It contains references to functions and variables that are in other files.
.EXAMPLE
    Invoke-Button -ParentGroupBox $Global:GroupBox -Text 'Click Me' -RowNumber 2 -ColumnNumber 3 -SizeType 'Large' -Function $OnClickFunction -ToolTip 'This is a button.'
.INPUTS
    [PSCustomObject]
    [System.Windows.Forms.GroupBox]
    [System.String]
    [System.Int32]
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

function Invoke-ButtonNEW {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory=$false,HelpMessage='The Global ApplicationObject containing the Settings.')]
        [PSCustomObject]$ApplicationObject = $Global:ApplicationObject,

        [Parameter(Mandatory=$true,HelpMessage='The Parent GroupBox to which this button will be added.')]
        [System.Windows.Forms.GroupBox]$ParentGroupBox,

        [Parameter(Mandatory=$false,HelpMessage='The text of the button.')]
        [System.String]$Text,

        [Parameter(Mandatory=$false,HelpMessage='The color of the text.')]
        [AllowEmptyString()]
        [System.String]$TextColor,

        [Parameter(Mandatory = $false,HelpMessage='The path of the image file in png format.')]
        [AllowEmptyString()]
        [System.String]$PNGImagePath,

        [Parameter(Mandatory=$false,HelpMessage='The location of the button expressed in rownumber.')]
        [System.Int32]$RowNumber = 1,

        [Parameter(Mandatory=$false,HelpMessage='The location of the button expressed in columnnumber.')]
        [System.Int32]$ColumnNumber = 1,

        [Parameter(Mandatory=$false,HelpMessage='The size type of the button (Small, Medium or Large).')]
        [AllowEmptyString()]
        [ValidateSet('Small','Medium','Large')]
        [System.String]$SizeType = 'Medium',

        [Parameter(Mandatory = $false,HelpMessage='The function to be invoked when the button is clicked.')]
        [System.EventHandler]$Function,

        [Parameter(Mandatory = $false,HelpMessage='The ToolTip of the button.')]
        [System.String]$ToolTip
    )

    begin {
        ####################################################################################################
        ### MAIN PROPERTIES ###

        # Input
        [System.Collections.Hashtable]$Settings = $ApplicationObject.Settings

        ####################################################################################################
    }
    
    process {
        # COORDINATES
        # Set the TopLeft X-coordinate of the button
        [System.Int32]$ButtonTopLeftX = $Settings.ColumnNumber.($ColumnNumber)
        # Set the TopLeft Y-coordinate of the button
        [System.Int32]$ButtonTopLeftY = $Settings.TextBox.TopMargin + (($RowNumber - 1) * $Settings.TextBox.Height)
        
        # SIZE
        # Set the button size
        [System.Int32[]]$ButtonSize = switch ($SizeType) {
            'Large'     { @($Settings.Button.LargeWidth,    $Settings.Button.LargeHeight) }
            'Medium'    { @($Settings.Button.MediumWidth,   $Settings.Button.MediumHeight) }
            'Small'     { @($Settings.Button.SmallWidth,    $Settings.Button.SmallHeight) }
        }

        # PARAMETERS
        # Set the parameters
        [System.Collections.Hashtable]$NewButtonParameters = @{
            ParentGroupBox  = $ParentGroupBox
            Location        = @($ButtonTopLeftX, $ButtonTopLeftY)
            TextColor       = $TextColor
            Size            = $ButtonSize
            PNGImagePath    = $PNGImagePath
            Function        = $Function
            ToolTip         = $ToolTip
        }
        # If the size is not small, then also add the text
        if (-Not($SizeType -eq 'Small')) { $NewButtonParameters['Text'] = $Text }

        # CREATION
        # Create the button
        New-Button @NewButtonParameters
    }

    end {
    }
}

### END OF SCRIPT
####################################################################################################
