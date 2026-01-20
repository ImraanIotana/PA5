####################################################################################################
<#
.SYNOPSIS
    This function creates the Application Name / Asset ID.
.DESCRIPTION
    This function is part of the Packaging Assistant. It contains references to classes, functions or variables, that are in other files.
.EXAMPLE
    Get-ApplicationName
.INPUTS
    -
.OUTPUTS
    [System.String]
.NOTES
    Version         : 5.3
    Author          : Imraan Iotana
    Creation Date   : May 2025
    Last Update     : May 2025
#>
####################################################################################################

function Get-ApplicationName {
    [CmdletBinding()]
    param (
    )
    
    begin {
        ####################################################################################################
        ### MAIN OBJECT ###

        [PSCustomObject]$Local:MainObject = @{
            # Output
            OutputObject    = [System.String]::Empty
        }

        ####################################################################################################
        ### MAIN FUNCTION METHODS ###

        # Add the Process method
        Add-Member -InputObject $Local:MainObject -MemberType ScriptMethod -Name Process -Value {
            # Get the application properties
            [PSCustomObject]$ApplicationProperties = Get-AssetIDParameters
            # Set the Application Name as the output
            $this.OutputObject = (Format-ApplicationID @ApplicationProperties)
        }
    }
    
    process {
        $Local:MainObject.Process()
    }
    
    end {
        # Return the output
        $Local:MainObject.OutputObject
    }
}

### END OF SCRIPT
####################################################################################################
