####################################################################################################
<#
.SYNOPSIS
    This function ...
.DESCRIPTION
    This function is self-contained and does not refer to functions, variables or classes, that are in other files.
    This function is part of the Packaging Assistant. It contains references to classes, functions or variables, that are in other files.
.EXAMPLE
    Function-Template -Initialize
.EXAMPLE
    Function-Template -Write -PropertyName OutputFolder -PropertyValue 'C:\Demo\WorkFolder'
.EXAMPLE
    Function-Template -Read -PropertyName OutputFolder
.EXAMPLE
    Function-Template -Remove -PropertyName OutputFolder
.INPUTS
    [System.String]
    [System.Management.Automation.SwitchParameter]
.OUTPUTS
    This function returns no stream output.
    [System.Boolean]
    [System.String]
.NOTES
    Version         : 5.5.1
    Author          : Imraan Iotana
    Creation Date   : September 2025
    Last Update     : September 2025
.COPYRIGHT
    Copyright (C) Iotana. All rights reserved.
#>
####################################################################################################

function Get-ApplicationProperties {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory=$true,HelpMessage='The ID of the application that will be handled.')]
        [Alias('Application','ApplicationName','Name')]
        [AllowNull()][AllowEmptyString()]
        [System.String]
        $ApplicationID
    )

    begin {
        ####################################################################################################
        ### MAIN PROPERTIES ###

        # Function
        [System.String[]]$FunctionDetails   = @($MyInvocation.MyCommand,$PSCmdlet.ParameterSetName,$PSBoundParameters.GetEnumerator())
        [System.String]$PreFix              = "[$($MyInvocation.MyCommand)]:"
        # Output
        [PSCustomObject]$OutputObject       = @{}

        ####################################################################################################

        # Write the Begin message
        Write-Function -Begin $FunctionDetails
    }
    
    process {
        # VALIDATION
        # Validate the ApplicationID
        if (Test-Object -IsEmpty $ApplicationID) { Write-Red "The Application ID is empty." ; Write-NoAction ; Return }
        # Validate the MetadataFolder
        [System.String]$MetadataFolder = Get-Path -ApplicationID $ApplicationID -Subfolder MetadataFolder
        if (-Not(Test-Path -Path $MetadataFolder)) { Write-Red "The MetadataFolder could not be found: ($MetadataFolder)" -NoAction ; Return }
        # Validate the MetadataFilePath
        [System.String]$MetadataFileName = "MetaData_$ApplicationID.json"
        [System.String]$MetadataFilePath = Join-Path -Path $MetadataFolder -ChildPath $MetadataFileName
        if (-Not(Test-Path -Path $MetadataFilePath)) { Write-Red "The Metadata file was not found at the expected location: ($MetadataFilePath)'" }

        # EXECUTION
        [PSCustomObject]$MetadataFileContent = Get-Content -Path $MetadataFilepath -Raw | ConvertFrom-Json
        [PSCustomObject]$OutputObject = $MetadataFileContent
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
