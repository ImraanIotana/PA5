####################################################################################################
<#
.SYNOPSIS
    This function creates a new meta data file for applications.
.DESCRIPTION
    This function is part of the Packaging Assistant. It contains functions and variables that are in other files.
.EXAMPLE
    New-MetaDataFile
.INPUTS
    [System.String]
.OUTPUTS
    This function returns no stream-output.
.NOTES
    Version         : 5.4.7
    Author          : Imraan Iotana
    Creation Date   : May 2025
    Last Update     : August 2025
#>
####################################################################################################

function New-MetaDataFile {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory=$true,HelpMessage='The ID of the application that will be handled.')]
        [Alias('Application','ApplicationName','Name')]
        [AllowEmptyString()]
        [System.String]
        $ApplicationID,

        [Parameter(Mandatory=$false,HelpMessage='The parentfolder in which this new folder will be placed.')]
        [System.String]
        $ParentOutputFolder = (Get-SharedAssetPath -OutputFolder)
    )
    
    begin {
        ####################################################################################################
        ### MAIN OBJECT ###

        [PSCustomObject]$Local:MainObject = @{
            # Function
            FunctionDetails     = [System.String[]]@($MyInvocation.MyCommand,$PSCmdlet.ParameterSetName,$PSBoundParameters.GetEnumerator())
            # Input
            ApplicationID       = $ApplicationID
            ParentOutputFolder  = $ParentOutputFolder
            # Output
            OutputFilePrefix    = [System.String]'MetaData_{0}.json'
        }

        ####################################################################################################
        ### MAIN FUNCTION METHODS ###

        # Add the Begin method
        $Local:MainObject | Add-Member -MemberType ScriptMethod -Name Begin -Value { Write-Message -Begin $this.FunctionDetails }

        # Add the End method
        $Local:MainObject | Add-Member -MemberType ScriptMethod -Name End -Value { Write-Message -End $this.FunctionDetails }

        # Add the Process method
        $Local:MainObject | Add-Member -MemberType ScriptMethod -Name Process -Value {
            # Add the ApplicationProperties to the MainObject
            $this.AddApplicationPropertiesToMainObject()
            # Add the Additional Properties to the ApplicationProperties
            $this.AddAdditionalPropertiesToApplicationProperties()
            # Output the ApplicationProperties to a json file
            $this.CreateMetaDataFile()
        }

        ####################################################################################################
        ### MAIN PROCESSING METHODS ###
    
        # Add the AddApplicationPropertiesToMainObject method
        $Local:MainObject | Add-Member -MemberType ScriptMethod -Name AddApplicationPropertiesToMainObject -Value {
            # Get the application properties
            [System.Collections.Hashtable]$ApplicationProperties = Get-AssetIDParameters
            $this | Add-Member -NotePropertyName ApplicationProperties -NotePropertyValue $ApplicationProperties
        }
    
        # Add the AddAdditionalPropertiesToApplicationProperties method
        $Local:MainObject | Add-Member -MemberType ScriptMethod -Name AddAdditionalPropertiesToApplicationProperties -Value {
            # Add the ApplicationID
            $this.ApplicationProperties.Add('ApplicationID',$this.ApplicationID)
            # Add the MetadataFileName
            $this.ApplicationProperties.Add('MetadataFileName',($this.OutputFilePrefix -f $this.ApplicationID))
            # Add the TimeStamp
            $this.ApplicationProperties.Add('TimeStampCreation',(Get-TimeStamp -ForMetadata))
            # Add the SCCM Detection properties
            $this.AddDetectionFileToApplicationProperties()
        }
    
        # Add the AddDetectionFileToApplicationProperties method
        $Local:MainObject | Add-Member -MemberType ScriptMethod -Name AddDetectionFileToApplicationProperties -Value {
            # Add the DetectionFile
            [System.String]$DetectionFilePath = $Global:AIDetectionFileTextBox.Text
            if (-Not(Confirm-Object -MandatoryPath $DetectionFilePath)) { Write-Warning 'No Detection file was entered. No SCCM Detection information added to the Metadata file.' ; Return }
            $this.ApplicationProperties.Add('DetectionFilePath',$DetectionFilePath)
            # Switch the file extension
            [System.IO.FileSystemInfo]$DetectionFileObject = Get-Item -Path $DetectionFilePath
            switch ($DetectionFileObject.Extension) {
                '.exe' {
                    [System.String]$DetectionFileVersionWithCommas = $DetectionFileObject.VersionInfo.FileVersion # add new code for parsing the version (major,minor,build,private)
                    $this.ApplicationProperties.Add('DetectionFileVersionWithCommas',$DetectionFileVersionWithCommas)
                    [System.String]$DetectionFileVersionWithPeriods = $DetectionFileVersionWithCommas.Replace(',','.')
                    $this.ApplicationProperties.Add('DetectionFileVersionWithPeriods',$DetectionFileVersionWithPeriods)
                    $this.ApplicationProperties.Add('SCCMDetectionMethod','File')
                }
                '.msi' {
                    [System.String]$MSIProductCode = Get-MSIProductCode -Path $DetectionFilePath
                    $this.ApplicationProperties.Add('DetectionMSIProductCode',$MSIProductCode)
                    $this.ApplicationProperties.Add('SCCMDetectionMethod','MSI')
                    # Change the DetectionFilePath to only the filename
                    $this.ApplicationProperties.DetectionFilePath = (Split-Path $DetectionFilePath -Leaf)

                }
                default {
                    Write-Warning 'Only EXE,MSI or REG are accepted. No SCCM Detection information will be added to the Metadata file.'
                }
            }
        }

        ####################################################################################################
        ### OUTPUT METHODS ###
    
        # Add the CreateMetaDataFile method
        $Local:MainObject | Add-Member -MemberType ScriptMethod -Name CreateMetaDataFile -Value {
            # Set the OutputFilePath
            [System.String]$ApplicationFolder   = Join-Path -Path $this.ParentOutputFolder -ChildPath $this.ApplicationID
            [System.String]$MetadataFolder      = Join-Path -Path $ApplicationFolder -ChildPath (Get-ApplicationSubfolders).MetadataFolder
            [System.String]$OutputFilePath      = Join-Path -Path $MetadataFolder -ChildPath $this.ApplicationProperties.MetadataFileName
            # Output the ApplicationProperties to a json file
            Write-Host ('Creating the metadata file... ({0})' -f $OutputFilePath) -ForegroundColor DarkGray
            $this.ApplicationProperties | ConvertTo-JSON | Out-File -FilePath $OutputFilePath
        }

        ####################################################################################################

        $Local:MainObject.Begin()   
    }
    
    process {
        $Local:MainObject.Process()
    }
    
    end {
        $Local:MainObject.End()
    }
}

### END OF SCRIPT
####################################################################################################
