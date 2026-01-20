####################################################################################################
<#
.SYNOPSIS
    This function ...
.DESCRIPTION
    This function is self-contained and does not refer to functions, variables or classes, that are in other files.
    This function is part of the Packaging Assistant. It contains references to classes, functions or variables, that are in other files.
    External classes    : -
    External functions  : -
    External variables  : $Global:ApplicationObject
.EXAMPLE
    Function-Template -Initialize
.EXAMPLE
    Function-Template -Write -PropertyName OutputFolder -PropertyValue 'C:\Demo\WorkFolder'
.EXAMPLE
    Function-Template -Read -PropertyName OutputFolder
.EXAMPLE
    Function-Template -Remove -PropertyName OutputFolder
.INPUTS
    [System.String]
    [System.Management.Automation.SwitchParameter]
.OUTPUTS
    [System.Boolean]
.NOTES
    Version         : 5.5.1
    Author          : Imraan Iotana
    Creation Date   : August 2025
    Last Update     : August 2025
#>
####################################################################################################

function Test-SCCMApplicationDeployment {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory=$true,HelpMessage='The ID of the application that will be handled.')]
        [Alias('Application','ApplicationName','Name')]
        [System.String]
        $ApplicationID,

        [Parameter(Mandatory=$true,HelpMessage='The subfolder of the application that must be retrieved.')]
        [System.String]
        $CollectionName,

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
        [System.String[]]$FunctionDetails   = @($MyInvocation.MyCommand,$PSCmdlet.ParameterSetName,$PSBoundParameters.GetEnumerator())
        # Output
        [System.Boolean]$OutputObject       = $null


        ####################################################################################################

        # Write the Begin message
        Write-Function -Begin $FunctionDetails
    }
    
    process {
        try {
            # Write the message
            Write-Line ('Checking if the Application ({0}) is deployed to the Collection ({1}). One moment please...' -f $ApplicationID,$CollectionName)
            # Switch to the SCCM Drive
            Invoke-SCCMConnectionAction -SwitchToDrive
            # Test the Install Deployment
            [System.Boolean]$DeploymentExists = (Get-CMApplicationDeployment -ApplicationName $ApplicationID).CollectionName -eq $CollectionName
            # Write the result to the host
            if ($OutHost) {
                if ($DeploymentExists) {
                    Write-Green ('The Application ({0}) is deployed to the Collection ({1}).' -f $ApplicationID,$CollectionName)
                } else {
                    Write-Yellow ('The Application ({0}) is NOT deployed to the Collection ({1}).' -f $ApplicationID,$CollectionName)
                }
            }
            # Switch back
            Invoke-SCCMConnectionAction -SwitchBack
            # Set the output
            $OutputObject = $DeploymentExists
        }
        catch {
            # Write the error
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
