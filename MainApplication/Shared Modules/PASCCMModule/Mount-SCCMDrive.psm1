####################################################################################################
<#
.SYNOPSIS
    This function ...
.DESCRIPTION
    This function is self-contained and does not refer to functions, variables or classes, that are in other files.
    This function is part of the Packaging Assistant. It contains functions and variables that are in other files.
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

function Mount-SCCMDrive {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory=$false,HelpMessage='The SCCM SiteCode (usually like "XYZ").')]
        [System.String]
        $SCCMSiteCode = (Get-Path -SCCMSiteCode),

        [Parameter(Mandatory=$false,HelpMessage='The SCCM Provider Machine Name (usually like "Server123.domain.com").')]
        [System.String]
        $ProviderMachineName = (Get-Path -SCCMProviderMachineName)
    )

    begin {
        ####################################################################################################
        ### MAIN PROPERTIES ###

        # Function
        [System.String[]]$FunctionDetails   = @($MyInvocation.MyCommand,$PSCmdlet.ParameterSetName,$PSBoundParameters.GetEnumerator())
        [System.String]$PreFix              = "[$($MyInvocation.MyCommand)]:"

        # Output
        [System.Boolean]$OutputObject       = $null

        ####################################################################################################
        ### SUPPORTING FUNCTIONS ###

        function Test-SCCMDriveMappingInternal {
            if ((Get-PSDrive -Name $SCCMSiteCode -PSProvider CMSite -ErrorAction SilentlyContinue) -eq $null) { $false } else { $true }
        }

        ####################################################################################################

        # Write the Begin message
        #Write-Function -Begin $FunctionDetails
    }
    
    process {
        try {
            # Connect to the SCCM site's drive if it is not already present
            if (Test-SCCMDriveMappingInternal) {
                Write-Verbose "The drive named ($SCCMSiteCode) is already mapped.'"
            } else {
                Write-Verbose "Mapping a new drive named ($SCCMSiteCode) to the SCCM Provider ($ProviderMachineName)..."
                New-PSDrive -Name $SCCMSiteCode -PSProvider CMSite -Root $ProviderMachineName
            }
        }
        catch [System.Management.Automation.ParameterBindingException]{
            Write-Host "The SCCM Sitecode or ProviderMachineName is empty. They will be filled with the default values. Respectively: ($($Global:ApplicationObject.Settings.SCCMDefaultSiteCode)) and ($($Global:ApplicationObject.Settings.SCCMDefaultProviderMachineName))"
        }
        catch {
            Write-FullError
        }
    }
    
    end {
        # Write the End message
        #Write-Function -End $FunctionDetails
    }
}

### END OF SCRIPT
####################################################################################################
