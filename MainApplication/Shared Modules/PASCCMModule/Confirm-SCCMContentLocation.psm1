####################################################################################################
<#
.SYNOPSIS
    This function checks the Content Location of an SCCM Application.
.DESCRIPTION
    This function is part of the Packaging Assistant. It contains references to classes, functions or variables, that are in other files.
.EXAMPLE
    Get-SCCMContentLocation -ApplicationID 'DemoVendor_DemoApplication_12.4'
.INPUTS
    [System.String]
.OUTPUTS
    [System.String]
.NOTES
    Version         : 5.5.1
    Author          : Imraan Iotana
    Creation Date   : September 2025
    Last Update     : September 2025
#>
####################################################################################################

function Confirm-SCCMContentLocation {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory=$true,HelpMessage='The ID of the application that will be handled.')]
        [Alias('Application','ApplicationName','Name')]
        [System.String]
        $ApplicationID,

        [Parameter(Mandatory=$false,HelpMessage='Switch for writing the details to the host.')]
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
        [System.String[]]$FunctionDetails   = @($MyInvocation.MyCommand,$PSCmdlet.ParameterSetName,$PSBoundParameters.GetEnumerator())
        # Output
        [System.Boolean]$OutputObject       = $null


        ####################################################################################################

        # Write the Begin message
        Write-Function -Begin $FunctionDetails
    }
    
    process {
        try {
            # Get both locations
            if ($OutHost) { Write-Line "Comparing the two values of the Content Location. One moment please...`n" }
            [System.String]$ContentLocationInSCCM = Get-SCCMContentLocation -ApplicationID $ApplicationID -FromSCCMInternal
            if ($OutHost) { Write-Line "The Content Location inside SCCM is:" ; Write-Host $ContentLocationInSCCM }
            [System.String]$ContentLocationInRepository = Get-SCCMContentLocation -ApplicationID $ApplicationID -FromSCCMRepository
            if ($OutHost) { Write-Line "The Content Location on the SCCM Repository is:" ; Write-Host $ContentLocationInRepository }
            # Compare them
            $OutputObject = if ($ContentLocationInSCCM -eq $ContentLocationInRepository) {
                if ($OutHost) { Write-Green "`nThe Content Location in SCCM is the same as on the Repository." }
                $true
            } else {
                if ($OutHost) { Write-Red "`nThe Content Location in SCCM is NOT the same as on the Repository." }
                $false
            }
        }
        catch {
            Write-FullError
        }
    }
    
    end {
        # Write the End message
        Write-Function -End $FunctionDetails
        # Return the output
        if ($PassThru) { $OutputObject }
    }
}

### END OF SCRIPT
####################################################################################################
