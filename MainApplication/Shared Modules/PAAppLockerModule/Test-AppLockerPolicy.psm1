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
    Version         : 5.7.2
    Author          : Imraan Iotana
    Creation Date   : August 2025
    Last Updated    : February 2026
#>
####################################################################################################

function Test-AppLockerPolicy {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory=$false,HelpMessage='The ID of the application that will be handled.')]
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

        ####################################################################################################
    }
    
    process {
        # VALIDATION
        # Validate the ApplicationID
        if (Test-String -IsEmpty $ApplicationID) { Write-Line "ApplicationID" -Type EmptyStringNoAction ; Return }
        # Validate the AppLockerLDAP
        if (Test-String -IsEmpty $AppLockerLDAP) { Write-Line "AppLockerLDAP" -Type EmptyStringNoAction ; Return }

        # EXECUTION
        try {
            # GET THE POLICY
            # Get the AppLocker policy as xml
            Write-Line ('Checking the AppLocker policies for the application ({0}). One moment please...' -f $ApplicationID)
            [System.Xml.XmlDocument]$AllPoliciesAsXML = Get-AppLockerPolicy -Domain -Ldap $AppLockerLDAP -Xml
            # If the AppLocker policy is empty, then return false
            if ($null -eq $AllPoliciesAsXML) { Write-Line ("No AppLocker Policy was obtained from $AppLockerLDAP.") -Type Fail ; Return }
            # Set the search string
            [System.String]$SearchString = ('//FileHashRule[contains(@Name,"{0}") or contains(@Description,"{0}")]' -f $ApplicationID)
            # Search the policy based on the Application ID
            [System.Xml.XmlElement[]]$AudacityPolicies = $AllPoliciesAsXML.SelectNodes($SearchString)


            # WRITE RESULTS AND SET OUTPUT
            # Set the OutputObject based on the result
            $OutputObject = if ($null -eq $AudacityPolicies -or $AudacityPolicies.Count -eq 0) {
                # If no Policies were found, then write the message
                Write-Line "No AppLocker policies were found for the application: ($ApplicationID)" -Type Info
            } else {
                # Set the total count of policies found
                [System.Int32]$TotalCount = $AudacityPolicies.Count
                # If Policies were found, and the OutHost switch is used, then show the details in the host
                if ($OutHost) {
                    Write-Line "$TotalCount AppLocker policies were found for the application: ($ApplicationID)" -Type Success
                    $AudacityPolicies | ForEach-Object {
                        [System.Int32]$Counter = ([array]::IndexOf($AudacityPolicies,$_) + 1)
                        Write-Host
                        Write-Line ("--- $Counter of $TotalCount ---")
                        Write-Host ("Name`t`t: $($_.Name)")
                        Write-Host ("Description`t: $($_.Description)")
                        Write-Host ("AD Group SID`t: $($_.UserOrGroupSid)")
                        Write-Host ("Action`t`t: $($_.Action)")
                    }
                }
                # If Policies were found, and the OutGridView switch is used, then show the details in a GridView
                if ($OutGridView) {
                    $AudacityPolicies | Select-Object Name,Description,Action,UserOrGroupSid | Out-GridView -Title ("Application: $ApplicationID - Entries: $TotalCount")
                }
                # If Policies were found, then return true
                $true
            }
        }
        catch {
            Write-FullError
            Return
        }
    }
    
    end {
        # Return the output
        if ($PassThru) { $OutputObject }
    }
}

### END OF FUNCTION
####################################################################################################
