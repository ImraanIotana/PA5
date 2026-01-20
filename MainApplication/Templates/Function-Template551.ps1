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
    Creation Date   : October 2025
    Last Update     : October 2025
.COPYRIGHT
    Copyright (C) Iotana. All rights reserved.
#>
####################################################################################################

function Function-Template551 {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory=$true,HelpMessage='The ID of the application that will be handled.')]
        [Alias('Application','ApplicationName','Name')]
        [AllowNull()][AllowEmptyString()]
        [System.String]
        $ApplicationID,

        [Parameter(Mandatory=$true,ParameterSetName='ParameterSetName1',HelpMessage='Switch for ... .')]
        [System.Management.Automation.SwitchParameter]
        $SwitchParameter,

        [Parameter(Mandatory=$true,HelpMessage='The subfolder of the application that must be retrieved.')]
        [ValidateSet('DocumentationFolder','AppLockerFolder','ShortcutsFolder','WorkFolder','MetadataFolder','BackupsFolder')]
        [System.String]
        $Subfolder,

        [Parameter(Mandatory=$false,HelpMessage='Switch for showing the details in the host.')]
        [System.Management.Automation.SwitchParameter]
        $OutHost,

        [Parameter(Mandatory=$false,HelpMessage='Switch for skipping the confirmations.')]
        [System.Management.Automation.SwitchParameter]
        $Force,

        [Parameter(Mandatory=$false,HelpMessage='Switch for returning the result as a boolean.')]
        [System.Management.Automation.SwitchParameter]
        $PassThru
    )

    begin {
        ####################################################################################################
        ### MAIN PROPERTIES ###

        # Function
        #[System.String[]]$FunctionDetails   = @($MyInvocation.MyCommand,$PSCmdlet.ParameterSetName,$PSBoundParameters.GetEnumerator())
        [System.String]$PreFix              = "[$($MyInvocation.MyCommand)]:"
        [System.String]$FunctionName        = $MyInvocation.MyCommand
        [System.String]$ParameterSetName    = $PSCmdlet.ParameterSetName

        # Output
        [System.Boolean]$DeploymentSuccess  = $null
        [System.Boolean]$OutputObject       = $null
        [System.String]$OutputObject        = [System.String]::Empty

        # Validation
        [System.Collections.Generic.List[System.Boolean]]$ValidationArrayList = @()

        ####################################################################################################
        ### SUPPORTING FUNCTIONS ###

        function Confirm-Input {
            $ValidationArrayList.Add((Confirm-Object -MandatoryString $ApplicationID))
        }

        ####################################################################################################

        # Write the Begin message
        #Write-Function -Begin $FunctionDetails
        # Validate the input
        Confirm-Input
    }
    
    process {
        # If the validation failed, then return
        if ($ValidationArrayList -contains $false) { Write-Message -ValidationFailed ; Return }

        # VALIDATION
        # Validate the properties
        if (Test-Object -IsEmpty $ApplicationID) { Write-Red "The Application ID is empty." -NoAction ; Return }
        [System.String]$ApplicationLogFilePath = Get-Path -ApplicationID $ApplicationID -LogFilePath
        if (Test-Object -IsEmpty $ApplicationLogFilePath) {
            Write-Red "$PreFix The LogFilePath String for the Application ($ApplicationID) could not be obtained." -NoAction ; Return
        }

        # EXECUTION
        Write-Line "Performing Audit: [$AuditName] on Application [$ApplicationID]"
        if (Test-Path -Path $ApplicationLogFilePath) {
            Write-Green "Audit Result: The Application ($ApplicationID) has a LogFile."
            Write-Green "The path of the LogFile is: ($ApplicationLogFilePath)"
            $OutputObject = $true
            Return
        }

        # CONFIRMATION
        Write-Red "Audit Result: The Application ($ApplicationID) does NOT have a LogFile."
        # Get confirmation
        [System.Boolean]$UserConfirmed = Get-UserConfirmation -Title 'Confirm Correction' -Body ("This will CREATE a new Logfile for the application:`n`n$ApplicationID`n`nAre you sure?")
        if (-Not($UserConfirmed)) { Return }

        # CORRECTION
        # Create the logfile by creating the first line
        Write-Success "Created LogFile for the application ($ApplicationID)" -ApplicationID $ApplicationID
        $OutputObject = $true

        # TESTING
        #Open-Folder (Split-Path -Path $ApplicationLogFilePath -Parent)
        #Invoke-Item -Path $ApplicationLogFilePath
    }
    
    end {
        # Write the End message
        #Write-Function -End $FunctionDetails
        # Return the output
        if ($PassThru) { $OutputObject }
    }
}

### END OF SCRIPT
####################################################################################################
