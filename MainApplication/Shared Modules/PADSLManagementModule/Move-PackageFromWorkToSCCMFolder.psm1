####################################################################################################
<#
.SYNOPSIS
    This function moves the package from the Work folder to the SCCM folder.
.DESCRIPTION
    This function is part of the Packaging Assistant. It contains functions and variables that are in other files.
.EXAMPLE
    Move-PackageFromWorkToSCCMFolder -ApplicationID 'Adobe_Reader_12.4'
.INPUTS
    [System.String]
    [System.Management.Automation.SwitchParameter]
.OUTPUTS
    [System.Boolean]
.NOTES
    Version         : 5.5.1
    Author          : Imraan Iotana
    Creation Date   : August 2025
    Last Update     : August 2025
#>
####################################################################################################

function Move-PackageFromWorkToSCCMFolder {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory=$true,HelpMessage='The ID of the application that will be handled.')]
        [Alias('Application','ApplicationName','Name')]
        [AllowEmptyString()]
        [System.String]
        $ApplicationID,

        [Parameter(Mandatory=$false,HelpMessage='Switch for suppressing the confirmation messages.')]
        [System.Management.Automation.SwitchParameter]
        $Force
    )

    begin {
    }
    
    process {
        try {
            # VALIDATION
            # Validate the input
            if (-Not(Confirm-Object -MandatoryString $ApplicationID)) { Write-Message -ValidationFailed ; Return }
            # Ask confirmation
            if (-Not($Force.IsPresent)) {
                [System.Boolean]$UserHasConfirmed = Get-UserConfirmation -Title 'Confirm move package' -Body ("This will MOVE the Package from the WORK folder to the SCCM folder, for the application`n`n{0}`n`nDo you want to continue?" -f $ApplicationID)
                if (-Not($UserHasConfirmed)) { Return }
            }
            # Get the properties
            [System.String]$SCCMfolder      = Get-DSLApplicationSubfolder -ApplicationID $ApplicationID -SubFolder SCCMFolder
            [System.String]$WorkFolder      = Get-DSLApplicationSubfolder -ApplicationID $ApplicationID -SubFolder WorkFolder
            [System.String]$FolderToCopy    = Join-Path -Path $WorkFolder -ChildPath $ApplicationID
            # Validate the paths
            if (-Not(Confirm-Object -MandatoryPath $SCCMfolder)) { Write-Red "The SCCM Folder could not be found: ($SCCMfolder)" ; Return }
            if (-Not(Confirm-Object -MandatoryPath $WorkFolder)) { Write-Red "The WorkFolder could not be found: ($WorkFolder)" ; Return }
            if (-Not(Confirm-Object -MandatoryPath $FolderToCopy)) { Write-Red "The FolderToCopy could not be found: ($FolderToCopy)" ; Return }


            # PREPARATION
            # Test if the folder is already present in the SCCMfolder
            [System.String]$FolderToTest    = Join-Path -Path $SCCMfolder -ChildPath $ApplicationID
            if (Test-Path -Path $FolderToTest) {
                if (-Not($Force.IsPresent)) {
                    # Ask confirmation
                    [System.Boolean]$UserHasConfirmed = Get-UserConfirmation -Title 'Overwrite existing folder' -Body 'The package is already present in the SCCM Folder. Do you want to RENAME it?'
                    if (-Not($UserHasConfirmed)) { Open-Folder -Path $Workfolder ; Return }
                }
                # Rename the folder
                [System.String]$NewName = ('{0}_{1}' -f (Get-TimeStamp -ForFileName),$ApplicationID)
                Rename-Item -Path $FolderToTest -NewName $NewName -Force | Out-Null
            }

            # MOVING
            # Move the package from the WORKfolder to the SCCMfolder
            Write-Busy ('Moving the WORKCOPY from the Workfolder to the SCCMfolder... ({0})' -f $FolderToCopy)
            Move-Item -Path $FolderToCopy -Destination $SCCMfolder -Force
            
            # TESTING
            # Test if the moved folder exists
            [System.String]$LeafName = Split-Path -Path $FolderToCopy -Leaf
            [System.String]$NewLocation = Join-Path -Path $SCCMfolder -ChildPath $LeafName
            if (Test-Path -Path $NewLocation) {
                Write-Success ('The WORKCOPY has been moved from the Workfolder to the SCCMfolder... ({0})' -f $ApplicationID)
            } else  {
                Write-Fail ('Something went wrong when moving the Workfolder. Make sure there no files or folders in use. ({0})' -f $ApplicationID)
            }

            # FINALIZATION
            # Open the folder
            Open-Folder -Path $SCCMfolder
        }
        catch {
            Write-FullError
        }
    }
    
    end {
    }
}

### END OF SCRIPT
####################################################################################################
