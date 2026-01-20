####################################################################################################
<#
.SYNOPSIS
    This function creates a new ComboBox.
.DESCRIPTION
    This function is part of the Packaging Assistant. It contains references to classes, functions or variables, that are in other files.
    External classes    : -
    External functions  : -
    External variables  : $Global:ApplicationObject
.EXAMPLE
    Invoke-ComboBox
.INPUTS
    -
.OUTPUTS
    This function returns no output.
.NOTES
    Version         : 2.0
    Author          : Imraan Noormohamed
    Creation Date   : October 2023
    Last Updated    : October 2023
#>
####################################################################################################

function Invoke-ComboBox {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory=$false,HelpMessage='The Global ApplicationObject containing the Settings.')]
        [PSCustomObject]
        $ApplicationObject = $Global:ApplicationObject,

        # The Parent GroupBox to which this ComboBox will be added.
        [Parameter(Mandatory=$true)]
        [System.Windows.Forms.GroupBox]
        $ParentGroupBox,

        # The location of the ComboBox expressed in rownumber.
        [Parameter(Mandatory=$false)]
        [System.Int32]
        $RowNumber = 1,

        # The sizetype of the ComboBox (small, medium or large). This will influence the width.
        [Parameter(Mandatory=$false)]
        [ValidateSet('Small','Medium','Large')]
        [System.String]
        $SizeType = 'Large',

        # The type of ComboBox (input or output). This will influence the background color, and the readonly property.
        [Parameter(Mandatory=$false)]
        [ValidateSet('Input','Output')]
        [System.String]
        $Type = 'Input',

        # The array of strings that will be displayed in the ComboBox
        [Parameter(Mandatory=$false)]
        [System.String[]]
        $ContentArray,

        # SelectedIndex
        [Parameter(Mandatory=$false)]
        [System.Int32]
        $SelectedIndex = -1,

        # The label that will be added to the left of the box
        [Parameter(Mandatory=$false)]
        [System.String]
        $Label,

        # The property name that will be added to the object, to interact with the registry
        [Parameter(Mandatory=$false)]
        [System.String]
        $PropertyName
    )

    begin {
        # Set the main object
        [PSCustomObject]$Local:MainObject = @{
            # Function
            FunctionDetails = [System.String[]]@($MyInvocation.MyCommand,$PSCmdlet.ParameterSetName,$PSBoundParameters.GetEnumerator())
            # ComboBox object
            ComboBox            = New-Object System.Windows.Forms.ComboBox
            # Input
            Settings            = $ApplicationObject.Settings
            ParentGroupBox      = $ParentGroupBox
            RowNumber           = $RowNumber
            SizeType            = $SizeType
            Type                = $Type
            ContentArray        = $ContentArray
            SelectedIndex       = $SelectedIndex
            Label               = $Label
            PropertyName        = $PropertyName
        }

        ####################################################################################################
        ### MAIN FUNCTION METHODS ###

        # Add the Process method
        Add-Member -InputObject $Local:MainObject -MemberType ScriptMethod -Name Process -Value {
            # Set the location of the ComboBox
            $this.SetComboBoxLocation()
            # Set the size of the ComboBox
            $this.SetComboBoxSize()
            # Set the font of the ComboBox
            $this.SetComboBoxFont()
            # Create the ComboBox
            $this.CreateComboBox()
            # Add the content to the combobox
            $this.AddContentToCombox($this.ComboBox,$this.ContentArray)
            # Set the SelectedIndex
            $this.SetSelectedIndex()
            # Create the label
            $this.CreateLabel()
        }

        ####################################################################################################
    
        # Add the SetComboBoxLocation method
        Add-Member -InputObject $Local:MainObject -MemberType ScriptMethod -Name SetComboBoxLocation -Value {
            # Set the TopLeftX of the ComboBox
            [System.Int32]$ComboBoxTopLeftX = $this.ParentGroupBox.Location.X + $this.Settings.TextBox.LeftMargin
            # Set the TopLeftY of the ComboBox
            [System.Int32]$ComboBoxTopLeftY = $this.Settings.TextBox.TopMargin + (($this.RowNumber - 1) * $this.Settings.TextBox.Height)
            # Add the result to the main object
            Add-Member -InputObject $this -NotePropertyName Location -NotePropertyValue @($ComboBoxTopLeftX, $ComboBoxTopLeftY)
        }
    
        # Add the SetComboBoxSize method
        Add-Member -InputObject $Local:MainObject -MemberType ScriptMethod -Name SetComboBoxSize -Value {
            # Set the Width of the ComboBox
            [System.Int32]$Width = switch ($this.SizeType) {
                'Large'     { $this.Settings.TextBox.LargeWidth }
                'Medium'    { $this.Settings.TextBox.MediumWidth }
                'Small'     { $this.Settings.TextBox.SmallWidth }
            }
            # Set the Height of the ComboBox
            [System.Int32]$Height = $this.Location.ComboBoxTopLeftY + $this.Settings.TextBox.Height
            # Add the result to the main object
            Add-Member -InputObject $this -NotePropertyName Size -NotePropertyValue @($Width, $Height)
        }
    
        # Add the SetComboBoxFont method
        Add-Member -InputObject $Local:MainObject -MemberType ScriptMethod -Name SetComboBoxFont -Value {
            # Set the font of the ComboBox
            [System.Drawing.Font]$Font = $this.Settings.MainFont
            # Add the result to the main object
            Add-Member -InputObject $this -NotePropertyName Font -NotePropertyValue $Font
        }

        ####################################################################################################
    
        # Add the CreateComboBox method
        Add-Member -InputObject $Local:MainObject -MemberType ScriptMethod -Name CreateComboBox -Value {
            # Create the ComboBox
            $this.ComboBox = New-ComboBox -ParentGroupBox $this.ParentGroupBox -Location $this.Location -Size $this.Size -Type $this.Type -Font $this.Font -PropertyName $this.PropertyName
        }
    
        # Add the CreateLabel method
        Add-Member -InputObject $Local:MainObject -MemberType ScriptMethod -Name CreateLabel -Value {
            # Create the label
            if ($this.Label) {
                #Write-Verbose 'Invoking a new label...'
                Invoke-Label -ParentGroupBox $this.ParentGroupBox -Text $this.Label -RowNumber $this.RowNumber
            }
        }

        ####################################################################################################

        # Add the AddContentToCombox method
        Add-Member -InputObject $Local:MainObject -MemberType ScriptMethod -Name AddContentToCombox -Value { param([System.Windows.Forms.ComboBox]$ComboBox,[System.String[]]$ContentArray)
            try {
                # if the content array is empty, write the message and return
                if (($null -eq $ContentArray) -or ($ContentArray.Count -eq 0)) { Write-Verbose 'The content array is empty. No values will be added to the combobox.' ; Return }
                # Add the content to the combobox
                $ContentArray | ForEach-Object {
                    $ComboBox.Items.Add($_) | Out-Null
                }
            }
            catch {
                # Write the error
                Write-FullError
            }
        }

        # Add the SetSelectedIndex method
        Add-Member -InputObject $Local:MainObject -MemberType ScriptMethod -Name SetSelectedIndex -Value {
            try {
                # Set the SelectedIndex
                $this.ComboBox.SelectedIndex = $this.SelectedIndex
            }
            catch {
                # Write the error
                Write-FullError
            }
        }#>

        ####################################################################################################

        # Write the Begin message
        #Write-Message -FunctionBegin -Details $Local:MainObject.FunctionDetails
    }
    
    process {
        $Local:MainObject.Process()
    }

    end {
        # Return the output
        $Local:MainObject.ComboBox
        # Write the End message
        #Write-Message -FunctionEnd -Details $Local:MainObject.FunctionDetails
    }
}



