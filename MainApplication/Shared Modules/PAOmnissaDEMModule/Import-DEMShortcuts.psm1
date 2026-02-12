####################################################################################################
<#
.SYNOPSIS
    This function imports Shortcuts Objects into Omnissa DEM.
.DESCRIPTION
    This function is part of the Packaging Assistant. It contains functions and variables that are in other files.
.EXAMPLE
    Import-DEMShortcuts -ApplicationID 'Adobe_Reader_12.4'
.EXAMPLE
    Import-DEMShortcuts -ApplicationID 'Adobe_Reader_12.4' -PassThru
.INPUTS
    [System.String]
    [System.Management.Automation.SwitchParameter]
.OUTPUTS
    [System.Boolean]
.NOTES
    Version         : 5.5.1
    Author          : Imraan Iotana
    Creation Date   : September 2025
    Last Update     : September 2025
.COPYRIGHT
    Copyright (C) Iotana. All rights reserved.
#>
####################################################################################################

function Import-DEMShortcuts {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory=$true,HelpMessage='The ID of the application that will be handled.')]
        [AllowNull()][AllowEmptyString()]
        [System.String]
        $ApplicationID,

        [Parameter(Mandatory=$false,HelpMessage='Switch for returning the result as a boolean.')]
        [System.Management.Automation.SwitchParameter]
        $PassThru
    )

    begin {
        ####################################################################################################
        ### MAIN PROPERTIES ###

        # Function
        [System.String[]]$FunctionDetails   = @($MyInvocation.MyCommand,$PSCmdlet.ParameterSetName,$PSBoundParameters.GetEnumerator())
        [System.String]$FunctionName        = $FunctionDetails[0]

        # Output
        [System.Boolean]$OutputObject       = $null

        # Handlers
        [System.String]$DEMShortcutRepository   = $Global:ApplicationObject.Settings.DEMShortcutRepository

        ####################################################################################################

        # Write the Begin message
        Write-Function -Begin $FunctionDetails
    }
    
    process {
        # VALIDATION
        # Validate the properties
        if (Test-Object -IsEmpty $ApplicationID) { Write-Red ('The Application ID is empty.') ; Write-NoAction ; Return }
        if (-Not(Test-Path -Path $DEMShortcutRepository)) { Write-Red ('The DEM Shortcut Repository does not exist: ({0})' -f $DEMShortcutRepository ) ; Write-NoAction ; Return }
        # If the DSLShortcutsFolder does not exist, then return
        [System.String]$DSLShortcutsFolder = Get-Path -ApplicationID $ApplicationID -Subfolder ShortcutsFolder
        if (-Not(Test-Path -Path $DSLShortcutsFolder)) { Write-Red ('The Shortcuts Folder on the DSL does not exist: ({0})' -f $DSLShortcutsFolder ) ; Write-NoAction ; Return }
        # Write the message
        Write-Line ('Searching Shortcut Objects in the Shortcuts Folder. One moment please... ({0})' -f $DSLShortcutsFolder)
        # Search the shortcuts
        [System.IO.FileSystemInfo[]]$FoundFileObjects = Get-ChildItem -Path $DSLShortcutsFolder -Filter *.xml | Where-Object { Get-Content -Path $_.FullName -Raw | Select-String -Pattern $ApplicationID }
        # If none were found, then return
        if ($FoundFileObjects.Count -eq 0) { Write-Host ('No Shortcut Objects were found that contain the string ({0}).' -f $ApplicationID) ; Write-NoAction ; Return }
        # Get confirmation
        if (Test-OmnissaDEMObjects -ApplicationID $ApplicationID -Shortcuts -PassThru -OutHost) {
            [System.Boolean]$UserConfirmedOverwrite = Get-UserConfirmation -Title 'Confirm Overwrite' -Body ("The shortcuts already exist. This will OVERWRITE the existing SHORTCUTS in OMNISSA DEM for the application:`n`n{0}`n`nAre you sure?" -f $ApplicationID)
            if (-Not($UserConfirmedOverwrite)) { Return }
        } else {
            [System.Boolean]$UserConfirmedImport = Get-UserConfirmation -Title 'Confirm Import' -Body ("This will IMPORT the SHORTCUTS into OMNISSA DEM for the application:`n`n{0}`n`nAre you sure?" -f $ApplicationID)
            if (-Not($UserConfirmedImport)) { Return }
        }

        # EXECUTION
        try {
            # Import the shortcuts
            $FoundFileObjects | ForEach-Object {
                Write-Busy ('Importing the Shortcut Object ({0}) into the DEM Repository ({1})...' -f $_.Basename,$DEMShortcutRepository) -ApplicationID $ApplicationID
                Copy-Item -Path $_.FullName -Destination $DEMShortcutRepository -Force
            }
            Write-Success ('Imported the Shortcuts into the DEM Repository ({0}).' -f $DEMShortcutRepository) -ApplicationID $ApplicationID
            # Set the output
            $OutputObject = $true
        }
        catch {
            # Write the errors
            Write-FullError
            Write-Fail ('Not imported the Shortcuts into the DEM Repository ({0}).' -f $DEMShortcutRepository) -ApplicationID $ApplicationID
            # Set the output
            $OutputObject = $false
        }
    }
    
    end {
        # Write the End message
        Write-Function -End $FunctionDetails
        # Return the output
        if ($PassThru) { $OutputObject }
    }
}

### END OF SCRIPT
####################################################################################################
