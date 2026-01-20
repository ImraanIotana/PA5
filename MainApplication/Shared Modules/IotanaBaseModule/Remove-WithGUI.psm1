####################################################################################################
<#
.SYNOPSIS
    This function removes a file or folder, showing the Windows Progressbar.
.DESCRIPTION
    This function is part of the Iotana Base Module. It contains functions or variables, that are in other files.
.EXAMPLE
    Remove-WithGUI -Path 'C:\Demo\Folder'
.EXAMPLE
    Remove-WithGUI -Path 'C:\Demo\Folder' -OutHost
.EXAMPLE
    Remove-WithGUI -Path 'C:\Demo\Folder' -OutHost -Force
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

function Remove-WithGUI {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory=$true,HelpMessage='The path of the item that will be removed.')]
        [System.String]
        $Path,

        [Parameter(Mandatory=$false,HelpMessage='Switch for writing to the host.')]
        [System.Management.Automation.SwitchParameter]
        $OutHost,

        [Parameter(Mandatory=$false,HelpMessage='Switch for skipping the confirmation.')]
        [System.Management.Automation.SwitchParameter]
        $Force
    )

    begin {
        ####################################################################################################
        ### MAIN PROPERTIES ###

        # Input
        [System.String]$ItemToDelete    = $Path

        # Handlers
        [System.Collections.Hashtable]$DeleteFlagsTable = @{
            MoveToRecycleBin            = 8
            NoConfirmation              = 10
            ShowProgressBar             = 16
        }

        # Confirmation Handlers
        [System.String]$ConfirmationTitle   = 'CONFIRM DELETION'
        [System.String]$ConfirmationBody    = "This will DELETE the file/folder:`n`n$ItemToDelete`n`nAre you sure?"

        ####################################################################################################
    }
    
    process {
        # VALIDATION
        # Validate the ItemToDelete
        if (-Not(Test-Path -Path $ItemToDelete)) { Write-Line "The item can not be found. ($ItemToDelete)" -Type Fail ; Return }


        # CONFIRMATION
        # If the Force parameter is not present, then ask confirmation
        if (-Not($Force.IsPresent)) {
            if (-Not(Get-UserConfirmation -Title $ConfirmationTitle -Body $ConfirmationBody)) { Return }
        }


        # PREPARATION - OBJECTS
        # Create the Shell Object
        [System.__ComObject]$ShellObject            = New-Object -ComObject Shell.Application
        # Get the Parentfolder Object
        [System.String]$ItemToDeleteParentFolder    = Split-Path -Path $ItemToDelete -Parent
        [System.__ComObject]$ParentFolderObject     = $ShellObject.Namespace($ItemToDeleteParentFolder)
        # Get the Leaf object
        [System.String]$ItemToDeleteLeafName        = Split-Path -Path $ItemToDelete -Leaf
        [System.__ComObject]$LeafObject             = $ParentFolderObject.ParseName($ItemToDeleteLeafName)


        # PREPARATION - FLAGS
        # Set the Delete Flag
        [System.Int32]$DeleteFlag                   = $DeleteFlagsTable.MoveToRecycleBin + $DeleteFlagsTable.NoConfirmation + $DeleteFlagsTable.ShowProgressBar


        # EXECUTION
        try {
            # Remove the item
            if ($OutHost) { Write-Line "Removing the item ($ItemToDelete)..." -Type Busy }
            $LeafObject.InvokeVerbEx('Delete',$DeleteFlag)
            if ($OutHost) { Write-Line "The item has been removed. ($ItemToDelete)" -Type Success }
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
