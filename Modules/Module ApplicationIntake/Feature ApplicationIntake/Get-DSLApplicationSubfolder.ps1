####################################################################################################
<#
.SYNOPSIS
    This function imports the Module MECM Application.
.DESCRIPTION
    This function is part of the Packaging Assistant. It contains references to classes, functions or variables, that are in other files.
.EXAMPLE
    Import-ModuleDSLSynchronization
.INPUTS
    [System.String]
.OUTPUTS
    [Microsoft.ConfigurationManagement.PowerShell.Framework.DetectionClause]
.NOTES
    Version         : 5.5
    Author          : Imraan Iotana
    Creation Date   : August 2025
    Last Update     : August 2025
#>
####################################################################################################

function Get-DSLApplicationSubfolder {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory=$true,HelpMessage='The Application that will be handled.')]
        [Alias('ApplicationName','Application','ApplicationFolder')]
        [System.String]
        $ApplicationID,

        [Parameter(Mandatory=$true,HelpMessage='The subfolder of the application that must be retrieved.')]
        [ValidateSet('DocumentationFolder','SCCMFolder','AppLockerFolder','ShortcutsFolder','WorkFolder','MetadataFolder','BackupsFolder')]
        [System.String]
        $Subfolder
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
            Subfolder       = $Subfolder
            # Validation
            #ValidationArray = [System.Boolean[]]@()
            # Handlers
            DSLFolder       = [System.String](Get-Path -DSLFolder)
            # Output
            OutputObject    = [System.String]::Empty
        }

        ####################################################################################################
        ### MAIN FUNCTION METHODS ###

        # Add the Begin method
        $Local:MainObject | Add-Member -MemberType ScriptMethod -Name Begin -Value { Write-Message -Begin $this.FunctionDetails }

        # Add the End method
        $Local:MainObject | Add-Member -MemberType ScriptMethod -Name End -Value { Write-Message -End $this.FunctionDetails }

        # Add the Process method
        $Local:MainObject | Add-Member -MemberType ScriptMethod -Name Process -Value {
            # Get the application folder on the DSL
            [System.String]$DSLFolder               = Get-Path -DSLFolder
            [System.String]$ApplicationFolderPath   = (Get-ChildItem -Path $DSLFolder -Recurse -Depth 1 -Directory | Where-Object { $_.Name -eq $ApplicationID }).FullName
            [System.String]$SubFolderLeaf           = (Get-ApplicationSubfolders).($this.SubFolder)
            $this.OutputObject                      = Join-Path -Path $ApplicationFolderPath -ChildPath $SubFolderLeaf
        }

        ####################################################################################################

        $Local:MainObject.Begin()        
    }
    
    process {
        $Local:MainObject.Process()
    }

    end {
        $Local:MainObject.End()
        # Return the output
        $Local:MainObject.OutputObject
    }
}

### END OF SCRIPT
####################################################################################################
