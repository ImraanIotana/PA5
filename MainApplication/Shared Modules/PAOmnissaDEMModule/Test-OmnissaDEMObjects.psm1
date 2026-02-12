####################################################################################################
<#
.SYNOPSIS
    This function checks if Omnissa DEM Objects exist, based on the ApplicationID.
.DESCRIPTION
    This function is part of the Packaging Assistant. It contains functions and variables that are in other files.
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

function Test-OmnissaDEMObjects {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory=$true,ValueFromPipeline=$true,HelpMessage='The ID of the application that will be handled.')]
        [AllowNull()]
        [AllowEmptyString()]
        [System.String]
        $ApplicationID,

        [Parameter(Mandatory=$true,ParameterSetName='TestShortcuts',HelpMessage='Switch for checking Shortcut Objects.')]
        [System.Management.Automation.SwitchParameter]
        $Shortcuts,

        [Parameter(Mandatory=$true,ParameterSetName='TestUserFiles',HelpMessage='Switch for checking UserFiles Objects.')]
        [System.Management.Automation.SwitchParameter]
        $UserFiles,

        [Parameter(Mandatory=$true,ParameterSetName='TestUserRegistry',HelpMessage='Switch for checking UserRegistry Objects.')]
        [System.Management.Automation.SwitchParameter]
        $UserRegistry,

        [Parameter(Mandatory=$false,HelpMessage='Switch for showing the details in the host.')]
        [System.Management.Automation.SwitchParameter]
        $OutHost,

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
        [System.String]$ObjectTypeText      = switch ($ParameterSetName) {
            'TestShortcuts'     { 'Shortcut' }
            'TestUserFiles'     { 'UserFile' }
            'TestUserRegistry'  { 'UserRegistry' }
        }

        ####################################################################################################

        # Write the Begin message
        Write-Function -Begin $FunctionDetails
    }
    
    process {
        # Validate the properties
        if (Test-Object -IsEmpty $ApplicationID) { Write-Red ('The Application ID is empty.') ; Write-NoAction ; Return }
        # Search the DEM Repositories for the objects
        [System.IO.FileSystemInfo[]]$FoundFileObjects = switch ($ParameterSetName) {
            'TestShortcuts'     { Get-OmnissaDEMObjects -ApplicationID $ApplicationID -Shortcuts }
            'TestUserFiles'     { Get-OmnissaDEMObjects -ApplicationID $ApplicationID -UserFiles }
            'TestUserRegistry'  { Get-OmnissaDEMObjects -ApplicationID $ApplicationID -UserRegistry }
        }
        # Set the message
        [System.String]$ResultMessage = ('{0} {1} Objects were found.' -f $FoundFileObjects.Count,$ObjectTypeText)
        # If none were found, write the message in yellow, and return
        if ($FoundFileObjects.Count -eq 0) { if ($OutHost) { Write-Yellow $ResultMessage } ; Return }
        # Write the message in green
        if ($OutHost) { Write-Green $ResultMessage ; $FoundFileObjects | ForEach-Object { Write-Host ('- {0}' -f $_.Name) } }
        # Set the output
        $OutputObject = $true
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
