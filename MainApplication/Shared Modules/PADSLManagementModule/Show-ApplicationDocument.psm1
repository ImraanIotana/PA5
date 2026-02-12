####################################################################################################
<#
.SYNOPSIS
    This function show the Word Document of the Application.
.DESCRIPTION
    This function is part of the Packaging Assistant. It contains functions and variables that are in other files.
.EXAMPLE
    Show-ApplicationDocument -ApplicationID 'Adobe_Reader_12.4'
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

function Show-ApplicationDocument {
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
        # Validate the WordDocumentFilePath string
        [System.String]$WordDocumentFilePath = Get-Path -ApplicationID $ApplicationID -WordDocumentPath
        if (Test-Object -IsEmpty $WordDocumentFilePath) {
            Write-Red "$PreFix The WordDocumentFilePath String could not be obtained for the Application ($ApplicationID)." -NoAction ; Return
        }
        # Validate the Document's existence
        if (-Not(Test-Path -Path $WordDocumentFilePath)) {
            Write-Red "The Word Document of the Application ($ApplicationID) could not be found.`n(Expected location: $WordDocumentFilePath)" -NoAction ; Return
        }

        # CONFIRMATION
        # Get confirmation
        [System.Boolean]$UserHasConfirmed = Get-UserConfirmation -Title "Confirm Open Document" -Body "This will open the Package Document of the application`n`n$ApplicationID`n`nWould you like to continue?"
        if (-Not($UserHasConfirmed)) { Return }

        # EXECUTION
        Invoke-Item -Path $WordDocumentFilePath
    }
    
    end {
    }
}

### END OF SCRIPT
####################################################################################################
