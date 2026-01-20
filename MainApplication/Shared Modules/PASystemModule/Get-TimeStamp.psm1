####################################################################################################
<#
.SYNOPSIS
    This function generates a timestamp in different handy formats.
.DESCRIPTION
    This function is part of the Packaging Assistant. It contains references to classes, functions or variables, that are in other files.
.EXAMPLE
    Get-TimeStamp -ForLogging
.INPUTS
    [System.Management.Automation.SwitchParameter]
.OUTPUTS
    [System.String]
.NOTES
    Version         : 5.5.1
    Author          : Imraan Iotana
    Creation Date   : July 2025
    Last Update     : August 2025
#>
####################################################################################################

function Get-TimeStamp {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory=$true,ParameterSetName='TimeStampForLogging',HelpMessage='Switch for creating a timestamp in the following format: 2025-07-15 13:22')]
        [System.Management.Automation.SwitchParameter]
        $ForLogging,

        [Parameter(Mandatory=$true,ParameterSetName='TimeStampForFileName',HelpMessage='Switch for creating a timestamp in the following format: 202507151322')]
        [System.Management.Automation.SwitchParameter]
        $ForFileName,

        [Parameter(Mandatory=$true,ParameterSetName='TimeStampForBackups',HelpMessage='Switch for creating a timestamp in the following format: 20250715_1322')]
        [System.Management.Automation.SwitchParameter]
        $ForBackups,

        [Parameter(Mandatory=$true,ParameterSetName='TimeStampForUniversalTime',HelpMessage='Switch for creating a timestamp in the following format: 20250715_132236_UTC')]
        [System.Management.Automation.SwitchParameter]
        $Universal,

        [Parameter(Mandatory=$true,ParameterSetName='TimeStampForMetadata',HelpMessage='Switch for creating a timestamp in the following format: 2025-07-15_13:22')]
        [System.Management.Automation.SwitchParameter]
        $ForMetadata
    )
    
    begin {
        ####################################################################################################
        ### MAIN PROPERTIES ###

        # Function
        [System.String[]]$FunctionDetails   = @($MyInvocation.MyCommand,$PSCmdlet.ParameterSetName,$PSBoundParameters.GetEnumerator())

        ####################################################################################################

        # Write the begin message
        Write-Function -Begin $FunctionDetails
    }
    
    process {
        # Switch on the ParameterSetName
        [System.String]$OutputObject = switch ($PSCmdlet.ParameterSetName) {
            'TimeStampForLogging'       { Get-Date -Format 'yyyy-MM-dd hh:mm' }
            'TimeStampForFileName'      { Get-Date -Format 'yyyyMMddhhmm' }
            'TimeStampForBackups'       { (Get-Date).ToUniversalTime().ToString('yyyyMMdd_HHmmss_UTC') }
            'TimeStampForUniversalTime' { (Get-Date).ToUniversalTime().ToString('yyyyMMdd_HHmmss_UTC') }
            #'TimeStampForBackups'      { Get-Date -Format "yyyyMMdd_HHmmss" }
            'TimeStampForMetadata'      { (Get-Date).ToUniversalTime().ToString('o') }
            default                     { Get-Date }
        }
    }
    
    end {
        # Write the end message
        Write-Function -End $FunctionDetails
        # Return the output
        $OutputObject
    }
}

### END OF FUNCTION
####################################################################################################
