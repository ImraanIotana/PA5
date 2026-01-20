####################################################################################################
<#
.SYNOPSIS
    This function copies the package from the SCCM folder to the Work folder.
.DESCRIPTION
    This function is part of the Packaging Assistant. It contains references to classes, functions or variables, that are in other files.
.EXAMPLE
    Update-ScriptInWorkFolder -ApplicationID 'Adobe_Reader_12.4'
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

function Update-ScriptInWorkFolder {
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

        # Handlers
        [System.String]$FolderToCopy        = '\\ksmod.nl\KSpackages\SoftwareLibrary\_Administration\Other\PowerShell\UniversalDeploymentScript\Deploy-ApplicationSupport'

        ####################################################################################################
        ### SUPPORTING FUNCTIONS ###

        function Remove-ExistingFolder {
            # Remove the existing folder
            Write-Busy "Removing the existing Script Folder from the Workfolder... ($ExistingFolder)"
            Remove-Item -Path $ExistingFolder -Recurse -Force
            #Remove-WithGUI -Path $ExistingFolder -Force
        }

        function Copy-IfNotExistYet {
            # Copy the package from the SCCMfolder to the WORKfolder
            Write-Busy "Copying the Script Folder to the Workfolder... ($ApplicationID)"
            Copy-WithGUI -ThisFolder $FolderToCopy -IntoThisFolder $DestinationFolder -Overwrite
            Write-Success "The new Scripts have been copied from the Script Folder to the Workfolder... ($ApplicationID)"
            # Open the folder
            #if ($Confirm.IsPresent) { Open-Folder -Path $DestinationFolder }
        }

        function Copy-AndOverWrite {
            Remove-ExistingFolder
            Copy-IfNotExistYet
        }

        ####################################################################################################
    }
    
    process {
        try {
            # Validate the input
            if (-Not(Confirm-Object -MandatoryString $ApplicationID)) { Write-Message -ValidationFailed ; Return }
            # Ask confirmation
            if ($Confirm.IsPresent) {
                [System.Boolean]$UserHasConfirmed = Get-UserConfirmation -Title 'Confirm update script' -Body ("This will UPDATE the SCRIPT in the WORK folder for the application:`n`n{0}`n`nDo you want to continue?" -f $ApplicationID)
                if (-Not($UserHasConfirmed)) { Return }
            }
            # Get the properties
            [System.String]$WorkFolder = Get-Path -ApplicationID $ApplicationID -SubFolder WorkFolder
            [System.String]$DestinationFolder = Join-Path -Path $WorkFolder -ChildPath $ApplicationID
            # Validate the paths
            [System.Collections.Generic.List[System.Boolean]]$ValidationArrayList = @()
            $FolderToCopy,$WorkFolder,$DestinationFolder | ForEach-Object { $ValidationArrayList.Add((Confirm-Object -MandatoryPath $_)) }
            #if (-Not(Confirm-Object -MandatoryPath $_)) { Write-Fail ('A mandatory folder could not be found: ({0})' -f $_) ; Return }
            if ($ValidationArrayList -contains $false) { Write-Fail ('A mandatory folder could not be found.') ; Write-NoAction ; Return }
            # Test if the folder is already present in the WORKfolder
            [System.String]$ExistingFolder = Join-Path -Path $DestinationFolder -ChildPath 'Deploy-ApplicationSupport'
            if (Test-Path -Path $ExistingFolder) {
                # If Force is present, then overwrite without confirmation
                if ($Force.IsPresent) {
                    Write-Line ('The Force parameter is present. The existing Work Copy will be overwritten!')
                    Copy-AndOverWrite
                } else {
                    Write-Host ('The Script Folder already exists for application ({0})' -f $ApplicationID)
                    if ($Confirm.IsPresent) {
                        # Ask confirmation
                        [System.Boolean]$UserHasConfirmed = Get-UserConfirmation -Title 'Overwrite existing Script Folder' -Body 'The Script Folder is already present in the WorkFolder. Do you want to OVERWRITE it?'
                        if (-Not($UserHasConfirmed)) {
                            #Open-Folder -Path $Workfolder
                            Return
                        }
                        else {
                            Write-Busy ('The existing Script Folder will be overwritten!')
                            Copy-AndOverWrite
                        }
                    }
                }
            } else {
                Write-Line ('The Script Folder does not exist yet. A new copy will be made.')
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
