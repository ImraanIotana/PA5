####################################################################################################
<#
.SYNOPSIS
    This function imports the ConfigurationManager.psd1 module.
.DESCRIPTION
    This function is part of the Packaging Assistant. It contains references to classes, functions or variables, that are in other files.
.EXAMPLE
    Import-SCCMPowerShellModule
.INPUTS
    [System.Management.Automation.SwitchParameter]
.OUTPUTS
    This function returns no stream output.
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

function Import-SCCMPowerShellModule {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory=$false,HelpMessage='Switch for showing the details in the host.')]
        [System.Management.Automation.SwitchParameter]
        $OutHost,

        [Parameter(Mandatory=$false,HelpMessage='Switch for skipping the confirmations.')]
        [System.Management.Automation.SwitchParameter]
        $Force,

        [Parameter(Mandatory=$false,HelpMessage='Switch for returning the result as a boolean.')]
        [System.Management.Automation.SwitchParameter]
        $PassThru
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
        ### SUPPORTING FUNCTIONS ###

        function Test-SCCMPowerShellModuleInternal {
            if ((Get-Module -Name ConfigurationManager) -eq $null) { $false } else { $true }
        }
        ####################################################################################################

        # Write the Begin message
        #Write-Function -Begin $FunctionDetails
    }
    
    process {
        try {
            # Check if the module is imported
            if (Test-SCCMPowerShellModuleInternal) {
                if ($OutHost) { Write-Green "The SCCM Module is already installed." }
                $OutputObject = $true
            } else {
                # Import the ConfigurationManager.psd1 module
                if ($OutHost) { Write-Busy "The SCCM PowerShell Module is not installed. Importing it now. One moment please..." }
                Import-Module "$($ENV:SMS_ADMIN_UI_PATH)\..\ConfigurationManager.psd1"
                # Check if the module is imported
                if (Test-SCCMPowerShellModuleInternal) {
                    # Return true
                    if ($OutHost) { Write-Green "The SCCM Module has been imported." }
                    $OutputObject = $true
                }
                else {
                    # Return false
                    if ($OutHost) { Write-Red "The SCCM Module has NOT been imported." }
                    $OutputObject = $false
                }
            }
        }
        catch {
            Write-FullError
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
