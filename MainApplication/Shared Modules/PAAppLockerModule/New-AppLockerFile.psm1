####################################################################################################
<#
.SYNOPSIS
    This function create a new AppLocker file (xml) that can be imported into the AppLocker Policy.
.DESCRIPTION
    This function is part of the Packaging Assistant. It contains references to classes, functions or variables, that are in other files.
.EXAMPLE
    New-AppLockerFile -Path 'C:\Demo\MyFolder'
.INPUTS
    [System.String]
.OUTPUTS
    This function returns no stream output.
.NOTES
    Version         : 5.4.6
    Author          : Imraan Iotana
    Creation Date   : July 2025
    Last Update     : July 2025
#>
####################################################################################################

function New-AppLockerFile {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory=$true,HelpMessage='The path folder to get all executables and dlls from.')]
        [AllowNull()]
        [System.String]
        $Path,

        [Parameter(Mandatory=$false,HelpMessage='The SID of the AD group that will be added to the policy file.')]
        [AllowEmptyString()]
        [System.String]
        $ADGroupSID,

        [Parameter(Mandatory=$false,HelpMessage='The parent folder where the output will be placed.')]
        [System.String]
        $OutputFolder = (Get-Path -OutputFolder),

        [Parameter(Mandatory=$false,HelpMessage='The Application ID.')]
        [System.String]
        $ApplicationID,

        [Parameter(Mandatory=$false,HelpMessage='Switch for asking the user for confirmation.')]
        [Alias('AskConfirmation')]
        [System.Management.Automation.SwitchParameter]
        $AskUserConfirmation
        )

    begin {
        ####################################################################################################
        ### MAIN OBJECT ###

        # Set the main object
        [PSCustomObject]$Local:MainObject = @{
            # Function
            FunctionDetails     = [System.String[]]@($MyInvocation.MyCommand,$PSCmdlet.ParameterSetName,$PSBoundParameters.GetEnumerator())
            # Input
            FolderToScan        = $Path
            ADGroupSID          = $ADGroupSID
            OutputFolder        = $OutputFolder
            ApplicationID       = $ApplicationID
            AskUserConfirmation = $AskUserConfirmation
            # Handlers
            AppLockerFolderName = [System.String](Get-ApplicationSubfolders).AppLockerFolder
            # FileName Handlers
            ReportFilePreFix    = [System.String]'AppLockerReport_{0}.txt'
            HashFilePrefix      = [System.String]'AppLockerPolicyHash_{0}.xml'
            PathFilePrefix      = [System.String]'AppLockerPolicyPath_{0}.xml'
            PublisherFilePrefix = [System.String]'AppLockerPolicyPublisher_{0}.xml'
            # Content Handlers
            TimeStamp           = [System.String](Get-TimeStamp -ForLogging)
            IntroLinePreFix     = [System.String]'AppLocker Information for the application: {0}'
            TimeStampPreFix     = [System.String]'Generated on: {0}'
            SeperationLine      = [System.String]'========================='
            # Warning Handlers
            EmptyFieldWarning   = [System.String]'The Installation Folder field is empty. No AppLocker file will be created.'
            EmptySIDWarning     = [System.String]'The AD Group SID is empty. The group EVERYONE will be used instead.'
            # Confirmation Handlers
            ConfirmationTitle   = [System.String]'Create AppLocker Policy'
            ConfirmationBody    = [System.String]'Would you like to create the AppLocker Policy files?'
        }

        ####################################################################################################
        ### MAIN FUNCTION METHODS ###
        
        # Add the Begin method
        Add-Member -InputObject $Local:MainObject -MemberType ScriptMethod -Name Begin -Value {
            # Write the Begin message
            Write-Message -FunctionBegin -Details $this.FunctionDetails
            # Set the filename of the output file
            $this | Add-Member -NotePropertyName ReportFileName -NotePropertyValue ($this.ReportFilePreFix -f $this.ApplicationID)
            # Set the introductory line of the output file
            $this | Add-Member -NotePropertyName IntroductoryLine -NotePropertyValue ($this.IntroLinePreFix -f $this.ApplicationID)
        }
    
        # Add the End method
        Add-Member -InputObject $Local:MainObject -MemberType ScriptMethod -Name End -Value {
            # Write the End message
            Write-Message -FunctionEnd -Details $this.FunctionDetails
        }

        # Add the Process method
        Add-Member -InputObject $Local:MainObject -MemberType ScriptMethod -Name Process -Value {
            # Get user confirmation
            if ($this.AskUserConfirmation.IsPresent) {
                [System.Boolean]$UserHasConfirmed = Get-UserConfirmation -Title $this.ConfirmationTitle -Body $this.ConfirmationBody
                if (-Not($UserHasConfirmed)) { Return }
            }
            # If the path is empty the return
            if (Test-Object -IsEmpty $this.FolderToScan) { Write-Warning $this.EmptyFieldWarning ;  Return }
            # If the ADGroupSID is empty, the use the SID for Everyone
            if (Test-Object -IsEmpty $this.ADGroupSID) { Write-Warning $this.EmptySIDWarning ; $this.ADGroupSID = 'S-1-1-0' }
            # Determine the output folder and files
            $this.CreateOutputFolder()
            $this.DetermineOutputFiles()
            # Write the Executables to the OutputFile
            $this.CreateAppLockerTextReport()
            $this.CreateAppLockerPolicyFile()
        }

        ####################################################################################################
        ### MAIN PROCESSING METHODS ###
    
        # Add the CreateOutputFolder method
        Add-Member -InputObject $Local:MainObject -MemberType ScriptMethod -Name CreateOutputFolder -Value {
            try {
                if (-Not(Test-Path -Path $this.OutputFolder)) { New-Item -Path $this.OutputFolder -ItemType Directory -Force | Out-Null}
            }
            catch{
                Write-FullError
            }
        }
    
        # Add the DetermineOutputFolder method
        Add-Member -InputObject $Local:MainObject -MemberType ScriptMethod -Name DetermineOutputFolder -Value {
            try {
                # Set the new application folder
                [System.String]$NewApplicationFolder = Join-Path -Path $this.ParentOutputFolder -ChildPath $this.ApplicationID
                $this | Add-Member -NotePropertyName NewApplicationFolder -NotePropertyValue $NewApplicationFolder
                # Set the OutputFolder folder
                [System.String]$OutputFolder = Join-Path -Path $NewApplicationFolder -ChildPath $this.AppLockerFolderName
                if (-Not(Test-Path -Path $OutputFolder)) { New-Item -Path $OutputFolder -ItemType Directory -Force | Out-Null}
                # Add the OutputFolder to the main object
                $this | Add-Member -NotePropertyName OutputFolder -NotePropertyValue $OutputFolder
            }
            catch{
                Write-FullError
            }
        }
    
        # Add the DetermineOutputFiles method
        Add-Member -InputObject $Local:MainObject -MemberType ScriptMethod -Name DetermineOutputFiles -Value {
            # Set the ReportFilePath
            [System.String]$ReportFilePath = Join-Path -Path $this.OutputFolder -ChildPath $this.ReportFileName
            $this | Add-Member -NotePropertyName ReportFilePath -NotePropertyValue $ReportFilePath
            # Set the AppLockerPolicy filepaths
            [System.String]$AppLockerPolicyHashFilePath = Join-Path -Path $this.OutputFolder -ChildPath ($this.HashFilePrefix -f $this.ApplicationID)
            $this | Add-Member -NotePropertyName AppLockerPolicyHashFilePath -NotePropertyValue $AppLockerPolicyHashFilePath
            [System.String]$AppLockerPolicyPathFilePath = Join-Path -Path $this.OutputFolder -ChildPath ($this.PathFilePrefix -f $this.ApplicationID)
            $this | Add-Member -NotePropertyName AppLockerPolicyPathFilePath -NotePropertyValue $AppLockerPolicyPathFilePath
            [System.String]$AppLockerPolicyPublisherFilePath = Join-Path -Path $this.OutputFolder -ChildPath ($this.PublisherFilePrefix -f $this.ApplicationID)
            $this | Add-Member -NotePropertyName AppLockerPolicyPublisherFilePath -NotePropertyValue $AppLockerPolicyPublisherFilePath
        }
    
        # Add the GetExecutablesFromFolder method
        Add-Member -InputObject $Local:MainObject -MemberType ScriptMethod -Name GetExecutablesFromFolder -Value { param([System.String]$Path)
            # Get the executables from the folder
            Write-Host ('Getting the executables from the folder: ({0})' -f $Path) -ForegroundColor DarkGray
            [System.IO.FileSystemInfo[]]$FileObjects = Get-ChildItem -Path $Path -File -Recurse | Where-Object { $_.Extension -eq '.exe' } -ErrorAction SilentlyContinue
            # Return the result
            $FileObjects
        }
    
        # Add the GetDLLsFromFolder method
        Add-Member -InputObject $Local:MainObject -MemberType ScriptMethod -Name GetDLLsFromFolder -Value { param([System.String]$Path)
            # Get the executables from the folder
            Write-Host ('Getting the DLLs from the folder: ({0})' -f $Path) -ForegroundColor DarkGray
            [System.IO.FileSystemInfo[]]$FileObjects = Get-ChildItem -Path $Path -File -Recurse | Where-Object { $_.Extension -eq '.dll' } -ErrorAction SilentlyContinue
            # Return the result
            $FileObjects
        }

        # Add the WriteLinesToOutputFile method
        Add-Member -InputObject $Local:MainObject -MemberType ScriptMethod -Name WriteLinesToOutputFile -Value { param([System.String[]]$TextLines)
            try{
                # Write the lines to the OutputFile
                $TextLines | ForEach-Object { Add-Content -Path $this.ReportFilePath -Value $_ }
            }
            catch{
                Write-FullError
            }
        }

        # Add the CreateAppLockerTextReport method
        Add-Member -InputObject $Local:MainObject -MemberType ScriptMethod -Name CreateAppLockerTextReport -Value {
            try {
                # Write the introductory line in the output file
                Write-Host 'Creating the AppLocker Policy Report...' -ForegroundColor DarkGray
                $this.WriteLinesToOutputFile(@($this.IntroductoryLine))
                $this.WriteLinesToOutputFile(@(($this.TimeStampPreFix -f $this.TimeStamp),''))
                $this.WriteLinesToOutputFile(@($this.SeperationLine,''))
                $this.WriteLinesToOutputFile(@('AppLocker Policy XML files have been created for the following files:',''))
                # Write the Executables to the OutputFile
                [System.IO.FileSystemInfo[]]$FileObjects = $this.GetExecutablesFromFolder($this.FolderToScan)
                $this.WriteLinesToOutputFile(@($this.SeperationLine,('Number of Exe-files: {0}' -f $FileObjects.Count),$this.SeperationLine))
                $FileObjects | ForEach-Object { $this.WriteLinesToOutputFile($_.FullName) }
                # Write a blank line
                $this.WriteLinesToOutputFile('')
                # Write the DLLs to the OutputFile
                [System.IO.FileSystemInfo[]]$FileObjects = $this.GetDLLsFromFolder($this.FolderToScan)
                $this.WriteLinesToOutputFile(@($this.SeperationLine,('Number of DLL-files: {0}' -f $FileObjects.Count),$this.SeperationLine))
                $FileObjects | ForEach-Object { $this.WriteLinesToOutputFile($_.FullName) }
            }
            catch {
                Write-FullError
            }
        }

        # Add the CreateAppLockerPolicyFile method
        Add-Member -InputObject $Local:MainObject -MemberType ScriptMethod -Name CreateAppLockerPolicyFile -Value {
            try {
                # Create the AppLocker Policy File
                Write-Host 'Creating the AppLocker Policy files. One moment please...' -ForegroundColor DarkGray
                Get-AppLockerFileInformation -Directory $this.FolderToScan -Recurse | New-AppLockerPolicy -RuleType Hash -User $this.ADGroupSID -RuleNamePrefix $this.ApplicationID -Optimize -XML > $this.AppLockerPolicyHashFilePath -IgnoreMissingFileInformation -InformationAction SilentlyContinue
                Get-AppLockerFileInformation -Directory $this.FolderToScan -Recurse | New-AppLockerPolicy -RuleType Path -User $this.ADGroupSID -RuleNamePrefix $this.ApplicationID -Optimize -XML > $this.AppLockerPolicyPathFilePath -IgnoreMissingFileInformation -InformationAction SilentlyContinue
                Get-AppLockerFileInformation -Directory $this.FolderToScan -Recurse | New-AppLockerPolicy -RuleType Publisher -User $this.ADGroupSID -RuleNamePrefix $this.ApplicationID -Optimize -XML > $this.AppLockerPolicyPublisherFilePath -IgnoreMissingFileInformation -InformationAction SilentlyContinue
            }
            catch {
                Write-FullError
            }
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
