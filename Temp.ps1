
    # Get the top folder
    [System.IO.DirectoryInfo[]]$FolderObjects = Get-ChildItem -Path $TemporaryWorkFolder -Directory
    [System.Int32]$NumberOfFolders = $FolderObjects.Count

    # If the top folder should be ignored
    if ($IgnoreTopFolder.IsPresent) {

        # If multiple folders were found
        if ($NumberOfFolders -gt 1) {
            # Write the message and open the folder
            Write-Line "Multiple folders were found at the Top level. Please make sure, that there is only one folder at the Top level." -Type Fail
            Open-Folder -Path $TemporaryWorkFolder
            $InstallationSuccess = $false ; Return

        # If 1 folder was found
        } elseif ($NumberOfFolders -eq 1) {
            # Set the top folder
            [System.String]$TopFolder = $FolderObjects[0].FullName
            Write-Line "The top folder will be ignored. ($TopFolder)"
            #  Copy the content of the top folder to the installation folder (Use Copy instead of Move, or else the ACL of the temp folder will remain on this folder.)
            Write-Line "Copying the content of the top folder ($TopFolder) to the installation folder ($InstallationFolder)..." -Type Busy
            Copy-Item -Path "$TopFolder\*" -Destination $InstallationFolder -Recurse -Force
            #Move-Item -Path "$TopFolder\*" -Destination $InstallationFolder -Force
            # Reset the ACL of the installation folder
            Set-AclFromParentFolder -Path $InstallationFolder
            # Remove the temporary folder
            Write-Line "Removing the temporary folder ($TemporaryWorkFolder)..."
            Remove-Item -Path $TemporaryWorkFolder -Recurse -Force
            Write-Line "The Compressed Folder has been successfully installed. ($InstallationFolder)" -Type Success
            $InstallationSuccess = $true ; Return

        # If no folders were found
        } elseif ($NumberOfFolders -lt 1) {
            # Write the message and open the folder
            Write-Line "No folders were found at the Top level. Please make sure, that there is one folder at the Top level." -Type Fail
            Open-Folder -Path $TemporaryWorkFolder
            $InstallationSuccess = $false ; Return
        }
    }