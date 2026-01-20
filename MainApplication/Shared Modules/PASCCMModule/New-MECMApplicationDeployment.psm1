####################################################################################################
<#
.SYNOPSIS
    This function updates  the DistributionPoints of an application in SCCM.
.DESCRIPTION
    This function is part of the Packaging Assistant. It contains references to classes, functions or variables, that are in other files.
.EXAMPLE
    New-MECMApplicationDeployment -ApplicationID Vendor_Application_1.2.3
.INPUTS
    [System.String]
.OUTPUTS
    This function returns no stream-output.
.NOTES
    Version         : 5.5
    Author          : Imraan Iotana
    Creation Date   : July 2025
    Last Update     : August 2025
#>
####################################################################################################

function New-MECMApplicationDeployment {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory=$true,ValueFromPipeline=$true,HelpMessage='The ID of the application that will be handled.')]
        [Alias('Application','ApplicationName','Name')]
        [AllowEmptyString()]
        [System.String]
        $ApplicationID
    )
    
    begin {
        ####################################################################################################
        ### MAIN OBJECT ###

        [PSCustomObject]$Local:MainObject = @{
            # Function
            FunctionDetails     = [System.String[]]@($MyInvocation.MyCommand,$PSCmdlet.ParameterSetName,$PSBoundParameters.GetEnumerator())
            # Input
            ApplicationID       = $ApplicationID
            # Validation
            ValidationArray     = [System.Boolean[]]@()
            # Handlers
            CollectionName      = [System.String]($Global:ApplicationObject.Settings.SCCMTestVDICollection)
        }

        ####################################################################################################
        ### MAIN FUNCTION METHODS ###

        # Add the Begin method
        $Local:MainObject | Add-Member -MemberType ScriptMethod -Name Begin -Value { Write-Message -Begin $this.FunctionDetails }

        # Add the End method
        $Local:MainObject | Add-Member -MemberType ScriptMethod -Name End -Value { Write-Message -End $this.FunctionDetails }

        # Add the Process method
        $Local:MainObject | Add-Member -MemberType ScriptMethod -Name Process -Value {
            # Validate the input
            $this.ValidateInput()
            # If the validation failed, then return
            if ($this.ValidationArray -contains $false) { Write-Message -ValidationFailed ; Return }
            # Create the Deployment
            $this.CreateInstallDeployment($this.ApplicationID,$this.CollectionName)
        }

        ####################################################################################################
        ### VALIDATION METHODS ###

        # Add the ValidateInput method
        $Local:MainObject | Add-Member -MemberType ScriptMethod -Name ValidateInput -Value {
            $this.ValidationArray += Confirm-Object -MandatoryString $this.ApplicationID
        }

        ####################################################################################################
        ### MAIN PROCESSING METHODS ###

        # Add the CreateInstallDeployment method
        Add-Member -InputObject $Local:MainObject -MemberType ScriptMethod -Name CreateInstallDeployment -Value { param([System.String]$ApplicationID,[System.String]$CollectionName)
            try {
                # Switch to the SCCM Drive
                Invoke-SCCMConnectionAction -SwitchToDrive
                # Create the Install Deployment
                if (Test-SCCMApplicationDeployment -ApplicationID $ApplicationID -CollectionName $CollectionName -PassThru) {
                    Write-Green ('The Application ({0}) is already deployed to the Collection ({1}).' -f $ApplicationID,$CollectionName) ; Write-NoAction
                } else {
                    # Get confirmation
                    [System.Boolean]$UserConfirmed = Get-UserConfirmation -Title 'Confirm Deployment' -Body ("This will CREATE the DEPLOYMENT to the Test/Packaging VDI's for the application:`n`n{0}`n`nAre you sure?" -f $ApplicationID)
                    if ($UserConfirmed) {
                        # Write the message
                        Write-Busy ('Creating the Deployment. One moment please... ({0})' -f $ApplicationID)
                        New-CMApplicationDeployment -ApplicationName $ApplicationID -CollectionName $CollectionName -DeployAction Install -DeployPurpose Available -UserNotification DisplayAll -PersistOnWriteFilterDevice $false
                        Write-Success ('The Deployment to the Collection ({0}) has been created for application ({1}).' -f $CollectionName,$ApplicationID)
                    } else {
                        Write-NoAction
                    }
                }
                # Switch back
                Invoke-SCCMConnectionAction -SwitchBack
            }
            catch {
                # Write the error
                Write-FullError
            }
        }
        
        ####################################################################################################

        $Local:MainObject.Begin()
    }
    
    process {
        $Local:MainObject.Process()
    }
    
    end {
        $Local:MainObject.End()
    }
}

### END OF SCRIPT
####################################################################################################
