####################################################################################################
<#
.SYNOPSIS
    This function test if an AppLocker policy exists based in the Application ID.
.DESCRIPTION
    This function is part of the Packaging Assistant. It contains references to classes, functions or variables, that are in other files.
.EXAMPLE
    Test-AppLockerPolicy -ApplicationID 'Adobe_Reader_12.4'
.INPUTS
    [System.Management.Automation.SwitchParameter]
.OUTPUTS
    [System.String]
.NOTES
    Version         : 5.5.1
    Author          : Imraan Iotana
    Creation Date   : August 2025
    Last Update     : August 2025
#>
####################################################################################################
######### FIX: $AudacityPolicies
function Test-AppLockerPolicy {
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

        [Parameter(Mandatory=$false,HelpMessage='Switch for returning the result as a boolean.')]
        [System.Management.Automation.SwitchParameter]
        $PassThru,

        [Parameter(Mandatory=$false,HelpMessage='Switch for showing the details in the host.')]
        [System.Management.Automation.SwitchParameter]
        $OutHost,

        [Parameter(Mandatory=$false,HelpMessage='Switch for showing the details in a GridView.')]
        [System.Management.Automation.SwitchParameter]
        $OutGridView
    )
    
    begin {
        ####################################################################################################
        ### MAIN PROPERTIES ###

        # Function
        [System.String[]]$FunctionDetails = @($MyInvocation.MyCommand,$PSCmdlet.ParameterSetName,$PSBoundParameters.GetEnumerator())

        ####################################################################################################

        # Write the begin message
        Write-Function -Begin $FunctionDetails
    }
    
    process {
        # Validate the input
        if (-Not(Confirm-Object -MandatoryString $AppLockerLDAP)) { Write-Red ('{0}: The property AppLockerLDAP is empty.' -f $FunctionDetails[0]) ; Return }
        Write-Line ('Checking the AppLocker policies for the application ({0}). One moment please...' -f $ApplicationID)
        # Get the AppLocker policy as xml
        [System.Xml.XmlDocument]$AllPoliciesAsXML = Get-AppLockerPolicy -Domain -Ldap $AppLockerLDAP -Xml
        # Set the search string
        [System.String]$SearchString = ('//FileHashRule[contains(@Name,"{0}") or contains(@Description,"{0}")]' -f $ApplicationID)
        # Search the policy based on the Application ID
        [System.Xml.XmlElement[]]$AudacityPolicies = $AllPoliciesAsXML.SelectNodes($SearchString)
        # Write the result, and set the OutputObject
        [System.Int32]$TotalCount = $AudacityPolicies.Count
        if (-Not($PassThru)) { Write-Host ('{0} AppLocker policies were found for the application: ({1})' -f $TotalCount,$ApplicationID) }
        # I fno policies were found, thern return false
        [System.Boolean]$OutputObject = if ($TotalCount -eq 0) {
            $false
        } else {
            if ($OutHost) {
                Write-Green ('{0} AppLocker policies were found for the application: ({1})' -f $TotalCount,$ApplicationID)
                $AudacityPolicies | ForEach-Object {
                    [System.Int32]$Counter = ([array]::IndexOf($AudacityPolicies,$_) + 1)
                    Write-Host
                    Write-Line ('--- {0} of {1} ---' -f $Counter,$TotalCount)
                    Write-Host ("Name`t`t: {0}" -f $_.Name)
                    Write-Host ("Description`t: {0}" -f $_.Description)
                    Write-Host ("AD Group SID`t: {0}" -f $_.UserOrGroupSid)
                    Write-Host ("Action`t`t: {0}" -f $_.Action)
                }
            }
            if ($OutGridView) {
                $AudacityPolicies | Select-Object Name,Description,Action,UserOrGroupSid | Out-GridView -Title ('Application: {0} - Entries: {1}' -f $ApplicationID, $TotalCount)
            }
            # Return true
            $true
        }
    }
    
    end {
        # Write the end message
        Write-Function -End $FunctionDetails
        # Return the output
        if ($PassThru) { $OutputObject }
    }
}

### END OF FUNCTION
####################################################################################################
