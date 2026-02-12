####################################################################################################
<#
.SYNOPSIS
    This function creates the Application Name / Asset ID.
.DESCRIPTION
    This function is part of the Packaging Assistant. It contains functions and variables that are in other files.
.EXAMPLE
    Get-ApplicationSubfolders
.INPUTS
    -
.OUTPUTS
    [System.Collections.Hashtable]
.NOTES
    Version         : 5.5
    Author          : Imraan Iotana
    Creation Date   : May 2025
    Last Update     : August 2025
#>
####################################################################################################

function Get-ApplicationSubfolders {
    [CmdletBinding()]
    param (
    )
    
    begin {
        ####################################################################################################
        ### MAIN OBJECT ###

        [PSCustomObject]$Local:MainObject = @{
            # Function
            FunctionDetails         = [System.String[]]@($MyInvocation.MyCommand,$PSCmdlet.ParameterSetName,$PSBoundParameters.GetEnumerator())
            # Output
            OutputObject            = [System.Collections.Hashtable]@{
                DocumentationFolder = '1. Documentation'
                SourceFilesFolder   = '2. SourceFiles'
                PackageFolder       = '3. Package'
                SCCMFolder          = '3. Package\SCCM'
                ThinClientFolder    = '3. Package\ThinClient'
                DEMFolder           = '6. DEM'
                ShortcutsFolder     = '6. DEM\Shortcuts'
                UserFilesFolder     = '6. DEM\UserFiles'
                UserRegistryFolder  = '6. DEM\UserRegistry'
                SecurityFolder      = '7. Security'
                AppLockerFolder     = '7. Security\AppLocker'
                STIGFolder          = '7. Security\STIG Hardening'
                WorkFolder          = '8. Work'
                ArchiveFolder       = '9. Archive'
                MetadataFolder      = '9. Archive\Metadata'
                BackupsFolder       = '9. Archive\Backups'
                LogFolder           = '9. Archive\Logs'
                ArchiveOtherFolder  = '9. Archive\Other'
                ScreenshotsFolder   = '9. Archive\Other\Screenshots'
            }
        }

        ####################################################################################################
        ### MAIN FUNCTION METHODS ###
        
        # Add the Begin method
        Add-Member -InputObject $Local:MainObject -MemberType ScriptMethod -Name Begin -Value { Write-Message -Begin $this.FunctionDetails }

        # Add the End method
        Add-Member -InputObject $Local:MainObject -MemberType ScriptMethod -Name End -Value { Write-Message -End $this.FunctionDetails }

        # Add the Process method
        Add-Member -InputObject $Local:MainObject -MemberType ScriptMethod -Name Process -Value {
            # Write the message
            Write-Verbose ('{0}: Returning the Application subfolders.' -f $this.FunctionDetails[0])
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
