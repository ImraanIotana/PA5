####################################################################################################
<#
.SYNOPSIS
    This function gets the Omnissa DEM Objects, based on the ApplicationID.
.DESCRIPTION
    This function is part of the Packaging Assistant. It contains references to classes, functions or variables, that are in other files.
.EXAMPLE
    Test-OmnissaDEMObjects -ApplicationID 'Adobe_Reader_12.4' -Shortcuts
.EXAMPLE
    Test-OmnissaDEMObjects -ApplicationID 'Adobe_Reader_12.4' -UserRegistry
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

function Get-OmnissaDEMObjects {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory=$true,ValueFromPipeline=$true,HelpMessage='The ID of the application that will be handled.')]
        [AllowNull()]
        [AllowEmptyString()]
        [System.String]
        $ApplicationID,

        [Parameter(Mandatory=$true,ParameterSetName='GetShortcuts',HelpMessage='Switch for checking Shortcut Objects.')]
        [System.Management.Automation.SwitchParameter]
        $Shortcuts,

        [Parameter(Mandatory=$true,ParameterSetName='GetUserFiles',HelpMessage='Switch for checking UserFiles Objects.')]
        [System.Management.Automation.SwitchParameter]
        $UserFiles,

        [Parameter(Mandatory=$true,ParameterSetName='GetUserRegistry',HelpMessage='Switch for checking UserRegistry Objects.')]
        [System.Management.Automation.SwitchParameter]
        $UserRegistry,

        [Parameter(Mandatory=$false,HelpMessage='Switch for showing the details in the host.')]
        [System.Management.Automation.SwitchParameter]
        $OutHost
    )

    begin {
        ####################################################################################################
        ### MAIN PROPERTIES ###

        # Function
        [System.String[]]$FunctionDetails   = @($MyInvocation.MyCommand,$PSCmdlet.ParameterSetName,$PSBoundParameters.GetEnumerator())
        [System.String]$FunctionName        = $FunctionDetails[0]
        [System.String]$ParameterSetName    = $FunctionDetails[1]

        # Output
        [System.IO.FileSystemInfo[]]$OutputObject = @()

        # Handlers
        [System.String]$RepositoryToSearch  = switch ($ParameterSetName) {
            'GetShortcuts'      { $Global:ApplicationObject.Settings.DEMShortcutRepository }
            'GetUserFiles'      { $Global:ApplicationObject.Settings.DEMUserFilesRepository }
            'GetUserRegistry'   { $Global:ApplicationObject.Settings.DEMUserRegistryRepository }
        }
        [System.String]$ObjectTypeText      = switch ($ParameterSetName) {
            'GetShortcuts'      { 'Shortcut' }
            'GetUserFiles'      { 'UserFile' }
            'GetUserRegistry'   { 'UserRegistry' }
        }

        ####################################################################################################

        # Write the Begin message
        Write-Function -Begin $FunctionDetails
    }
    
    process {
        # Validate the properties
        if (Test-Object -IsEmpty $ApplicationID) { Write-Red ('The Application ID is empty.') ; Write-NoAction ; Return }
        # Search the DEM Repositories for the objects
        if ($OutHost) { Write-Line ('Searching Omnissa DEM Objects of the application ({0}) in the Repository ({1}). One moment please...' -f $ApplicationID,$RepositoryToSearch) }
        [System.IO.FileSystemInfo[]]$FoundFileObjects = Get-ChildItem -Path $RepositoryToSearch -Filter *.xml | Where-Object { Get-Content -Path $_.FullName -Raw | Select-String -Pattern $ApplicationID }
        # Set the message
        [System.String]$ResultMessage = ('{0} {1} Objects were found.' -f $FoundFileObjects.Count,$ObjectTypeText)
        # If none were found, write the message in yellow, and return
        if ($FoundFileObjects.Count -eq 0) { if ($OutHost) { Write-Yellow $ResultMessage } ; Return }
        # Write the message in green
        if ($OutHost) { Write-Green $ResultMessage ; $FoundFileObjects | ForEach-Object { Write-Host ('- {0}' -f $_.Name) } }
        # Set the output
        $OutputObject = $FoundFileObjects
    }
    
    end {
        # Write the End message
        Write-Function -End $FunctionDetails
        # Return the output
        $OutputObject
    }
}

### END OF SCRIPT
####################################################################################################
