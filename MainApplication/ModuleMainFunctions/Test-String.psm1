####################################################################################################
<#
.SYNOPSIS
    This function tests if a String is empty or populated.
.DESCRIPTION
    This function is part of the Packaging Assistant. It contains functions or variables, that are in other files.
.EXAMPLE
    Test-String -IsEmpty $MyString
.EXAMPLE
    Test-String -IsPopulated $MyString
.INPUTS
    [System.String]
.OUTPUTS
    [System.Boolean]
.NOTES
    Version         : 5.7.1.011
    Author          : Imraan Iotana
    Creation Date   : September 2025
    Last Update     : February 2026
.COPYRIGHT
    Copyright (C) Iotana. All rights reserved.
#>
####################################################################################################

function Test-String {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory=$true,ParameterSetName='TestStringIsEmpty',HelpMessage='The string that will be handled.')]
        [AllowNull()][AllowEmptyString()]
        [System.String]$IsEmpty,

        [Parameter(Mandatory=$true,ParameterSetName='TestStringIsPopulated',HelpMessage='The string that will be handled.')]
        [AllowNull()][AllowEmptyString()]
        [System.String]$IsPopulated
    )

    begin {
        ####################################################################################################
        ### MAIN PROPERTIES ###

        # Function
        [System.String]$ParameterSetName    = $PSCmdlet.ParameterSetName

        # Input
        [System.String]$StringToTest        = if ($ParameterSetName -eq 'TestStringIsEmpty') { $IsEmpty } else { $IsPopulated }

        # Output
        [System.Boolean]$OutputObject       = $null

        ####################################################################################################
    }
    
    process {
        # If the String is empty then return true, else return false
        [System.Boolean]$StringIsEmpty = if ( [System.String]::IsNullOrWhiteSpace($StringToTest) ) { $true } else { $false }

        # Set the OutputObject based on the ParameterSetName
        $OutputObject = switch ($ParameterSetName) {
            'TestStringIsEmpty'     { $StringIsEmpty }
            'TestStringIsPopulated' { -Not($StringIsEmpty) }
        }
    }
    
    end {
        # Return the output
        $OutputObject
    }
}

### END OF SCRIPT
####################################################################################################

