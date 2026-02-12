####################################################################################################
<#
.SYNOPSIS
    This function removes the Deployment of an Application in SCCM.
.DESCRIPTION
    This function is part of the Packaging Assistant. It contains functions and variables that are in other files.
.EXAMPLE
    Remove-MECMApplicationDeployment -ApplicationID 'Adobe_Reader_12.3' -CollectionName 'TestComputers'
.INPUTS
    [System.String]
.OUTPUTS
    This function returns no stream-output.
.NOTES
    Version         : 5.5.1
    Author          : Imraan Iotana
    Creation Date   : July 2025
    Last Update     : August 2025
#>
####################################################################################################

function Remove-MECMApplicationDeployment {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory=$true,HelpMessage='The ID of the application that will be handled.')]
        [Alias('Application','ApplicationName','Name')]
        [System.String]
        $ApplicationID,

        [Parameter(Mandatory=$false,HelpMessage='The name of the Collection that will be handled.')]
        [System.String]
        $CollectionName = $Global:ApplicationObject.Settings.SCCMTestVDICollection
    )
    
    begin {
        ####################################################################################################
        ### MAIN PROPERTIES ###

        # Function
        [System.String[]]$FunctionDetails   = @($MyInvocation.MyCommand,$PSCmdlet.ParameterSetName,$PSBoundParameters.GetEnumerator())

        ####################################################################################################

        # Write the Begin message
        Write-Function -Begin $FunctionDetails
    }
    
    process {
        # If the deployment does not exist, return
        if (-Not(Test-SCCMApplicationDeployment -ApplicationID $ApplicationID -CollectionName $CollectionName -PassThru)) {
            Write-Green ('The Application ({0}) is not deployed to the Collection ({1}).' -f $ApplicationID,$CollectionName)
            Write-NoAction ; Return
        }
        # Get user confirmation
        [System.Boolean]$UserHasConfirmed = Get-UserConfirmation -Title 'Confirm removal of Deployment' -Body ("This will REMOVE the DEPLOYMENT to the Test/Packaging VDI's for the application:`n`n{0}`n`nAre you sure?" -f $ApplicationID)
        if (-Not($UserHasConfirmed)) { Return }
        # Remove the Application Deployment
        try {
            Write-Busy ('Removing the Deployment for the Application ({0}). One moment please...' -f $ApplicationID)
            Invoke-SCCMConnectionAction -SwitchToDrive
            Remove-CMApplicationDeployment -ApplicationName $ApplicationID -CollectionName $CollectionName -Force
            Invoke-SCCMConnectionAction -SwitchBack
            Write-Success ('The Deployment has been removed for the Application ({0}).' -f $ApplicationID)
        }
        catch [System.InvalidOperationException] {
            # Write the message
            Write-Line ('The Application ({0}) has no Deployment to a Collection named ({1}).' -f $ApplicationID,$CollectionName)
        }
        catch {
            # Write the error
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
