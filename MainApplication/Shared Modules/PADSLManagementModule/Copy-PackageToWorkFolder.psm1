####################################################################################################
<#
.SYNOPSIS
    This function copies the package from the SCCM folder to the Work folder.
.DESCRIPTION
    This function is part of the Packaging Assistant. It contains references to classes, functions or variables, that are in other files.
.EXAMPLE
    Copy-PackageToWorkFolder -ApplicationID 'Adobe_Reader_12.4'
.INPUTS
    [System.String]
    [System.Management.Automation.SwitchParameter]
.OUTPUTS
    This function returns no stream output.
.NOTES
    Version         : 5.5.1
    Author          : Imraan Iotana
    Creation Date   : August 2025
    Last Update     : August 2025
.COPYRIGHT
    Copyright (C) Iotana. All rights reserved.
#>
####################################################################################################

function Copy-PackageToWorkFolder {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory=$true,HelpMessage='The ID of the application that will be handled.')]
        [Alias('Application','ApplicationName','Name')]
        [AllowEmptyString()]
        [System.String]
        $ApplicationID,

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


        ####################################################################################################
        ### SUPPORTING FUNCTIONS ###

        function Remove-ExistingFolder {
            # Remove the existing folder
            Write-Busy "Removing the existing folder from the Workfolder... ($ExistingFolder)"
            Remove-WithGUI -Path $ExistingFolder -Force
        }

        function Copy-IfNotExistYet {
            # Copy the package from the SCCMfolder to the WORKfolder
            Write-Busy "Making a WORKCOPY in the Workfolder... ($ApplicationID)"
            Copy-WithGUI -ThisFolder $FolderToCopy -IntoThisFolder $Workfolder -Overwrite
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
            # Validate the input
            if (-Not(Confirm-Object -MandatoryString $ApplicationID)) { Write-Message -ValidationFailed ; Return }
            # Ask confirmation
            if ($Confirm.IsPresent) {
                [System.Boolean]$UserHasConfirmed = Get-UserConfirmation -Title 'Confirm copy package' -Body ("This will COPY the SCCM Package to the WORK folder for the application:`n`n{0}`n`nDo you want to continue?" -f $ApplicationID)
                if (-Not($UserHasConfirmed)) { Return }
            }
            # Get the properties
            [System.String]$SCCMfolder      = Get-DSLApplicationSubfolder -ApplicationID $ApplicationID -SubFolder SCCMFolder
            [System.String]$FolderToCopy    = Join-Path -Path $SCCMfolder -ChildPath $ApplicationID
            [System.String]$WorkFolder      = Get-DSLApplicationSubfolder -ApplicationID $ApplicationID -SubFolder WorkFolder
            # Validate the paths
            if (-Not(Test-Path -Path $SCCMfolder)) { Write-Host "The SCCM folder is not present. The copy will be skipped. ($SCCMfolder)" ; Return }
            if (-Not(Test-Path -Path $FolderToCopy)) { Write-Host "The sourcefolder is not present. The copy will be skipped. ($FolderToCopy)" ; Return }
            if (-Not(Test-Path -Path $WorkFolder)) { Write-Host "The WorkFolder is not present. The copy will be skipped. ($WorkFolder)" ; Return }

            # EXECUTION
            # Test if the folder is already present in the WORKfolder
            [System.String]$ExistingFolder = Join-Path -Path $WorkFolder -ChildPath $ApplicationID
            if (Test-Path -Path $ExistingFolder) {
                # If Force is present, then overwrite without confirmation
                if ($Force.IsPresent) {
                    Write-Host ('The Force parameter is present. The existing Work Copy will be overwritten!')
                    Copy-AndOverWrite
                } else {
                    Write-Host "The Work Copy already exists for application ($ApplicationID)"
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
