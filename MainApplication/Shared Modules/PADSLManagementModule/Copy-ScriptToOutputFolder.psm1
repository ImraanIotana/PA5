####################################################################################################
<#
.SYNOPSIS
    This function copies the Deployment Script from the network folder to the Output folder.
.DESCRIPTION
    This function is part of the Packaging Assistant. It may contain functions or variables, that are in other files.
.EXAMPLE
    Copy-ScriptToOutputFolder
.INPUTS
    [System.String]
    [System.Management.Automation.SwitchParameter]
.OUTPUTS
    This function returns no stream output.
.NOTES
    Version         : 5.5.2
    Author          : Imraan Iotana
    Creation Date   : November 2025
    Last Update     : November 2025
.COPYRIGHT
    Copyright (C) Iotana. All rights reserved.
#>
####################################################################################################

function Copy-ScriptToOutputFolder {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory=$false,HelpMessage='Switch for showing the confirmation messages.')]
        [System.Management.Automation.SwitchParameter]
        $Confirm,

        [Parameter(Mandatory=$false,HelpMessage='Switch for suppressing the confirmation messages.')]
        [System.Management.Automation.SwitchParameter]
        $Force
    )

    begin {
        ####################################################################################################
        ### MAIN PROPERTIES ###

        # Handlers
        [System.String]$FolderToCopy = $Global:ApplicationObject.Settings.DeploymentScriptPath
        [System.String]$OutputFolder = Get-Path -OutputFolder

        ####################################################################################################
        ### SUPPORTING FUNCTIONS ###

        function Remove-ExistingFolder {
            # Remove the existing folder
            Write-Busy "Removing the existing folder from the Workfolder... ($ExistingFolder)"
            Remove-Item -Path $ExistingFolder -Recurse -Force | Out-Null
        }

        function Copy-IfNotExistYet {
            # Copy the package from the SCCMfolder to the WORKfolder
            Write-Busy "Making a WORKCOPY in the Workfolder... ($ApplicationID)"
            Copy-Item -Path $FolderToCopy -Destination $WorkFolder -Recurse -Force | Out-Null
            Write-Success "The WORKCOPY has been created in the Workfolder... ($ApplicationID)"
            # Open the folder
            if ($Confirm.IsPresent) { Open-Folder -Path $Workfolder }
        }

        function Copy-AndOverWrite {
            Remove-ExistingFolder
            Copy-IfNotExistYet
        }

        ####################################################################################################
    }
    
    process {
        try {
            # VALIDATION
            # Validate the paths
            if (-Not(Test-Path -Path $FolderToCopy)) { Write-Host "The Source folder is not present. No action has been taken. ($FolderToCopy)" ; Return }
            if (-Not(Test-Path -Path $OutputFolder)) { Write-Host "The Output folder is not present. No action has been taken. ($OutputFolder)" ; Return }
            # Ask confirmation
            if (-Not($Force.IsPresent)) {
                [System.Boolean]$UserConfirmed = Get-UserConfirmation -Title 'Confirm copy script' -Body ("This will COPY the SCCM Package to the WORK folder for the application:`n`n{0}`n`nDo you want to continue?" -f $ApplicationID)
                if (-Not($UserConfirmed)) { Return }
            }

            # EXECUTION
            Write-Busy "$FolderToCopy will be copied..."
            # Test if the folder is already present in the WORKfolder
            [System.String]$ExistingFolder = Join-Path -Path $OutputFolder -ChildPath (Split-Path -Path $FolderToCopy -Leaf)
            if (Test-Path -Path $ExistingFolder) {
                # If Force is present, then overwrite without confirmation
                if ($Force.IsPresent) {
                    Write-Host ('The Force parameter is present. The existing folder will be overwritten!')
                    Copy-AndOverWrite
                } else {
                    Write-Host "The folder already exists ($ExistingFolder)"
                    if ($Confirm.IsPresent) {
                        # Ask confirmation
                        [System.Boolean]$UserHasConfirmed = Get-UserConfirmation -Title 'Overwrite existing Work Copy' -Body 'The Work Copy is already present in the WorkFolder. Do you want to OVERWRITE it?'
                        if (-Not($UserHasConfirmed)) {
                            Open-Folder -Path $Workfolder ; Return
                        }
                        else {
                            Write-Busy "The existing Work Copy will be overwritten!"
                            Copy-AndOverWrite
                        }
                    }
                }
            } else {
                Write-Line "The Work Copy does not exist yet. A new copy will be made."
                Copy-IfNotExistYet
            }
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
