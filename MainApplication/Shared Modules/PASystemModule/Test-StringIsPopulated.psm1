####################################################################################################
<#
.SYNOPSIS
    This function tests if a string is populated
.DESCRIPTION
    This function is part of the Universal Deployment Script. It contains references to classes, functions or variables, that are in other files.
.EXAMPLE
    Test-StringIsPopulated -String $MyString
.INPUTS
    [System.String]
.OUTPUTS
    [System.Boolean]
.NOTES
    Version         : 5.5.1
    Author          : Imraan Iotana
    Creation Date   : September 2025
    Last Update     : September 2025
#>
####################################################################################################

function Test-StringIsPopulated {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory=$true,ValueFromPipeline=$true,HelpMessage='The string that will be handled.')]
        [Alias('StringToTest')]
        [AllowNull()]
        [AllowEmptyString()]
        [System.String]
        $String
    )

    begin {
        ####################################################################################################
        ### MAIN PROPERTIES ###

        # Function
        [System.String[]]$FunctionDetails   = @($MyInvocation.MyCommand,$PSCmdlet.ParameterSetName,$PSBoundParameters.GetEnumerator())
        # Output
        [System.Boolean]$OutputObject       = $null

        ####################################################################################################

        # Write the Begin message
        Write-Function -Begin $FunctionDetails
    }
    
    process {
        # If the String is empty then return true, else return false
        Write-Verbose ('[{0}]: Testing if the String is empty...' -f $FunctionDetails[0])
        $StringIsEmpty = if ([System.String]::IsNullOrWhiteSpace($String)) {
            Write-Verbose ('[{0}]: The String is empty.' -f $FunctionDetails[0])
            $true
        } else {
            Write-Verbose ('[{0}]: The String is NOT empty.' -f $FunctionDetails[0])
            $false
        }
        # Set the output
        $OutputObject = (-Not($StringIsEmpty))
    }
    
    end {
        # Write the End message
        Write-Function -End $FunctionDetails
        # Return the output
        $OutputObject
    }
}

### END OF SCRIPT
####################################################################################################
