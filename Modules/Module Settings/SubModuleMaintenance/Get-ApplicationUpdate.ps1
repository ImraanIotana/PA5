####################################################################################################
<#
.SYNOPSIS
    This function downloads the update file from the URL.
.DESCRIPTION
    This function is part of the Packaging Assistant. It contains references to functions and variables that are in other files.
.EXAMPLE
    Get-ApplicationUpdate
.INPUTS
    -
.OUTPUTS
    This function returns no stream output.
.NOTES
    Version         : 5.7.0
    Author          : Imraan Iotana
    Creation Date   : January 2026
    Last Update     : January 2026
.COPYRIGHT
    Copyright (C) Iotana. All rights reserved.
#>
####################################################################################################

function Get-ApplicationUpdate {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        [AllowEmptyString()]
        [System.String]$URL
    )

    begin {
        ####################################################################################################
        ### MAIN PROPERTIES ###

        # Input
        [System.String]$ZipFileToDownload       = $URL

        # Download Handlers
        [System.String]$OutputFolder            = Get-Path -OutputFolder
        [System.String]$OutputFileName          = "PAUpdate.zip"
        [System.String]$OutputFilePath          = Join-Path -Path $OutputFolder -ChildPath $OutputFileName

        # Extraction Handlers
        [System.String]$CurrentVersion          = $Global:ApplicationObject.Version
        [System.String]$ExtractFolder           = Join-Path -Path $OutputFolder -ChildPath ("Update for PA $CurrentVersion")

        # Other Handlers
        [System.String]$InstallationFolder      = $Global:SMFUInstallationFolderTextBox.Text
        [System.String]$UpdateScriptFileName    = "Install-PAUpdate.ps1"
        [System.String]$UpdateScriptFilePath    = Join-Path -Path $OutputFolder -ChildPath $UpdateScriptFileName

        ####################################################################################################

    }
    
    process {
        # VALIDATION
        # If the URL is empty, return
        if ([System.String]::IsNullOrEmpty($ZipFileToDownload)) { Write-Line "The URL is empty. No action has been taken." ; Return }

        # PREPARATION
        # If the zip file already exists, remove it
        if (Test-Path -Path $OutputFilePath) { Write-Line "Removing the previous update file... ($OutputFilePath)" ; Remove-Item -Path $OutputFilePath -Force }
        # If the extract folder already exists, remove it
        if (Test-Path -Path $ExtractFolder) { Write-Line "Removing the previous extracted folder... ($ExtractFolder)" ; Remove-Item -Path $ExtractFolder -Recurse -Force }
        # If the update script already exists, remove it
        if (Test-Path -Path $UpdateScriptFilePath) { Write-Line "Removing the previous update script... ($UpdateScriptFilePath)" ; Remove-Item -Path $UpdateScriptFilePath -Force }


        # EXECUTION
        try {
            # Download the update file
            Write-Line "Downloading update... ($ZipFileToDownload)" -Type Busy
            Invoke-WebRequest $ZipFileToDownload -OutFile $OutputFilePath

            # Extract the update file
            Write-Line "Extracting the update file to folder... ($OutputFolder)" -Type Busy
            Expand-Archive -Path $OutputFilePath -DestinationPath $ExtractFolder -Force

            # Switch on the number of folders inside the extract folder
            [System.IO.DirectoryInfo[]]$FolderObjects = Get-ChildItem -Path $ExtractFolder -Directory
            switch ($FolderObjects.Count) {
                1 {
                    # Change the value of the extract folder
                    [System.String]$FolderToCopyFrom = $FolderObjects[0].FullName
                }
                default {
                    # Do nothing
                }
            }

            # Remove the update file after extraction
            Write-Line "Removing the update file... ($OutputFilePath)" -Type Busy
            Remove-Item -Path $OutputFilePath -Force

            # Create the update script
            Write-Line "Creating the update script..." -Type Busy
            [System.String]$UpdateContent = @"
            Write-Host "Starting the update process..." -ForegroundColor Yellow
            Start-Sleep -Seconds 2
            Write-Host "Removing the old files from the installation folder... ($InstallationFolder)" -ForegroundColor Yellow
            Remove-Item -Path "$InstallationFolder\*" -Recurse -Force -ErrorAction SilentlyContinue
            Write-Host "Copying the new files to the installation folder... ($InstallationFolder)" -ForegroundColor Yellow
            Copy-Item -Path "$FolderToCopyFrom\*" -Destination "$InstallationFolder" -Recurse -Force
            Write-Host "Removing the Extract folder... ($ExtractFolder)" -ForegroundColor Yellow
            Remove-Item -Path "$ExtractFolder" -Recurse -Force -ErrorAction SilentlyContinue
            Write-Host "Update process completed successfully!" -ForegroundColor Green
            pause
"@
            Set-Content -Path $UpdateScriptFilePath -Value $UpdateContent -Force -Encoding UTF8

            # Write the message
            Write-Line "The update has been downloaded." -Type Success

            # Open the extract folder
            Open-Folder -Path $ExtractFolder

            # Open the installation folder
            Open-Folder -Path $InstallationFolder
        }
        catch [System.Net.WebException] {
            # Write the error message
            Write-Line "The update file could not be reached. Please check your spelling (or your internet connection) and try again." -Type Fail
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