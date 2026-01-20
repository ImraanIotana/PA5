####################################################################################################
<#
.SYNOPSIS
    This function fills the Description field in the AppLocker Policy File, with the Application ID.
    And makes a backup before applying any changes.
.DESCRIPTION
    This function is part of the Packaging Assistant. It contains references to classes, functions or variables, that are in other files.
.EXAMPLE
    Confirm-AppLockerPolicy -ApplicationID 'Adobe_Reader_12.4'
.INPUTS
    [System.String]
.OUTPUTS
    This function returns no stream output.
.NOTES
    Version         : 5.5.1
    Author          : Imraan Iotana
    Creation Date   : August 2025
    Last Update     : August 2025
#>
####################################################################################################

function Confirm-AppLockerPolicy {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory=$true,ValueFromPipeline=$true,HelpMessage='The ID of the application that will be handled.')]
        [Alias('Application','ApplicationName','Name')]
        [System.String]
        $ApplicationID
    )
    
    begin {
        ####################################################################################################
        ### MAIN PROPERTIES ###

        # Function
        [System.String[]]$FunctionDetails = @($MyInvocation.MyCommand,$PSCmdlet.ParameterSetName,$PSBoundParameters.GetEnumerator())
        # Handlers
        [System.Boolean]$BackupMade = $false

        ####################################################################################################

        # Write the begin message
        Write-Function -Begin $FunctionDetails
    }
    
    process {
        try {
            # Get the Policy file from the DSL
            [System.String]$AppLockerDSLFolder = (Get-Path -ApplicationID $ApplicationID -SubFolder AppLockerFolder)
            if (-Not($AppLockerDSLFolder)) { Write-Red ('The AppLocker Folder could not be found: ({0})' -f $AppLockerDSLFolder) }
            [System.IO.FileSystemInfo[]]$AppLockerPolicyFileObjects = Get-ChildItem -Path $AppLockerDSLFolder -File -Filter *.xml | Where-Object { $_.Name.StartsWith('AppLockerPolicy') -and $_.Basename.Contains($ApplicationID) }
            # If no files were found, then return
            if (-Not($AppLockerPolicyFileObjects)) {
                Write-Red ('The AppLocker Policy files could not be found at the expected location: ({0})' -f $AppLockerDSLFolder)
                Open-Folder -Folder $AppLockerDSLFolder
                Return
            }
            # Set the search string
            [System.String]$HashSearchString        = ('//FileHashRule[@Description!="{0}"]' -f $ApplicationID)
            [System.String]$PathSearchString        = ('//FilePathRule[@Description!="{0}"]' -f $ApplicationID)
            [System.String]$PublisherSearchString   = ('//FilePublisherRule[@Description!="{0}"]' -f $ApplicationID)
            # For each XML file
            foreach ($PolicyFileObject in $AppLockerPolicyFileObjects) {
                # Get the content
                [System.Xml.XmlDocument]$XMLContent = Get-Content -Path $PolicyFileObject.FullName
                # Get the nodes without Description
                [System.Xml.XMLElement[]]$HashNodesWithoutDescription       = $XMLContent.SelectNodes($HashSearchString)
                [System.Xml.XMLElement[]]$PathNodesWithoutDescription       = $XMLContent.SelectNodes($PathSearchString)
                [System.Xml.XMLElement[]]$PublisherNodesWithoutDescription  = $XMLContent.SelectNodes($PublisherSearchString)
                # If there is an empty Description field, then make a backup of the AppLockerFolder
                if ($HashNodesWithoutDescription -or $PathNodesWithoutDescription -or $PublisherNodesWithoutDescription) {
                    if ($BackupMade -eq $false) { New-SubFolderBackup -ApplicationID $ApplicationID -SubFolder AppLockerFolder -Force ; $BackupMade = $true }
                }
                # Fill the Description field with the ApplicationID (Policy by Hash)
                if (-Not($HashNodesWithoutDescription)) {
                    Write-Verbose ('No Nodes without Description found in the file: ({0})' -f $PolicyFileObject.FullName)
                } else {
                    foreach ($Node in $HashNodesWithoutDescription) {
                        Write-Line ('Adding the Application ID ({0}) to the Description field, in the file: ({1})...' -f $ApplicationID,$PolicyFileObject.Name)
                        $Node.Description = $ApplicationID
                    }
                    $XMLContent.Save($PolicyFileObject.FullName)
                }
                # Fill the Description field with the ApplicationID (Policy by Path)
                if (-Not($PathNodesWithoutDescription)) {
                    Write-Verbose ('No Nodes without Description found in the file: ({0})' -f $PolicyFileObject.FullName)
                } else {
                    foreach ($Node in $PathNodesWithoutDescription) {
                        Write-Line ('Adding the Application ID ({0}) to the Description field, in the file: ({1})...' -f $ApplicationID,$PolicyFileObject.Name)
                        $Node.Description = $ApplicationID
                    }
                    $XMLContent.Save($PolicyFileObject.FullName)
                }
                # Fill the Description field with the ApplicationID (Policy by Publisher)
                if (-Not($PublisherNodesWithoutDescription)) {
                    Write-Verbose ('No Nodes without Description found in the file: ({0})' -f $PolicyFileObject.FullName)
                } else {
                    foreach ($Node in $PublisherNodesWithoutDescription) {
                        Write-Line ('Adding the Application ID ({0}) to the Description field, in the file: ({1})...' -f $ApplicationID,$PolicyFileObject.Name)
                        $Node.Description = $ApplicationID
                    }
                    $XMLContent.Save($PolicyFileObject.FullName)
                }
            }
        }
        catch {
            Write-FullError
        }
    }
    
    end {
        # Write the end message
        Write-Function -End $FunctionDetails
    }
}

### END OF FUNCTION
####################################################################################################
