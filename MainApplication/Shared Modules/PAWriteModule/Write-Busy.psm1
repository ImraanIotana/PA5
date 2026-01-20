####################################################################################################
<#
.SYNOPSIS
    This function write a line to the host, in the colors assigned to this action.
.DESCRIPTION
    This function is self-contained and does not refer to functions, variables or classes, that are in other files.
.EXAMPLE
    Write-Busy "Hello World!"
.INPUTS
    [System.String]
.OUTPUTS
    This function returns no stream output.
.NOTES
    Version         : 5.5.1
    Author          : Imraan Iotana
    Creation Date   : September 2025
    Last Update     : September 2025
#>
####################################################################################################

function Write-Busy {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory=$true,Position=0,HelpMessage='The message that will be written to the host.')]
        [AllowNull()]
        [AllowEmptyString()]
        [System.String]
        $Message,

        [Parameter(Mandatory=$false,HelpMessage='The Application for which a Log Entry will be made.')]
        [System.String]
        $ApplicationID,

        [Parameter(Mandatory=$false,HelpMessage='Switch for writing the NoAction message.')]
        [System.Management.Automation.SwitchParameter]
        $NoAction
    )

    begin {
    }
    
    process {
        # Write to the host
        Write-Host $Message -ForegroundColor Gray -BackgroundColor DarkGray
        # Write the NoAction message
        if ($NoAction) { Write-NoAction }
        # Write to the log
        if ($ApplicationID) { Add-LogEntry -Message $Message -ApplicationID $ApplicationID -Type Info }
    }
    
    end {
    }
}

### END OF FUNCTION
####################################################################################################


