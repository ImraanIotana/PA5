####################################################################################################
<#
.SYNOPSIS
    This function creates a new ComboBox.
.DESCRIPTION
    This function is part of the Packaging Assistant. It contains references to functions and variables that are in other files.
.EXAMPLE
    Invoke-ComboBox -ParentGroupBox $MyGroupBox -RowNumber 1 -SizeType Medium -Type Output -Label 'Select:' -ContentArray ('One','Two','Three') -PropertyName 'UserChoice'
.INPUTS
    [PSCustomObject]
    [System.Windows.Forms.GroupBox]
    [System.Int32]
    [System.String]
.OUTPUTS
    [System.Windows.Forms.ComboBox]
.NOTES
    Version         : 5.7.0
    Author          : Imraan Iotana
    Creation Date   : October 2023
    Last Update     : January 2026
#>
####################################################################################################

function Invoke-ComboBoxOLD {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory=$false,HelpMessage='The Global ApplicationObject containing the Settings.')]
        [PSCustomObject]$ApplicationObject = $Global:ApplicationObject,

        [Parameter(Mandatory=$true,HelpMessage='The Parent GroupBox to which this ComboBox will be added.')]
        [System.Windows.Forms.GroupBox]$ParentGroupBox,

        [Parameter(Mandatory=$false,HelpMessage='The location of the ComboBox expressed in rownumber.')]
        [System.Int32]$RowNumber = 1,

        [Parameter(Mandatory=$false,HelpMessage='The sizetype of the ComboBox, this will influence the width.')]
        [ValidateSet('Small','Medium','Large')]
        [System.String]$SizeType = 'Large',

        [Parameter(Mandatory=$false,HelpMessage='The type of ComboBox, this will influence the background color, and the readonly property.')]
        [ValidateSet('Input','Output')]
        [System.String]$Type = 'Input',

        [Parameter(Mandatory=$false,HelpMessage='The array of strings that will be displayed in the ComboBox.')]
        [System.String[]]$ContentArray,

        [Parameter(Mandatory=$false,HelpMessage='The selected row that is shown after creation. "SelectedIndex=-1" selects the empty top row.')]
        [System.Int32]$SelectedIndex = -1,

        [Parameter(Mandatory=$false,HelpMessage='The label that will be added to the left of the box.')]
        [System.String]$Label,

        [Parameter(Mandatory=$false,HelpMessage='The property name that will be added to the object, to interact with the registry')]
        [System.String]$PropertyName
    )

    begin {
        ####################################################################################################
        ### MAIN PROPERTIES ###

        # Input
        [System.Collections.Hashtable]$Settings     = $ApplicationObject.Settings

        # Create a New ComboBox
        [System.Windows.Forms.ComboBox]$NewComboBox = New-Object System.Windows.Forms.ComboBox

        ####################################################################################################
    }
    
    process {
        try {
            # LOCATION
            # Set the Location of the ComboBox
            [System.Int32]$ComboBoxTopLeftX = $ParentGroupBox.Location.X + $Settings.TextBox.LeftMargin
            [System.Int32]$ComboBoxTopLeftY = $Settings.TextBox.TopMargin + (($RowNumber - 1) * $Settings.TextBox.Height)
            [System.Int32[]]$Location       = @($ComboBoxTopLeftX, $ComboBoxTopLeftY)
            $NewComboBox.Location           = New-Object System.Drawing.Point($Location)
    
            # SIZE
            # Set the Size of the ComboBox
            [System.Int32]$Width = switch ($SizeType) {
                'Large'     { $Settings.TextBox.LargeWidth }
                'Medium'    { $Settings.TextBox.MediumWidth }
                'Small'     { $Settings.TextBox.SmallWidth }
            }
            [System.Int32]$Height   = $ComboBoxTopLeftY + $Settings.TextBox.Height
            $NewComboBox.Size       = New-Object System.Drawing.Size($Width, $Height)

    
            # FONT
            # Set the font of the ComboBox
            $NewComboBox.Font = $Settings.MainFont

            # COLORS
            # Set the ForeColor
            $NewComboBox.ForeColor = 'Black'
            # Set the BackColor
            [System.String]$BackColor = switch ($Type) {
                'Input'     { 'White' }
                'Output'    { 'Beige' }
            }
            $NewComboBox.BackColor = $BackColor

            # CONTENT
            # # Add the content to the ComboBox
            if (($null -eq $ContentArray) -or ($ContentArray.Count -eq 0)) { Write-Verbose 'No content will be added.' } else { $ContentArray | ForEach-Object { $NewComboBox.Items.Add($_) | Out-Null } }
            # Set the SelectedIndex
            $NewComboBox.SelectedIndex = $SelectedIndex

            # INTERACTION WITH REGISTRY
            if ($PropertyName) {
                # Add the propertyname
                $NewComboBox | Add-Member -MemberType NoteProperty -Name PropertyName -Value $PropertyName
                # Make it interact with the registry
                $NewComboBox.Text = Invoke-RegistrySettings -Read -PropertyName $NewComboBox.PropertyName
                $NewComboBox.Add_SelectedIndexChanged([System.EventHandler]{ param($ComboBox=$NewComboBox) Invoke-RegistrySettings -Write -PropertyName $ComboBox.PropertyName -PropertyValue $ComboBox.Text })
            }

            # ADD TO PARENT
            # Add the ComboBox to the ParentGroupBox
            $ParentGroupBox.Controls.Add($NewComboBox)
            # Create the label
            if ($Label) { Invoke-Label -ParentGroupBox $ParentGroupBox -Text $Label -RowNumber $RowNumber }
        }
        catch {
            Write-FullError
        }

    }

    end {
        # Return the output
        $NewComboBox
    }
}

### END OF SCRIPT
####################################################################################################

