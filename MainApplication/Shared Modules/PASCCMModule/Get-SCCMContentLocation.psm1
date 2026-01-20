####################################################################################################
<#
.SYNOPSIS
    This function get the Content Location of an SCCM Application.
.DESCRIPTION
    This function is part of the Packaging Assistant. It contains references to classes, functions or variables, that are in other files.
.EXAMPLE
    Get-SCCMContentLocation -ApplicationID 'Adobe_Reader_12.4'
.INPUTS
    [System.String]
.OUTPUTS
    [System.String]
.NOTES
    Version         : 5.5.1
    Author          : Imraan Iotana
    Creation Date   : September 2025
    Last Update     : September 2025
#>
####################################################################################################

function Get-SCCMContentLocation {
    [CmdletBinding(DefaultParameterSetName='GetFromSCCMInternal')]
    param (
        [Parameter(Mandatory=$true,HelpMessage='The ID of the application that will be handled.')]
        [Alias('Application','ApplicationName','Name')]
        [System.String]
        $ApplicationID,

        [Parameter(Mandatory=$false,ParameterSetName='GetFromSCCMInternal',HelpMessage='Switch for getting the Content Location from as set inside SCCM.')]
        [System.Management.Automation.SwitchParameter]
        $FromSCCMInternal,

        [Parameter(Mandatory=$false,ParameterSetName='GetFromSCCMRepository',HelpMessage='Switch for getting the Content Location from SCCM Repository.')]
        [System.Management.Automation.SwitchParameter]
        $FromSCCMRepository
    )

    begin {
        ####################################################################################################
        ### MAIN PROPERTIES ###

        # Function
        [System.String[]]$FunctionDetails   = @($MyInvocation.MyCommand,$PSCmdlet.ParameterSetName,$PSBoundParameters.GetEnumerator())
        # Handlers
        [System.String]$SCCMRepository      = $Global:ApplicationObject.Settings.SCCMRepository
        # Output
        [System.String]$OutputObject        = [System.String]::Empty

        ####################################################################################################
        ### SUPPORTING FUNCTIONS ###

        function Get-FromSCCMInternal { param([System.String]$ApplicationID = $ApplicationID)
            # Get the DeploymentType
            Invoke-SCCMConnectionAction -SwitchToDrive
            [Microsoft.ConfigurationManagement.ManagementProvider.WqlQueryEngine.WqlResultObject]$DeploymentType = Get-CMDeploymentType -ApplicationName $ApplicationID | Where-Object { $_.LocalizedDisplayName -eq 'Install' }
            Invoke-SCCMConnectionAction -SwitchBack
            # Get the XML
            [System.Xml.XmlDocument]$XML = $DeploymentType.SDMPackageXML
            # Get the ContentLocation
            [System.String]$ContentLocation = $XML.AppMgmtDigest.DeploymentType.Installer.Contents.Content.Location
            # Return the result
            $ContentLocation
        }

        function Get-FromSCCMRepository { param([System.String]$ApplicationID = $ApplicationID)
            # Find the folder on the SCCM Repository
            Write-Verbose ('Searching the application ({0}) on the SCCM Repository ({1}). One moment please...' -f $ApplicationID,$SCCMRepository)
            [System.IO.DirectoryInfo[]]$ApplicationFolderObjectsOnSCCMRepository = Get-ChildItem -Path $SCCMRepository -Recurse -Directory | Where-Object { $_.Basename -eq $ApplicationID }
            [System.String]$ContentLocation = switch ($ApplicationFolderObjectsOnSCCMRepository.Count) {
                1 {
                    #Return the result
                    Write-Verbose ('Application Folder found on the SCCM Repository: ({0})' -f $ApplicationFolderObjectsOnSCCMRepository.FullName)
                    $ApplicationFolderObjectsOnSCCMRepository.FullName
                }
                0 { Write-FullError ('Source Folder NOT found on the SCCM Repository: ({0})' -f $SCCMRepository) ; Write-NoAction ; Return }
                Default { Write-FullError ('Multiple Folders found on the SCCM Repository with the name ({0}). Please remove the duplicates.' -f $ApplicationID) ; Write-NoAction ; Return }
            }
            # Return the result
            $ContentLocation
        }


        ####################################################################################################

        # Write the Begin message
        Write-Function -Begin $FunctionDetails
    }
    
    process {
        # Switch on the ParameterSetName
        [System.String]$ContentLocation = switch ($FunctionDetails[1]) {
            'GetFromSCCMInternal'   { Get-FromSCCMInternal }
            'GetFromSCCMRepository' { Get-FromSCCMRepository }
        }
        # Trim the result
        if ($ContentLocation) { $OutputObject = $ContentLocation.TrimEnd('\') }
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
