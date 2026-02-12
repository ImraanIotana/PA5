####################################################################################################
<#
.SYNOPSIS
    This function updates the Content Location of an Application inside SCCM.
.DESCRIPTION
    This function is part of the Packaging Assistant. It contains functions and variables that are in other files.
.EXAMPLE
    Update-SCCMContentLocation -ApplicationID 'DemoVendor_DemoApplication_12.4'
.INPUTS
    [System.String]
.OUTPUTS
    This function returns no stream output.
.NOTES
    Version         : 5.5.1
    Author          : Imraan Iotana
    Creation Date   : September 2025
    Last Update     : October 2025
#>
####################################################################################################

function Update-SCCMContentLocation {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory=$true,HelpMessage='The ID of the application that will be handled.')]
        [System.String]
        $ApplicationID
    )

    begin {
        ####################################################################################################
        ### MAIN PROPERTIES ###

        # Function
        #[System.String[]]$FunctionDetails   = @($MyInvocation.MyCommand,$PSCmdlet.ParameterSetName,$PSBoundParameters.GetEnumerator())

        ####################################################################################################

        # Write the Begin message
        #Write-Function -Begin $FunctionDetails
    }
    
    process {
        # CONFIRMATION
        # Get confirmation
        [System.Boolean]$UserConfirmed = Get-UserConfirmation -Title "Confirm Audit" -Body "This will AUDIT the SCCM Content Location for the application:`n`n$ApplicationID`n`nAre you sure?"
        if (-Not($UserConfirmed)) { Return }

        # EXECUTION
        # Compare the locations
        if (Confirm-SCCMContentLocation -ApplicationID $ApplicationID -OutHost -PassThru) {
            Write-NoAction
        } else {
            try {
                # Get confirmation
                [System.Boolean]$UserConfirmed = Get-UserConfirmation -Title "Confirm correction SCCM Content Location" -Body "This will CORRECT the Content Location inside SCCM for the application:`n`n$ApplicationID`n`nAre you sure?"
                if (-Not($UserConfirmed)) { Return }
                # Get the Content Locations
                [System.String]$ContentLocationInSCCM = Get-SCCMContentLocation -ApplicationID $ApplicationID -FromSCCMInternal
                Write-Line "The Content Location inside SCCM is:`n$ContentLocationInSCCM"
                [System.String]$ContentLocationInRepository = Get-SCCMContentLocation -ApplicationID $ApplicationID -FromSCCMRepository
                Write-Line "The Content Location on the SCCM Repository is:`n$ContentLocationInRepository"
                # Update the DeploymentType
                Write-Busy "Updating the SCCM Content Location for the application ($ApplicationID). One moment please..." -ApplicationID $ApplicationID
                Invoke-SCCMConnectionAction -SwitchToDrive
                Set-CMScriptDeploymentType -ApplicationName $ApplicationID -DeploymentTypeName 'Install' -ContentLocation $ContentLocationInRepository
                Invoke-SCCMConnectionAction -SwitchBack
                # Confirm the change
                Write-Busy "Validating the change. One moment please..."
                if (Confirm-SCCMContentLocation -ApplicationID $ApplicationID -PassThru) {
                    Write-Success "The SCCM Content Location has been updated for the application ($ApplicationID)." -ApplicationID $ApplicationID
                    Write-Success '(The Distribution Points will be updated automatically. No extra action needed.)'
                } else {
                    Write-Fail "Something went wrong when updating the Content Location for the application ($ApplicationID)." -ApplicationID $ApplicationID
                }
            }
            catch {
                Invoke-SCCMConnectionAction -SwitchBack
                Write-FullError
            }
        }
    }
    
    end {
        # Write the End message
        #Write-Function -End $FunctionDetails
    }
}

### END OF SCRIPT
####################################################################################################
