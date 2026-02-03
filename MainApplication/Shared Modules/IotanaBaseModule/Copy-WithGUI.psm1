####################################################################################################
<#
.SYNOPSIS
    This function copies and moves files and folders, showing the Windows Progressbar.
.DESCRIPTION
    This function is part of the Packaging Assistant. It contains functions or variables, that are in other files.
.EXAMPLE
    Copy-WithGUI -ThisFolder 'C:\Demo\CopyThisFolder' -IntoThisFolder 'D:\Archives'
.EXAMPLE
    Copy-WithGUI -ThisFolder 'C:\Demo\CopyThisFolder' -IntoThisFolder 'D:\Archives' -OpenFolder
.EXAMPLE
    Copy-WithGUI -ThisFolder 'C:\Demo\CopyThisFolder' -IntoThisFolder 'D:\Archives' -Overwrite -OpenFolder
.INPUTS
    [System.String]
    [System.Management.Automation.SwitchParameter]
.OUTPUTS
    This function returns no stream output.
.NOTES
    Version         : 5.7.1.014
    Author          : Imraan Iotana
    Creation Date   : December 2025
    Last Update     : February 2026
.COPYRIGHT
    Copyright (C) Iotana. All rights reserved.
#>
####################################################################################################

function Copy-WithGUI {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory=$true,HelpMessage='The path of the source folder that will be copied.')]
        [System.String]$ThisFolder,

        [Parameter(Mandatory=$true,HelpMessage='The path of the folder into which the source folder will be copied.')]
        [System.String]$IntoThisFolder,

        [Parameter(Mandatory=$false,HelpMessage='Switch for overwriting an existing folder.')]
        [System.Management.Automation.SwitchParameter]$Overwrite,

        [Parameter(Mandatory=$false,HelpMessage='Switch for moving instead of copying.')]
        [System.Management.Automation.SwitchParameter]$Move,

        [Parameter(Mandatory=$false,HelpMessage='Switch for writing to the host.')]
        [System.Management.Automation.SwitchParameter]$OutHost,

        [Parameter(Mandatory=$false,HelpMessage='Switch for opening the destination folder.')]
        [System.Management.Automation.SwitchParameter]$OpenFolder
    )

    begin {
        ####################################################################################################
        ### MAIN PROPERTIES ###

        # Input
        [System.String]$FolderToCopy        = $ThisFolder
        [System.String]$FolderToCopyInto    = $IntoThisFolder

        ####################################################################################################
    }
    
    process {
        # VALIDATION
        # Validate the FolderToCopy
        if (-Not(Test-Path -Path $FolderToCopy)) { Write-Line "The Source folder can not be found. ($FolderToCopy)" -Type Fail ; Return }
        # Validate the FolderToCopyInto
        if (-Not(Test-Path -Path $FolderToCopyInto)) { Write-Line "The Destinationfolder can not be found. ($FolderToCopyInto)" -Type Fail ; Return }



        # CONFIRMATION
        # Set the Destination
        [System.String]$UltimateFolderPath = Join-Path -Path $FolderToCopyInto -ChildPath (Split-Path -Path $FolderToCopy -Leaf)
        # If the Destination already exists
        if (Test-Path -Path $UltimateFolderPath) {
            # Write the message
            if ($OutHost) { Write-Line "The Destination already exists. ($UltimateFolderPath)" -Type Busy }
            
            # Check if the folder should be overwritten
            $ShouldOverwrite = $Overwrite.IsPresent -or (Get-UserConfirmation -Title 'Confirm Overwrite' -Body "This will OVERWRITE the EXISTING Folder:`n`n$UltimateFolderPath`n`nAre you sure?")
            
            # If the folder should not be overwritten, then exit
            if (-not $ShouldOverwrite) {
                if ($OutHost) { Write-Line "The Destination will not be overwritten." }
                return
            }
            
            # Remove the Destination
            Remove-WithGUI -Path $UltimateFolderPath -OutHost -Force
            if ($OutHost) { Write-Line "The existing Destination has been removed. ($UltimateFolderPath)" -Type Success }
        }


        # PREPARATION
        # Create the Shell Object
        [System.__ComObject]$ShellObject        = New-Object -ComObject Shell.Application
        [System.__ComObject]$SourceObject       = $ShellObject.Namespace($FolderToCopy)
        [System.__ComObject]$DestinationObject  = $ShellObject.Namespace($FolderToCopyInto)


        # EXECUTION
        try {
            # Copy the folder
            if ($OutHost) { Write-Line "Copying the folder ($FolderToCopy) into the folder ($FolderToCopyInto)..." -Type Busy }
            $DestinationObject.CopyHere($SourceObject,16)
            if ($OutHost) { Write-Line "The folder has been copied. ($FolderToCopy)" -Type Success }
            # Open the folder
            if ($OpenFolder) { Open-Folder -HighlightItem $UltimateFolderPath }
        }
        catch {
            Write-FullError
        }


        # CLEANUP
        # Cleanup the Shell Object
        [System.Runtime.InteropServices.Marshal]::ReleaseComObject($ShellObject) | Out-Null
        Remove-Variable -Name ShellObject

        ####################################################################################################
    }
    
    end {
    }
}

### END OF SCRIPT
####################################################################################################
