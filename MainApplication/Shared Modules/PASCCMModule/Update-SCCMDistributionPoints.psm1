####################################################################################################
<#
.SYNOPSIS
    This function updates the DistributionPoints of an SCCM Application.
.DESCRIPTION
    This function is part of the Packaging Assistant. It contains functions and variables that are in other files.
.EXAMPLE
    Update-SCCMDistributionPoints -ApplicationID Adobe_Reader_12.4
.INPUTS
    [System.String]
.OUTPUTS
    This function returns no stream output.
.NOTES
    Version         : 5.5
    Author          : Imraan Iotana
    Creation Date   : July 2025
    Last Update     : September 2025
#>
####################################################################################################

function Update-SCCMDistributionPoints {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory=$true,HelpMessage='The ID of the application that will be handled.')]
        [AllowEmptyString()]
        [System.String]
        $ApplicationID
    )
    
    begin {
        ####################################################################################################
        ### MAIN OBJECT ###

        [PSCustomObject]$Local:MainObject = @{
            # Function
            #FunctionDetails     = [System.String[]]@($MyInvocation.MyCommand,$PSCmdlet.ParameterSetName,$PSBoundParameters.GetEnumerator())
            # Input
            ApplicationID       = $ApplicationID
            # Validation
            ValidationArray     = [System.Boolean[]]@()
            # Confirmation Handlers
            ConfirmationTitle   = [System.String]'Confirm Update SCCM Distribution Points'
            ConfirmationBody    = [System.String]"This will UPDATE the SCCM DISTRIBUTION POINTS of the application:`n`n{0}`n`nAre you sure?"
            # Message Handlers
            MessageUpdating     = [System.String]'Updating the DistributionPoints for the application ({0}). One moment please...'
            MessageUpdated      = [System.String]'The DistributionPoints have been updated for the application: ({0})'
        }

        ####################################################################################################
        ### MAIN FUNCTION METHODS ###

        # Add the Begin method
        #$Local:MainObject | Add-Member -MemberType ScriptMethod -Name Begin -Value { Write-Message -Begin $this.FunctionDetails }

        # Add the End method
        #$Local:MainObject | Add-Member -MemberType ScriptMethod -Name End -Value { Write-Message -End $this.FunctionDetails }

        # Add the Process method
        $Local:MainObject | Add-Member -MemberType ScriptMethod -Name Process -Value {
            # Get user confirmation
            [System.Boolean]$UserHasConfirmed = Get-UserConfirmation -Title $this.ConfirmationTitle -Body ($this.ConfirmationBody -f $ApplicationID)
            if (-Not($UserHasConfirmed)) { Return }
            # Validate the input
            $this.ValidateInput()
            # If the validation failed, then return
            if ($this.ValidationArray -contains $false) { Write-Message -ValidationFailed ; Return }
            # Update the Distribution Points
            $this.UpdateDistributionPoints($this.ApplicationID)
        }

        ####################################################################################################
        ### VALIDATION METHODS ###

        # Add the ValidateInput method
        $Local:MainObject | Add-Member -MemberType ScriptMethod -Name ValidateInput -Value {
            $this.ValidationArray += Confirm-Object -MandatoryString $this.ApplicationID
        }

        ####################################################################################################
        ### MAIN PROCESSING METHODS ###

        # Add the UpdateDistributionPoints method
        $Local:MainObject | Add-Member -MemberType ScriptMethod -Name UpdateDistributionPoints -Value { param([System.String]$ApplicationID)
            try {
                # Switch to the SCCM Drive
                Invoke-SCCMConnectionAction -SwitchToDrive
                # Get the SCCM Application
                [Microsoft.ConfigurationManagement.ManagementProvider.WqlQueryEngine.WqlResultObject]$SCCMApplicationObject = Get-SCCMApplication -ApplicationID $ApplicationID
                [System.String]$LocalizedDisplayName = $SCCMApplicationObject.LocalizedDisplayName
                Invoke-SCCMConnectionAction -SwitchBack
                # Update the DP's
                Write-Busy "Updating the DistributionPoints for the application ($LocalizedDisplayName). One moment please..." -ApplicationID $ApplicationID
                Invoke-SCCMConnectionAction -SwitchToDrive
                Update-CMDistributionPoint -ApplicationName $LocalizedDisplayName -DeploymentTypeName Install
                Invoke-SCCMConnectionAction -SwitchBack
                Write-Success "The DistributionPoints have been updated for the application ($LocalizedDisplayName)." -ApplicationID $ApplicationID
            }
            catch [System.Management.Automation.ParameterBindingException] {
                Invoke-SCCMConnectionAction -SwitchBack
                Write-Fail "An error has occured (ParameterBindingException). Please check if the Deployment Type 'Install' exist. ($ApplicationID)" -ApplicationID $ApplicationID
                #Write-FullError
            }
            catch [System.ArgumentException] {
                Invoke-SCCMConnectionAction -SwitchBack
                Write-Fail "An error has occured (ArgumentException). Please check if the Deployment Type 'Install' exist. ($ApplicationID)" -ApplicationID $ApplicationID
                #Write-FullError
            }
            catch {
                Invoke-SCCMConnectionAction -SwitchBack
                Write-Fail "An unknown error has occured." -ApplicationID $ApplicationID
                Write-FullError
            }
        }
        
        ####################################################################################################

        #$Local:MainObject.Begin()
    }
    
    process {
        $Local:MainObject.Process()
    }
    
    end {
        #$Local:MainObject.End()
    }
}

### END OF SCRIPT
####################################################################################################
