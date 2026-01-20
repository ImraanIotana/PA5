####################################################################################################
<#
.SYNOPSIS
    This function creates a new Button.
.DESCRIPTION
    This function is part of the Packaging Assistant. It contains references to classes, functions or variables, that are in other files.
    External classes    : -
    External functions  : -
    External variables  : $Global:ApplicationObject
.EXAMPLE
    Invoke-Button
.INPUTS
    -
.OUTPUTS
    This function returns no stream output.
.NOTES
    Version         : 5.0
    Author          : Imraan Iotana
    Creation Date   : October 2023
    Last Update     : February 2025
#>
####################################################################################################

function Invoke-Button {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory=$false,HelpMessage='The Global ApplicationObject containing the Settings.')]
        [PSCustomObject]
        $ApplicationObject = $Global:ApplicationObject,

        # The Parent GroupBox to which this button will be added.
        [Parameter(Mandatory=$true)]
        [System.Windows.Forms.GroupBox]
        $ParentGroupBox,

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

        # The location of the button expressed in rownumber.
        [Parameter(Mandatory=$false)]
        [System.Int32]
        $RowNumber = 1,

        # The location of the button expressed in columnnumber.
        [Parameter(Mandatory=$false)]
        [System.Int32]
        $ColumnNumber = 1,

        # The sizetype of the button (small, medium or large). This will influence the width and height.
        [Parameter(Mandatory=$false)]
        [AllowEmptyString()]
        [ValidateSet('Small','Medium','Large')]
        [System.String]
        $SizeType = 'Medium',

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
        ####################################################################################################
        ### MAIN OBJECT ###

        # Set the main object
        [PSCustomObject]$Local:MainObject = @{
            # Function
            FunctionDetails = [System.String[]]@($MyInvocation.MyCommand,$PSCmdlet.ParameterSetName,$PSBoundParameters.GetEnumerator())
            # Input
            ParentGroupBox      = $ParentGroupBox
            Text                = $Text
            TextColor           = $TextColor
            RowNumber           = $RowNumber
            PNGImagePath        = $PNGImagePath
            ColumnNumber        = $ColumnNumber
            SizeType            = $SizeType
            Function            = $Function
            ToolTip             = $ToolTip
            # Handlers
            Settings            = $ApplicationObject.Settings
        }

        ####################################################################################################
        ### MAIN FUNCTION METHODS ###

        # Add the Process method
        Add-Member -InputObject $Local:MainObject -MemberType ScriptMethod -Name Process -Value {
            # Set the location of the button
            $this.SetButtonLocation()
            # Add the Button Size to the main object
            $this.AddButtonSizeToMainObject($this.Settings,$this.SizeType)
            # Create the button
            $this.CreateButton()
        }

        ####################################################################################################
        ### BUTTON LOCATION
    
        # Add the SetButtonLocation method
        Add-Member -InputObject $Local:MainObject -MemberType ScriptMethod -Name SetButtonLocation -Value {
            # Set the TopLeftX of the button
            [System.Int32]$ButtonTopLeftX = $this.SetButtonTopLeftX()
            # Set the TopLeftY of the button
            [System.Int32]$ButtonTopLeftY = $this.SetButtonTopLeftY()
            # Add the result to the main object
            Add-Member -InputObject $this -NotePropertyName Location -NotePropertyValue @($ButtonTopLeftX, $ButtonTopLeftY)
        }
    
        # Add the SetButtonTopLeftX method
        Add-Member -InputObject $Local:MainObject -MemberType ScriptMethod -Name SetButtonTopLeftX -Value {
            # Set the TopLeftX of the button
            [System.Int32]$ButtonTopLeftX = $this.Settings.ColumnNumber.($this.ColumnNumber)
            # Return the result
            $ButtonTopLeftX
        }
    
        # Add the SetButtonTopLeftY method
        Add-Member -InputObject $Local:MainObject -MemberType ScriptMethod -Name SetButtonTopLeftY -Value {
            # Set the TopLeftY of the button
            [System.Int32]$ButtonTopLeftY = $this.Settings.TextBox.TopMargin + (($this.RowNumber - 1) * $this.Settings.TextBox.Height)
            # Return the result
            $ButtonTopLeftY
        }

        ####################################################################################################
        ### BUTTON SIZE
    
        # Add the AddButtonSizeToMainObject method
        Add-Member -InputObject $Local:MainObject -MemberType ScriptMethod -Name AddButtonSizeToMainObject -Value { param([System.Collections.Hashtable]$Settings,[System.String]$SizeType)
            # Get the button size
            [System.Int32[]]$ButtonSize = switch ($SizeType) {
                'Large'     { Get-GraphicalDimension -Button -Size -Large }
                'Medium'    { Get-GraphicalDimension -Button -Size -Medium }
                'Small'     { Get-GraphicalDimension -Button -Size -Small }
            }
            # Add the result to the main object
            Add-Member -InputObject $this -NotePropertyName Size -NotePropertyValue $ButtonSize
        }

        ####################################################################################################
    
        # Add the CreateButton method
        Add-Member -InputObject $Local:MainObject -MemberType ScriptMethod -Name CreateButton -Value {
            # Set the parameters
            [System.Collections.Hashtable]$Params = @{
                ParentGroupBox  = $this.ParentGroupBox
                Location        = $this.Location
                #Text            = $this.Text
                TextColor       = $this.TextColor
                Size            = $this.Size
                PNGImagePath    = $this.PNGImagePath
                Function        = $this.Function
                ToolTip         = $this.ToolTip
            }
            # If the size is not small, then also add the text
            if (-Not($this.SizeType -eq 'Small')) { $Params.Add('Text', $this.Text) }
            # Create the button
            New-Button @Params
        }
    }
    
    process {
        $Local:MainObject.Process()
    }

    end {
    }
}

### END OF SCRIPT
####################################################################################################
