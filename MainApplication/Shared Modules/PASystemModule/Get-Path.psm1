####################################################################################################
<#
.SYNOPSIS
    This function generates a timestamp in different handy formats.
.DESCRIPTION
    This function is part of the Packaging Assistant. It contains functions and variables that are in other files.
.EXAMPLE
    Get-Path -ApplicationID 'Adobe_Reader_12.4' -SubFolder AppLockerFolder
.EXAMPLE
    Get-Path -DSL
.INPUTS
    [System.Management.Automation.SwitchParameter]
.OUTPUTS
    [System.String]
.NOTES
    Version         : 5.5.1
    Author          : Imraan Iotana
    Creation Date   : July 2025
    Last Update     : August 2025
#>
####################################################################################################

function Get-Path {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory=$true,ParameterSetName='GetApplicationFolder',HelpMessage='The ID of the application that will be handled.')]
        [Parameter(Mandatory=$true,ParameterSetName='GetApplicationSubFolder')]
        [Parameter(Mandatory=$true,ParameterSetName='GetApplicationLogFilePath')]
        [Parameter(Mandatory=$true,ParameterSetName='GetApplicationWordDocumentPath')]
        [Alias('Application','ApplicationName','Name')]
        [System.String]
        $ApplicationID,

        [Parameter(Mandatory=$true,ParameterSetName='GetApplicationSubFolder',HelpMessage='The subfolder of the application that must be retrieved.')]
        [System.String]
        $Subfolder,

        [Parameter(Mandatory=$true,ParameterSetName='GetApplicationLogFilePath',HelpMessage='Switch for returning the path of the logfile.')]
        [System.Management.Automation.SwitchParameter]
        $LogFilePath,

        [Parameter(Mandatory=$true,ParameterSetName='GetApplicationWordDocumentPath',HelpMessage='Switch for returning the path of the Word Document.')]
        [System.Management.Automation.SwitchParameter]
        $WordDocumentPath,

        [Parameter(Mandatory=$true,ParameterSetName='GetDSLFolder',HelpMessage='Switch for returning the DSL folder')]
        [System.Management.Automation.SwitchParameter]
        [Alias('DSLFolder','SoftwareLibrary')]
        $DSL,

        [Parameter(Mandatory=$true,ParameterSetName='GetUserDownloadsFolder',HelpMessage='Switch for returning the users downloads folder')]
        [System.Management.Automation.SwitchParameter]
        $DownloadsFolder,

        [Parameter(Mandatory=$true,ParameterSetName='GetOutputFolder',HelpMessage='Switch for returning the output folder')]
        [System.Management.Automation.SwitchParameter]
        $OutputFolder,

        [Parameter(Mandatory=$true,ParameterSetName='GetAppLockerLDAPTEST',HelpMessage='Switch for returning the AppLocker LDAP for Test')]
        [System.Management.Automation.SwitchParameter]
        $AppLockerLDAPTEST,

        [Parameter(Mandatory=$true,ParameterSetName='GetAppLockerLDAPPROD',HelpMessage='Switch for returning the AppLocker LDAP for Production')]
        [System.Management.Automation.SwitchParameter]
        $AppLockerLDAPPROD,

        [Parameter(Mandatory=$true,ParameterSetName='GetSCCMRepository',HelpMessage='Switch for returning the SCCMRepository')]
        [System.Management.Automation.SwitchParameter]
        $SCCMRepository,

        [Parameter(Mandatory=$true,ParameterSetName='GetSCCMSiteCode',HelpMessage='Switch for returning the SCCMSiteCode')]
        [System.Management.Automation.SwitchParameter]
        $SCCMSiteCode,

        [Parameter(Mandatory=$true,ParameterSetName='GetSCCMProviderMachineName',HelpMessage='Switch for returning the SCCMSiteCode')]
        [System.Management.Automation.SwitchParameter]
        $SCCMProviderMachineName
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
        # Switch on the ParameterSetName
        [System.String]$OutputObject = switch ($PSCmdlet.ParameterSetName) {
            'GetApplicationFolder'          { Get-DSLApplicationFolder -ApplicationID $ApplicationID }
            'GetApplicationSubFolder'       {
                [System.String]$ApplicationFolder   = Get-Path -ApplicationID $ApplicationID
                if (-Not($ApplicationFolder)) { Write-Red ('The Application Folder could not be found: ({0})' -f $ApplicationFolder) ; Return }
                [System.String]$SubFolderPath       = Join-Path -Path $ApplicationFolder -ChildPath (Get-ApplicationSubfolders).($SubFolder)
                $SubFolderPath
            }
            'GetApplicationLogFilePath'     {
                [System.String]$ApplicationLogFolder    = Get-Path -ApplicationID $ApplicationID -Subfolder LogFolder
                [System.String]$LogFileName             = "ApplicationLog_$ApplicationID.csv"
                [System.String]$ApplicationLogFilePath  = Join-Path -Path $ApplicationLogFolder -ChildPath $LogFileName
                $ApplicationLogFilePath
            }
            'GetApplicationWordDocumentPath'    {
                [System.String]$ApplicationDocumentationFolder  = Get-Path -ApplicationID $ApplicationID -Subfolder DocumentationFolder
                [System.String]$WordDocumentFileName            = "KS Client Application Form - $ApplicationID.docx"
                [System.String]$WordDocumentFilePath            = Join-Path -Path $ApplicationDocumentationFolder -ChildPath $WordDocumentFileName
                $WordDocumentFilePath
            }
            'GetDSLFolder'                  { Invoke-RegistrySettings -Read -PropertyName MSet_SGen_FFol_DSLFolderTextBox }
            'GetUserDownloadsFolder'        { Join-Path -Path $ENV:USERPROFILE -ChildPath 'Downloads' }
            'GetOutputFolder'               { Invoke-RegistrySettings -Read -PropertyName MSet_SGen_FFol_OutputFolderTextBox }
            'GetAppLockerLDAPTEST'          { Invoke-RegistrySettings -Read -PropertyName MSet_SApp_FApp_TB_LDAPTEST }
            'GetAppLockerLDAPPROD'          { Invoke-RegistrySettings -Read -PropertyName MSet_SApp_FApp_TB_LDAPPROD }
            'GetSCCMRepository'             { Invoke-RegistrySettings -Read -PropertyName ASSSSCCMRepositoryTextBox }
            'GetSCCMSiteCode'               { Invoke-RegistrySettings -Read -PropertyName ASSSSiteCodeTextBox }
            'GetSCCMProviderMachineName'    { Invoke-RegistrySettings -Read -PropertyName ASSSProviderMachineNameTextBox }
            default                         { Write-FullError }
        }
    }
    
    end {
        # Write the end message
        Write-Function -End $FunctionDetails
        # Return the output
        $OutputObject
    }
}

### END OF FUNCTION
####################################################################################################
