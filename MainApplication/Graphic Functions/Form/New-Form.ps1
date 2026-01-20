####################################################################################################
<#
.SYNOPSIS
    This function creates and returns a new Form Object.
.DESCRIPTION
    This function is self-contained and does not refer to functions, variables or classes, that are in other files.
.EXAMPLE
    New-Form -Title 'My Application' -Icon 'C:\Demo\Star.ico' -Size (100,100)
.INPUTS
    [System.String]
    [System.Int32[]]
.OUTPUTS
    [System.Windows.Forms.Form]
.NOTES
    Version         : 5.0
    Author          : Imraan Iotana
    Creation Date   : October 2023
    Last Update     : February 2025
#>
####################################################################################################

function New-Form {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory=$false,HelpMessage='The title shown at the top of the form.')]
        [Alias('FormTitle')]
        [System.String]
        $Title = 'Default Title',

        [Parameter(Mandatory=$false,HelpMessage='The path of the icon, shown at the top of the form.')]
        [Alias('Icon')]
        [System.String]
        $IconPath,
        
        [Parameter(Mandatory=$false,HelpMessage='The size of the form.')]
        [System.Int32[]]
        $Size = @(300,300)
    )
    
    begin {
        ####################################################################################################
        ### MAIN OBJECT ###

        [PSCustomObject]$Local:MainObject = @{
            # Function
            FunctionDetails = [System.String[]]@($MyInvocation.MyCommand,$PSCmdlet.ParameterSetName,$PSBoundParameters.GetEnumerator())
            # Input
            FormTitle           = $Title
            FormIconPath        = $IconPath
            FormWidth           = $Size[0]
            FormHeight          = $Size[1]
            # Output
            OutputObject        = New-Object System.Windows.Forms.Form
            # Static Form Handlers
            MinimizeBox         = [System.Boolean]$true
            MaximizeBox         = [System.Boolean]$false
            StartPosition       = [System.String]'CenterScreen'
            FormBorderStyle     = [System.Windows.Forms.FormBorderStyle]::FixedSingle
        }

        ####################################################################################################
        ### MAIN FUNCTION METHODS ###

        # Add the Process method
        Add-Member -InputObject $Local:MainObject -MemberType ScriptMethod -Name Process -Value {
            # Get the FormProperties
            [System.Collections.Hashtable]$FormProperties = $this.GetFormProperties()
            # Set the FormProperties on the Output Object
            $this.SetFormPropertiesOnOutputObject($FormProperties)
        }

        ####################################################################################################
        ### MAIN PROCESSING METHODS ###
    
        # Add the GetFormProperties method
        Add-Member -InputObject $Local:MainObject -MemberType ScriptMethod -Name GetFormProperties -Value {
            # Create the FormProperties hashtable
            [System.Collections.Hashtable]$FormProperties = @{
                # Variable properties
                Text            = $this.FormTitle
                Icon            = $this.FormIconPath
				Width			= $this.FormWidth
				Height			= $this.FormHeight
                # Static properties
                MinimizeBox     = $this.MinimizeBox
                MaximizeBox     = $this.MaximizeBox
                StartPosition   = $this.StartPosition
                FormBorderStyle = $this.FormBorderStyle
            }
            # Return the result
            $FormProperties
        }

        # Add the SetFormPropertiesOnOutputObject method
        Add-Member -InputObject $Local:MainObject -MemberType ScriptMethod -Name SetFormPropertiesOnOutputObject -Value { param([System.Collections.Hashtable]$FormProperties)
            $FormProperties.GetEnumerator() | ForEach-Object {
                [System.String]$PropertyName    = $_.Name
                [System.String]$PropertyValue   = $_.Value
                Write-Verbose ('Adding property ({0}) with value: {1}' -f $PropertyName,$PropertyValue)
                $this.OutputObject.($PropertyName) = $PropertyValue
            }
        }

        ####################################################################################################

        #region BEGIN
        # Write the Begin message
        #Write-Message -FunctionBegin -Details $Local:MainObject.FunctionDetails
        #endregion BEGIN
    }
    
    process {
        #region PROCESS
        $Local:MainObject.Process()
        #endregion PROCESS
    }
    
    end {
        #region END
        # Return the output
        $Local:MainObject.OutputObject
        # Write the End message
        #Write-Message -FunctionEnd -Details $Local:MainObject.FunctionDetails
        #endregion END
    }
}
