####################################################################################################
<#
.SYNOPSIS
    This function moves your local screenshots to the Screenshots folder of the Application.
.DESCRIPTION
    This function is part of the Packaging Assistant. It contains functions and variables that are in other files.
.EXAMPLE
    Move-ScreenShotsToDSL -ApplicationID 'Adobe_Reader_12.4'
.INPUTS
    [System.String]
    [System.Management.Automation.SwitchParameter]
.OUTPUTS
    This function returns no stream output.
.NOTES
    Version         : 5.5.1
    Author          : Imraan Iotana
    Creation Date   : September 2025
    Last Update     : September 2025
.COPYRIGHT
    Copyright (C) Iotana. All rights reserved.
#>
####################################################################################################

function Move-ScreenShotsToDSL {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory=$true,HelpMessage='The ID of the application that will be handled.')]
        [Alias('Application','ApplicationName','Name')]
        [AllowNull()][AllowEmptyString()]
        [System.String]
        $ApplicationID
    )

    begin {
        ####################################################################################################
        ### MAIN PROPERTIES ###

        # Handlers
        [System.String]$NetworkScreenshotsFolder    = ($Global:ApplicationObject.Settings.NetworkScreenshotsFolderFix -f $ENV:USERNAME)
        #[System.String]$LocalScreenshotsFolder      = 'To be determined...'

        ####################################################################################################
    }
    
    process {
        # VALIDATION
        # Validate the ApplicationID
        if (Test-Object -IsEmpty $ApplicationID) { Write-Red "The Application ID is empty." -NoAction ; Return }
        # Validate the UserScreenshotsFolder
        [System.String]$UserScreenshotsFolder = $NetworkScreenshotsFolder
        if (Test-Object -IsEmpty $UserScreenshotsFolder) {
            Write-Red "The User's ScreenshotsFolder could not be obtained." -NoAction ; Return
        }
        if (-Not(Test-Path -Path $UserScreenshotsFolder) ){
            Write-Red "The User's ScreenshotsFolder could not be reached. Make sure it exists: ($UserScreenshotsFolder)" -NoAction ; Return
        }
        # Validate the ApplicationScreenshotsFolder
        [System.String]$ApplicationScreenshotsFolder = Get-Path -ApplicationID $ApplicationID -Subfolder ScreenshotsFolder
        if (Test-Object -IsEmpty $ApplicationScreenshotsFolder) {
            Write-Red "The ScreenshotsFolder for the Application ($ApplicationID) could not be obtained." -NoAction ; Return
        }
        if (-Not(Test-Path -Path $ApplicationScreenshotsFolder)) {
            Write-Red "The ScreenshotsFolder for the Application ($ApplicationID) could not be reached. Make sure it exists: ($ApplicationScreenshotsFolder)" -NoAction ; Return
        }

        # CONFIRMATION
        # Get confirmation
        [System.Boolean]$UserConfirmed = Get-UserConfirmation -Title 'Move screenshots' -Body ("This will MOVE your SCREENSHOTS to the DSL for the application:`n`n$ApplicationID`n`nAre you sure?")
        if (-Not($UserConfirmed)) { Return }

        # EXECUTION
        try {
            # Set the SourceFolder
            [System.String]$SourceFolder = $UserScreenshotsFolder
            # Check the amount of files
            [System.IO.FileSystemInfo[]]$ScreenshotObjects = Get-ChildItem -Path $SourceFolder -Recurse -File -ErrorAction SilentlyContinue
            if ($ScreenshotObjects.Count -eq 0) { Write-Green "No files were found in the Screenshots folder. No screenshots were moved. ($SourceFolder)" ; Return }
            # Get the DestinationFolder
            [System.String]$DestinationFolder = $ApplicationScreenshotsFolder
            # Move the screenshots
            foreach ($Item in $ScreenshotObjects) {
                Write-Busy "Moving screenshot: ($($Item.FullName))"
                Move-Item -Path $Item.FullName -Destination $DestinationFolder
            }
            Write-Success "The screenshots have been moved to: ($DestinationFolder)"
        }
        catch {
            Write-FullError
        }

        # TESTING
        #Open-Folder -Path $DestinationFolder
    }
    
    end {
    }
}

### END OF SCRIPT
####################################################################################################
