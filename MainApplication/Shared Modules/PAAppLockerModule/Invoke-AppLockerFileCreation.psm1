####################################################################################################
<#
.SYNOPSIS
    This function generates a timestamp in different handy formats.
.DESCRIPTION
    This function is part of the Packaging Assistant. It contains functions and variables that are in other files.
.EXAMPLE
    Invoke-AppLockerFileCreation
.INPUTS
    [System.Management.Automation.SwitchParameter]
.OUTPUTS
    [System.String]
.NOTES
    Version         : 5.4.8
    Author          : Imraan Iotana
    Creation Date   : July 2025
    Last Update     : July 2025
#>
####################################################################################################

function Invoke-AppLockerFileCreation {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory=$true,HelpMessage='The parent folder where the output will be placed.')]
        [System.String]
        $ApplicationID,

        [Parameter(Mandatory=$true,HelpMessage='The path folder to get all executables and dlls from.')]
        [System.String]
        $FolderToScan,

        [Parameter(Mandatory=$true,HelpMessage='The SID of the AD group that will be added to the policy file.')]
        [AllowEmptyString()]
        [System.String]
        $ADGroupSID
    )
    
    begin {
        ####################################################################################################
        ### MAIN PROPERTIES ###

        # Function
        [System.String[]]$FunctionDetails   = @($MyInvocation.MyCommand,$PSCmdlet.ParameterSetName,$PSBoundParameters.GetEnumerator())

        ####################################################################################################

        # Write the begin message
        Write-Function -Begin $FunctionDetails
    }
    
    process {
        # Get Confirmation
        [System.Boolean]$UserConfirmed = Get-UserConfirmation -Title 'Confirm AppLocker File Creation' -Body ("This will CREATE the AppLocker Policy for the application:`n`n{0}`n`nAre you sure?" -f $ApplicationID)
        if (-Not($UserConfirmed)) { Return }
        # Make a backup of the files on the DSL
        if (-Not(New-ApplicationBackup -ApplicationID $ApplicationID -Type AppLockerFolder)) { Write-Red 'Something went wrong with the backup. The process has been halted.' ; Write-NoAction ; Return }
        # Create the AppLocker files
        [System.String]$OutputFolder = Get-Path -ApplicationID $ApplicationID -SubFolder AppLockerFolder
        New-AppLockerFile -Path $FolderToScan -ADGroupSID $ADGroupSID -OutputFolder $OutputFolder -ApplicationID $ApplicationID
        Open-Folder -Path $OutputFolder
    }
    
    end {
        # Write the end message
        Write-Function -End $FunctionDetails
    }
}

### END OF SCRIPT
####################################################################################################
