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

        # Handlers
        [System.String]$OutputFolder        = Get-Path -OutputFolder
        [System.String]$OutputFileName      = "PAUpdate.zip"
        [System.String]$OutputFilePath      = Join-Path -Path $OutputFolder -ChildPath $OutputFileName

        ####################################################################################################

    }
    
    process {
        # VALIDATION
        if ([System.String]::IsNullOrEmpty($ZipFileToDownload)) { Write-Line "The URL is empty. No action has been taken." ; Return }

        # EXECUTION
        try {
            Write-Line "DOWNLOADING $ZipFileToDownload"
    
            Invoke-WebRequest $ZipFileToDownload -OutFile $OutputFilePath
            #Expand-Archive -Path $DownloadedFile -DestinationPath C:\Users\iotan500\Downloads -Force

            #Remove-Item -Path $DownloadedFile -Force
            Open-Folder -Path $OutputFolder
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