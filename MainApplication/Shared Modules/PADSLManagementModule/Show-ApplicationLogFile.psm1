####################################################################################################
<#
.SYNOPSIS
    This function show the Logfile of the Application.
.DESCRIPTION
    This function is part of the Packaging Assistant. It contains functions and variables that are in other files.
.EXAMPLE
    Show-ApplicationLogFile -ApplicationID 'Adobe_Reader_12.4'
.INPUTS
    [System.String]
.OUTPUTS
    This function returns no stream output.
.NOTES
    Version         : 5.5.1
    Author          : Imraan Iotana
    Creation Date   : September 2025
    Last Update     : September 2025
.COPYRIGHT
    Copyright (C) Iotana. All rights reserved.
#>
####################################################################################################

function Show-ApplicationLogFile {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory=$true,HelpMessage='The ID of the application that will be handled.')]
        [Alias('Application','ApplicationName','Name')]
        [AllowNull()][AllowEmptyString()]
        [System.String]
        $ApplicationID
    )

    begin {
        ####################################################################################################
        ### MAIN PROPERTIES ###

        # Function
        [System.String]$PreFix                  = "[$($MyInvocation.MyCommand)]:"
    }
    
    process {
        # VALIDATION
        # Validate the ApplicationID
        if (Test-Object -IsEmpty $ApplicationID) { Write-Red "The Application ID is empty." -NoAction ; Return }
        # Validate the ApplicationLogFilePath string
        [System.String]$ApplicationLogFilePath = Get-Path -ApplicationID $ApplicationID -LogFilePath
        if (Test-Object -IsEmpty $ApplicationLogFilePath) {
            Write-Red "$PreFix The LogFilePath String could not be obtained for the Application ($ApplicationID)." -NoAction ; Return
        }
        # Validate the logfile's existence
        if (-Not(Test-Path -Path $ApplicationLogFilePath)) {
            Write-Red "The logfile of the Application ($ApplicationID) could not be found.`n(Expected location: $ApplicationLogFilePath)" -NoAction ; Return
        }

        # EXECUTION
        Import-Csv -Path $ApplicationLogFilePath | Out-GridView -Title "Application Log of the application: $ApplicationID"
    }
    
    end {
    }
}

### END OF SCRIPT
####################################################################################################
