####################################################################################################
<#
.SYNOPSIS
    This function ...
.DESCRIPTION
    This function is self-contained and does not refer to functions, variables or classes, that are in other files.
    This function is part of the Packaging Assistant. It contains functions and variables that are in other files.
    External classes    : -
    External functions  : -
    External variables  : $Global:ApplicationObject
.EXAMPLE
    New-FunctionTemplate507 -Initialize
.EXAMPLE
    New-FunctionTemplate507 -Write -PropertyName OutputFolder -PropertyValue 'C:\Demo\WorkFolder'
.EXAMPLE
    New-FunctionTemplate507 -Read -PropertyName OutputFolder
.EXAMPLE
    New-FunctionTemplate507 -Remove -PropertyName OutputFolder
.INPUTS
    [System.Management.Automation.SwitchParameter]
    [System.String]
.OUTPUTS
    This function returns no stream-output.
    [System.String]
.NOTES
    Version         : 5.5
    Author          : Imraan Iotana
    Creation Date   : August 2025
    Last Update     : August 2025
#>
####################################################################################################

function New-SubFolderBackup {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory=$true,HelpMessage='The Application that will be handled.')]
        [Alias('ApplicationName','Application','ApplicationFolder')]
        [System.String]
        $ApplicationID,

        [Parameter(Mandatory=$true,HelpMessage='The SubFolder that will be backed up.')]
        [System.String]
        $SubFolder,

        [Parameter(Mandatory=$false,HelpMessage='Switch for removing the files after the backup is made.')]
        [System.Management.Automation.SwitchParameter]
        $RemoveFilesAfterBackup,

        [Parameter(Mandatory=$false,HelpMessage='Switch for returning the result as a boolean.')]
        [System.Management.Automation.SwitchParameter]
        $PassThru,

        [Parameter(Mandatory=$false,HelpMessage='Switch for skipping the confirmations.')]
        [System.Management.Automation.SwitchParameter]
        $Force
    )

    begin {
        ####################################################################################################
        ### MAIN PROPERTIES ###

        # Function
        [System.String[]]$FunctionDetails   = @($MyInvocation.MyCommand,$PSCmdlet.ParameterSetName,$PSBoundParameters.GetEnumerator())
        # Handlers
        [System.String]$TimeStamp           = (Get-TimeStamp -ForBackups)
        # Output
        [System.Boolean]$OutputObject       = $false

        ####################################################################################################

        # Write the begin message
        Write-Function -Begin $FunctionDetails
    }
    
    process {
        # VALIDATION
        # Validate the input
        [System.String[]]$ValidSubFolders = (Get-ApplicationSubfolders).Keys
        if (-Not($ValidSubFolders.Contains($Subfolder))) {
            Write-Red ('The entered SubFolder ({0}) is not a valid name.' -f $Subfolder) ; Write-Line "Valid names are: $ValidSubFolders"
        }
        # Set the properties
        [System.String]$SubFolderToBackup   = Get-Path -ApplicationID $ApplicationID -Subfolder $Subfolder
        [System.String]$DSLBackupsFolder    = Get-Path -ApplicationID $ApplicationID -Subfolder BackupsFolder
        [System.String]$BackupFileName      = ('{0}_{1}_{2}.zip' -f $ApplicationID,$Subfolder,$TimeStamp)
        [System.String]$DSLBackupFilePath   = Join-Path -Path $DSLBackupsFolder -ChildPath $BackupFileName
        # Validate the SubFolderToBackup
        if (-Not(Confirm-Object -MandatoryPath $SubFolderToBackup)) { Write-Red ('The folder to backup does not exist: ({0})' -f $SubFolderToBackup) ; Return }
        # Check if there are files in the folder
        [System.Object[]]$ObjectsInsideSubfolder = Get-ChildItem -Path $SubFolderToBackup
        if ($ObjectsInsideSubfolder.Count -eq 0) {
            Write-Host ('No files to backup in subfolder ({0}).' -f $SubFolderToBackup) ; $OutputObject = $true ; Return
        }
        # Get confirmation
        if (-Not($Force)) {
            [System.Boolean]$UserConfirmedBackup = Get-UserConfirmation -Title ('Confirm Backup') -Body ("This will create a backup of the subfolder ({0}) of the application:`n`n{1}`n`nAre you sure?" -f $SubFolder,$ApplicationID)
            if (-Not($UserConfirmedBackup)) { Return }
        }

        # EXECUTION
        try {
            # If the DSLBackupsFolder does not exist, create it
            if (-Not(Confirm-Object -MandatoryPath $DSLBackupsFolder)) { New-Item -Path $DSLBackupsFolder -ItemType Directory -Force | Out-Null }
            # Make the backup
            Write-Busy ('Creating a backup of the ({0}) of the Application ({1})' -f $Subfolder,$ApplicationID) -ApplicationID $ApplicationID
            Compress-Archive -Path "$SubFolderToBackup\*" -DestinationPath $DSLBackupFilePath
            # Validate the backup
            Write-Busy ('Validation the backup of the ({0}) of the Application ({1})' -f $Subfolder,$ApplicationID)
            if (Test-Path -Path $DSLBackupFilePath) {
                # Remove the old files on the DSL
                if ($RemoveFilesAfterBackup) {
                    if (-Not($Force)) {
                        [System.Boolean]$UserConfirmedRemoval = Get-UserConfirmation -Title ('Confirm Removal') -Body ("Backup successful.`n`nWould you like to remove the old files in the folder:`n`n({0})" -f $SubFolderToBackup)
                        if (-Not($UserConfirmedRemoval)) { Return }
                    }
                    Write-Busy ('Removing old files in folder ({0})...' -f $SubFolderToBackup)
                    Get-ChildItem -Path $SubFolderToBackup -Recurse | Remove-Item -Force -Recurse
                }
                # Set the output to true
                Write-Success ('Created a backup of the ({0}) of the Application ({1})' -f $Subfolder,$ApplicationID) -ApplicationID $ApplicationID
                $OutputObject = $true
            } else {
                # Write the errors
                Write-FullError
                Write-Fail ('Not created a backup of the ({0}) of the Application ({1})' -f $Subfolder,$ApplicationID) -ApplicationID $ApplicationID
            }
        

        }
        catch {
            Write-FullError
        }
    }
    
    end {
        # Write the end message
        Write-Function -End $FunctionDetails
        # Return the output
        if ($PassThru) { $OutputObject }
    }
}

### END OF SCRIPT
####################################################################################################
