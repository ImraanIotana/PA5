####################################################################################################
<#
.SYNOPSIS
    This function creates a new ComboBox.
.DESCRIPTION
    This function is self-contained and does not refer to functions, variables or classes, that are in other files.
.EXAMPLE
    New-ComboBox -Parent $MyGroupBox -Type Input -TextColor 'Green' -Location (100,75) -Size (50,50)
.INPUTS
    [System.Windows.Forms.Groupbox]
    [System.String]
    [System.Int32[]]
    [System.Drawing.Font]
.OUTPUTS
    [System.Windows.Forms.ComboBox]
.NOTES
    Version         : 2.0
    Author          : Imraan Noormohamed
    Creation Date   : October 2023
    Last Updated    : October 2023
#>
####################################################################################################

function New-ComboBox {
    [CmdletBinding()]
    param (
        # The Parent GroupBox to which this combobox will be added.
        [Parameter(Mandatory=$true)]
        [System.Windows.Forms.Groupbox]
        $ParentGroupbox,

        # The type of combobox (input or output). This will influence the background color, and the readonly property.
        [Parameter(Mandatory=$false)]
        [ValidateSet('Input','Output')]
        [System.String]
        $Type = 'Input',

        # The coordinates of the topleft corner.
        [Parameter(Mandatory=$true)]
        [System.Int32[]]
        $Location,

        # The size of the ComboBox.
        [Parameter(Mandatory=$true)]
        [System.Int32[]]
        $Size,

        # The font of the text.
        [Parameter(Mandatory=$false)]
        [System.Drawing.Font]
        $Font,

        # The color of the text.
        [Parameter(Mandatory=$false)]
        [System.String]
        $TextColor = 'Black',

        # The property name that will be added to the object
        [Parameter(Mandatory=$false)]
        [System.String]
        $PropertyName
    )

    begin {
        # Set the main object
        [PSCustomObject]$Local:MainObject = @{
            # Function
            FunctionDetails     = [System.String[]]@($MyInvocation.MyCommand,$PSCmdlet.ParameterSetName,$PSBoundParameters.GetEnumerator())
            # Input
            Type                = $Type
            Font                = $Font
            ParentGroupbox      = $ParentGroupbox
            PropertyName        = $PropertyName
            # ComboBox object
            ComboBox             = New-Object System.Windows.Forms.ComboBox
            # ComboBox properties
            Properties          = @{
                ForeColor       = $TextColor
                Location        = New-Object System.Drawing.Point($Location)
                Size            = New-Object System.Drawing.Size($Size)
            }
            # Handlers
            InputColor          = 'White'
            OutputColor         = 'Beige'
        }

        ####################################################################################################
        ### MAIN FUNCTION METHODS ###
    
        # Add the Process method
        Add-Member -InputObject $Local:MainObject -MemberType ScriptMethod -Name Process -Value {
            # Set the properties of the combobox
            $this.SetBackGroundColor()
            #$this.SetReadOnlyProperty()
            $this.SetFont()
            # Add all properties to the combobox
            $this.AddAllProperties()
        }

        ####################################################################################################
    
        # Add the SetBackGroundColor method
        Add-Member -InputObject $Local:MainObject -MemberType ScriptMethod -Name SetBackGroundColor -Value {
            # Add the background color to the properties
            [System.String]$BackColor = switch ($this.Type) {
                'Input'     { $this.InputColor }
                'Output'    { $this.OutputColor }
            }
            $this.Properties.Add('BackColor', $BackColor)
        }
    
        <# Add the SetReadOnlyProperty method
        Add-Member -InputObject $Local:MainObject -MemberType ScriptMethod -Name SetReadOnlyProperty -Value {
            # Add the readonly value to the properties
            [System.Boolean]$ReadOnly = switch ($this.Type) {
                'Input'     { $false }
                'Output'    { $true }
            }
            $this.Properties.Add('ReadOnly', $ReadOnly)
        }#>

        # Add the SetFont method
        Add-Member -InputObject $Local:MainObject -MemberType ScriptMethod -Name SetFont -Value {
            # Add the font to the properties
            if ($this.Font) { $this.Properties.Add('Font', $this.Font) }
        }

        # Add the AddPropertyNameToComboBox method
        Add-Member -InputObject $Local:MainObject -MemberType ScriptMethod -Name AddPropertyNameToComboBox -Value {
            # Add the propertyname
            if ($this.PropertyName) {
                $this.ComboBox | Add-Member -MemberType NoteProperty -Name PropertyName -Value $this.PropertyName
                # Make it interact with the registry
                $this.MakeComboBoxInteractWithRegistry($this.ComboBox)
            }
        }
    
        # Add the MakeComboBoxInteractWithRegistry method
        Add-Member -InputObject $Local:MainObject -MemberType ScriptMethod -Name MakeComboBoxInteractWithRegistry -Value { param([System.Windows.Forms.ComboBox[]]$ComboBoxes)
            # Make it interact with the registry
            $ComboBoxes | ForEach-Object {
                $_.Text = Invoke-RegistrySettings -Read -PropertyName $_.PropertyName
                $_.Add_SelectedIndexChanged([System.EventHandler]{ param($ComboBox=$_) Invoke-RegistrySettings -Write -PropertyName $ComboBox.PropertyName -PropertyValue $ComboBox.Text })
            }
        }

        ####################################################################################################

        # Add the AddAllProperties method
        Add-Member -InputObject $Local:MainObject -MemberType ScriptMethod -Name AddAllProperties -Value {
            # Add all properties to the combobox
            $this.Properties.GetEnumerator() | ForEach-Object {
                #Write-Verbose ('Adding property ({0}) with value: {1}' -f $_.Name,$_.Value)
                $this.ComboBox.($_.Name) = $_.Value
            }
            # If a PropertyName was passed thru, then add it
            if ($this.PropertyName) { $this.AddPropertyNameToComboBox() }
            # Add the new combobox to the parent
            $this.ParentGroupbox.Controls.Add($this.ComboBox)
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
        $Local:MainObject.ComboBox
        # Write the End message
        #Write-Message -FunctionEnd -Details $Local:MainObject.FunctionDetails
    }
}



