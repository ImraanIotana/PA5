####################################################################################################
<#
.SYNOPSIS
    This function test if an SCCM User Collection exists.
.DESCRIPTION
    This function is part of the Packaging Assistant. It contains references to classes, functions or variables, that are in other files.
    External classes    : -
    External functions  : Write-FullError
    External variables  : -
.EXAMPLE
    Test-SCCMUserCollection -Name "CollectionNameHere"
.INPUTS
    [System.String]
.OUTPUTS
    [System.Boolean]
.NOTES
    Version         : 4.8
    Author          : Imraan Iotana
    Creation Date   : September 2024
    Last Updated    : September 2024
#>
####################################################################################################

function Test-SCCMUserCollection {
    [CmdletBinding()]
    param (
        # The name of the Collection
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
            CollectionName     = $Name
            # Output
            OutputObject        = [System.Boolean]$null
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
            # Test if the Collection exists
            $this.OutputObject = $this.TestSCCMUserCollection($this.CollectionName)
        }

        ####################################################################################################
        ### MAIN PROCESSING METHODS ###
    
        # Add the TestSCCMUserCollection method
        Add-Member -InputObject $Local:MainObject -MemberType ScriptMethod -Name TestSCCMUserCollection -Value { param([System.String]$CollectionName)
            # Write the message
            Write-Verbose ('Testing if the SCCM UserCollection exists: ({0})' -f $CollectionName)
            try {
                # Get the UserCollection info
                [Microsoft.ConfigurationManagement.ManagementProvider.WqlQueryEngine.WqlResultObject[]]$SCCMUserCollectionObjects = Get-CMUserCollection -Name $CollectionName
                if ($SCCMUserCollectionObjects) {
                    # Write the message and return true
                    Write-Verbose ('The SCCM UserCollection exists: ({0})' -f $CollectionName)
                    $true
                } else {
                    # Write the message and return false
                    Write-Verbose ('The SCCM UserCollection does NOT exist: ({0})' -f $CollectionName)
                    $false
                }
            }
            catch [System.Management.Automation.CommandNotFoundException] {
                # Write the message and return false
                Write-Host ('The SCCM PowerShell Module is not installed.')
                $false
            }
            catch [System.InvalidOperationException] {
                # Write the message and return false
                Write-Host ('You are not connected to the SCCM Drive.')
                $false
            }
            catch {
                # Write the error and return false
                Write-FullError
                $false
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
        # Return the result
        $Local:MainObject.OutputObject
        #endregion END
    }
}

### END OF SCRIPT
####################################################################################################
