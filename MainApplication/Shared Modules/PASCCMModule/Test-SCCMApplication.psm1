####################################################################################################
<#
.SYNOPSIS
    This function tests if an SCCM Application exists.
.DESCRIPTION
    This function is part of the Packaging Assistant. It contains references to classes, functions or variables, that are in other files.
.EXAMPLE
    Test-SCCMApplication -ApplicationID 'Adobe_Reader_12.4' -PassThru
.EXAMPLE
    Test-SCCMApplication -ApplicationID 'Adobe_Reader_12.4' -OutHost
.INPUTS
    [System.String]
    [System.Management.Automation.SwitchParameter]
.OUTPUTS
    [System.Boolean]
.NOTES
    Version         : 5.5.1
    Author          : Imraan Iotana
    Creation Date   : September 2025
    Last Update     : September 2025
.COPYRIGHT
    Copyright (C) Iotana. All rights reserved.
#>
####################################################################################################

function Test-SCCMApplication {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory=$true,HelpMessage='The ID of the application that will be handled.')]
        [Alias('Application','ApplicationName','Name')]
        [AllowNull()][AllowEmptyString()]
        [System.String]
        $ApplicationID,

        [Parameter(Mandatory=$false,HelpMessage='Switch for showing the details in the host.')]
        [System.Management.Automation.SwitchParameter]
        $OutHost,

        [Parameter(Mandatory=$false,HelpMessage='Switch for returning the result as a boolean.')]
        [System.Management.Automation.SwitchParameter]
        $PassThru
    )

    begin {
        ####################################################################################################
        ### MAIN PROPERTIES ###

        # Function
        #[System.String[]]$FunctionDetails   = @($MyInvocation.MyCommand,$PSCmdlet.ParameterSetName,$PSBoundParameters.GetEnumerator())
        [System.String]$PreFix              = "[$($MyInvocation.MyCommand)]:"
        # Output
        [System.Boolean]$OutputObject       = $null

        ####################################################################################################

        # Write the Begin message
        #Write-Function -Begin $FunctionDetails
    }
    
    process {
        # VALIDATION
        # Validate the properties
        if (Test-Object -IsEmpty $ApplicationID) { Write-Red "The Application ID is empty." -NoAction ; Return }
  
        # EXECUTION
        $OutputObject = try {
            # Check the SCCM Application
            if ($OutHost) { Write-Line "Testing if the SCCM Application exists: ($ApplicationID)" }
            Invoke-SCCMConnectionAction -SwitchToDrive
            [Microsoft.ConfigurationManagement.ManagementProvider.WqlQueryEngine.WqlResultObject[]]$SCCMApplicationObjects = Get-CMApplication -Name $ApplicationID -Fast
            Invoke-SCCMConnectionAction -SwitchBack
            if ($SCCMApplicationObjects) {
                # Write the message and return true
                if ($OutHost) { Write-Green "The SCCM Application exists: ($ApplicationID)" }
                $true
            } else {
                # Write the message and return false
                if ($OutHost) { Write-Yellow "The SCCM Application does NOT exist: ($ApplicationID)" }
                $false
            }
        }
        catch [System.Management.Automation.CommandNotFoundException] {
            # Write the error and return false
            Write-Red "$PreFix The SCCM PowerShell Module is not installed."
            $false
        }
        catch [System.InvalidOperationException] {
            # Write the error and return false
            Write-Red "$PreFix You are not connected to the SCCM Drive."
            $false
        }
        catch {
            # Write the error and return false
            Write-FullError
            $false
        }
    }
    
    end {
        # Write the End message
        #Write-Function -End $FunctionDetails
        # Return the output
        if ($PassThru) { $OutputObject }
    }
}

### END OF SCRIPT
####################################################################################################
