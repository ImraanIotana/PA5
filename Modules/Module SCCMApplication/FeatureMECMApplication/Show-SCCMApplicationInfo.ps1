####################################################################################################
<#
.SYNOPSIS
    This function shows details of an SCCM Application.
.DESCRIPTION
    This function is part of the Packaging Assistant. It contains references to classes, functions or variables, that are in other files.
.EXAMPLE
    Show-SCCMApplicationInfo -Name Notepad++
.INPUTS
    [System.String]
.OUTPUTS
    This function returns no stream-output.
.NOTES
    Version         : 5.4.7
    Author          : Imraan Iotana
    Creation Date   : September 2024
    Last Updated    : July 2025
#>
####################################################################################################

function Show-SCCMApplicationInfo {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory=$true,ParameterSetName='ShowApplicationByApplicationID',HelpMessage='The ApplicationID of the Application.')]
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

        ####################################################################################################
        ### MAIN FUNCTION METHODS ###
        
        # Add the Begin method
        Add-Member -InputObject $Local:MainObject -MemberType ScriptMethod -Name Begin -Value {
            # Write the Begin message
            Write-Message -FunctionBegin -Details $this.FunctionDetails
        }

        # Add the End method
        Add-Member -InputObject $Local:MainObject -MemberType ScriptMethod -Name End -Value {
            # Write the End message
            Write-Message -FunctionEnd -Details $this.FunctionDetails
        }

        # Add the Process method
        Add-Member -InputObject $Local:MainObject -MemberType ScriptMethod -Name Process -Value {
            # Show the Application info
            $this.ShowSCCMApplicationInfo()
        }

        ####################################################################################################
        ### MAIN PROCESSING METHODS ###
    
        # Add the ShowSCCMApplicationInfo method
        Add-Member -InputObject $Local:MainObject -MemberType ScriptMethod -Name ShowSCCMApplicationInfo -Value { param([System.String]$ApplicationName = $this.ApplicationName,[System.String]$ApplicationID = $this.ApplicationID)
            try {
                # Switch to the SCCM Drive
                Invoke-SCCMConnectionAction -SwitchToDrive
                # Get the Application info
                [Microsoft.ConfigurationManagement.ManagementProvider.WqlQueryEngine.WqlResultObject[]]$SCCMApplicationObject = Get-SCCMApplication -ApplicationID $ApplicationID
                # Switch back
                Invoke-SCCMConnectionAction -SwitchBack
                # Write the result
                if ($SCCMApplicationObject) { Write-SCCMApplicationToHost -SCCMApplicationObject $SCCMApplicationObject }
            }
            catch [System.Management.Automation.CommandNotFoundException] {
                Write-Host ('Show-SCCMApplicationInfo: The SCCM PowerShell Module is not installed.')
            }
            catch [System.InvalidOperationException] {
                Write-Host ('Show-SCCMApplicationInfo: You are not connected to the SCCM Drive.')
            }
            catch {
                Write-FullError
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
    }
}

### END OF SCRIPT
####################################################################################################
