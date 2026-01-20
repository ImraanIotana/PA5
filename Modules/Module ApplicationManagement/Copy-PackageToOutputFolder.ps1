####################################################################################################
<#
.SYNOPSIS
    This function copies copies the SCCM Package or the WorkCopy, from the DSL to the OutputFolder.
.DESCRIPTION
    This function is part of the Packaging Assistant. It contains functions or variables, that are in other files.
.EXAMPLE
    Copy-PackageToOutputFolder -ApplicationID 'Adobe_Reader_12.3'
.EXAMPLE
    Copy-PackageToOutputFolder -ApplicationID 'Adobe_Reader_12.3' -SCCMPackage -OpenPowerShell
.INPUTS
    [System.String]
    [System.Management.Automation.SwitchParameter]
.OUTPUTS
    This function returns no stream output.
.NOTES
    Version         : 5.6
    Author          : Imraan Iotana
    Creation Date   : December 2025
    Last Update     : December 2025
.COPYRIGHT
    Copyright (C) Iotana. All rights reserved.
#>
####################################################################################################

function Copy-PackageToOutputFolder {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory=$true,HelpMessage='The ID of the application that will be handled.')]
        [Alias('Application','ApplicationName','Name')]
        [System.String]
        $ApplicationID,

        [Parameter(Mandatory=$false,ParameterSetName='CopySCCMPackage',HelpMessage='Switch for copying the SCCM Package.')]
        [System.Management.Automation.SwitchParameter]
        $SCCMPackage,

        [Parameter(Mandatory=$false,ParameterSetName='CopyWorkCopy',HelpMessage='Switch for copying the WorkCopy.')]
        [System.Management.Automation.SwitchParameter]
        $WorkCopy,

        [Parameter(Mandatory=$false,HelpMessage='Switch for opening the PowerShell Console after the copy.')]
        [System.Management.Automation.SwitchParameter]
        $OpenPowerShell
    )

    begin {
        ####################################################################################################
        ### MAIN PROPERTIES ###

        # Function
        [System.String]$ParameterSetName    = $PSCmdlet.ParameterSetName

        # Handlers
        [System.String]$FolderToCopyInto    = Get-Path -OutputFolder
        [System.String[]]$ScriptFileNames   = @('Deploy-Application.ps1','Deploy-Application-WORKSTATION.ps1')


        ####################################################################################################
    }
    
    process {
        # PREPARATION
        # Set the FolderIdentifier
        [System.String]$FolderIdentifier = switch ($ParameterSetName) {
            'CopySCCMPackage'   { 'SCCMFolder'}
            'CopyWorkCopy'      { 'WorkFolder'}
        }
        # Set the Folders
        [System.String]$FolderContainingThePackage = Get-Path -ApplicationID $ApplicationID -SubFolder $FolderIdentifier
        [System.String]$FolderToCopy = Join-Path -Path $FolderContainingThePackage -ChildPath $ApplicationID


        # VALIDATION
        # Validate the FolderToCopy
        if (-Not(Test-Path -Path $FolderToCopy)) { Write-Line "The WorkCopy can not be found. ($FolderToCopy)" -Type Fail ; Return }
        # Validate the FolderToCopyInto
        if (-Not(Test-Path -Path $FolderToCopyInto)) { Write-Line "The Destinationfolder can not be found. ($FolderToCopyInto)" -Type Fail ; Return }


        # EXECUTION - COPY
        # Copy the folder
        try {
            Copy-WithGUI -ThisFolder $FolderToCopy -IntoThisFolder $FolderToCopyInto -OutHost    
        }
        catch {
            Write-FullError
        }

        # EXECUTION - POWERSHELL
        if ($OpenPowerShell.IsPresent) {
            # Set the path to the ps1 file
            [System.String]$UltimateFolderPath = Join-Path -Path $FolderToCopyInto -ChildPath (Split-Path -Path $FolderToCopy -Leaf)
            # Open the ps1 ile
            foreach ($ScriptFileName in $ScriptFileNames) {
                [System.String]$ScriptFilePath = Join-Path -Path $UltimateFolderPath -ChildPath $ScriptFileName
                if (Test-Path -Path $ScriptFilePath) { Start-PowerShell -Path $ScriptFilePath }
            }
        }
    }
    
    end {
    }
}

### END OF SCRIPT
####################################################################################################
