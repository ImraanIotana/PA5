####################################################################################################
<#
.SYNOPSIS
    This function creates a new SCCM Application.
.DESCRIPTION
    This function is part of the Packaging Assistant. It contains functions and variables that are in other files.
.EXAMPLE
    New-SCCMApplication -ApplicationID 'Adobe_Reader_12.4'
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

function New-SCCMApplication {
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
        #[System.String[]]$FunctionDetails   = @($MyInvocation.MyCommand,$PSCmdlet.ParameterSetName,$PSBoundParameters.GetEnumerator())
        #[System.String]$PreFix              = "[$($MyInvocation.MyCommand)]:"
        # Output
        #[System.Boolean]$OutputObject       = $null


        ####################################################################################################

        # Write the Begin message
        #Write-Function -Begin $FunctionDetails
    }
    
    process {
        # VALIDATION
        # Validate the properties
        if (Test-Object -IsEmpty $ApplicationID) { Write-Red "The Application ID is empty." -NoAction ; Return }
        [PSCustomObject]$ApplicationProperties = Get-ApplicationProperties -ApplicationID $ApplicationID
        #Write-Object $ApplicationProperties
        [System.String]$Publisher = $ApplicationProperties.VendorNameShort ; if (Test-StringIsEmpty $Publisher) { Write-Fail "The Publisher value is empty." ; Return }
        [System.String]$ApplicationName = $ApplicationProperties.ApplicationID ; if (Test-StringIsEmpty $ApplicationName) { Write-Fail "The ApplicationName value is empty." ; Return }
        [System.String]$SoftwareVersion = $ApplicationProperties.ApplicationVersionShort ; if (Test-StringIsEmpty $SoftwareVersion) { Write-Fail "The SoftwareVersion value is empty." ; Return }

        # Test if the SCCM Application exists
        if (Test-SCCMApplication -ApplicationID $ApplicationID -PassThru) {
            Write-Green "The SCCM Application already exists: ($ApplicationID)" -NoAction ; Return
        }

        # EXECUTION
        try {
            # Get confirmation
            [System.Boolean]$UserConfirmed = Get-UserConfirmation -Title "Confirm new SCCM Application" -Body "This will CREATE a NEW SCCM APPLICATION:`n`n$ApplicationID`n`nAre you sure?"
            if (-Not($UserConfirmed)) { Return }
            # Write the message
            Write-Busy "Creating a new SCCM Application. One moment please... ($ApplicationName)" -ApplicationID $ApplicationID
            # Create the Application
            Invoke-SCCMConnectionAction -SwitchToDrive
            New-CMApplication -Name $ApplicationName -Publisher $Publisher -SoftwareVersion $SoftwareVersion -Description $ApplicationID
            Invoke-SCCMConnectionAction -SwitchBack
            # Write the message
            Write-Success "The SCCM Application has been successfully created: ($ApplicationName)" -ApplicationID $ApplicationID
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
        #Write-Function -End $FunctionDetails
    }
}

### END OF SCRIPT
####################################################################################################
