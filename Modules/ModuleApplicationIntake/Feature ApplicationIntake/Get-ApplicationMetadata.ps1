####################################################################################################
<#
.SYNOPSIS
    This function gets application information from the Metadata file.
.DESCRIPTION
    This function is part of the Packaging Assistant. It contains functions and variables that are in other files.
.EXAMPLE
    Get-ApplicationMetadata -ApplicationID NotepadTeam_Notepad++_8.7.7 -PropertyName VendorNameFull
.INPUTS
    [System.String]
.OUTPUTS
    [System.String]
.NOTES
    Version         : 5.4.8
    Author          : Imraan Iotana
    Creation Date   : July 2025
    Last Update     : July 2025
#>
####################################################################################################

function Get-ApplicationMetadata {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory=$true,HelpMessage='The path of the Metadata JSON file.')]
        [Alias('Application','ApplicationName')]
        [AllowEmptyString()]
        [System.String]
        $ApplicationID,

        [Parameter(Mandatory=$true,HelpMessage='The property to get from the JSON file.')]
        [Alias('Property')]
        [AllowEmptyString()]
        [System.String]
        $PropertyName
    )
    
    begin {
        ####################################################################################################
        ### MAIN OBJECT ###

        [PSCustomObject]$Local:MainObject = @{
            # Function
            FunctionDetails = [System.String[]]@($MyInvocation.MyCommand,$PSCmdlet.ParameterSetName,$PSBoundParameters.GetEnumerator())
            # Input
            ApplicationID   = $ApplicationID
            PropertyName    = $PropertyName
            # Validation
            ValidationArray = [System.Boolean[]]@()
            # Output
            OutputObject    = [System.String]::Empty
        }

        ####################################################################################################
        ### MAIN FUNCTION METHODS ###
        
        # Add the Begin method
        Add-Member -InputObject $Local:MainObject -MemberType ScriptMethod -Name Begin -Value {
            # Write the Begin message
            Write-Message -FunctionBegin -Details $this.FunctionDetails
            # Validate the input
            $this.ValidationArray += Confirm-Object -MandatoryString $this.ApplicationID
            $this.ValidationArray += Confirm-Object -MandatoryString $this.PropertyName
        }

        # Add the End method
        Add-Member -InputObject $Local:MainObject -MemberType ScriptMethod -Name End -Value {
            # Write the End message
            Write-Message -FunctionEnd -Details $this.FunctionDetails
        }

        # Add the Process method
        Add-Member -InputObject $Local:MainObject -MemberType ScriptMethod -Name Process -Value {
            # If the validation failed, then return
            if ($this.ValidationArray -contains $false) { Write-Message -ValidationFailed ; Return }
            # Add the MetadataFilePath to the main object
            $this | Add-Member -NotePropertyName MetadataFilePath -NotePropertyValue (Get-SharedAssetPath -MetadataFilePath -ApplicationID $this.ApplicationID)
            # If the metadata file is not found, then return
            if (-Not(Test-Path -Path $this.MetadataFilePath)) { Write-Warning ('The Metadata file was not found at the expected location: ({0})' -f $this.MetadataFilePath) ; Return }
            # Get the property
            $this.OutputObject = $this.GetApplicationProperty($this.PropertyName)
        }

        ####################################################################################################
        ### MAIN PROCESSING METHODS ###

        # Add the GetApplicationProperty method
        Add-Member -InputObject $Local:MainObject -MemberType ScriptMethod -Name GetApplicationProperty -Value { param([System.String]$PropertyName)
            try {
                # Read the file
                Write-Verbose ('Getting the property: ({0})' -f $PropertyName)
                [PSCustomObject]$MetadataFileContent = Get-Content -Path $this.MetadataFilepath -Raw | ConvertFrom-Json
                # Get the property value
                [System.String]$PropertyValue = $MetadataFileContent.$PropertyName
                [System.String]$TextColor = if (Test-Object -IsEmpty $MetadataFileContent.$PropertyName) { 'Red' } else { 'DarkGray' }
                Write-Host ('The value of property ({0}) is ({1})' -f $PropertyName,$PropertyValue) -ForegroundColor $TextColor
                # Return the result
                $PropertyValue
            }
            catch {
                Write-FullError
            }
        }
        
        ####################################################################################################

        $Local:MainObject.Begin()
    }
    
    process {
        $Local:MainObject.Process()
    }
    
    end {
        $Local:MainObject.End()
        # Return the output
        $Local:MainObject.OutputObject
    }
}

### END OF SCRIPT
####################################################################################################
