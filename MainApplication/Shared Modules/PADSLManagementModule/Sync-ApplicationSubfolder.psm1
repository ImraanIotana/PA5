####################################################################################################
<#
.SYNOPSIS
    This function ...
.DESCRIPTION
    This function is self-contained and does not refer to functions, variables or classes, that are in other files.
    This function is part of the Packaging Assistant. It contains references to classes, functions or variables, that are in other files.
    External classes    : -
    External functions  : -
    External variables  : $Global:ApplicationObject
.EXAMPLE
    Function-Template -Initialize
.EXAMPLE
    Function-Template -Write -PropertyName OutputFolder -PropertyValue 'C:\Demo\WorkFolder'
.EXAMPLE
    Function-Template -Read -PropertyName OutputFolder
.EXAMPLE
    Function-Template -Remove -PropertyName OutputFolder
.INPUTS
    [System.String]
    [System.Management.Automation.SwitchParameter]
.OUTPUTS
    This function returns no stream output.
    [System.Boolean]
    [System.String]
.NOTES
    Version         : 5.5.1
    Author          : Imraan Iotana
    Creation Date   : August 2025
    Last Update     : August 2025
#>
####################################################################################################

function Sync-ApplicationSubfolder {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory=$true,ParameterSetName='SyncFromLocalToDSL',HelpMessage='The ID of the application that will be handled.')]
        [Alias('Application','ApplicationName','Name')]
        [System.String]
        $ApplicationID,

        [Parameter(Mandatory=$true,ParameterSetName='SyncFromLocalToDSL',HelpMessage='Switch for synching from the local folder to the DSL.')]
        [System.Management.Automation.SwitchParameter]
        $FromLocalToDSL,

        [Parameter(Mandatory=$true,ParameterSetName='SyncFromLocalToDSL',HelpMessage='The subfolder of the application that will be synched.')]
        [System.String]
        $Subfolder
    )

    begin {
        ####################################################################################################
        ### MAIN PROPERTIES ###

        # Function
        [System.String[]]$FunctionDetails   = @($MyInvocation.MyCommand,$PSCmdlet.ParameterSetName,$PSBoundParameters.GetEnumerator())
        # Confirmation Handlers
        [System.String]$ConfirmationTitle   = 'Confirm Synchronization'
        [System.String]$ConfirmationBody    = "This will COPY the OMNISSA DEM Files from your LOCAL Folder to the DSL folder for the application:`n`n{0}`n`nAre you sure?"

        ####################################################################################################
        ### SUPPORTING FUNCTIONS ###

        function Confirm-Input {
            # Validate the input
            [System.String[]]$ValidSubFolders = (Get-ApplicationSubfolders).Keys
            if ($ValidSubFolders.Contains($Subfolder)) {
                Return $true
            } else {
                Write-Red ('The entered SubFolder ({0}) is not a valid name.' -f $Subfolder)
                Write-Line "Valid names are: $ValidSubFolders"
                Return $false
            }
        }

        function Get-LOCALSubFolder {
            [System.String]$LOCALApplicationFolder  = Join-Path -Path (Get-Path -OutputFolder) -ChildPath $ApplicationID
            [System.String]$LOCALSubFolder          = Join-Path -Path $LOCALApplicationFolder -ChildPath (Get-ApplicationSubfolders).$Subfolder
            # Return the result
            $LOCALSubFolder
        }

        ####################################################################################################

        # Write the Begin message
        Write-Function -Begin $FunctionDetails
    }
    
    process {
        try {
            # Validate the input
            if (-Not(Confirm-Input)) { Return }
            # Get user confirmation
            [System.Boolean]$UserHasConfirmed = Get-UserConfirmation -Title $ConfirmationTitle -Body ($ConfirmationBody -f $ApplicationID)
            if (-Not($UserHasConfirmed)) { Return }
            # Set the properties
            [System.String]$DSLFolderToSync     = Get-DSLApplicationSubfolder -ApplicationID $ApplicationID -Subfolder $Subfolder
            [System.String]$LOCALFolderToSync   = Get-LOCALSubFolder
            [System.Object[]]$ObjectsInsideLOCALfolder = Get-ChildItem -Path $LOCALFolderToSync
            # Write the message
            Write-Yellow ('Uploading the files from LOCAL to DSL for ({0})' -f $ApplicationID)
            if ($ObjectsInsideLOCALfolder.Count -eq 0) {
                Write-Line ('No files to backup in subfolder ({0}).' -f $LOCALFolderToSync)
            }
            # Backup the AppLocker files on the DSL
            if (New-SubFolderBackup -ApplicationID $ApplicationID -SubFolder $Subfolder -Force -PassThru) {
                # Copy the AppLocker Files from LOCAL to DSL
                Copy-Item -Path "$LOCALFolderToSync\*" -Destination $DSLFolderToSync -Recurse -Force
                Write-Green ('The files have been copied from ({0}) to ({1})...' -F $LOCALFolderToSync, $DSLFolderToSync)
            } else {
                Write-Warning 'Something went wrong with the backup. The process has been halted.'
            }
        }
        catch {
            Write-FullError
        }
    }
    
    end {
        # Write the End message
        Write-Function -End $FunctionDetails
    }
}

### END OF SCRIPT
####################################################################################################
