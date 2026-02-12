####################################################################################################
<#
.SYNOPSIS
    This function returns the full path of an Application folder on the DSL. Or of all folders.
.DESCRIPTION
    This function is part of the Packaging Assistant. It contains functions and variables that are in other files.
.EXAMPLE
    Get-DSLApplicationFolder -AssetName MainApplicationIcon
.EXAMPLE
    Get-DSLApplicationFolder -OutputFolder
.INPUTS
    [System.Management.Automation.SwitchParameter]
    [System.Object]
    [System.String]
.OUTPUTS
    [System.String]
    [System.String[]]
.NOTES
    Version         : 5.4.8
    Author          : Imraan Iotana
    Creation Date   : July 2025
    Last Update     : July 2025
#>
####################################################################################################

function Get-DSLApplicationFolder {
    [CmdletBinding()]
    [Alias('Get-ApplicationFolderFromDSL')]
    param (
        [Parameter(Mandatory=$true,ParameterSetName='ReturnAllApplicationFolders',HelpMessage='Switch for returning the basenames of ApplicationFolders on the DSL.')]
        [Alias('AllFolderPaths','AllApplicationFolders')]
        [System.Management.Automation.SwitchParameter]
        $All, # Under construction

        [Parameter(Mandatory=$false,ParameterSetName='ReturnAllApplicationFolders',HelpMessage='Switch for returning the basenames of the ApplicationFolders on the DSL.')]
        [Alias('Basename','BasenameOnly','BasenamesOnly')]
        [System.Management.Automation.SwitchParameter]
        $Basenames, # Under construction

        [Parameter(Mandatory=$true,ParameterSetName='ReturnApplicationFolderPathFromBox',HelpMessage='The Textbox or ComboBox from which the text will be read.')]
        [Alias('FromTextBox','FromComboBox')]
        [System.Object]
        $FromBox,

        [Parameter(Mandatory=$true,ParameterSetName='ReturnApplicationFolderPathFromString',HelpMessage='ApplicationID of the Application.')]
        [Alias('Application','ApplicationName')]
        [System.String]
        $ApplicationID
    )

    begin {
        ####################################################################################################
        ### MAIN OBJECT ###

        # Create the main object
        [PSCustomObject]$Local:MainObject = @{
            # Function
            FunctionDetails     = [System.String[]]@($MyInvocation.MyCommand,$PSCmdlet.ParameterSetName,$PSBoundParameters.GetEnumerator())
            ParameterSetName    = [System.String]$PSCmdlet.ParameterSetName
            # Input
            BoxToGetTextFrom    = $FromBox
            ApplicationID       = $ApplicationID
            Basenames           = $Basenames
            # Handlers
            DSLFolder           = [System.String](Get-Path -DSLFolder)
        }

        ####################################################################################################
        ### MAIN FUNCTION METHODS ###
        
        # Add the Begin method
        Add-Member -InputObject $Local:MainObject -MemberType ScriptMethod -Name Begin -Value {
            # Write the Begin message
            Write-Message -FunctionBegin -Details $this.FunctionDetails
        }

        # Add the End method
        Add-Member -InputObject $Local:MainObject -MemberType ScriptMethod -Name End -Value {
            # Write the End message
            Write-Message -FunctionEnd -Details $this.FunctionDetails
        }

        # Add the Process method
        Add-Member -InputObject $Local:MainObject -MemberType ScriptMethod -Name Process -Value {
            # Switch on the ParameterSetName
            switch ($this.FunctionDetails[1]) {
                'ReturnAllApplicationFolders'           { $this.GetAllApplicationFolders() }
                'ReturnApplicationFolderPathFromBox'    { [System.String]$ApplicationID = $this.BoxToGetTextFrom.Text ; $this.GetDSLApplicationFolderPath($ApplicationID) }
                'ReturnApplicationFolderPathFromString' { $this.GetDSLApplicationFolderPath($this.ApplicationID) }
            }
        }

        ####################################################################################################
        ### MAIN PROCESSING METHODS ###
    
        # Add the GetAllApplicationFolders method
        Add-Member -InputObject $Local:MainObject -MemberType ScriptMethod -Name GetAllApplicationFolders -Value {
            try {
                # Search the Customer folder objects
                [System.IO.FileSystemInfo[]]$CustomerFolderObjects = (Get-ChildItem -Path $this.DSLFolder -Directory | Where-Object { -Not($_.Name.StartsWith('_')) })
                # Search the subfolders in the folder
                [System.String[]]$DSLApplicationFolders = @()
                foreach ($CustomerFolderObject in $CustomerFolderObjects) {
                    [System.String[]]$SubFolders = if ($this.Basenames.IsPresent) {
                        (Get-ChildItem -Path $CustomerFolderObject.FullName -Directory | Where-Object { -Not($_.Name.StartsWith('_')) }).Name
                    } else {
                        (Get-ChildItem -Path $CustomerFolderObject.FullName -Directory | Where-Object { -Not($_.Name.StartsWith('_')) }).FullName
                    }
                    $DSLApplicationFolders += $SubFolders
                }
                # Clean up the results
                $CleanedUpArray = $DSLApplicationFolders | Where-Object { Test-Object -IsPopulated $_ } | Get-Unique | Sort-Object
                # Add the result to the main object
                $this | Add-Member -NotePropertyName OutputObject -NotePropertyValue $CleanedUpArray
                #$CleanedUpArray | Out-Host # for testing
            }
            catch {
                Write-FullError
            }
        }
    
        # Add the GetDSLApplicationFolderPath method
        Add-Member -InputObject $Local:MainObject -MemberType ScriptMethod -Name GetDSLApplicationFolderPath -Value { param([System.String]$ApplicationID)
            try {
                # Search the ApplicationFolder
                [System.String]$ApplicationFolderPath = (Get-ChildItem -Path $this.DSLFolder -Recurse -Depth 1 -Directory | Where-Object { $_.Name -eq $ApplicationID }).FullName
                # Add the result to the main object
                $this | Add-Member -NotePropertyName OutputObject -NotePropertyValue $ApplicationFolderPath
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
        # Return the output
        $Local:MainObject.OutputObject
    }
}

### END OF SCRIPT
####################################################################################################
