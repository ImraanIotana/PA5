####################################################################################################
<#
.SYNOPSIS
    This function test if an AppLocker policy exists based in the Application ID.
.DESCRIPTION
    This function is part of the Packaging Assistant. It contains functions and variables that are in other files.
.EXAMPLE
    Remove-AppLockerPolicy -ApplicationID 'Adobe_Reader_12.4'
.INPUTS
    [System.String]
.OUTPUTS
    This function returns no stream output.
.NOTES
    Version         : 5.5.1
    Author          : Imraan Iotana
    Creation Date   : August 2025
    Last Update     : August 2025
#>
####################################################################################################

function Remove-AppLockerPolicy {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory=$true,ValueFromPipeline=$true,HelpMessage='The ID of the application that will be handled.')]
        [Alias('Application','ApplicationName','Name')]
        [System.String]
        $ApplicationID,

        [Parameter(Mandatory=$false,ValueFromPipeline=$true,HelpMessage='The LDAP of the AppLocker policy that will be queried.')]
        [Alias('LDAP')]
        [System.String]
        $AppLockerLDAP = (Get-ApplicationSetting -Name 'AppLockerLDAPTEST'),

        [Parameter(Mandatory=$false,HelpMessage='Switch for skipping the confirmations.')]
        [System.Management.Automation.SwitchParameter]
        $Force
    )
    
    begin {
        ####################################################################################################
        ### MAIN PROPERTIES ###

        # Function
        [System.String[]]$FunctionDetails   = @($MyInvocation.MyCommand,$PSCmdlet.ParameterSetName,$PSBoundParameters.GetEnumerator())
        # Handlers
        [System.String]$ExportFileNameCircumFix = 'AppLockerPolicy_Export_{0}.XML'
        [System.String]$TimeStamp = (Get-TimeStamp -ForBackups)

        ####################################################################################################

        # Write the begin message
        Write-Function -Begin $FunctionDetails
    }
    
    process {
        try {
            # Validate the input
            if (-Not(Confirm-Object -MandatoryString $AppLockerLDAP)) { Write-Red ('{0}: The property AppLockerLDAP is empty.' -f $FunctionDetails[0]) ; Return }
            # If the policy already exist, ask confirmation
            if (Test-AppLockerPolicy -ApplicationID $ApplicationID -PassThru) {
                # Ask confirmation
                if (-Not($Force)) {
                    [System.Boolean]$UserHasConfirmed = Get-UserConfirmation -Title 'Confirm removal existing Policy' -Body ("This will REMOVE the AppLocker Policy for the application:`n`n{0}`n`nAre you sure?" -f $ApplicationID)
                    if (-Not($UserHasConfirmed)) { Return }
                }
            } else {
                Write-Host ('No AppLocker policies were found for the application: ({0})' -f $ApplicationID) ; Write-NoAction ; Return
            }
            # Get the Policy file from the DSL
            [System.String]$AppLockerDSLFolder = (Get-Path -ApplicationID $ApplicationID -SubFolder AppLockerFolder)
            [System.IO.FileSystemInfo]$AppLockerPolicyFileObject = Get-ChildItem -Path $AppLockerDSLFolder -File -Filter *.xml | Where-Object { $_.Name.StartsWith('AppLockerPolicyHash') -and $_.Basename.Contains($ApplicationID) }
            # if the file was not found, then return
            if (-Not($AppLockerPolicyFileObject)) {
                Write-Red ('The AppLocker Policy file could not be found at the expected location: ({0})' -f $AppLockerDSLFolder)
                Open-Folder -Folder $AppLockerDSLFolder
                Return
            }
            # Remove the policy
            Write-Busy ('Removing existing AppLocker Policies, for the application ({0}), from ({1}).' -f $ApplicationID,$AppLockerLDAP) -ApplicationID $ApplicationID
            # Get the AppLocker policy as xml
            [System.Xml.XmlDocument]$AllPoliciesAsXML = Get-AppLockerPolicy -Domain -Ldap $AppLockerLDAP -Xml
            # Set the search string
            [System.String]$SearchString = ('//FileHashRule[contains(@Name,"{0}") or contains(@Description,"{0}")]' -f $ApplicationID)
            # Search the policy based in the Application ID
            [System.Xml.XmlElement[]]$RulesToRemove = $AllPoliciesAsXML.SelectNodes($SearchString)
            foreach ($Rule in $RulesToRemove) { $Rule.ParentNode.RemoveChild($Rule) }
            # Set the temporary xml file
            [System.String]$TempLocalXMLFile = Join-Path -Path $ENV:TEMP -ChildPath ($ExportFileNameCircumFix -f $TimeStamp)
            $AllPoliciesAsXML.Save($TempLocalXMLFile)
            # Import the temporary xml file
            Set-AppLockerPolicy -Ldap $AppLockerLDAP -XmlPolicy $TempLocalXMLFile
            [System.String]$RemovedMessage = ('Removed existing AppLocker Policies, for the application ({0}), from ({1}).' -f $ApplicationID,$AppLockerLDAP)
            Write-Success ('Removed existing AppLocker Policies, for the application ({0}), from ({1}).' -f $ApplicationID,$AppLockerLDAP) -ApplicationID $ApplicationID
        }
        catch [System.UnauthorizedAccessException] {
            Write-Fail ('Not removed any AppLocker Policies. You do not have permissions to REMOVE in this GPO: ({0})' -f $AppLockerLDAP) -ApplicationID $ApplicationID
        }
    }
    
    end {
        # Write the end message
        Write-Function -End $FunctionDetails
    }
}

### END OF FUNCTION
####################################################################################################
