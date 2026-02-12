####################################################################################################
<#
.SYNOPSIS
    This function update the DeploymentScript that is used by the Application Intake Module of the Packaging Assistant.
.DESCRIPTION
    This function is part of the Packaging Assistant. It contains functions and variables that are in other files.
.EXAMPLE
    Update-DeploymentScript
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
    Creation Date   : September 2025
    Last Update     : September 2025
.COPYRIGHT
    Copyright (C) Iotana. All rights reserved.
#>
####################################################################################################

function Update-InternalDeploymentScript {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory=$false,HelpMessage='Switch for skipping the confirmations.')]
        [System.Management.Automation.SwitchParameter]
        $Force
    )

    begin {
        ####################################################################################################
        ### MAIN PROPERTIES ###

        # Function
        [System.String]$PreFix                  = "[$($MyInvocation.MyCommand)]:"
        # Handlers
        [System.String]$DeploymentScriptPath    = $Global:ApplicationObject.Settings.DeploymentScriptPath
        [System.String]$MaintainanceName        = $Global:FAMActionComboBox.Text
        [System.String]$WorkFolder              = "$ENV:TEMP\PAWorkFolder"
        [System.String]$SearchFolder            = $Global:ApplicationObject.RootFolder

        ####################################################################################################
    }
    
    process {
        # VALIDATION
        # Validate the properties
        if (Test-Object -IsEmpty $DeploymentScriptPath) { Write-Fail "$PreFix The DeploymentScriptPath string is empty." -NoAction ; Return }
        if (-Not(Test-Path -Path $DeploymentScriptPath)) { Write-Fail "$PreFix The DeploymentScriptPath could not be reached. ($DeploymentScriptPath)" -NoAction ; Return }
        # Validate the current zipfile
        [System.String]$LeafName = Split-Path -Path $DeploymentScriptPath -Leaf
        [System.String]$CURRENTZipFilePath = (Get-ChildItem -Path $SearchFolder -Filter *.zip -Recurse | Where-Object { $_.Basename -eq $LeafName }).FullName
        if (-Not($CURRENTZipFilePath)) { Write-Fail "$PreFix The current zipfile could not be found" -NoAction ; Return }

        # CONFIRMATION
        if (-Not($Force)) {
            Write-Line "Performing Maintainance: [$MaintainanceName]"
            # Get confirmation
            [System.Boolean]$UserConfirmed = Get-UserConfirmation -Title 'Confirm Maintainance' -Body "This will REPLACE the current DeploymentScript with the latest version.`n`nAre you sure?"
            if (-Not($UserConfirmed)) { Return }
        }

        # COPYING
        # Copy the script to the temp folder
        Write-Busy "Copying the latest DeploymentScriptPath to the Temporary WorkFolder... ($WorkFolder)"
        Remove-Item -Path $WorkFolder -Recurse -Force | Out-Null
        New-Item -Path $WorkFolder -ItemType Directory -Force | Out-Null
        Copy-Item -Path $DeploymentScriptPath -Destination $WorkFolder -Recurse -Force | Out-Null
        # Validate the copy
        [System.String]$FolderToZip = Join-Path -Path $WorkFolder -ChildPath $LeafName
        if (-Not(Test-Path -Path $FolderToZip)) { Write-Fail "$PreFix The copy of the DeploymentScript has failed. ($FolderToZip)" ; Write-NoAction ; Open-Folder -Path $WorkFolder ; Return }

        # COMPRESSING
        Write-Busy "Compressing the DeploymentScript in the Temporary WorkFolder... ($WorkFolder)"
        [System.String]$NEWZipFilePath = "$FolderToZip.zip"
        Compress-Archive -Path $FolderToZip -DestinationPath $NEWZipFilePath

        # COPYING
        Write-Busy "Updating the current DeploymentScript with the NEW one..."
        Copy-Item -Path $NEWZipFilePath -Destination $CURRENTZipFilePath -Recurse -Force | Out-Null

        # CLEANUP
        Write-Busy "Removing the Temporary WorkFolder... ($WorkFolder)"
        Remove-Item -Path $WorkFolder -Recurse -Force | Out-Null
        Write-Success "The DeploymentScript has been updated."
    }
    
    end {
    }
}

### END OF SCRIPT
####################################################################################################
