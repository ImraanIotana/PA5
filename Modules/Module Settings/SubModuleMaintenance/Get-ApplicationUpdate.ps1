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
        [System.String]$ZipFileToDownload   = $URL

        # Download Handlers
        [System.String]$OutputFolder        = Get-Path -OutputFolder
        [System.String]$OutputFileName      = "PAUpdate.zip"
        [System.String]$OutputFilePath      = Join-Path -Path $OutputFolder -ChildPath $OutputFileName

        # Extraction Handlers
        [System.String]$CurrentVersion      = $Global:ApplicationObject.Version
        [System.String]$ExtractFolder       = Join-Path -Path $OutputFolder -ChildPath ("Update for PA $CurrentVersion")

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

        # EXECUTION
        try {
            # Download the update file
            Write-Line "Downloading update... ($ZipFileToDownload)" -Type Busy
            Invoke-WebRequest $ZipFileToDownload -OutFile $OutputFilePath

            # Extract the update file
            Write-Line "Extracting the update file to folder... ($OutputFolder)" -Type Busy
            Expand-Archive -Path $OutputFilePath -DestinationPath $ExtractFolder -Force

            # Remove the update file after extraction
            Write-Line "Removing the update file... ($OutputFilePath)" -Type Busy
            Remove-Item -Path $OutputFilePath -Force

            # Write the message
            Write-Line "The update has been downloaded." -Type Success

            # Open the extract folder
            Open-Folder -Path $ExtractFolder
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