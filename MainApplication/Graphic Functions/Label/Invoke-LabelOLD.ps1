####################################################################################################
<#
.SYNOPSIS
    This function creates a new Label.
.DESCRIPTION
    This function is part of the Packaging Assistant. It contains references to classes, functions or variables, that are in other files.
    External classes    : -
    External functions  : -
    External variables  : $Global:ApplicationObject
.EXAMPLE
    Invoke-Label
.INPUTS
    [System.Windows.Forms.GroupBox]
    [System.String]
    [System.Int32]
.OUTPUTS
    [System.Windows.Forms.Label]
.NOTES
    Version         : 1.9
    Author          : Imraan Noormohamed
    Creation Date   : October 2023
    Last Updated    : October 2023
#>
####################################################################################################
 
function Invoke-LabelOLD {
    [CmdletBinding()]
    param (
        # The Parent GroupBox to which this label will be added.
        [Parameter(Mandatory=$true)]
        [System.Windows.Forms.GroupBox]
        $ParentGroupBox,

        # The text of the label.
        [Parameter(Mandatory=$true)]
        [System.String]
        $Text,

        # The color of the text.
        [Parameter(Mandatory=$false)]
        [System.String]
        $TextColor,

        # The location of the label expressed in rownumber.
        [Parameter(Mandatory=$false)]
        [System.Int32]
        $RowNumber = 1
    )

    begin {
        # Set the main object
        [PSCustomObject]$Local:MainObject = @{
            # Function
            FunctionDetails = [System.String[]]@($MyInvocation.MyCommand,$PSCmdlet.ParameterSetName,$PSBoundParameters.GetEnumerator())
            # TextBox object
            #TextBox             = New-Object System.Windows.Forms.Label
            # Input
            ParentGroupBox      = $ParentGroupBox
            Text                = $Text
            TextColor           = $TextColor
            RowNumber           = $RowNumber
            # Handlers
            Settings            = $Global:ApplicationObject.Settings
        }

        ####################################################################################################
        ### MAIN FUNCTION METHODS ###

        # Add the Process method
        Add-Member -InputObject $Local:MainObject -MemberType ScriptMethod -Name Process -Value {
            # Set the location of the label
            $this.SetLabelLocation()
            # Set the font of the label
            $this.SetLabelFont()
            # Create the label
            $this.CreateLabel()
        }

        ####################################################################################################
    
        # Add the SetLabelLocation method
        Add-Member -InputObject $Local:MainObject -MemberType ScriptMethod -Name SetLabelLocation -Value {
            # Write the message
            Write-Verbose 'Setting the Label location...'
            # Set the X of the label
            [System.Int32]$LabelX = $this.ParentGroupBox.Location.X + $this.Settings.Label.LeftMargin
            # Set the Y of the label
            [System.Int32]$LabelY = ($this.Settings.TextBox.TopMargin + 2) + (($this.RowNumber - 1) * $this.Settings.TextBox.Height)
            # Add the result to the main object
            Add-Member -InputObject $this -NotePropertyName Location -NotePropertyValue @($LabelX, $LabelY)
        }
    
        # Add the SetLabelFont method
        Add-Member -InputObject $Local:MainObject -MemberType ScriptMethod -Name SetLabelFont -Value {
            # Write the message
            Write-Verbose 'Setting the Label font...'
            # Set the font of the label
            [System.Drawing.Font]$Font = $this.Settings.MainFont
            # Add the result to the main object
            Add-Member -InputObject $this -NotePropertyName Font -NotePropertyValue $Font
        }

        ####################################################################################################
    
        # Add the CreateLabel method
        Add-Member -InputObject $Local:MainObject -MemberType ScriptMethod -Name CreateLabel -Value {
            # Create the label
            Write-Verbose 'Invoking a new label...'
            #$this.Label = 
            New-Label -ParentGroupBox $ParentGroupBox -Location $this.Location -Text $this.Text -Font $this.Font -TextColor $this.TextColor
        }

        ####################################################################################################

        # Write the Begin message
        #Write-Message -FunctionBegin -Details $Local:MainObject.FunctionDetails
    }
    
    process {
        $Local:MainObject.Process()
    }

    end {
        # Write the End message
        #Write-Message -FunctionEnd -Details $Local:MainObject.FunctionDetails
    }
}



