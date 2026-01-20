####################################################################################################
<#
.SYNOPSIS
    This function removes an SCCM Application.
.DESCRIPTION
    This function is part of the Packaging Assistant. It contains references to classes, functions or variables, that are in other files.
.EXAMPLE
    Remove-SCCMApplication -ApplicationID 'Adobe_Reader_12.4'
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

function Remove-SCCMApplication {
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
        [System.String[]]$FunctionDetails   = @($MyInvocation.MyCommand,$PSCmdlet.ParameterSetName,$PSBoundParameters.GetEnumerator())
        [System.String]$PreFix              = "[$($MyInvocation.MyCommand)]:"
        # Output
        [System.Boolean]$OutputObject       = $null


        ####################################################################################################

        # Write the Begin message
        Write-Function -Begin $FunctionDetails
    }
    
    process {
        # VALIDATION
        # Validate the properties
        if (Test-Object -IsEmpty $ApplicationID) { Write-Red "The Application ID is empty." -NoAction ; Return }

        # Test if the SCCM Application exists
        if (-Not(Test-SCCMApplication -ApplicationID $ApplicationID -PassThru)) {
            Write-Green "The SCCM Application does not exist: ($ApplicationID)" -NoAction ; Return
        }

        # EXECUTION
        try {
            # Get confirmation
            [System.Boolean]$UserConfirmed = Get-UserConfirmation -Title "Confirm Removal" -Body "This will REMOVE the SCCM Application:`n`n$ApplicationID`n`nAre you sure?"
            if (-Not($UserConfirmed)) { Return }
            # Write the message
            Write-Busy "Removing the SCCM Application. One moment please... ($ApplicationID)" -ApplicationID $ApplicationID
            # Create the Application
            Invoke-SCCMConnectionAction -SwitchToDrive
            Remove-CMApplication -Name $ApplicationID -Force
            Invoke-SCCMConnectionAction -SwitchBack
            # Write the message
            Write-Success "The SCCM Application has been successfully removed: ($ApplicationID)" -ApplicationID $ApplicationID
        }
        catch [System.Management.Automation.CommandNotFoundException] {
            Write-Fail "The SCCM/MECM PowerShell Module is not installed." -ApplicationID $ApplicationID
        }
        catch [System.InvalidOperationException] {
            Write-Fail "You are not connected to the SCCM/MECM Drive. Or the location you are trying to reach does not exist." -ApplicationID $ApplicationID
        }
        catch {
            Write-FullError
        }
    }
    
    end {
        # Write the End message
        Write-Function -End $FunctionDetails
    }
}

### END OF SCRIPT
####################################################################################################
