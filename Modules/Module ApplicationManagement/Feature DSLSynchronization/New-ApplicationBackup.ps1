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

function New-ApplicationBackup {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory=$true,HelpMessage='The Application that will be handled.')]
        [Alias('ApplicationName','Application','ApplicationFolder')]
        [System.String]
        $ApplicationID,

        [Parameter(Mandatory=$true,HelpMessage='The type of backup that will be made.')]
        #[ValidateSet('Full','AppLockerFolder','ShortcutsFolder','DocumentationFolder')]
        [System.String]
        $Type
    )

    begin {
        ####################################################################################################
        ### MAIN OBJECT ###

        # Create the main object
        [PSCustomObject]$Local:MainObject = @{
            # Function
            FunctionDetails = [System.String[]]@($MyInvocation.MyCommand,$PSCmdlet.ParameterSetName,$PSBoundParameters.GetEnumerator())
            # Input
            ApplicationID   = $ApplicationID
            Type            = $Type
            # Output
            OutputObject    = [System.Boolean]$null
            # Validation
            ValidationArray = [System.Boolean[]]@()
            # Handlers
            TimeStamp       = [System.String](Get-TimeStamp -ForBackups)
        }

        ####################################################################################################
        ### MAIN FUNCTION METHODS ###
        
        # Add the Begin method
        Add-Member -InputObject $Local:MainObject -MemberType ScriptMethod -Name Begin -Value {
            # Write the Begin message
            Write-Message -FunctionBegin -Details $this.FunctionDetails
            # Validate the input (under construction)
            #$this.ValidateInput()
        }

        # Add the End method
        Add-Member -InputObject $Local:MainObject -MemberType ScriptMethod -Name End -Value { Write-Message -FunctionEnd -Details $this.FunctionDetails }

        # Add the Process method
        $Local:MainObject | Add-Member -MemberType ScriptMethod -Name Process -Value {
            # If the validation failed, then return (under construction)
            #if ($this.ValidationArray -contains $false) { Write-Message -ValidationFailed ; Return }
            # Make the backup
            $this.OutputObject = $this.MakeBackup($this.ApplicationID,$this.Type) 
        }

        ####################################################################################################
        ### VALIDATION METHODS ###

        # Add the ValidateInput method (under construction # get the subfolders for validation)
        Add-Member -InputObject $Local:MainObject -MemberType ScriptMethod -Name ValidateInput -Value {
            $this.ValidationSuccess += Confirm-Object -MandatoryString $this.InputString
        }

        ####################################################################################################
        ### MAIN PROCESSING METHODS ###
        
        # Add the MakeBackup method
        Add-Member -InputObject $Local:MainObject -MemberType ScriptMethod -Name MakeBackup -Value { param([System.String]$ApplicationID,[System.String]$Subfolder)
            try {
                # Set the properties
                [System.String]$SubFolderToBackup   = Get-DSLApplicationSubfolder -ApplicationID $ApplicationID -Subfolder $Subfolder
                [System.String]$DSLBackupsFolder    = Get-DSLApplicationSubfolder -ApplicationID $ApplicationID -Subfolder BackupsFolder
                [System.String]$BackupFileName      = ('{0}_{1}.zip' -f $Subfolder,$this.TimeStamp)
                [System.String]$DSLBackupFilePath   = Join-Path -Path $DSLBackupsFolder -ChildPath $BackupFileName
                if (-Not(Test-Path -Path $DSLBackupsFolder)) { New-Item -Path $DSLBackupsFolder -ItemType Directory -Force | Out-Null }
                # Backup the files
                Write-Host ('Making a backup of the ({0}) of the Application ({1})' -f $Subfolder,$ApplicationID) -ForegroundColor DarkGray
                [System.Object[]]$ObjectsInsideSubfolder = Get-ChildItem -Path $SubFolderToBackup
                if ($ObjectsInsideSubfolder.Count -eq 0) {
                    Write-Host ('No files to backup in subfolder ({0}).' -f $SubFolderToBackup) -ForegroundColor DarkGray
                } else {
                    # Make the backup
                    Compress-Archive -Path "$SubFolderToBackup\*" -DestinationPath $DSLBackupFilePath
                    # If the backup was succesful
                    if (Test-Path -Path $DSLBackupFilePath) {
                        # Remove the old files on the DSL
                        #[System.Boolean]$UserHasConfirmed = Get-UserConfirmation -Title ('Confirm Removal') -Body ('Backup successful. Would you like to remove the old files in the folder ({0})...' -f $SubFolderToBackup)
                        #if (-Not($UserHasConfirmed)) { Return $true }
                        Write-Host ('Removing old files in folder ({0})...' -f $SubFolderToBackup) -ForegroundColor DarkGray
                        Get-ChildItem -Path $SubFolderToBackup -Recurse | Remove-Item -Force -Recurse
                    } else {
                        Write-FullError 'Backup NOT successful!' ; Return $false
                    }
                }
                # Return true
                Return $true
            }
            catch {
                # Write the error and return false
                Write-FullError ; Return $false
            }
        }

        ####################################################################################################
        ### SUPPORTING METHODS ###


        
        ####################################################################################################

        $Local:MainObject.Begin()
    }
    
    process {
        $Local:MainObject.Process()
    }
    
    end {
        $Local:MainObject.End()
        # Return the output
        $Local:MainObject.OutputObject
    }
}

### END OF SCRIPT
####################################################################################################
