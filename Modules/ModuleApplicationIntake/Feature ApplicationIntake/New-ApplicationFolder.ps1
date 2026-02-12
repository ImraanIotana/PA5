####################################################################################################
<#
.SYNOPSIS
    This function creates a new application folder.
.DESCRIPTION
    This function is part of the Packaging Assistant. It contains functions and variables that are in other files.
.EXAMPLE
    New-ApplicationFolder
.INPUTS
    [System.String]
.OUTPUTS
    This function returns no stream-output.
.NOTES
    Version         : 5.5
    Author          : Imraan Iotana
    Creation Date   : May 2025
    Last Update     : August 2025
#>
####################################################################################################

function New-ApplicationFolder {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory=$false,HelpMessage='The parentfolder in which this new folder will be placed.')]
        [System.String]
        $OutputFolder = (Get-SharedAssetPath -OutputFolder)
    )
    
    begin {
        ####################################################################################################
        ### MAIN OBJECT ###

        [PSCustomObject]$Local:MainObject = @{
            # Function
            FunctionDetails = [System.String[]]@($MyInvocation.MyCommand,$PSCmdlet.ParameterSetName,$PSBoundParameters.GetEnumerator())
            # Input
            OutputFolder    = $OutputFolder
            # SubFolders
            SubFolderNames  = [System.Collections.Hashtable](Get-ApplicationSubfolders)
        }

        ####################################################################################################
        ### MAIN FUNCTION METHODS ###

        # Add the Begin method
        Add-Member -InputObject $Local:MainObject -MemberType ScriptMethod -Name Begin -Value { Write-Message -Begin $this.FunctionDetails }

        # Add the End method
        Add-Member -InputObject $Local:MainObject -MemberType ScriptMethod -Name End -Value { Write-Message -End $this.FunctionDetails }

        # Add the Process method
        Add-Member -InputObject $Local:MainObject -MemberType ScriptMethod -Name Process -Value {
            try {
                # Get the ApplicationName
                [System.String]$ApplicationName = Get-ApplicationName
                # Set the new application folder
                [System.String]$NewApplicationFolder = Join-Path -Path $this.OutputFolder -ChildPath $ApplicationName
                # Write the message
                Write-Host ('Creating the Application folder... ({0})' -f $NewApplicationFolder) -ForegroundColor DarkGray
                # Create the folder
                New-Item -Path $NewApplicationFolder -ItemType Directory -Force | Out-Null
                # Create the subfolders
                $this.SubFolderNames.GetEnumerator() | ForEach-Object {
                    [System.String]$SubFolderPath = Join-Path -Path $NewApplicationFolder -ChildPath $_.Value
                    New-Item -Path $SubFolderPath -ItemType Directory -Force | Out-Null
                }
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
