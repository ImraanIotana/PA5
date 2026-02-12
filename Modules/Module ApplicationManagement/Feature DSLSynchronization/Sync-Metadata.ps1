####################################################################################################
<#
.SYNOPSIS
    This function updates the Metadata file on the DSL with information from the Local Metadata file.
.DESCRIPTION
    This function is part of the Packaging Assistant. It contains functions and variables that are in other files.
.EXAMPLE
    Sync-Metadata -ApplicationID Adobe_Reader_12.4
.INPUTS
    [System.String]
.OUTPUTS
    This function returns no stream-output.
.NOTES
    Version         : 5.5
    Author          : Imraan Iotana
    Creation Date   : August 2025
    Last Update     : August 2025
#>
####################################################################################################

function Sync-Metadata {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory=$true,ValueFromPipeline=$true,HelpMessage='The ID of the application that will be handled.')]
        [Alias('Application','ApplicationName','Name')]
        [AllowEmptyString()]
        [System.String]
        $ApplicationID
    )

    begin {
        ####################################################################################################
        ### MAIN OBJECT ###

        # Create the main object
        [PSCustomObject]$Local:MainObject = @{
            # Function
            FunctionDetails     = [System.String[]]@($MyInvocation.MyCommand,$PSCmdlet.ParameterSetName,$PSBoundParameters.GetEnumerator())
            # Input
            ApplicationID       = $ApplicationID
            # Validation
            ValidationArray     = [System.Boolean[]]@()
            # Handlers
            LocalFolder         = [System.String](Get-SharedAssetPath -OutputFolder)
            MetadataSubFolder   = [System.String](Get-ApplicationSubfolders).MetadataFolder
            ObsoleteProperties  = [System.String[]]@('ApplicationFolder','MetadataFolder','OutputFilePath')
            # Confirmation Handlers
            ConfirmationTitle   = [System.String]'Confirm Synchronization'
            ConfirmationBody    = [System.String]"This will SYNCHRONISE the METADATA file from your LOCAL folder to the DSL folder for the application:`n`n{0}`n`nAre you sure?"
            ConfirmationTitle2  = [System.String]'Confirm Overwrite'
            ConfirmationBody2   = [System.String]"Do you want to OVERWRITE the value of the property ({0}) in de DSL file?`n`nOld value:`n{1}`n`nNew value:`n{2}"
        }

        ####################################################################################################
        ### MAIN FUNCTION METHODS ###
        
        # Add the Begin method
        $Local:MainObject | Add-Member -MemberType ScriptMethod -Name Begin -Value {
            # Write the Begin message
            Write-Message -Begin $this.FunctionDetails
            # Add the MetadataFile properties to the main object
            $this | Add-Member -NotePropertyName LOCALMetadataFolder -NotePropertyValue ([System.IO.Path]::Combine($this.LocalFolder,$this.ApplicationID,$this.MetadataSubFolder))
            $this | Add-Member -NotePropertyName LOCALMetadataFilePath -NotePropertyValue $this.GetLOCALMetadataFilePath()
            $this | Add-Member -NotePropertyName DSLMetadataFilePath -NotePropertyValue (Get-SharedAssetPath -MetadataFilePath -ApplicationID $this.ApplicationID)
            # Validate the input
            $this.ValidateInput()
        }

        # Add the End method
        $Local:MainObject | Add-Member -MemberType ScriptMethod -Name End -Value { Write-Message -End $this.FunctionDetails }

        # Add the Process method
        $Local:MainObject | Add-Member -MemberType ScriptMethod -Name Process -Value {
            # Get user confirmation
            [System.Boolean]$UserHasConfirmed = Get-UserConfirmation -Title ($this.ConfirmationTitle) -Body ($this.ConfirmationBody -f $ApplicationID)
            if (-Not($UserHasConfirmed)) { Return }
            try {
                # If the validation failed, then return
                if ($this.ValidationArray -contains $false) { Write-Message -ValidationFailed ; Return }
                # Get the content
                [PSCustomObject]$LOCALJSONData  = Get-Content -Path $this.LOCALMetadataFilePath | ConvertFrom-Json
                [PSCustomObject]$DSLJSONData    = Get-Content -Path $this.DSLMetadataFilePath | ConvertFrom-Json
                # For each property in the LOCAL JSON
                foreach ($LocalProperty in $LOCALJSONData.PSObject.Properties) {
                    [System.String]$LocalPropertyName   = $LocalProperty.Name
                    [System.String]$LocalPropertyValue  = $LocalProperty.Value
                    # If the property name in the LOCAL JSON also appears in the DSL JSON, then compare the values
                    if ($DSLJSONData.PSObject.Properties.Name -contains $LocalPropertyName) {
                        # Skip the creation time property
                        if ($LocalPropertyName -eq 'TimeStampCreation') { Write-Line "The property ($LocalPropertyName) will be skipped." ; continue }
                        # If the value of both properties are equal
                        [System.String]$DSLPropertyValue = $DSLJSONData.($LocalPropertyName)
                        if ($LocalPropertyValue -eq $DSLPropertyValue) {
                            Write-Green ('This property exists in both files: ({0}). Both values are equal: ({1})' -f $LocalPropertyName,$LocalPropertyValue)
                        } else {
                            Write-Red ('The values of ({0}) in both files are different - Local: ({1}) - DSL: ({2})' -f $LocalPropertyName,$LocalPropertyValue,$DSLPropertyValue)
                            # Get user confirmation
                            [System.String]$ConfirmationBody2 = $this.ConfirmationBody2 -f $LocalPropertyName,$DSLPropertyValue,$LocalPropertyValue
                            [System.Boolean]$UserHasConfirmed = Get-UserConfirmation -Title $this.ConfirmationTitle2 -Body $ConfirmationBody2
                            # If confirmed, overwrite the value of the DSL JSON
                            if ($UserHasConfirmed) {
                                Write-Host ('Changing the value of ({0}) from ({1}) to ({2}).' -f $LocalPropertyName,$DSLPropertyValue,$LocalPropertyValue)
                                $DSLJSONData.($LocalPropertyName) = $LocalPropertyValue
                            } else {
                                Write-Host 'The value will NOT be overwritten.'
                            }
                        }
                    } else {
                        Write-Yellow ('This property only exists in the LOCAL file. Adding it to the DSL file: ({0})' -f $LocalPropertyName)
                        $DSLJSONData | Add-Member -NotePropertyName $LocalPropertyName -NotePropertyValue $LocalPropertyValue
                    }
                }
                # Remove the obsolete properties
                $this.ObsoleteProperties | ForEach-Object { $DSLJSONData.PSObject.Properties.Remove($_) }
                # Write the data to the DSL Metadata file
                New-ApplicationBackup -ApplicationID $this.ApplicationID -Type MetadataFolder | Out-Null
                $DSLJSONData | ConvertTo-JSON | Set-Content -Path $this.DSLMetadataFilePath -Encoding UTF8
                Write-Green ('The DSL file has been updated: ({0})' -f $this.DSLMetadataFilePath)
            }
            catch {
                Write-FullError
            }
        }

        ####################################################################################################
        ### VALIDATION METHODS ###

        # Add the ValidateInput method
        $Local:MainObject | Add-Member -MemberType ScriptMethod -Name ValidateInput -Value {
            # Validate the input
            $this.ValidationArray += Confirm-Object -MandatoryPath $this.LOCALMetadataFilePath
            $this.ValidationArray += Confirm-Object -MandatoryPath $this.DSLMetadataFilePath
        }

        ####################################################################################################
        ### MAIN PROCESSING METHODS ###

        ####################################################################################################
        ### SUPPORTING METHODS ###

        # Add the GetLOCALMetadataFilePath method
        $Local:MainObject | Add-Member -MemberType ScriptMethod -Name GetLOCALMetadataFilePath -Value {
            [System.IO.FileInfo]$LOCALMetadataFileObject = Get-ChildItem -Path $this.LOCALMetadataFolder -File -Filter *.json | Where-Object { $_.Basename -eq ('MetaData_{0}' -f $this.ApplicationID) }
            [System.String]$LOCALMetadataFilePath = $LOCALMetadataFileObject.FullName
            # Return the result
            if (Test-Object -IsEmpty $LOCALMetadataFilePath) { Write-Warning "The LOCAL Metadata file could not be found in the folder ($LOCALMetadataFolder)." ; $null } else { $LOCALMetadataFilePath }
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
