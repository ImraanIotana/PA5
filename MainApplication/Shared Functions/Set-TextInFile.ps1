####################################################################################################
<#
.SYNOPSIS
    This function replace text in a file.
.DESCRIPTION
    This function is part of the Packaging Assistant. It contains functions and variables that are in other files.
.EXAMPLE
    Set-TextInFile -FilePath 'C:\Demo\Demo.txt' -StringToReplace 'Text to be replaced' -ReplaceWith 'Replace with this text'
.INPUTS
    [System.String]
.OUTPUTS
    This function returns no stream-output.
.NOTES
    Version         : 5.4.3
    Author          : Imraan Iotana
    Creation Date   : June 2025
    Last Update     : June 2025
#>
####################################################################################################

function Set-TextInFile {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory=$true,HelpMessage='The path of the file of which the text will be replaced.')]
        [System.String]
        $FilePath,

        [Parameter(Mandatory=$true,HelpMessage='The text that will be replaced with the new string.')]
        [System.String]
        $StringToReplace,

        [Parameter(Mandatory=$true,HelpMessage='The text that will replace the old string.')]
        [System.String]
        $ReplaceWith
    )

    begin {
        ####################################################################################################
        ### MAIN OBJECT ###

        # Set the main object
        [PSCustomObject]$Local:MainObject = @{
            # Input
            FilePath        = $FilePath
            StringToReplace = $StringToReplace
            ReplaceWith     = $ReplaceWith
        }

        ####################################################################################################
        ### MAIN FUNCTION METHODS ###

        # Add the Process method
        Add-Member -InputObject $Local:MainObject -MemberType ScriptMethod -Name Process -Value {
            try {
                # Write the message
                Write-Host ('Replacing ({0}) with ({1}) in file ({2})...' -f $this.StringToReplace,$this.ReplaceWith,$this.FilePath ) -ForegroundColor DarkGray
                # Replace the text in the file
                $Content = Get-Content -Path $this.FilePath
                $Content = $Content -replace $this.StringToReplace,$this.ReplaceWith
                $Content | Set-Content -Path $this.FilePath
            }
            catch {
                Write-FullError
            }
        }

    }
    
    process {
        $Local:MainObject.Process()
    }

    end {
    }
}

### END OF SCRIPT
####################################################################################################
