####################################################################################################
<#
.SYNOPSIS
    This function writes the function details verbose.
.DESCRIPTION
    This function is part of the Packaging Assistant. It contains references to classes, functions or variables, that are in other files.
.EXAMPLE
    Write-Function -Begin -Details @($MyInvocation.MyCommand,$PSCmdlet.ParameterSetName,$PSBoundParameters.GetEnumerator())
.INPUTS
    [System.String[]]
.OUTPUTS
    This function returns no stream output.
.NOTES
    Version         : 5.5.1
    Author          : Imraan Iotana
    Creation Date   : August 2025
    Last Update     : August 2025
#>
####################################################################################################

function Write-Function {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory=$true,ParameterSetName='WriteFunctionBegin',HelpMessage='Switch for writing the Function Begin message')]
        [System.String[]]
        $Begin,

        [Parameter(Mandatory=$true,ParameterSetName='WriteFunctionEnd',HelpMessage='Switch for writing the Function End message')]
        [System.String[]]
        $End
    )

    begin {
        ####################################################################################################
        ### MAIN PROPERTIES ###

        # Set the details
        [System.String[]]$FunctionDetails = switch ($PSCmdlet.ParameterSetName) {
            'WriteFunctionBegin'    { $Begin }
            'WriteFunctionEnd'      { $End }
        }
        # Set the prefix
        [System.String]$MessagePreFix = switch ($PSCmdlet.ParameterSetName) {
            'WriteFunctionBegin'    { '*** BEGIN {0}' }
            'WriteFunctionEnd'      { '___ END {0}' }
        }
        # Handlers
        [System.String]$MessageCircumFix = 'Function: [{0}] ParameterSetName: [{1}] Arguments: {2}'
    }
    
    process {
        try {
            # Set the text
            [System.String]$MessageText = ($MessageCircumFix -f $FunctionDetails[0],$FunctionDetails[1],$FunctionDetails[2])
            # Write the message
            Write-Verbose ($MessagePreFix -f $MessageText)
        }
        catch {
            Write-FullError
        }
    }
    
    end {
    }
}

### END OF FUNCTION
####################################################################################################