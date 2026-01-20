####################################################################################################
<#
.SYNOPSIS
    This function exports the AppLocker policy to an XMl file.
.DESCRIPTION
    This function is part of the Packaging Assistant. It contains references to classes, functions or variables, that are in other files.
.EXAMPLE
    Export-AppLockerPolicy
.INPUTS
    [System.String]
.OUTPUTS
    [System.String]
.NOTES
    Version         : 5.5.1
    Author          : Imraan Iotana
    Creation Date   : August 2025
    Last Update     : August 2025
#>
####################################################################################################

function Export-AppLockerPolicy {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory=$false,HelpMessage='The LDAP of the AppLocker policy that will be handled.')]
        [Alias('LDAP')]
        [System.String]
        $AppLockerLDAP = (Get-Path -AppLockerLDAPTEST),

        [Parameter(Mandatory=$false,HelpMessage='The folder where the output will be placed.')]
        [System.String]
        $OutputFolder = (Get-Path -OutputFolder),

        [Parameter(Mandatory=$false,HelpMessage='Switch for returning the result.')]
        [System.Management.Automation.SwitchParameter]
        $PassThru
    )
    
    begin {
        ####################################################################################################
        ### MAIN PROPERTIES ###

        # Function
        [System.String[]]$FunctionDetails = @($MyInvocation.MyCommand,$PSCmdlet.ParameterSetName,$PSBoundParameters.GetEnumerator())
        # Handlers
        [System.String]$ExportFileNameCircumFix = 'AppLockerPolicy_Export_{0}.xml'
        [System.String]$TimeStamp = (Get-TimeStamp -Universal)

        ####################################################################################################

        # Write the begin message
        Write-Function -Begin $FunctionDetails
    }
    
    process {
        try {
            # Get confirmation
            [System.Boolean]$UserHasConfirmed = Get-UserConfirmation -Title 'Export Policy' -Body ("This will export the AppLocker Policy to an XML file.`n`nDo you want to continue?")
            if (-Not($UserHasConfirmed)) { Return }
            # Set the properties
            [System.String]$OutputFileName = ($ExportFileNameCircumFix -f $TimeStamp)
            [System.String]$OutputFilePath = Join-Path -Path $OutputFolder -ChildPath $OutputFileName
            # Export the AppLocker policy as xml
            Get-AppLockerPolicy -Domain -Ldap $AppLockerLDAP -Xml | Set-Content $OutputFilePath
            Open-Folder -Folder $OutputFolder
        }
        catch {
            Write-FullError
        }
    }
    
    end {
        # Write the end message
        Write-Function -End $FunctionDetails
        # Return the output
        if ($PassThru) { $OutputFilePath }
    }
}

### END OF FUNCTION
####################################################################################################
