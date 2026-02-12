####################################################################################################
<#
.SYNOPSIS
    This function checks if the logfile of an application exists. And creates it, if it doesn't exist.
.DESCRIPTION
    This function is part of the Packaging Assistant. It contains functions and variables that are in other files.
.EXAMPLE
    Confirm-LogFileExistence -ApplicationID 'Adobe_Reader_12.4'
.INPUTS
    [System.String]
    [System.Management.Automation.SwitchParameter]
.OUTPUTS
    [System.Boolean]
.NOTES
    Version         : 5.5.1
    Author          : Imraan Iotana
    Creation Date   : September 2025
    Last Update     : October 2025
.COPYRIGHT
    Copyright (C) Iotana. All rights reserved.
#>
####################################################################################################

function Confirm-LogFileExistence {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory=$true,HelpMessage='The ID of the application that will be handled.')]
        [Alias('Application','ApplicationName','Name')]
        [AllowNull()][AllowEmptyString()]
        [System.String]
        $ApplicationID,

        [Parameter(Mandatory=$false,HelpMessage='The name of the Audit that will be performed.')]
        [AllowNull()][AllowEmptyString()]
        [System.String]
        $AuditName,

        [Parameter(Mandatory=$false,HelpMessage='Switch for returning the result as a boolean.')]
        [System.Management.Automation.SwitchParameter]
        $PassThru
    )

    begin {
        ####################################################################################################
        ### MAIN PROPERTIES ###

        # Function
        [System.String]$PreFix          = "[$($MyInvocation.MyCommand)]:"
        # Output
        [System.Boolean]$OutputObject   = $null

        ####################################################################################################
    }
    
    process {
        # VALIDATION
        # Validate the properties
        if (Test-Object -IsEmpty $ApplicationID) { Write-Red "$PreFix The Application ID is empty." -NoAction ; Return }
        [System.String]$ApplicationLogFilePath = Get-Path -ApplicationID $ApplicationID -LogFilePath
        if (Test-Object -IsEmpty $ApplicationLogFilePath) {
            Write-Red "$PreFix The LogFilePath String for the Application ($ApplicationID) could not be obtained." -NoAction ; Return
        }

        # EXECUTION
        Write-Line "Performing Audit: [$AuditName] on Application [$ApplicationID]"
        if (Test-Path -Path $ApplicationLogFilePath) {
            Write-Green "Audit Result: The Application ($ApplicationID) has a LogFile."
            Write-Green "The path of the LogFile is: ($ApplicationLogFilePath)"
            $OutputObject = $true
            Return
        }

        # CONFIRMATION
        Write-Red "Audit Result: The Application ($ApplicationID) does NOT have a LogFile."
        # Get confirmation
        [System.Boolean]$UserConfirmedCorrection = Get-UserConfirmation -Title 'Confirm Correction' -Body "This will CREATE a new Logfile for the application:`n`n$ApplicationID`n`nAre you sure?"
        if (-Not($UserConfirmedCorrection)) { Return }

        # CORRECTION
        # Create the logfile by creating the first line
        Write-Success "Created the initial Logfile for the application $ApplicationID" -ApplicationID $ApplicationID
        $OutputObject = $true
    }
    
    end {
        # TESTING
        #Open-Folder (Split-Path -Path $ApplicationLogFilePath -Parent)
        #Invoke-Item -Path $ApplicationLogFilePath
        # Return the output
        if ($PassThru) { $OutputObject }
    }
}

### END OF SCRIPT
####################################################################################################
