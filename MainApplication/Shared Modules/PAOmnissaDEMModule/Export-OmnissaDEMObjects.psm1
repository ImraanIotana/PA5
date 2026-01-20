####################################################################################################
<#
.SYNOPSIS
    This function exports Omnissa DEM Objects from the Omnissa DEM Reposority to the DSL.
.DESCRIPTION
    This function is part of the Packaging Assistant. It contains references to classes, functions or variables, that are in other files.
.EXAMPLE
    Export-OmnissaDEMObjects -ApplicationID 'Adobe_Reader_12.4' -Shortcuts
.EXAMPLE
    Export-OmnissaDEMObjects -ApplicationID 'Adobe_Reader_12.4' -UserRegistry -PassThru
.INPUTS
    [System.String]
    [System.Management.Automation.SwitchParameter]
.OUTPUTS
    [System.Boolean]
.NOTES
    Version         : 5.5.1
    Author          : Imraan Iotana
    Creation Date   : September 2025
    Last Update     : September 2025
.COPYRIGHT
    Copyright (C) Iotana. All rights reserved.
#>
####################################################################################################

function Export-OmnissaDEMObjects {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory=$true,HelpMessage='The ID of the application that will be handled.')]
        [AllowNull()][AllowEmptyString()]
        [System.String]
        $ApplicationID,

        [Parameter(Mandatory=$true,ParameterSetName='ExportShortcuts',HelpMessage='Switch for the Shortcut Objects.')]
        [System.Management.Automation.SwitchParameter]
        $Shortcuts,

        [Parameter(Mandatory=$true,ParameterSetName='ExportUserFiles',HelpMessage='Switch for the UserFiles Objects.')]
        [System.Management.Automation.SwitchParameter]
        $UserFiles,

        [Parameter(Mandatory=$true,ParameterSetName='ExportUserRegistry',HelpMessage='Switch for the UserRegistry Objects.')]
        [System.Management.Automation.SwitchParameter]
        $UserRegistry,

        [Parameter(Mandatory=$false,HelpMessage='Switch for returning the result as a boolean.')]
        [System.Management.Automation.SwitchParameter]
        $PassThru
    )

    begin {
        ####################################################################################################
        ### MAIN PROPERTIES ###

        # Function
        [System.String[]]$FunctionDetails   = @($MyInvocation.MyCommand,$PSCmdlet.ParameterSetName,$PSBoundParameters.GetEnumerator())
        [System.String]$FunctionName        = $FunctionDetails[0]
        [System.String]$ParameterSetName    = $FunctionDetails[1]

        # Output
        [System.Boolean]$OutputObject       = $null

        # Handlers
        [System.String]$RepositoryToSearch  = switch ($ParameterSetName) {
            'ExportShortcuts'       { $Global:ApplicationObject.Settings.DEMShortcutRepository }
            'ExportUserFiles'       { $Global:ApplicationObject.Settings.DEMUserFilesRepository }
            'ExportUserRegistry'    { $Global:ApplicationObject.Settings.DEMUserRegistryRepository }
        }
        [System.String]$SubfolderIdentifier = switch ($ParameterSetName) {
            'ExportShortcuts'       { 'ShortcutsFolder' }
            'ExportUserFiles'       { 'UserFilesFolder' }
            'ExportUserRegistry'    { 'UserRegistryFolder' }
        }
        [System.String]$ObjectTypeText      = switch ($ParameterSetName) {
            'ExportShortcuts'       { 'Shortcut' }
            'ExportUserFiles'       { 'UserFile' }
            'ExportUserRegistry'    { 'UserRegistry' }
        }

        ####################################################################################################

        # Write the Begin message
        Write-Function -Begin $FunctionDetails
    }
    
    process {
        # VALIDATION
        # Validate the properties
        if (Test-Object -IsEmpty $ApplicationID) { Write-Red 'The Application ID is empty.' ; Write-NoAction ; Return }
        if (-Not(Test-Path -Path $RepositoryToSearch)) { Write-Red "The DEM Repository does not exist: ($RepositoryToSearch)" ; Write-NoAction ; Return }
        # If no objects were found in DEM, then return
        [System.Boolean]$ObjectsExist = switch ($ParameterSetName) {
            'ExportShortcuts'       { Test-OmnissaDEMObjects -ApplicationID $ApplicationID -Shortcuts -PassThru -OutHost }
            'ExportUserFiles'       { Test-OmnissaDEMObjects -ApplicationID $ApplicationID -UserFiles -PassThru -OutHost }
            'ExportUserRegistry'    { Test-OmnissaDEMObjects -ApplicationID $ApplicationID -UserRegistry -PassThru -OutHost }
        }
        if (-Not($ObjectsExist)) { Write-Host ("No DEM $ObjectTypeText Objects were found, that contain the string ($ApplicationID)") ; Write-NoAction ; Return }
        # Get confirmation
        [System.Boolean]$UserConfirmedExport = Get-UserConfirmation -Title 'Confirm Export' -Body ("This will EXPORT the $($ObjectTypeText.ToUpper()) Objects from OMNISSA DEM for the application:`n`n$ApplicationID`n`nAre you sure?")
        if (-Not($UserConfirmedExport)) { Return }

        # EXECUTION
        try {
            # If the FolderToExportTo does not exist, then create it
            [System.String]$FolderToExportTo = Get-Path -ApplicationID $ApplicationID -Subfolder $SubfolderIdentifier
            if (-Not(Test-Path -Path $FolderToExportTo)) {
                Write-Busy ("The Export Folder on the DSL does not exist yet. Creating the folder: ($FolderToExportTo)" ) -ApplicationID $ApplicationID
                New-Item -Path $FolderToExportTo -ItemType Directory -Force | Out-Null
            }
            # Make a backup
            [System.Boolean]$BackupMade = New-SubFolderBackup -ApplicationID $ApplicationID -Subfolder $SubfolderIdentifier -Force -PassThru -RemoveFilesAfterBackup
            if (-Not($BackupMade)) { Return }
            # Search the DEM Repositories for the objects
            [System.IO.FileSystemInfo[]]$FoundFileObjects = switch ($ParameterSetName) {
                'ExportShortcuts'       { Get-OmnissaDEMObjects -ApplicationID $ApplicationID -Shortcuts }
                'ExportUserFiles'       { Get-OmnissaDEMObjects -ApplicationID $ApplicationID -UserFiles }
                'ExportUserRegistry'    { Get-OmnissaDEMObjects -ApplicationID $ApplicationID -UserRegistry }
            }
            # Export the objects
            foreach ($FileObject in $FoundFileObjects) {
                Write-Busy "Exporting the $ObjectTypeText Object ($($FileObject.Basename)) from the DEM Repository ($RepositoryToSearch) to ($FolderToExportTo)" -ApplicationID $ApplicationID
                Copy-Item -Path $FileObject.FullName -Destination $FolderToExportTo -Force | Out-Null
                # In case of UserFiles and UserRegistry also get the related zip file
                switch ($ParameterSetName) {
                    'ExportShortcuts'   { Write-Verbose 'Shortcut Object do not have related zip-files. No extra action needed.' }
                    Default             {
                        [System.IO.FileSystemInfo]$ZipFileObject = Get-ChildItem -Path $RepositoryToSearch -Filter *.zip | Where-Object { $_.Basename -eq $FileObject.Basename }
                        Write-Busy "Exporting the $ObjectTypeText ZipFile ($($ZipFileObject.Basename)) from the DEM Repository ($RepositoryToSearch) to ($FolderToExportTo)" -ApplicationID $ApplicationID
                        Copy-Item -Path $ZipFileObject.FullName -Destination $FolderToExportTo -Force | Out-Null
                    }
                }
            }
            Write-Success "Exported the $ObjectTypeText Objects from the DEM Repository ($RepositoryToSearch) to ($FolderToExportTo)" -ApplicationID $ApplicationID
            # Open the folder
            Open-Folder -Path $FolderToExportTo
            # Set the output
            $OutputObject = $true
        }
        catch {
            # Write the errors
            Write-FullError
            Write-Fail "Not exported the $ObjectTypeText Objects from the DEM Repository ($RepositoryToSearch)." -ApplicationID $ApplicationID
            # Set the output
            $OutputObject = $false
        }
    }
    
    end {
        # Write the End message
        Write-Function -End $FunctionDetails
        # Return the output
        if ($PassThru) { $OutputObject }
    }
}

### END OF SCRIPT
####################################################################################################
