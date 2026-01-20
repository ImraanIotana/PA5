####################################################################################################
<#
.SYNOPSIS
    This function imports the Module MECM Application.
.DESCRIPTION
    This function is part of the Packaging Assistant. It contains references to classes, functions or variables, that are in other files.
.EXAMPLE
    New-MECMDetectionClause -DetectionFilePath 'C:\Demo\MyFile.exe' -DetectionFileVersion '1.2.3'
.INPUTS
    [System.String]
.OUTPUTS
    [Microsoft.ConfigurationManagement.PowerShell.Framework.DetectionClause]
.NOTES
    Version         : 5.5
    Author          : Imraan Iotana
    Creation Date   : July 2025
    Last Update     : July 2025
#>
####################################################################################################

function New-MECMDetectionClause {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory=$true,ParameterSetName='DetectExeFile',HelpMessage='The file for which a clause will be created.')]
        [Alias('DetectionFile','Path')]
        [AllowEmptyString()]
        [System.String]
        $DetectionFilePath,

        [Parameter(Mandatory=$true,ParameterSetName='DetectExeFile',HelpMessage='The version of the EXE file.')]
        [Alias('DetectionVersion','Version')]
        [AllowEmptyString()]
        [System.String]
        $DetectionFileVersion,

        [Parameter(Mandatory=$true,ParameterSetName='DetectMSIFile',HelpMessage='The ProductCode of the MSI file.')]
        [Alias('MSIProductCode','GUID')]
        [AllowEmptyString()]
        [System.String]
        $ProductCode
    )

    begin {
        ####################################################################################################
        ### MAIN OBJECT ###

        # Create the main object
        [PSCustomObject]$Local:MainObject = @{
            # Function
            FunctionDetails         = [System.String[]]@($MyInvocation.MyCommand,$PSCmdlet.ParameterSetName,$PSBoundParameters.GetEnumerator())
            # Input
            DetectionFilePath       = $DetectionFilePath
            DetectionFileVersion    = $DetectionFileVersion
            ProductCode             = $ProductCode
            # Validation
            ValidationArray         = [System.Boolean[]]@()
        }

        ####################################################################################################
        ### MAIN FUNCTION METHODS ###

        # Add the Begin method
        $Local:MainObject | Add-Member -MemberType ScriptMethod -Name Begin -Value {
            # Write the Begin message
            Write-Message -Begin $this.FunctionDetails
            # Validate the input based on the ParameterSetName
            switch ($this.FunctionDetails[1]) {
                'DetectExeFile' {
                    $this.ValidationArray += Confirm-Object -MandatoryString $this.DetectionFilePath
                    $this.ValidationArray += Confirm-Object -MandatoryString $this.DetectionFileVersion
                }
                'DetectMSIFile' {
                    $this.ValidationArray += Confirm-Object -MandatoryString $this.ProductCode
                }
            }
        }

        # Add the End method
        $Local:MainObject | Add-Member -MemberType ScriptMethod -Name End -Value { Write-Message -End $this.FunctionDetails }

        # Add the Process method
        $Local:MainObject | Add-Member -MemberType ScriptMethod -Name Process -Value {
            # If the validation failed, then return
            if ($this.ValidationArray -contains $false) { Write-Message -ValidationFailed ; Return }
            # Get the clause based on the ParameterSetName
            [Microsoft.ConfigurationManagement.PowerShell.Framework.DetectionClause]$DetectionClause = switch ($this.FunctionDetails[1]) {
                'DetectExeFile' { $this.GetEXEFileDetectionClause($this.DetectionFilePath,$this.DetectionFileVersion) }
                'DetectMSIFile' { $this.GetMSIDetectionClause($this.ProductCode) }
            }
            # Add the clause to the main object
            $this | Add-Member -NotePropertyName OutputObject -NotePropertyValue $DetectionClause
        }

        ####################################################################################################
        ### MAIN PROCESSING METHODS ###

        # Add the GetEXEFileDetectionClause method
        $Local:MainObject | Add-Member -MemberType ScriptMethod -Name GetEXEFileDetectionClause -Value { param([System.String]$DetectionFilePath,[System.String]$DetectionFileVersion)
            try {
                # Write the message
                Write-Host ('Creating the EXE-file Detection Clause. One moment please... ({0})' -f $DetectionFilePath) -ForegroundColor DarkGray
                # If the string is empty, the use a dummy file
                #if (Test-Object -IsEmpty $DetectionFilePath) { $DetectionFilePath = 'C:\Program Files\ApplicationFolder\Application.exe' }
                # Set the properties
                [System.String]$ParentFolder    = Split-Path -Path $DetectionFilePath -Parent
                [System.String]$FileName        = Split-Path -Path $DetectionFilePath -Leaf
                # Set the parameters
                [System.Collections.Hashtable]$Parameters = @{
                    FileName            = $FileName
                    Path                = $ParentFolder
                    Value               = $true
                    PropertyType        = 'Version'
                    ExpressionOperator  = 'GreaterEquals'
                    ExpectedValue       = $DetectionFileVersion
                }
                # Create the FileDetection Clause
                [Microsoft.ConfigurationManagement.PowerShell.Framework.DetectionClause]$FileDetectionClause = New-CMDetectionClauseFile @Parameters
                # Write the message
                Write-Host ('The FileDetection Clause has been created. ({0})' -f $DetectionFilePath) -ForegroundColor DarkGray
                # Return the result
                #$FileDetectionClause | Select-Object * | Out-Host | Format-List
                $FileDetectionClause
            }
            catch {
                # Write the error
                Write-FullError
            }
        }

        # Add the GetMSIDetectionClause method
        $Local:MainObject | Add-Member -MemberType ScriptMethod -Name GetMSIDetectionClause -Value { param([System.String]$MSIProductCode)
            try {
                # Write the message
                Write-Host ('Creating the MSI file Detection Clause. One moment please... ({0})' -f $DetectionFilePath) -ForegroundColor DarkGray
                # Create the FileDetection Clause
                [Microsoft.ConfigurationManagement.PowerShell.Framework.DetectionClause]$FileDetectionClause = New-CMDetectionClauseWindowsInstaller -ProductCode $MSIProductCode -Existence
                # Write the message
                Write-Host ('The FileDetection Clause has been created. ({0})' -f $DetectionFilePath) -ForegroundColor DarkGray
                # Return the result
                $FileDetectionClause | Select-Object * | Out-Host | Format-List
                $FileDetectionClause
            }
            catch {
                # Write the error
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
