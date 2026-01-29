####################################################################################################
<#
.SYNOPSIS
    This function unzips the DeploymentScript and places it in the Work folder.
.DESCRIPTION
    This function is part of the Packaging Assistant. It contains references to classes, functions or variables, that are in other files.
.EXAMPLE
    Expand-DeploymentScript -ZipFileSourcePath 'C:\Demo\Demo.zip'
.INPUTS
    [System.String]
.OUTPUTS
    [System.String]
.NOTES
    Version         : 5.4.3
    Author          : Imraan Iotana
    Creation Date   : March 2025
    Last Update     : June 2025
#>
####################################################################################################

function Expand-DeploymentScript {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory=$true,HelpMessage='The path of the zipfile.')]
        [System.String]
        $ZipFileSourcePath,

        [Parameter(Mandatory=$false,HelpMessage='The folder where the output will be placed.')]
        [Alias('OutputFolder')]
        [System.String]
        $ParentOutputFolder = (Get-SharedAssetPath -OutputFolder),

        [Parameter(Mandatory=$false,HelpMessage='Switch for asking the user for confirmation.')]
        [Alias('AskConfirmation')]
        [System.Management.Automation.SwitchParameter]
        $Confirm
        )

    begin {
        ####################################################################################################
        ### MAIN OBJECT ###

        # Set the main object
        [PSCustomObject]$Local:MainObject = @{
            # Function
            FunctionDetails     = [System.String[]]@($MyInvocation.MyCommand,$PSCmdlet.ParameterSetName,$PSBoundParameters.GetEnumerator())
            # Input
            ZipFileSourcePath   = $ZipFileSourcePath
            ParentOutputFolder  = $ParentOutputFolder
            Confirm             = $Confirm
            # Handlers
            WorkFolderName      = (Get-ApplicationSubfolders).WorkFolder
            ScriptFileName      = 'Deploy-Application.ps1'
            # Confirmation Handlers
            ConfirmationTitle   = [System.String]'Create DeploymentScript'
            ConfirmationBody    = [System.String]'Would you like to add the Universal Deployment Script?'
        }

        ####################################################################################################
        ### MAIN FUNCTION METHODS ###
        
        # Add the Begin method
        Add-Member -InputObject $Local:MainObject -MemberType ScriptMethod -Name Begin -Value {
            # Write the Begin message
            Write-Message -FunctionBegin -Details $this.FunctionDetails
            # Add the ApplicationID to the main object
            $this | Add-Member -NotePropertyName ApplicationID -NotePropertyValue (Get-ApplicationName)
        }

        # Add the End method
        Add-Member -InputObject $Local:MainObject -MemberType ScriptMethod -Name End -Value {
            # Write the End message
            Write-Message -FunctionEnd -Details $this.FunctionDetails
        }

        # Add the Process method
        Add-Member -InputObject $Local:MainObject -MemberType ScriptMethod -Name Process -Value {
            # Get user confirmation
            if ($this.Confirm.IsPresent) {
                [System.Boolean]$UserHasConfirmed = Get-UserConfirmation -Title $this.ConfirmationTitle -Body $this.ConfirmationBody
                if (-Not($UserHasConfirmed)) { Return }
            }
            # Validate the input
            if (-Not ($this.ValidateInput())) { Return }
            # Determine the output folder
            $this.DetermineOutputFolder()
            # Extract the zipfile to the output folder
            $this.ExtractZipFileToOutputFolder()
            # Replace the Asset ID inside the ps1 file
            $this.ReplaceAssetIDInsidePS1File()
            # Open the folder
            #Open-Folder -Path $this.NewApplicationFolder
        }

        ####################################################################################################
        ### VALIDATION METHODS ###

        # Add the ValidateInput method
        Add-Member -InputObject $Local:MainObject -MemberType ScriptMethod -Name ValidateInput -Value {
            # Validate the input
            [System.IO.FileSystemInfo]$SourceFileObject = Get-Item -Path $this.ZipFileSourcePath -ErrorAction SilentlyContinue
            if ($SourceFileObject) {
                # Add the object to the main object and return true
                $this | Add-Member -NotePropertyName SourceFileObject -NotePropertyValue $SourceFileObject
                $true
            } else {
                # Else return false
                Write-Message -ValidationFailed
                $false
            }
        }

        ####################################################################################################
        ### MAIN PROCESSING METHODS ###
    
        # Add the DetermineOutputFolder method
        Add-Member -InputObject $Local:MainObject -MemberType ScriptMethod -Name DetermineOutputFolder -Value {
            # Set the new application folder
            [System.String]$NewApplicationFolder = Join-Path -Path $this.ParentOutputFolder -ChildPath $this.ApplicationID
            $this | Add-Member -NotePropertyName NewApplicationFolder -NotePropertyValue $NewApplicationFolder
            # Determine the Work folder
            [System.String]$WorkFolder = (Get-ChildItem -Path $NewApplicationFolder -Directory | Where-Object { $_.BaseName -eq $this.WorkFolderName } | Select-Object -First 1).FullName
            # Add the output folder to the main object
            $this | Add-Member -NotePropertyName OutputFolder -NotePropertyValue $WorkFolder
        }

        # Add the ExtractZipFileToOutputFolder method
        Add-Member -InputObject $Local:MainObject -MemberType ScriptMethod -Name ExtractZipFileToOutputFolder -Value {
            try {
                # Write the message
                Write-Host ('Unzipping the file ({0}). One moment please...' -f $this.ZipFileSourcePath) -ForegroundColor DarkGray
                # Unzip the source file
                Expand-Archive -Path $this.ZipFileSourcePath -DestinationPath $this.OutputFolder
                # Rename the new folder
                [System.String]$CurrentScriptFolder = (Get-ChildItem -Path $this.OutputFolder -Directory | Where-Object { $_.BaseName -eq $this.SourceFileObject.BaseName } | Select-Object -First 1).FullName
                [System.String]$NewScriptFolder     = Join-Path -Path $this.OutputFolder -ChildPath $this.ApplicationID
                Rename-Item -Path $CurrentScriptFolder -NewName $NewScriptFolder
                # Add the NewScriptFolder to the main object
                $this | Add-Member -NotePropertyName NewScriptFolder -NotePropertyValue $NewScriptFolder
            }
            catch {
                Write-FullError
            }
        }
        
        # Add the ReplaceAssetIDInsidePS1File method
        Add-Member -InputObject $Local:MainObject -MemberType ScriptMethod -Name ReplaceAssetIDInsidePS1File -Value {
            try {
                # Replace the AssetID inside the PS1 file
                [System.String]$PS1File = (Get-ChildItem -Path $this.OutputFolder -Recurse | Where-Object { $_.Name -eq $this.ScriptFileName } | Select-Object -First 1).FullName
                Set-TextInFile -FilePath $PS1File -StringToReplace '<<ASSETID>>' -ReplaceWith $this.ApplicationID
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
    }
}

### END OF SCRIPT
####################################################################################################
