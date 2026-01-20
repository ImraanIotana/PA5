####################################################################################################
<#
.SYNOPSIS
    This function writes the details of an SCCM Application to the host.
.DESCRIPTION
    This function is part of the Packaging Assistant. It contains references to classes, functions or variables, that are in other files.
.EXAMPLE
    Write-SCCMApplicationToHost -SCCMApplicationObject $MySCCMApplicationObject
.INPUTS
    [Microsoft.ConfigurationManagement.ManagementProvider.WqlQueryEngine.WqlResultObject[]]
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

function Write-SCCMApplicationToHost {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory=$true,HelpMessage='The SCCM Application Object that will be handled.')]
        [AllowNull()]
        [Microsoft.ConfigurationManagement.ManagementProvider.WqlQueryEngine.WqlResultObject[]]
        $SCCMApplicationObject
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
        # VALIDATION
        if ($null -eq $SCCMApplicationObject) { Write-Red 'The SCCM Application object is $null.' ; Write-NoAction ; Return }

        # EXECUTION
        $SCCMApplicationObject | ForEach-Object {
            Write-Green "Full Name`t: $($_.LocalizedDisplayName)"
            Write-Host "Manufacturer`t: $($_.Manufacturer)"
            Write-Host "Version`t`t: $($_.SoftwareVersion)"
            Write-Host "Created by`t: $($_.CreatedBy)"
            Write-Host "Created on`t: $($_.DateCreated)"
            Write-Host "Last updated by`t: $($_.LastModifiedBy)"
            Write-Host "Last updated on`t: $($_.DateLastmodified)"
            Write-Host "Revision`t: $($_.CIVersion)"
            Write-Host "CI_UniqueID`t: $($_.CI_UniqueID)"
            Write-Host "Comment`t`t: $($_.LocalizedDescription)`n"
        }

        # TESTING
        #$SCCMApplicationObject | Select-Object * | Out-Host | Format-List
    }
    
    end {
        # Write the End message
        Write-Function -End $FunctionDetails
    }
}

### END OF SCRIPT
####################################################################################################
