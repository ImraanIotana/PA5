####################################################################################################
<#
.SYNOPSIS
    This function shows details of an SCCM User Collection.
.DESCRIPTION
    This function is part of the Packaging Assistant. It contains functions and variables that are in other files.
    External classes    : -
    External functions  : Test-SCCMUserCollection, Write-FullError
    External variables  : -
.EXAMPLE
    Show-SCCMUserCollectionInfo -Name "ApplicationNameHere"
.INPUTS
    [System.String]
.OUTPUTS
    This function returns no stream-output.
.NOTES
    Version         : 4.8
    Author          : Imraan Iotana
    Creation Date   : September 2024
    Last Updated    : September 2024
#>
####################################################################################################

function Show-SCCMUserCollectionInfo {
    [CmdletBinding()]
    param (
        # The name of the User Collection
        [Parameter(Mandatory=$true)]
        [System.String]
        $Name
    )

    begin {
        ####################################################################################################
        ### MAIN OBJECT ###

        # Create the main object
        [PSCustomObject]$Local:MainObject = @{
            # Function
            FunctionName        = [System.String]$MyInvocation.MyCommand
            FunctionArguments   = [System.String]$PSBoundParameters.GetEnumerator()
            ParameterSetName    = [System.String]$PSCmdlet.ParameterSetName
            FunctionCircumFix   = [System.String]'Function: [{0}] ParameterSetName: [{1}] Arguments: {2}'
            # Input
            UserCollectionName  = $Name
        }

        ####################################################################################################
        ### MAIN FUNCTION METHODS ###
        
        # Add the Begin method
        Add-Member -InputObject $Local:MainObject -MemberType ScriptMethod -Name Begin -Value {
            # Add the function details
            Add-Member -InputObject $this -NotePropertyName FunctionDetails -NotePropertyValue ($this.FunctionCircumFix -f $this.FunctionName, $this.ParameterSetName, $this.FunctionArguments)
            # Write the Begin message
            Write-Verbose ('+++ BEGIN {0}' -f $this.FunctionDetails)
            # Switch to the SCCM Drive
            Invoke-SCCMConnectionAction -SwitchToDrive
        }

        # Add the End method
        Add-Member -InputObject $Local:MainObject -MemberType ScriptMethod -Name End -Value {
            # Switch back
            Invoke-SCCMConnectionAction -SwitchBack
            # Write the End message
            Write-Verbose ('___ END {0}' -f $this.FunctionDetails)
        }

        # Add the Process method
        Add-Member -InputObject $Local:MainObject -MemberType ScriptMethod -Name Process -Value {
            # Show the UserCollection info
            $this.ShowSCCMUserCollectionInfo($this.UserCollectionName)
        }

        ####################################################################################################
        ### MAIN PROCESSING METHODS ###
    
        # Add the ShowSCCMUserCollectionInfo method
        Add-Member -InputObject $Local:MainObject -MemberType ScriptMethod -Name ShowSCCMUserCollectionInfo -Value { param([System.String]$UserCollectionName)
            # If the UserCollection does not exist, write the message and return
            if (-Not(Test-SCCMUserCollection -Name $UserCollectionName)) {
                Write-Host ('The User Collection does not exist: ({0})' -f $UserCollectionName)
                Return
            }
            try {
                # Get the UserCollection info
                [Microsoft.ConfigurationManagement.ManagementProvider.WqlQueryEngine.WqlResultObject]$SCCMUserCollectionObject = Get-CMUserCollection -Name $UserCollectionName
                Write-Host ('User Collection found: ({0})' -f $UserCollectionName) -ForegroundColor Green
                $SCCMUserCollectionObject | ForEach-Object {
                    [Microsoft.ConfigurationManagement.ManagementProvider.IResultObject]$QueryInfo = Get-CMUserCollectionQueryMembershipRule -CollectionName $_.Name
                    Write-Host ("Full Name`t: {0}" -f $_.Name)
                    Write-Host ("MemberCount`t: {0}" -f $_.MemberCount)
                    Write-Host ("Query Name`t: {0}`n" -f $QueryInfo.RuleName)
                    #Write-Host ("Query Expression:`n{0}`n" -f $QueryInfo.QueryExpression)
                }
            }
            catch [System.Management.Automation.CommandNotFoundException] {
                # Write the message
                Write-Host ('The SCCM PowerShell Module is not installed.')
            }
            catch [System.InvalidOperationException] {
                # Write the message
                Write-Host ('You are not connected to the SCCM Drive.')
            }
            catch {
                # Write the error
                Write-FullError
            }
        }

        ####################################################################################################

        #region BEGIN
        $Local:MainObject.Begin()
        #endregion BEGIN
    }
    
    process {
        #region PROCESS
        $Local:MainObject.Process()
        #endregion PROCESS
    }

    end {
        #region END
        $Local:MainObject.End()
        #endregion END
    }
}

### END OF SCRIPT
####################################################################################################
