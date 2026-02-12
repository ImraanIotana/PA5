####################################################################################################
<#
.SYNOPSIS
    This function sorts a hastable.
.DESCRIPTION
    This function is part of the Packaging Assistant. It contains functions and variables that are in other files.
.EXAMPLE
    Sort-Hashtable
.INPUTS
    -
.OUTPUTS
    [System.String]
.NOTES
    Version         : 5.4.5
    Author          : Imraan Iotana
    Creation Date   : July 2025
    Last Update     : July 2025
#>
####################################################################################################

function Sort-Hashtable {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory=$true,HelpMessage='The hashtable that will be sorted.')]
        [System.Collections.Hashtable]
        $Hashtable
    )
    
    begin {
        ####################################################################################################
        ### MAIN OBJECT ###

        [PSCustomObject]$Local:MainObject = @{
            # Input
            HashtableToSort = $Hashtable
            # Output
            OutputObject    = [System.Collections.Hashtable]@{}
        }

        ####################################################################################################
        ### MAIN FUNCTION METHODS ###

        # Add the Process method
        Add-Member -InputObject $Local:MainObject -MemberType ScriptMethod -Name Process -Value {
            # Sort the hashtable
            $this.HashtableToSort.GetEnumerator() | Sort-Object Name | ForEach-Object {
                Write-Host ('Name: ({0}) - Value: ({1})' -f $_.Name,$_.Value)
                $this.OutputObject[$_.Name] = $_.Value
            }
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
