####################################################################################################
<#
.SYNOPSIS
    This function confirms/validates an object
.DESCRIPTION
    This function is part of the Packaging Assistant. It contains references to classes, functions or variables, that are in other files.
.EXAMPLE
    Confirm-Object -MandatoryBox $MyTextBox
.INPUTS
    [System.Object[]]
.OUTPUTS
    [System.Boolean]
.NOTES
    Version         : 5.4.7
    Author          : Imraan Iotana
    Creation Date   : May 2025
    Last Update     : July 2025
#>
####################################################################################################

function Confirm-Object {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory=$true,ParameterSetName='ValidateMandatoryString',HelpMessage='The mandatory string that will be validated')]
        [AllowEmptyString()]
        [System.String]
        $MandatoryString,

        [Parameter(Mandatory=$true,ParameterSetName='ValidateMandatoryPath',HelpMessage='The mandatory path that will be validated')]
        [AllowEmptyString()]
        [System.String]
        $MandatoryPath,

        [Parameter(Mandatory=$true,ParameterSetName='ValidateMandatoryBoxes',HelpMessage='The TextBoxes or ComboBoxes of which the content will be validated.')]
        [System.Object[]]
        $MandatoryBox
    )
    
    begin {
        ####################################################################################################
        ### MAIN OBJECT ###

        [PSCustomObject]$Local:MainObject = @{
            # Function
            FunctionDetails     = [System.String[]]@($MyInvocation.MyCommand,$PSCmdlet.ParameterSetName,$PSBoundParameters.GetEnumerator())
            ParameterSetName    = [System.String]$PSCmdlet.ParameterSetName
            # Input
            StringToValidate    = $MandatoryString
            PathToValidate      = $MandatoryPath
            BoxesToValidate     = $MandatoryBox
            # Output
            OutputObject        = [System.Boolean]$null
        }

        ####################################################################################################
        ### MAIN FUNCTION METHODS ###
        
        # Add the Begin method
        Add-Member -InputObject $Local:MainObject -MemberType ScriptMethod -Name Begin -Value {
            # Write the Begin message
            Write-Message -FunctionBegin -Details $this.FunctionDetails
        }
        
        # Add the End method
        Add-Member -InputObject $Local:MainObject -MemberType ScriptMethod -Name End -Value {
            # Write the End message
            Write-Message -FunctionEnd -Details $this.FunctionDetails
        }

        # Add the Process method
        Add-Member -InputObject $Local:MainObject -MemberType ScriptMethod -Name Process -Value {
            # Switch on the ParameterSetName
            $this.OutputObject = switch ($this.ParameterSetName) {
                'ValidateMandatoryString'   { $this.ValidateMandatoryStringMethod($this.StringToValidate) }
                'ValidateMandatoryPath'     { $this.ValidateMandatoryPathMethod($this.PathToValidate) }
                'ValidateMandatoryBoxes'    { $this.ValidateMandatoryBoxesProcess($this.BoxesToValidate) }
            }
        }

        ####################################################################################################
        ### MAIN PROCESSING METHODS ###
        
        # Add the ValidateMandatoryBoxesProcess method
        Add-Member -InputObject $Local:MainObject -MemberType ScriptMethod -Name ValidateMandatoryBoxesProcess -Value { param([System.Object[]]$BoxesToValidate)
            [System.Boolean[]]$ResultArray = @()
            foreach ($Box in $BoxesToValidate) {
                # Test if the string is empty, and add the result to the array
                [System.Boolean]$BoxIsPopulated = Test-Object -IsPopulated ($Box.Text)
                if ($BoxIsPopulated) { $ResultArray += $true } else { $ResultArray += $false }
            }
            # If the array contains false, then return false
            [System.Boolean]$Result = if ($ResultArray -contains $false) { Write-Message -MandatoryField ; $false } else { $true }
            # Return the result
            $Result
        }

        ####################################################################################################
        ### SUPPORTING METHODS ###

        # Add the ValidateMandatoryStringMethod method
        Add-Member -InputObject $Local:MainObject -MemberType ScriptMethod -Name ValidateMandatoryStringMethod -Value { param([System.String]$StringToValidate)
            # If the string is populated then return true, else return false
            Write-Verbose ('ValidateMandatoryStringMethod: Testing if the string is populated: ({0})' -f $StringToValidate)
            if ([System.String]::IsNullOrEmpty($StringToValidate)) {
                Write-Verbose 'ValidateMandatoryStringMethod: The string is empty.'    
                $false
            } else {
                Write-Verbose ('ValidateMandatoryStringMethod: The string is populated: ({0})' -f $StringToValidate)
                $true
            }
        }
        
        # Add the ValidateMandatoryPathMethod method
        Add-Member -InputObject $Local:MainObject -MemberType ScriptMethod -Name ValidateMandatoryPathMethod -Value { param([System.String]$PathToValidate)
            try {
                # Validate the string
                if (-Not($this.ValidateMandatoryStringMethod($PathToValidate))) { $false ; Return }
                # Validate the path
                Write-Verbose ('ValidateMandatoryPathMethod: Testing if the path exists: ({0})' -f $PathToValidate)
                if (Test-Path -Path $PathToValidate) {
                    Write-Verbose ('ValidateMandatoryPathMethod: The path exists: ({0})' -f $PathToValidate)
                    $true
                } else {
                    Write-FullError ('ValidateMandatoryPathMethod: The path does not exist, or could not be reached: ({0})' -f $PathToValidate)
                    $false
                }
            }
            catch { Write-FullError }
        }
        
        ####################################################################################################

        $Local:MainObject.Begin()
    }
    
    process {
        $Local:MainObject.Process()
    }
    
    end {
        $Local:MainObject.End()
        # Return the output
        $Local:MainObject.OutputObject
    }
}

### END OF SCRIPT
####################################################################################################
