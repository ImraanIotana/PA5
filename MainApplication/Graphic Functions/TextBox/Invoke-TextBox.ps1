####################################################################################################
<#
.SYNOPSIS
    This function creates a new TextBox.
.DESCRIPTION
    This function is part of the Packaging Assistant. It contains references to classes, functions or variables, that are in other files.
    External classes    : -
    External functions  : Write-Message, Test-Object, New-TextBox, Invoke-Label
    External variables  : $Global:ApplicationObject
.EXAMPLE
    Invoke-TextBox
.INPUTS
    -
.OUTPUTS
    This function returns no stream output.
.NOTES
    Version         : 5.0
    Author          : Imraan Noormohamed
    Creation Date   : October 2023
    Last Update     : February 2025
#>
####################################################################################################

function Invoke-TextBox {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory=$false,HelpMessage='ApplicationObject containing the Settings.')]
        [PSCustomObject]
        $ApplicationObject = $Global:ApplicationObject,

        [Parameter(Mandatory=$true,HelpMessage='The Parent GroupBox to which this TextBox will be added.')]
        [System.Windows.Forms.GroupBox]
        $ParentGroupBox,

        [Parameter(Mandatory=$false,HelpMessage='The location of the TextBox expressed in rownumber.')]
        [System.Int32]
        $RowNumber = 1,

        [Parameter(Mandatory=$false,HelpMessage='The SizeType of the TextBox (small, medium or large). This will influence only the width, not the height.')]
        [ValidateSet('Small','Medium','Large')]
        [System.String]
        $SizeType = 'Large',

        [Parameter(Mandatory=$false,HelpMessage='The Type of TextBox (input or output). This will influence the TextBox background color, and the readonly property.')]
        [ValidateSet('Input','Output')]
        [System.String]
        $Type = 'Input',

        [Parameter(Mandatory=$false,HelpMessage='The Label that will be placed on the left of the TextBox.')]
        [System.String]
        $Label,

        [Parameter(Mandatory=$false,HelpMessage='The color of the text.')]
        [System.String]
        $TextColor = 'Black',

        [Parameter(Mandatory=$false,HelpMessage='The PropertyName that will be added to the object, to interact with the registry.')]
        [System.String]
        $PropertyName
    )

    begin {
        ####################################################################################################
        ### MAIN OBJECT ###

        # Set the main object
        [PSCustomObject]$Local:MainObject = @{
            # Function
            FunctionDetails = [System.String[]]@($MyInvocation.MyCommand,$PSCmdlet.ParameterSetName,$PSBoundParameters.GetEnumerator())
            # Input
            Settings        = $ApplicationObject.Settings
            ParentGroupBox  = $ParentGroupBox
            RowNumber       = $RowNumber
            SizeType        = $SizeType
            Type            = $Type
            TextColor       = $TextColor
            LabelText       = $Label
            PropertyName    = $PropertyName
            # Output
            OutputObject    = New-Object System.Windows.Forms.TextBox
        }

        ####################################################################################################
        ### MAIN FUNCTION METHODS ###

        # Add the Process method
        Add-Member -InputObject $Local:MainObject -MemberType ScriptMethod -Name Process -Value {
            # Set the location of the textbox
            $this.AddTextBoxLocationToMainObject($this.Settings,$this.ParentGroupBox,$this.RowNumber)
            # Set the size of the textbox
            $this.AddTextBoxSizeToMainObject($this.Settings,$this.SizeType)
            # Set the font of the textbox
            $this.AddTextBoxFontToMainObject($this.Settings)
            # Create the Label
            $this.CreateLabel($this.ParentGroupBox,$this.RowNumber,$this.LabelText)
            # Create the TextBox
            $this.CreateTextBox()
        }

        ####################################################################################################
        ### CALCULATION METHODS
    
        # Add the AddTextBoxLocationToMainObject method
        Add-Member -InputObject $Local:MainObject -MemberType ScriptMethod -Name AddTextBoxLocationToMainObject -Value { param([System.Collections.Hashtable]$Settings,[System.Windows.Forms.GroupBox]$ParentGroupBox,[System.Int32]$RowNumber)
            # Write the message
            #Write-Verbose 'Adding the TextBox Location to the Main Object...'
            # Set the TopLeftX of the textbox
            [System.Int32]$TextBoxTopLeftX = $ParentGroupBox.Location.X + $Settings.TextBox.LeftMargin
            # Set the TopLeftY of the textbox
            [System.Int32]$TextBoxTopLeftY = $Settings.TextBox.TopMargin + (($RowNumber - 1) * $Settings.TextBox.Height)
            # Add the result to the main object
            Add-Member -InputObject $this -NotePropertyName Location -NotePropertyValue @($TextBoxTopLeftX, $TextBoxTopLeftY)
        }
    
        # Add the AddTextBoxSizeToMainObject method
        Add-Member -InputObject $Local:MainObject -MemberType ScriptMethod -Name AddTextBoxSizeToMainObject -Value { param([System.Collections.Hashtable]$Settings,[System.String]$SizeType)
            # Write the message
            #Write-Verbose 'Adding the TextBox Size to the Main Object...'
            # Get the Width of the TextBox from the Global Settings
            [System.Int32]$Width = switch ($SizeType) {
                'Large'     { Get-GraphicalDimension -TextBox -Width -Large }
                'Medium'    { Get-GraphicalDimension -TextBox -Width -Medium }
                'Small'     { Get-GraphicalDimension -TextBox -Width -Small }
            }
            # Set the Height of the textbox
            [System.Int32]$Height = $this.Location.TextBoxTopLeftY + $Settings.TextBox.Height
            # Add the result to the main object
            Add-Member -InputObject $this -NotePropertyName Size -NotePropertyValue @($Width, $Height)
        }
    
        # Add the AddTextBoxFontToMainObject method
        Add-Member -InputObject $Local:MainObject -MemberType ScriptMethod -Name AddTextBoxFontToMainObject -Value { param([System.Collections.Hashtable]$Settings)
            # Write the message
            #Write-Verbose 'Adding the TextBox Font to the Main Object...'
            # Get the Font from the Global Settings
            [System.Drawing.Font]$Font = $Settings.MainFont
            # Add the result to the main object
            Add-Member -InputObject $this -NotePropertyName Font -NotePropertyValue $Font
        }

        ####################################################################################################
        ### CREATE METHODS
    
        # Add the CreateLabel method
        Add-Member -InputObject $Local:MainObject -MemberType ScriptMethod -Name CreateLabel -Value { param([System.Windows.Forms.GroupBox]$ParentGroupBox,[System.Int32]$RowNumber,[System.String]$LabelText)
            # Create the label
            if (Test-Object -IsPopulated $LabelText) {
                #Write-Verbose 'Invoking a new label...'
                Invoke-Label -ParentGroupBox $ParentGroupBox -Text $LabelText -RowNumber $RowNumber
            }
        }
    
        # Add the CreateTextBox method
        Add-Member -InputObject $Local:MainObject -MemberType ScriptMethod -Name CreateTextBox -Value {
            # Create the textbox
            #Write-Verbose 'Invoking a new textbox...'
            $this.OutputObject = New-TextBox -ParentGroupBox $this.ParentGroupBox -Location $this.Location -Size $this.Size -Type $this.Type -TextColor $this.TextColor -Font $this.Font -PropertyName $this.PropertyName
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



