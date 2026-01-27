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

function Invoke-Button {
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
                'Large'     { @($this.Settings.Button.LargeWidth, $this.Settings.Button.LargeHeight) }
                'Medium'    { @($this.Settings.Button.MediumWidth, $this.Settings.Button.MediumHeight) }
                'Small'     { @($this.Settings.Button.SmallWidth, $this.Settings.Button.SmallHeight) }
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
