####################################################################################################
<#
.SYNOPSIS
    This function returns the full path af a shared asset, or folder.
.DESCRIPTION
    This function is part of the Packaging Assistant. It contains references to classes, functions or variables, that are in other files.
    External classes    : -
    External functions  : Invoke-RegistrySettings
    External variables  : $Global:ApplicationObject
.EXAMPLE
    Get-SharedAssetPath -AssetName MainApplicationIcon
.EXAMPLE
    Get-SharedAssetPath -OutputFolder
.INPUTS
    [System.String]
    [System.Management.Automation.SwitchParameter]
.OUTPUTS
    [System.String]
.NOTES
    Version         : 5.3.1
    Author          : Imraan Iotana
    Creation Date   : October 2024
    Last Update     : May 2025
#>
####################################################################################################

function Get-SharedAssetPath {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory=$true,ParameterSetName='ReturnAssetPath',HelpMessage='The shared asset of which the full path will be returned')]
        [Alias('Asset','FileName','File','SharedAssetName','SharedAsset')]
        [ValidateSet('MainApplicationIcon','VersionHistoryFile','MakeAppX','SignTool','MSIXIvantiTemplate','UninstallView')]
        [System.String]
        $AssetName,

        [Parameter(Mandatory=$true,ParameterSetName='ReturnIntuneWinAppUtil',HelpMessage='Switch for returning the IntuneWinAppUtil executable.')]
        [System.Management.Automation.SwitchParameter]
        $IntuneWinAppUtil,

        [Parameter(Mandatory=$true,ParameterSetName='ReturnIntuneWinFileDecoder',HelpMessage='Switch for returning the IntuneWinFileDecoder executable.')]
        [System.Management.Automation.SwitchParameter]
        $IntuneWinFileDecoder,

        [Parameter(Mandatory=$true,ParameterSetName='ReturnIconExtractor',HelpMessage='Switch for returning the icon extractor executable.')]
        [System.Management.Automation.SwitchParameter]
        $IconExtractor,

        [Parameter(Mandatory=$true,ParameterSetName='ReturnOutputFolder',HelpMessage='Switch for returning the OutputFolder.')]
        [System.Management.Automation.SwitchParameter]
        $OutputFolder,

        [Parameter(Mandatory=$true,ParameterSetName='ReturnLogFolder',HelpMessage='Switch for returning the LogFolder.')]
        [System.Management.Automation.SwitchParameter]
        $LogFolder,

        [Parameter(Mandatory=$true,ParameterSetName='ReturnUserFullName',HelpMessage='Switch for returning the UserFullName.')]
        [System.Management.Automation.SwitchParameter]
        $UserFullName,

        [Parameter(Mandatory=$true,ParameterSetName='ReturnUserEmail',HelpMessage='Switch for returning the UserEmail.')]
        [System.Management.Automation.SwitchParameter]
        $UserEmail,

        [Parameter(Mandatory=$true,ParameterSetName='ReturnSCCMSiteCode',HelpMessage='Switch for returning the SCCMSiteCode.')]
        [System.Management.Automation.SwitchParameter]
        $SCCMSiteCode,

        [Parameter(Mandatory=$true,ParameterSetName='ReturnSCCMProviderMachineName',HelpMessage='Switch for returning the SCCM Provider Machine Name.')]
        [System.Management.Automation.SwitchParameter]
        $SCCMProviderMachineName,

        [Parameter(Mandatory=$true,ParameterSetName='ReturnSCCMRepository',HelpMessage='Switch for returning the SCCM Repository.')]
        [System.Management.Automation.SwitchParameter]
        $SCCMRepository,

        ### DSL and ApplicationFolder parameters
        [Parameter(Mandatory=$true,ParameterSetName='ReturnDSLFolder',HelpMessage='Switch for returning the DSLFolder.')]
        [Alias('DSL','SoftwareLibrary')]
        [System.Management.Automation.SwitchParameter]
        $DSLFolder,

        [Parameter(Mandatory=$true,ParameterSetName='ReturnApplicationFolders',HelpMessage='Switch for returning the ApplicationFolders on the DSL.')]
        [Alias('Applications','DSLApplicationFolders')]
        [System.Management.Automation.SwitchParameter]
        $ApplicationFolders,

        [Parameter(Mandatory=$true,ParameterSetName='ReturnApplicationFolderPath',HelpMessage='Switch for returning the full path of the ApplicationFolder on the DSL.')]
        [Alias('ApplicationFolder')]
        [System.Management.Automation.SwitchParameter]
        $ApplicationFolderPath,

        [Parameter(Mandatory=$true,ParameterSetName='ReturnApplicationCustomer',HelpMessage='Switch for returning the customer of the Application.')]
        [System.Management.Automation.SwitchParameter]
        $ApplicationCustomer,

        [Parameter(Mandatory=$true,ParameterSetName='ReturnSCCMFolderPath',HelpMessage='Switch for returning the SCCMFolderPath of the Application.')]
        [System.Management.Automation.SwitchParameter]
        $SCCMFolderPath,

        [Parameter(Mandatory=$true,ParameterSetName='ReturnSCCMImageFolderPath',HelpMessage='Switch for returning the SCCMImageFolderPath of the Application.')]
        [System.Management.Automation.SwitchParameter]
        $SCCMImageFolderPath,

        [Parameter(Mandatory=$true,ParameterSetName='ReturnSCCMImagePath',HelpMessage='Switch for returning the SCCMImagePath of the Application.')]
        [System.Management.Automation.SwitchParameter]
        $SCCMImagePath,

        [Parameter(Mandatory=$true,ParameterSetName='ReturnMetadataFolderPath',HelpMessage='Switch for returning the MetadataFolderPath of the Application.')]
        [System.Management.Automation.SwitchParameter]
        $MetadataFolderPath,

        [Parameter(Mandatory=$true,ParameterSetName='ReturnMetadataFilePath',HelpMessage='Switch for returning the MetadataFilePath of the Application.')]
        [System.Management.Automation.SwitchParameter]
        $MetadataFilePath,

        [Parameter(Mandatory=$true,ParameterSetName='ReturnDeploymentScript',HelpMessage='Switch for returning the DeploymentScript of the Application.')]
        [System.Management.Automation.SwitchParameter]
        $DeploymentScript,

        [Parameter(Mandatory=$true,ParameterSetName='ReturnApplicationFolderPath',HelpMessage='ApplicationID of the Application.')]
        [Parameter(Mandatory=$true,ParameterSetName='ReturnApplicationCustomer')]
        [Parameter(Mandatory=$true,ParameterSetName='ReturnSCCMFolderPath')]
        [Parameter(Mandatory=$true,ParameterSetName='ReturnSCCMImageFolderPath')]
        [Parameter(Mandatory=$true,ParameterSetName='ReturnSCCMImagePath')]
        [Parameter(Mandatory=$true,ParameterSetName='ReturnMetadataFolderPath')]
        [Parameter(Mandatory=$true,ParameterSetName='ReturnMetadataFilePath')]
        [Parameter(Mandatory=$true,ParameterSetName='ReturnDeploymentScript')]
        [Alias('Application','ApplicationName')]
        [System.String]
        $ApplicationID
    )

    begin {
        ####################################################################################################
        ### MAIN OBJECT ###

        # Create the main object
        [PSCustomObject]$Local:MainObject = @{
            # Function
            ParameterSetName        = [System.String]$PSCmdlet.ParameterSetName
            # Folder Handlers
            SharedAssetsFolder      = $Global:ApplicationObject.WorkFolders.SharedAssets
            # Filename Handlers
            MainApplicationIcon     = $Global:ApplicationObject.IconFileName
            VersionHistoryFile      = 'Version History.txt'
            MakeAppX                = 'makeappx.exe'
            SignTool                = 'signtool.exe'
            IconExtractor           = 'extracticon.exe'
            MSIXIvantiTemplate      = 'TemplateMSIXIvantiObject.xml'
            UninstallView           = 'UninstallView.exe'
            # Intune Filename Handlers
            IntuneWinAppUtil        = 'IntuneWinAppUtil.exe'
            IntuneWinFileDecoder    = 'IntuneWinAppUtilDecoder.exe'
            # Input
            AssetName               = $AssetName
            ApplicationID           = $ApplicationID
            # Output
            OutputObject            = [System.String]::Empty
        }

        ####################################################################################################
        ### MAIN FUNCTION METHODS ###

        # Add the Process method
        Add-Member -InputObject $Local:MainObject -MemberType ScriptMethod -Name Process -Value {
            # Switch on the ParameterSetName
            $this.OutputObject = switch ($this.ParameterSetName) {
                # Files
                'ReturnAssetPath'               { $this.GetSharedAssetFullPathOLD($this.SharedAssetsFolder,$this.AssetName) }
                'ReturnIntuneWinAppUtil'        { $this.GetSharedAssetFullPath($this.SharedAssetsFolder,$this.IntuneWinAppUtil) }
                'ReturnIntuneWinFileDecoder'    { $this.GetSharedAssetFullPath($this.SharedAssetsFolder,$this.IntuneWinFileDecoder) }
                'ReturnIconExtractor'           { $this.GetSharedAssetFullPath($this.SharedAssetsFolder,$this.IconExtractor) }
                # Folders
                'ReturnDSLFolder'               { Invoke-RegistrySettings -Read -PropertyName MSet_SGen_FFol_DSLFolderTextBox }
                'ReturnApplicationFolders'      { $this.GetDSLApplicationFolders() }
                'ReturnApplicationFolderPath'   { $this.GetDSLApplicationFolderPath($this.ApplicationID) }
                'ReturnApplicationCustomer'     { $this.GetApplicationCustomerName($this.ApplicationID) }
                'ReturnSCCMFolderPath'          { $this.GetApplicationSCCMFolderPath($this.ApplicationID) }
                'ReturnDeploymentScript'        { $this.GetApplicationDeploymentScriptPath($this.ApplicationID) }
                'ReturnMetadataFolderPath'      { $this.GetApplicationMetadataFolderPath($this.ApplicationID) }
                'ReturnMetadataFilePath'        { $this.GetApplicationMetadataFilePath($this.ApplicationID) }
                'ReturnOutputFolder'            { Invoke-RegistrySettings -Read -PropertyName MSet_SGen_FFol_OutputFolderTextBox }
                'ReturnLogFolder'               { $Global:ApplicationObject.LogFolder }
                # SCCM
                'ReturnSCCMImageFolderPath'     { $this.GetApplicationSCCMImageFolderPath($this.ApplicationID) }
                'ReturnSCCMImagePath'           { $this.GetApplicationSCCMImagePath($this.ApplicationID) }
                'ReturnSCCMRepository'          { $Global:ApplicationObject.Settings.SCCMRepository }
                # User
                'ReturnUserFullName'            { Invoke-RegistrySettings -Read -PropertyName ASPSUserFullNameTextBox }
                'ReturnUserEmail'               { Invoke-RegistrySettings -Read -PropertyName ASPSUserEmailTextBox }
                # SCCM Server properties
                'ReturnSCCMSiteCode'            { Invoke-RegistrySettings -Read -PropertyName ASSSSiteCodeTextBox }
                'ReturnSCCMProviderMachineName' { Invoke-RegistrySettings -Read -PropertyName ASSSProviderMachineNameTextBox }
            }
        }

        ####################################################################################################
        ### MAIN PROCESSING METHODS ###
    
        # Add the GetSharedAssetFullPathOLD method
        Add-Member -InputObject $Local:MainObject -MemberType ScriptMethod -Name GetSharedAssetFullPathOLD -Value { param([System.String]$FolderToSearch,[System.String]$AssetName)
            # Get the filename based on the assetname
            [System.String]$FileNameToFind = $this.($AssetName)
            # Search the file in the folder
            [System.IO.FileSystemInfo[]]$FoundFileObjects = (Get-ChildItem -Path $FolderToSearch -Recurse -File | Where-Object { $_.Name -eq $FileNameToFind })
            # Switch on the amount
            [System.IO.FileSystemInfo]$FileObject = switch ($FoundFileObjects.Count) {
                0 { Write-Host 'No shared asset with the name ({0}) was found.' ;  $null }
                1 { $FoundFileObjects[0] }
                { $_ -gt 1} { (Write-Host 'Multiple shared assets with the name ({0}) were found. The first one will be returned : ({1})' -f $FileNameToFind,$FoundFileObjects[0].FullName ) ; $FoundFileObjects[0] }
            }
            # Set the SharedAssetPath
            [System.String]$SharedAssetPath = if ($FileObject) { $FileObject.FullName } else { $null }
            # Return the result
            $SharedAssetPath
        }
    
        # Add the GetSharedAssetFullPath method
        Add-Member -InputObject $Local:MainObject -MemberType ScriptMethod -Name GetSharedAssetFullPath -Value { param([System.String]$FolderToSearch,[System.String]$FileNameToFind)
            # Search the file in the folder
            [System.IO.FileSystemInfo[]]$FoundFileObjects = (Get-ChildItem -Path $FolderToSearch -Recurse -File | Where-Object { $_.Name -eq $FileNameToFind })
            # Switch on the amount
            [System.IO.FileSystemInfo]$FileObject = switch ($FoundFileObjects.Count) {
                0 { Write-Host ('No shared asset with the name ({0}) was found.' -f $FileNameToFind) ;  $null }
                1 { $FoundFileObjects[0] }
                { $_ -gt 1} { (Write-Host 'Multiple shared assets with the name ({0}) were found. The first one will be returned : ({1})' -f $FileNameToFind,$FoundFileObjects[0].FullName ) ; $FoundFileObjects[0] }
            }
            # Set the SharedAssetPath
            [System.String]$SharedAssetPath = if ($FileObject) { $FileObject.FullName } else { $null }
            # Return the result
            $SharedAssetPath
        }
    
        # Add the GetDSLApplicationFolders method
        Add-Member -InputObject $Local:MainObject -MemberType ScriptMethod -Name GetDSLApplicationFolders -Value {
            # Set the DSLFolder
            [System.String]$DSLFolder = Get-SharedAssetPath -DSLFolder
            # Search the Customer folder objects
            [System.IO.FileSystemInfo[]]$CustomerFolderObjects = (Get-ChildItem -Path $DSLFolder -Directory | Where-Object { -Not($_.Name.StartsWith('_')) })
            # Search the subfolders in the folder
            [System.String[]]$DSLApplicationFolders = @()
            foreach ($CustomerFolderObject in $CustomerFolderObjects) {
                [System.String[]]$SubFolders = (Get-ChildItem -Path $CustomerFolderObject.FullName -Directory | Where-Object { -Not($_.Name.StartsWith('_')) }).Name
                $DSLApplicationFolders += $SubFolders
            }
            # Clean up the results
            $CleanedUpArray = $DSLApplicationFolders | Where-Object { Test-Object -IsPopulated $_ } | Get-Unique | Sort-Object
            # Return the result
            $CleanedUpArray
        }
    
        # Add the GetDSLApplicationFolderPath method
        Add-Member -InputObject $Local:MainObject -MemberType ScriptMethod -Name GetDSLApplicationFolderPath -Value { param([System.String]$ApplicationID)
            try {
                # Get the DSLFolder
                [System.String]$DSLFolder = Get-SharedAssetPath -DSLFolder
                # Search the ApplicationFolder
                [System.String]$ApplicationFolderPath = (Get-ChildItem -Path $DSLFolder -Recurse -Depth 1 -Directory | Where-Object { $_.Name -eq $ApplicationID }).FullName
                # Return the result
                $ApplicationFolderPath
            }
            catch {
                Write-FullError
            }
        }
    
        # Add the GetApplicationSCCMFolderPath method
        Add-Member -InputObject $Local:MainObject -MemberType ScriptMethod -Name GetApplicationSCCMFolderPath -Value { param([System.String]$ApplicationID)
            try {
                # Set the properties
                [System.String]$ApplicationFolderPath   = $this.GetDSLApplicationFolderPath($ApplicationID)
                [System.String]$SCCMFolder              = (Get-ApplicationSubfolders).SCCMFolder
                [System.String]$ChildPath               = ('{0}\{1}' -f $SCCMFolder,$ApplicationID)
                # Set the DeploymentScriptPath
                [System.String]$ApplicationSCCMFolderPath = Join-Path -Path $ApplicationFolderPath -ChildPath $ChildPath
                # Return the result
                $ApplicationSCCMFolderPath
            }
            catch {
                Write-FullError
            }
        }
    
        # Add the GetApplicationCustomerName method
        Add-Member -InputObject $Local:MainObject -MemberType ScriptMethod -Name GetApplicationCustomerName -Value { param([System.String]$ApplicationID)
            try {
                # Get the ApplicationFolder
                [System.String]$ApplicationFolderPath = $this.GetDSLApplicationFolderPath($ApplicationID)
                [System.IO.FileSystemInfo]$ApplicationFolderObject = Get-Item -Path $ApplicationFolderPath
                # Get the CustomerName
                [System.String]$CustomerName = Split-Path -Path $ApplicationFolderObject.PSParentPath -Leaf
                # Return the result
                $CustomerName
            }
            catch {
                Write-FullError
            }
        }
    
        # Add the GetApplicationDeploymentScriptPath method
        Add-Member -InputObject $Local:MainObject -MemberType ScriptMethod -Name GetApplicationDeploymentScriptPath -Value { param([System.String]$ApplicationID)
            try {
                # Set the properties
                [System.String]$ApplicationSCCMFolderPath = $this.GetApplicationSCCMFolderPath($ApplicationID)
                [System.String]$ChildPath = ('Deploy-Application.ps1')
                # Set the DeploymentScriptPath
                [System.String]$DeploymentScriptPath = Join-Path -Path $ApplicationSCCMFolderPath -ChildPath $ChildPath
                # Return the result
                $DeploymentScriptPath
            }
            catch {
                Write-FullError
            }
        }
    
        # Add the GetApplicationSCCMImageFolderPath method
        Add-Member -InputObject $Local:MainObject -MemberType ScriptMethod -Name GetApplicationSCCMImageFolderPath -Value { param([System.String]$ApplicationID)
            try {
                # Set the properties
                [System.String]$SCCMFolderPath  = $this.GetApplicationSCCMFolderPath($ApplicationID)
                [System.String]$ChildPath       = ('SourceFiles\_SCCM Input')
                # Set the SCCMImageFolderPath
                [System.String]$SCCMImageFolderPath = Join-Path -Path $SCCMFolderPath -ChildPath $ChildPath
                # Return the result
                $SCCMImageFolderPath
            }
            catch {
                Write-FullError
            }
        }
    
        # Add the GetApplicationSCCMImagePath method
        Add-Member -InputObject $Local:MainObject -MemberType ScriptMethod -Name GetApplicationSCCMImagePath -Value { param([System.String]$ApplicationID)
            try {
                # Set the properties
                [System.String]$SCCMImageFolderPath = $this.GetApplicationSCCMImageFolderPath($ApplicationID)
                [System.String]$ChildPath           = ('{0}.png' -f $ApplicationID)
                # Set the SCCMImagePath
                [System.String]$SCCMImagePath       = Join-Path -Path $SCCMImageFolderPath -ChildPath $ChildPath
                # Return the result
                $SCCMImagePath
            }
            catch {
                Write-FullError
            }
        }
    
        # Add the GetApplicationMetadataFolderPath method
        Add-Member -InputObject $Local:MainObject -MemberType ScriptMethod -Name GetApplicationMetadataFolderPath -Value { param([System.String]$ApplicationID)
            try {
                # Set the properties
                [System.String]$ApplicationFolderPath   = $this.GetDSLApplicationFolderPath($ApplicationID)
                [System.String]$MetadataFolderName      = (Get-ApplicationSubfolders).MetadataFolder
                # Set the MetadataFolderPath
                [System.String]$MetadataFolderPath      = Join-Path -Path $ApplicationFolderPath -ChildPath $MetadataFolderName
                # Return the result
                $MetadataFolderPath
            }
            catch {
                Write-FullError
            }
        }
    
        # Add the GetApplicationMetadataFilePath method
        Add-Member -InputObject $Local:MainObject -MemberType ScriptMethod -Name GetApplicationMetadataFilePath -Value { param([System.String]$ApplicationID)
            try {
                # Set the properties
                [System.String]$MetadataFolderPath  = $this.GetApplicationMetadataFolderPath($ApplicationID)
                [System.String]$MetadataFileName    = ('MetaData_{0}.json' -f $ApplicationID)
                # Set the MetadataFilePath
                [System.String]$MetadataFilePath    = Join-Path -Path $MetadataFolderPath -ChildPath $MetadataFileName
                # Return the result
                $MetadataFilePath
            }
            catch {
                Write-FullError
            }
        }
    }
    
    process {
        $Local:MainObject.Process()
    }

    end {
        # Return the output
        $Local:MainObject.OutputObject
    }
}

### END OF SCRIPT
####################################################################################################
