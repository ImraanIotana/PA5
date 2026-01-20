####################################################################################################
<#
.SYNOPSIS
    This function imports the Module MECM Application.
.DESCRIPTION
    This function is part of the Packaging Assistant. It contains references to classes, functions or variables, that are in other files.
.EXAMPLE
    Import-ModuleDSLSynchronization
.INPUTS
    [System.Windows.Forms.TabControl]
.OUTPUTS
    This function returns no stream-output.
.NOTES
    Version         : 5.5
    Author          : Imraan Iotana
    Creation Date   : July 2025
    Last Update     : July 2025
#>
####################################################################################################

function Sync-DSLFolder {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory=$true,ParameterSetName='SyncFromDSLToLOCAL',HelpMessage='Switch for synching from the DSL to the local folder.')]
        [System.Management.Automation.SwitchParameter]
        $FromDSLToLocal,

        [Parameter(Mandatory=$true,ParameterSetName='SyncFromLocalToDSL',HelpMessage='Switch for synching from the local folder to the DSL.')]
        [System.Management.Automation.SwitchParameter]
        $FromLocalToDSL,

        [Parameter(Mandatory=$true,HelpMessage='The ApplicationID of the Application.')]
        [System.String]
        $ApplicationID,

        [Parameter(Mandatory=$false,HelpMessage='Switch for synching only the AppLocker file.')]
        [System.Management.Automation.SwitchParameter]
        $AppLocker,

        [Parameter(Mandatory=$false,HelpMessage='Switch for synching only the workfolder.')]
        [System.Management.Automation.SwitchParameter]
        $Smart,

        [Parameter(Mandatory=$false,HelpMessage='Switch for synching all files and folders.')]
        [System.Management.Automation.SwitchParameter]
        $Full
    )

    begin {
        ####################################################################################################
        ### MAIN OBJECT ###

        # Create the main object
        [PSCustomObject]$Local:MainObject = @{
            # Function
            FunctionDetails     = [System.String[]]@($MyInvocation.MyCommand,$PSCmdlet.ParameterSetName,$PSBoundParameters.GetEnumerator())
            # Input
            ApplicationID       = $ApplicationID
            # Input switches
            AppLocker           = $AppLocker
            Smart               = $Smart
            Full                = $Full
            # Confirmation Handlers
            ConfirmationTitle1  = [System.String]'Confirm Synchronization'
            ConfirmationBody1   = [System.String]"This will COPY the APPLOCKER Files from your LOCAL Folder to the DSL folder for the application:`n`n{0}`n`nAre you sure?"
        }

        ####################################################################################################
        ### MAIN FUNCTION METHODS ###

        # Add the Begin method
        $Local:MainObject | Add-Member -MemberType ScriptMethod -Name Begin -Value { Write-Message -Begin $this.FunctionDetails }

        # Add the End method
        $Local:MainObject | Add-Member -MemberType ScriptMethod -Name End -Value { Write-Message -End $this.FunctionDetails }

        # Add the Process method
        $Local:MainObject | Add-Member -MemberType ScriptMethod -Name Process -Value {
            # Set the ParameterSetName
            [System.String]$ParameterSetName = $this.FunctionDetails[1]
            # Switch on the ParameterSetName
            switch ($ParameterSetName) {
                'SyncFromDSLToLOCAL'    {
                    if ($this.Full.IsPresent)   { $this.SyncFULLFromDSLToLOCAL($this.ApplicationID)}
                    if ($this.Smart.IsPresent)  { $this.SyncSMARTFromDSLToLOCAL($this.ApplicationID)}
                }
                'SyncFromLocalToDSL'    {
                    if ($this.AppLocker.IsPresent) { $this.SyncAPPLOCKERFILESFromLOCALToDSL($this.ApplicationID)} else { Write-NoAction }
                }
            }

        }

        ####################################################################################################
        ### MAIN PROCESSING METHODS ###

        # Add the SyncAPPLOCKERFILESFromLOCALToDSL method
        $Local:MainObject | Add-Member -MemberType ScriptMethod -Name SyncAPPLOCKERFILESFromLOCALToDSL -Value { param([System.String]$ApplicationID)
            try {
                # Get user confirmation
                [System.Boolean]$UserHasConfirmed = Get-UserConfirmation -Title ($this.ConfirmationTitle1) -Body ($this.ConfirmationBody1 -f $ApplicationID)
                if (-Not($UserHasConfirmed)) { Return }
                # Set the properties
                [System.String]$DSLAppLockerFolder      = Get-DSLApplicationSubfolder -ApplicationID $ApplicationID -Subfolder AppLockerFolder
                [System.String]$LOCALAppLockerFolder    = $this.GetLOCALAppLockerFolder($ApplicationID)
                [System.Object[]]$ObjectsInsideLOCALfolder = Get-ChildItem -Path $LOCALAppLockerFolder
                # Write the message
                Write-Line ('Uploading AppLocker Files from LOCAL to DSL for ({0})' -f $ApplicationID)
                if ($ObjectsInsideLOCALfolder.Count -eq 0) {
                    Write-Host ('No files to backup in subfolder ({0}).' -f $DSLAppLockerFolder)
                }
                # Backup the AppLocker files on the DSL
                if (New-ApplicationBackup -ApplicationID $ApplicationID -Type AppLockerFolder) {
                    # Remove the old files
                    Remove-Item -Path ("$DSLAppLockerFolder\*") -Recurse -Force
                    # Copy the AppLocker Files from LOCAL to DSL
                    Copy-Item -Path "$LOCALAppLockerFolder\*" -Destination $DSLAppLockerFolder -Recurse -Force
                    Write-Success ('The AppLocker Files have been copied from ({0}) to ({1})...' -F $LOCALAppLockerFolder, $DSLAppLockerFolder)
                } else {
                    Write-Fail 'Something went wrong with the backup. The process has been halted.'
                }
            }
            catch {
                Write-FullError
            }
        }

        # Add the SyncFULLFromDSLToLOCAL method
        $Local:MainObject | Add-Member -MemberType ScriptMethod -Name SyncFULLFromDSLToLOCAL -Value { param([System.String]$ApplicationID)
            try {
                # Get the Applicationfolder on the DSL
                [System.String]$DSLApplicationFolder    = Get-DSLApplicationFolder -ApplicationID $ApplicationID
                [System.Double]$FolderSizeInMB = Get-FolderSize -Path $DSLApplicationFolder
                # Get user confirmation
                [System.Boolean]$UserHasConfirmed = Get-UserConfirmation -Title ('Confirm FULL download from DSL to LOCAL') -Body ('This will COPY the ENTIRE folder ({0}) from the DSL to your LOCAL folder. The folder size is ({1}) MB. Are you sure?' -f $ApplicationID, $FolderSizeInMB)
                if (-Not($UserHasConfirmed)) { Return }
                #Write-Host ('Synching the full folder from the DSL to your Local Output folder for ({0})' -f $ApplicationID) -ForegroundColor Yellow
                # Get the properties
                [System.String]$LOCALApplicationFolder  = $this.GetLOCALApplicationFolder($ApplicationID)
                [System.String]$LOCALOUTPUTFolder       = Get-SharedAssetPath -OutputFolder
                # If the DSL folder does not exist then return
                if (-Not(Test-Path -Path $DSLApplicationFolder)) { Write-FullError ('The DSL folder does NOT exists! ({0})' -f $DSLApplicationFolder) ; Return }
                # If the local folder does not exist, then copy it, else remove it first
                if (Test-Path -Path $LOCALApplicationFolder) {
                    # Get user confirmation
                    [System.Boolean]$UserHasConfirmedOverWrite = Get-UserConfirmation -Title ('Overwrite existing local folder') -Body ('The LOCAL folder ALREADY EXISTS ({0}). Do you want to OVERWRITE it?' -f $LOCALApplicationFolder)
                    if (-Not($UserHasConfirmedOverWrite)) { Return }
                }
                # If user has confirmed, the remove the folder
                if ($UserHasConfirmedOverWrite) {
                    Write-Host ('Removing the LOCAL folder: ({0})' -f $LOCALApplicationFolder)
                    Remove-Item -Path $LOCALApplicationFolder -Recurse -Force | Out-Null
                    while (Test-Path -Path $LOCALApplicationFolder) { Start-Sleep -Seconds 1 }
                }
                # Copy the folder
                Write-Host ('Synching DSL Folder to LOCAL ({0})' -f $DSLApplicationFolder) -ForegroundColor DarkGray
                Copy-Item -Path $DSLApplicationFolder -Destination $LOCALOUTPUTFolder -Recurse -Force | Out-Null
                Write-Host ('The DSL folder has been copied to your LOCAL folder: ({0})' -f $LOCALApplicationFolder) -ForegroundColor Green
                Open-Folder -Path $LOCALApplicationFolder
            }
            catch {
                Write-FullError
            }
        }

        # Add the SyncSMARTFromDSLToLOCAL method
        $Local:MainObject | Add-Member -MemberType ScriptMethod -Name SyncSMARTFromDSLToLOCAL -Value { param([System.String]$ApplicationID)
            try {
                # Get the Applicationfolder on the DSL
                [System.String]$DSLApplicationFolder    = Get-DSLApplicationFolder -ApplicationID $ApplicationID
                [System.String[]]$SubFoldersToIgnore    = @((Get-ApplicationSubfolders).SourceFilesFolder,(Get-ApplicationSubfolders).PackageFolder)
                [System.Double]$FolderSizeInMB          = Get-FolderSize -Path $DSLApplicationFolder
                # Get user confirmation
                [System.Boolean]$UserConfirmedSmartSync = Get-UserConfirmation -Title ('Confirm SMART download from DSL to LOCAL') -Body ("This will copy SELECTED folders from the DSL to your LOCAL folder. Are you sure?`n`nApplication: {0}`nFolder size: ({1}) MB. " -f $ApplicationID, $FolderSizeInMB)
                if (-Not($UserConfirmedSmartSync)) { Return }
                Write-Line ('Synching selected folders from the DSL to your Local Output folder for ({0})' -f $ApplicationID)
                # Make a work copy of the package
                #Copy-PackageToWorkFolder -ApplicationID $ApplicationID
                # Get the properties
                [System.String]$LOCALOUTPUTFolder       = Get-SharedAssetPath -OutputFolder
                [System.String]$LOCALApplicationFolder  = Join-Path -Path $LOCALOUTPUTFolder -ChildPath $ApplicationID
                # If the DSL folder does not exist then return
                if (-Not(Test-Path -Path $DSLApplicationFolder)) { Write-FullError ('The DSL folder does NOT exists: ({0})' -f $DSLApplicationFolder) ; Return }
                # If the local folder already exists, remove it first
                if (Test-Path -Path $LOCALApplicationFolder) {
                    # Get user confirmation
                    [System.Boolean]$UserConfirmedOverWrite = Get-UserConfirmation -Title ('Overwrite existing local folder') -Body ('The LOCAL folder ALREADY EXISTS ({0}). Do you want to OVERWRITE it?' -f $LOCALApplicationFolder)
                    if (-Not($UserConfirmedOverWrite)) { Return }
                }
                # If user confirmed, then remove the folder, and make a new one
                if ($UserConfirmedOverWrite) {
                    Write-Busy ('Removing the LOCAL folder: ({0})' -f $LOCALApplicationFolder)
                    Remove-Item -Path $LOCALApplicationFolder -Recurse -Force | Out-Null
                    while (Test-Path -Path $LOCALApplicationFolder) { Start-Sleep -Seconds 1 }
                }
                # Copy the folder
                Write-Busy ('Smart-Synching DSL Folder to LOCAL ({0})' -f $DSLApplicationFolder)
                New-Item -Path $LOCALApplicationFolder -ItemType Directory -Force | Out-Null
                [System.IO.DirectoryInfo[]]$FolderObjectsToCopy = Get-ChildItem -Path $DSLApplicationFolder -Directory -Exclude $SubFoldersToIgnore
                foreach ($FolderObject in $FolderObjectsToCopy) { Copy-Item -Path $FolderObject.FullName -Destination $LOCALApplicationFolder -Recurse -Force | Out-Null }
                Write-Success ('The DSL folder has been Smart-Synched to your LOCAL folder: ({0})' -f $LOCALApplicationFolder)
                Open-Folder -Path $LOCALApplicationFolder
            }
            catch {
                Write-FullError
            }
        }

        ####################################################################################################
        ### SUPPORTING METHODS ###


        # Add the GetLOCALAppLockerFolder method
        $Local:MainObject | Add-Member -MemberType ScriptMethod -Name GetLOCALAppLockerFolder -Value { param([System.String]$ApplicationID)
            [System.String]$LOCALAppLockerFolder    = Join-Path -Path $this.GetLOCALApplicationFolder($ApplicationID) -ChildPath (Get-ApplicationSubfolders).AppLockerFolder
            # Return the result
            $LOCALAppLockerFolder
        }

        # Add the GetLOCALApplicationFolder method
        $Local:MainObject | Add-Member -MemberType ScriptMethod -Name GetLOCALApplicationFolder -Value { param([System.String]$ApplicationID)
            Join-Path -Path (Get-SharedAssetPath -OutputFolder) -ChildPath $ApplicationID
        }

        ####################################################################################################

        $Local:MainObject.Begin()        
    }
    
    process {
        $Local:MainObject.Process()
    }

    end {
        $Local:MainObject.End()
    }
}

### END OF SCRIPT
####################################################################################################
