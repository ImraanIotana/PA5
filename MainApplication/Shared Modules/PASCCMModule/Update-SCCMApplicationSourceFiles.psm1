####################################################################################################
<#
.SYNOPSIS
    This function copies the source files of an application from the DSL to the SCCM Repository.
.DESCRIPTION
    This function is part of the Packaging Assistant. It contains references to classes, functions or variables, that are in other files.
.EXAMPLE
    Update-SCCMApplicationSourceFiles -ApplicationID DemoVendor_DemoApplication_1.2.3
.INPUTS
    -
.OUTPUTS
    This function returns no stream output.
.NOTES
    Version         : 5.5.1
    Author          : Imraan Iotana
    Creation Date   : July 2025
    Last Update     : September 2025
#>
####################################################################################################

function Update-SCCMApplicationSourceFiles {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory=$true,ValueFromPipeline=$true,HelpMessage='The ID of the application that will be updated.')]
        [Alias('Application','ApplicationName','Name')]
        [AllowEmptyString()]
        [System.String]
        $ApplicationID
    )
    
    begin {
        ####################################################################################################
        ### MAIN PROPERTIES ###

        # Function
        [System.String[]]$FunctionDetails   = @($MyInvocation.MyCommand,$PSCmdlet.ParameterSetName,$PSBoundParameters.GetEnumerator())


        ####################################################################################################

        # Write the Begin message
        Write-Function -Begin $FunctionDetails
    }
    
    process {
        # VALIDATION

        # Validate the input
        if (Test-Object -IsEmpty $ApplicationID) { Write-Red 'The Application ID is empty.' ; Write-NoAction ; Return }

        # Get confirmation
        [System.Boolean]$UserConfirmed = Get-UserConfirmation -Title "Confirm Update SCCM Source Files" -Body "This will UPDATE the SOURCE FILES of the application:`n`n$ApplicationID`n`nAre you sure?"
        if (-Not($UserConfirmed)) { Return }
        
        # Set the Folder properties
        [System.String]$SCCMSubFolderPath   = (Get-Path -ApplicationID $ApplicationID -Subfolder SCCMFolder)
        [System.String]$FolderToCopy        = Join-Path -Path $SCCMSubFolderPath -ChildPath $ApplicationID
        [System.String]$SCCMRepository      = (Get-Path -SCCMRepository)

        # Validate the folder on the DSL
        Write-Line "Searching the Package Folder on the DSL. One moment please... ($ApplicationID)"
        if (Test-Path -Path $FolderToCopy) {
            Write-Green "Package Folder found on the DSL: ($FolderToCopy)"
        } else {
            Write-Red "Package Folder NOT found at expected location: ($FolderToCopy)" ; Write-NoAction ; Return
        }

        # Validate the folder on the SCCM Repository
        Write-Line "Searching the Source Folder on the SCCM Repository. One moment please... ($ApplicationID)."
        [System.IO.FileSystemInfo[]]$ApplicationFolderObjectsOnSCCMRepository = Get-ChildItem -Path $SCCMRepository -Recurse -Directory | Where-Object { $_.Basename -eq $ApplicationID }
        switch ($ApplicationFolderObjectsOnSCCMRepository.Count) {
            0 { Write-Red "Source Folder NOT found on the SCCM Repository: ($SCCMRepository)" ; Write-NoAction ; Return }
            1 { [System.String]$ApplicationFolderOnSCCMRepository = $ApplicationFolderObjectsOnSCCMRepository[0].FullName
                Write-Green "Source Folder found on the SCCM Repository: ($ApplicationFolderOnSCCMRepository)"
            }
            Default { Write-Red "Multiple Folders found on the SCCM Repository with the name ($ApplicationID). Please remove the duplicates." ; Write-NoAction ; Return }
        }

        # EXECUTION
        try {
            # Remove the current sources from the SCCM Repository
            Write-Busy "Updating the Source Files on the SCCM Repository for the Application ($ApplicationID). One moment please..." -ApplicationID $ApplicationID
            Write-Busy "Removing the old Source Folder from the SCCM Repository: ($ApplicationFolderOnSCCMRepository)" -ApplicationID $ApplicationID
            Remove-WithGUI -Path $ApplicationFolderOnSCCMRepository -OutHost -Force

            # Copy the sources
            [System.String]$DestinationFolder = Split-Path -Path $ApplicationFolderOnSCCMRepository -Parent
            Write-Busy "Copying the new Source Files from the DSL to the SCCM Repository: ($FolderToCopy)" -ApplicationID $ApplicationID
            Copy-WithGUI -ThisFolder $FolderToCopy -IntoThisFolder $DestinationFolder -OpenFolder
            Write-Success "The new Source Files have been copied to the SCCM Repository: ($ApplicationFolderOnSCCMRepository)" -ApplicationID $ApplicationID
        }
        catch {
            Write-FullError
        }
    }
    
    end {
        # Write the End message
        Write-Function -End $FunctionDetails
    }
}

### END OF SCRIPT
####################################################################################################
