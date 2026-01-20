####################################################################################################
<#
.SYNOPSIS
    This function removes an SCCM User Collection.
.DESCRIPTION
    This function is part of the Packaging Assistant. It contains references to classes, functions or variables, that are in other files.
    External classes    : -
    External functions  : Test-SCCMUserCollection, Write-FullError
    External variables  : -
.EXAMPLE
    Remove-SCCMUserCollection -Name "ApplicationNameHere"
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

function Remove-SCCMUserCollection {
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
            FunctionName            = [System.String]$MyInvocation.MyCommand
            FunctionArguments       = [System.String]$PSBoundParameters.GetEnumerator()
            ParameterSetName        = [System.String]$PSCmdlet.ParameterSetName
            FunctionCircumFix       = [System.String]'Function: [{0}] ParameterSetName: [{1}] Arguments: {2}'
            # Input
            UserCollectionName      = $Name
        }

        ####################################################################################################
        ### MAIN FUNCTION METHODS ###
        
        # Add the Begin method
        Add-Member -InputObject $Local:MainObject -MemberType ScriptMethod -Name Begin -Value {
            # Add the function details
            Add-Member -InputObject $this -NotePropertyName FunctionDetails -NotePropertyValue ($this.FunctionCircumFix -f $this.FunctionName, $this.ParameterSetName, $this.FunctionArguments)
            # Write the Begin message
            Write-Verbose ('+++ BEGIN {0}' -f $this.FunctionDetails)
        }

        # Add the End method
        Add-Member -InputObject $Local:MainObject -MemberType ScriptMethod -Name End -Value {
            # Write the End message
            Write-Verbose ('___ END {0}' -f $this.FunctionDetails)
        }

        # Add the Process method
        Add-Member -InputObject $Local:MainObject -MemberType ScriptMethod -Name Process -Value {
            # Remove the UserCollection
            $this.RemoveSCCMUserCollection($this.UserCollectionName)
        }

        ####################################################################################################
        ### MAIN PROCESSING METHODS ###
    
        # Add the RemoveSCCMUserCollection method
        Add-Member -InputObject $Local:MainObject -MemberType ScriptMethod -Name RemoveSCCMUserCollection -Value { param([System.String]$UserCollectionName)
            # If the UserCollection does not exist, write the message and return
            if (-Not(Test-SCCMUserCollection -Name $UserCollectionName)) {
                Write-Host ('The User Collection does not exist. No action has been taken. ({0})' -f $UserCollectionName) -ForegroundColor DarkGray
                Return
            }
            try {
                # Write the message
                Write-Host ('Removing the User Collection. One moment please... ({0})' -f $UserCollectionName) -ForegroundColor DarkGray
                # Remove the UserCollection
                Remove-CMCollection -Name $UserCollectionName -Force
                # Write the message
                Write-Host ('The User Collection has been removed. ({0})' -f $UserCollectionName) -ForegroundColor Green
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
