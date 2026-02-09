####################################################################################################
<#
.SYNOPSIS
    This function test if an AppLocker policy exists based in the Application ID.
.DESCRIPTION
    This function is part of the Packaging Assistant. It contains references to classes, functions or variables, that are in other files.
.EXAMPLE
    Add-AppLockerPolicy -ApplicationID 'Adobe_Reader_12.4'
.INPUTS
    [System.String]
.OUTPUTS
    This function returns no stream output.
.NOTES
    Version         : 5.5.1
    Author          : Imraan Iotana
    Creation Date   : August 2025
    Last Update     : September 2025
#>
####################################################################################################

function Add-AppLockerPolicy {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory=$true,ValueFromPipeline=$true,HelpMessage='The ID of the application that will be handled.')]
        [Alias('Application','ApplicationName','Name')]
        [System.String]
        $ApplicationID,

        [Parameter(Mandatory=$false,ValueFromPipeline=$true,HelpMessage='The LDAP of the AppLocker policy that will be queried.')]
        [Alias('LDAP')]
        [System.String]
        $AppLockerLDAP = (Get-ApplicationSetting -Name 'AppLockerLDAPTEST')
    )
    
    begin {
        ####################################################################################################
        ### MAIN PROPERTIES ###

        # Function
        [System.String[]]$FunctionDetails = @($MyInvocation.MyCommand,$PSCmdlet.ParameterSetName,$PSBoundParameters.GetEnumerator())
        [System.String]$FunctionName        = $FunctionDetails[0]

        ####################################################################################################

        # Write the begin message
        Write-Function -Begin $FunctionDetails
    }
    
    process {
        try {
            # Validate the input
            if (-Not(Confirm-Object -MandatoryString $AppLockerLDAP)) { Write-Red ('{0}: The property AppLockerLDAP is empty.' -f $FunctionName) ; Return }
            # If the policy already exist, ask confirmation
            if (Test-AppLockerPolicy -ApplicationID $ApplicationID -AppLockerLDAP $AppLockerLDAP -PassThru) {
                # Ask confirmation
                [System.Boolean]$UserConfirmedOverWrite = Get-UserConfirmation -Title 'Confirm overwrite existing Policy' -Body ("The AppLocker Policy ALREADY EXISTS for the application:`n`n{0}`n`nDo you want to OVERWRITE the existing Policy?" -f $ApplicationID)
                if (-Not($UserConfirmedOverWrite)) { Return }
            } else {
                # Ask confirmation
                [System.Boolean]$UserConfirmedImport = Get-UserConfirmation -Title 'Confirm import new Policy' -Body ("The AppLocker Policy DOES NOT EXIST YET for the application:`n`n{0}`n`nDo you want to IMPORT the Policy?" -f $ApplicationID)
                if (-Not($UserConfirmedImport)) { Return }
            }
            # Get the Policy file from the DSL
            [System.String]$AppLockerDSLFolder = (Get-Path -ApplicationID $ApplicationID -SubFolder AppLockerFolder)
            if (-Not($AppLockerDSLFolder)) { Write-Red ('The AppLocker Folder could not be found: ({0})' -f $AppLockerDSLFolder) ; Return }
            [System.IO.FileSystemInfo]$AppLockerPolicyFileObject = Get-ChildItem -Path $AppLockerDSLFolder -File -Filter *.xml | Where-Object { $_.Name.StartsWith('AppLockerPolicyHash') -and $_.Basename.Contains($ApplicationID) }
            # if the file was not found, then return
            if (-Not($AppLockerPolicyFileObject)) {
                Write-Red ('The AppLocker Policy file was not found at the expected location: ({0})' -f $AppLockerDSLFolder)
                Open-Folder -Folder $AppLockerDSLFolder
                Return
            }
            # Remove the existing policies
            if ($UserConfirmedOverWrite) { Remove-AppLockerPolicy -ApplicationID $ApplicationID -Force }
            # Import the policy
            Write-Busy ('Importing the AppLocker Policies, for the application ({0}), into ({1}).' -f $ApplicationID,$AppLockerLDAP) -ApplicationID $ApplicationID
            Confirm-AppLockerPolicy -ApplicationID $ApplicationID
            Set-AppLockerPolicy -Ldap $AppLockerLDAP -XmlPolicy $AppLockerPolicyFileObject.FullName -Merge
            Write-Success ('Imported the AppLocker Policies, for the application ({0}), into ({1}).' -f $ApplicationID,$AppLockerLDAP) -ApplicationID $ApplicationID
        }
        catch [System.UnauthorizedAccessException] {
            Write-Fail ('Not imported any AppLocker Policies. You do not have permissions to WRITE in this GPO: ({0})' -f $AppLockerLDAP) -ApplicationID $ApplicationID
        }
        catch {
            Write-FullError
        }
    }
    
    end {
        # Write the end message
        Write-Function -End $FunctionDetails
    }
}

### END OF FUNCTION
####################################################################################################
