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
    Version         : 5.7.0
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

        # Input
        [System.String]$StringToTest        = switch ($ParameterSetName) {
            'TestStringIsEmpty'             { $IsEmpty }
            'TestStringIsPopulated'         { $IsPopulated }
        }

        # Output
        [System.Boolean]$OutputObject       = $null

        # Handlers
        [System.String]$ParameterSetName    = $PSCmdlet.ParameterSetName

        ####################################################################################################
    }
    
    process {
        # If the String is empty then return true, else return false
        [System.Boolean]$StringIsEmpty = if ( ([System.String]::IsNullOrWhiteSpace($StringToTest)) -or ([System.String]::IsNullOrEmpty($StringToTest)) ) { $true } else { $false }

        # Switch on the ParameterSetName
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

