####################################################################################################
<#
.SYNOPSIS
    This function tests if an AppLocker policy exists, based on the Application ID.
.DESCRIPTION
    Queries AppLocker policies by LDAP and checks for rules matching the Application ID.
.EXAMPLE
    Test-AppLockerPolicy -ApplicationID 'Adobe_Reader_12.4'
.INPUTS
    [System.String]
    [System.Management.Automation.SwitchParameter]
.OUTPUTS
    [System.Boolean]
.NOTES
    This function is part of the Packaging Assistant. It contains functions and variables that are in other files.
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
        [Parameter(Mandatory=$true,HelpMessage='The ID of the application that will be handled.')]
        [System.String]$ApplicationID,

        [Parameter(Mandatory=$false,HelpMessage='The LDAP of the AppLocker policy that will be queried.')]
        [System.String]$AppLockerLDAP,

        [Parameter(Mandatory=$false,HelpMessage='Switch for returning the result as a boolean.')]
        [System.Management.Automation.SwitchParameter]$PassThru,

        [Parameter(Mandatory=$false,HelpMessage='Switch for showing the details in the host.')]
        [System.Management.Automation.SwitchParameter]$OutHost,

        [Parameter(Mandatory=$false,HelpMessage='Switch for showing the details in a GridView.')]
        [System.Management.Automation.SwitchParameter]$OutGridView
    )
    
    begin {
        ####################################################################################################
        ### MAIN PROPERTIES ###

        # OutputObject
        [System.Boolean]$OutputObject = $false
    }
    
    process {
        # VALIDATION
        # Validate the input
        if (Test-String -IsEmpty $AppLockerLDAP) { Write-Line 'The AppLockerLDAP string is empty.' -Type Fail ; Return }


        # Get the AppLocker policy as xml
        Write-Line ('Checking the AppLocker policies for the application ({0}). One moment please...' -f $ApplicationID)
        [System.Xml.XmlDocument]$AllPoliciesAsXML = Get-AppLockerPolicy -Domain -Ldap $AppLockerLDAP -Xml
        # Set the search string
        [System.String]$SearchString = ('//FileHashRule[contains(@Name,"{0}") or contains(@Description,"{0}")]' -f $ApplicationID)
        # Search the policy based on the Application ID
        [System.Xml.XmlElement[]]$AudacityPolicies = $AllPoliciesAsXML.SelectNodes($SearchString)
        # Write the result, and set the OutputObject
        [System.Int32]$TotalCount = $AudacityPolicies.Count
        if (-Not($PassThru)) { Write-Host ('{0} AppLocker policies were found for the application: ({1})' -f $TotalCount,$ApplicationID) }
        # If no policies were found, then return false
        [System.Boolean]$OutputObject = if ($TotalCount -eq 0) {
            $false
        } else {
            if ($OutHost) {
                # Write the details to the host
                Write-Line "$TotalCount AppLocker policies were found for the application: ($ApplicationID)" -Type Success
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
            # If the OutGridView switch is used, then show the details in a GridView
            if ($OutGridView) {
                $AudacityPolicies | Select-Object Name,Description,Action,UserOrGroupSid | Out-GridView -Title ('Application: {0} - Entries: {1}' -f $ApplicationID, $TotalCount)
            }
            # Return true
            $true
        }
    }
    
    end {
        # Return the output
        if ($PassThru) { $OutputObject }
    }
}

### END OF FUNCTION
####################################################################################################
