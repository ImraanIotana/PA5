####################################################################################################
<#
.SYNOPSIS
    This function gets an SCCM Application.
.DESCRIPTION
    This function is part of the Packaging Assistant. It contains functions and variables that are in other files.
.EXAMPLE
    Get-SCCMApplication -Name "ApplicationNameHere"
.INPUTS
    [System.String]
.OUTPUTS
    [System.Boolean]
.NOTES
    Version         : 5.4.4
    Author          : Imraan Iotana
    Creation Date   : September 2024
    Last Updated    : July 2025
#>
####################################################################################################

function Get-SCCMApplication {
    [CmdletBinding()]
    param (        
        [Parameter(Mandatory=$true,HelpMessage='The Comment/LocalizedDescription of the Application.',ParameterSetName='FindApplicationByApplicationID')]
        [Alias('Comment')]
        [System.String]
        $ApplicationID
    )

    begin {
        ####################################################################################################
        ### MAIN OBJECT ###

        # Create the main object
        [PSCustomObject]$Local:MainObject = @{
            # Function
            FunctionDetails = [System.String[]]@($MyInvocation.MyCommand,$PSCmdlet.ParameterSetName,$PSBoundParameters.GetEnumerator())
            # Input
            ApplicationID   = $ApplicationID
        }
        [System.String]$PreFix = "[$($MyInvocation.MyCommand)]:"

        ####################################################################################################
        ### MAIN FUNCTION METHODS ###

        # Add the Begin method
        $Local:MainObject | Add-Member -MemberType ScriptMethod -Name Begin -Value { Write-Message -Begin $this.FunctionDetails }

        # Add the End method
        $Local:MainObject | Add-Member -MemberType ScriptMethod -Name End -Value { Write-Message -End $this.FunctionDetails }

        # Add the Process method
        $Local:MainObject | Add-Member -MemberType ScriptMethod -Name Process -Value {
            # Get the Application and add the result to the main object
            [Microsoft.ConfigurationManagement.ManagementProvider.WqlQueryEngine.WqlResultObject]$OutputObject = $this.GetSCCMApplicationObject()
            $this | Add-Member -NotePropertyName OutputObject -NotePropertyValue $OutputObject
        }

        ####################################################################################################
        ### MAIN PROCESSING METHODS ###
    
        # Add the GetSCCMApplicationObject method
        Add-Member -InputObject $Local:MainObject -MemberType ScriptMethod -Name GetSCCMApplicationObject -Value {
            # Write the message
            Write-Line ('Searching the SCCM Application ({0})...' -f $this.ApplicationID)
            try {
                # Switch on the ParameterSetName
                [Microsoft.ConfigurationManagement.ManagementProvider.WqlQueryEngine.WqlResultObject[]]$SCCMApplicationObjects = Get-CMApplication -Fast | Where-Object { $_.LocalizedDisplayName.Contains($this.ApplicationID) }
                # Switch on the amount of found objects
                switch($SCCMApplicationObjects.Count) {
                    0 {
                        # Write the message and return null
                        Write-Host ('The Application was not found in SCCM.')
                        $null
                    }
                    1 {
                        # Write the message and return the object
                        Write-Host ('The SCCM Application was found.')
                        $SCCMApplicationObjects[0]
                    }
                    Default {
                        # Write the message and return the object
                        Write-Host ('{0} SCCM Applications were found. The first one will be returned.' -f $SCCMApplicationObjects.Count)
                        $SCCMApplicationObjects[0]
                    }
                }
            }
            catch [System.Management.Automation.CommandNotFoundException] {
                # Write the message and return null
                Write-Red "$PreFix The SCCM PowerShell Module is not installed."
                $null
            }
            catch [System.InvalidOperationException] {
                # Write the message and return null
                Write-Red "$PreFix You are not connected to the SCCM Drive."
                $null
            }
            catch {
                # Write the error and return null
                Write-FullError
                $null
            }
        }

        ####################################################################################################

        $Local:MainObject.Begin()
    }
    
    process {
        $Local:MainObject.Process()
    }

    end {
        $Local:MainObject.End()
        # Return the result
        $Local:MainObject.OutputObject
    }
}

### END OF SCRIPT
####################################################################################################
