####################################################################################################
<#
.SYNOPSIS
    This function fills a word document with application properties.
.DESCRIPTION
    This function is part of the Packaging Assistant. It contains references to classes, functions or variables, that are in other files.
    External classes    : -
    External functions  : Write-Message
    External variables  : -
.EXAMPLE
    Format-WordDocument -VendorNameFull 'Adobe Inc.' -VendorNameShort 'Adobe' etc...
.INPUTS
    [System.String]
.OUTPUTS
    [System.String]
.NOTES
    Version         : 5.3.1
    Author          : Imraan Iotana
    Creation Date   : March 2025
    Last Update     : May 2025
#>
####################################################################################################

function Format-WordDocument {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory=$true,HelpMessage='The path of the Word document.')]
        [System.String]
        $IntakeDocumentSourcePath,

        [Parameter(Mandatory=$false,HelpMessage='The folder where the output will be placed.')]
        [Alias('OutputFolder')]
        [System.String]
        $ParentOutputFolder = (Get-SharedAssetPath -OutputFolder),

        [Parameter(Mandatory=$false,HelpMessage='Switch for asking the user for confirmation.')]
        [Alias('AskConfirmation')]
        [System.Management.Automation.SwitchParameter]
        $Confirm
        )

    begin {
        ####################################################################################################
        ### MAIN OBJECT ###

        # Set the main object
        [PSCustomObject]$Local:MainObject = @{
            # Function
            FunctionDetails                 = [System.String[]]@($MyInvocation.MyCommand,$PSCmdlet.ParameterSetName,$PSBoundParameters.GetEnumerator())
            # Input
            IntakeDocumentSourcePath        = $IntakeDocumentSourcePath
            ParentOutputFolder              = $ParentOutputFolder
            Confirm                         = $Confirm
            # Handlers
            IntakeDocumentFileNamePrefix    = [System.String]'KS Client Application Form - {0}.docx'
            TimeStamp                       = [System.String](Get-Date -UFormat '%Y-%m-%d')
            # Confirmation Handlers
            ConfirmationTitle               = [System.String]'Create Word document'
            ConfirmationBody                = [System.String]'Would you like to create the Word documents?'
        }

        ####################################################################################################
        ### MAIN FUNCTION METHODS ###
        
        # Add the Begin method
        Add-Member -InputObject $Local:MainObject -MemberType ScriptMethod -Name Begin -Value {
            # Write the Begin message
            Write-Message -FunctionBegin -Details $this.FunctionDetails
            # Get the application properties, and add them to the main object
            [PSCustomObject]$ApplicationProperties = Get-AssetIDParameters
            Add-Member -InputObject $this -NotePropertyName ApplicationProperties -NotePropertyValue $ApplicationProperties
            # Add the additional properties to the ApplicationProperties
            Add-Member -InputObject $this.ApplicationProperties -NotePropertyName AssetID -NotePropertyValue (Get-ApplicationName)
            Add-Member -InputObject $this.ApplicationProperties -NotePropertyName UserFullName -NotePropertyValue (Get-SharedAssetPath -UserFullName)
            Add-Member -InputObject $this.ApplicationProperties -NotePropertyName UserEmail -NotePropertyValue (Get-SharedAssetPath -UserEmail)
            Add-Member -InputObject $this.ApplicationProperties -NotePropertyName ParentOutputFolder -NotePropertyValue $this.ParentOutputFolder
            Add-Member -InputObject $this.ApplicationProperties -NotePropertyName IntakeDocumentSourcePath -NotePropertyValue $this.IntakeDocumentSourcePath
            Add-Member -InputObject $this.ApplicationProperties -NotePropertyName IntakeDocumentFileNamePrefix -NotePropertyValue $this.IntakeDocumentFileNamePrefix
        }

        # Add the End method
        Add-Member -InputObject $Local:MainObject -MemberType ScriptMethod -Name End -Value {
            # Write the End message
            Write-Message -FunctionEnd -Details $this.FunctionDetails
        }

        # Add the Process method
        Add-Member -InputObject $Local:MainObject -MemberType ScriptMethod -Name Process -Value {
            # Get user confirmation
            if ($this.Confirm.IsPresent) {
                [System.Boolean]$UserHasConfirmed = Get-UserConfirmation -Title $this.ConfirmationTitle -Body $this.ConfirmationBody
                if (-Not($UserHasConfirmed)) { Return }
            }
            # Validate the input
            #if (-Not ($this.ValidateInput($this.ApplicationProperties))) { Return }
            # Create the new application folder
            $this.DetermineOutputFolder($this.ApplicationProperties)
            #$this.CreateNewApplicationFolder($this.ApplicationProperties)
            # Copy the intake document
            $this.CopyIntakeDocument($this.ApplicationProperties)
            # Format the intake document
            $this.ReplaceTextInWordDocument($this.ApplicationProperties)
            # Open the folder
            #Open-Folder -Path $this.ApplicationProperties.NewApplicationFolder
        }

        ####################################################################################################
        ### VALIDATION METHODS ###

        # Add the ValidateInput method
        Add-Member -InputObject $Local:MainObject -MemberType ScriptMethod -Name ValidateInput -Value { param([PSCustomObject]$ApplicationProperties)
            # Check the array of input
            if ($ApplicationProperties.Values -contains '') { $false } else { $true }
        }

        ####################################################################################################
        ### MAIN PROCESSING METHODS ###
    
        # Add the DetermineOutputFolder method
        Add-Member -InputObject $Local:MainObject -MemberType ScriptMethod -Name DetermineOutputFolder -Value { param([PSCustomObject]$ApplicationProperties)
            # Set the new application folder
            [System.String]$NewApplicationFolder = Join-Path -Path $ApplicationProperties.ParentOutputFolder -ChildPath $ApplicationProperties.AssetID
            Add-Member -InputObject $ApplicationProperties -NotePropertyName NewApplicationFolder -NotePropertyValue $NewApplicationFolder
            # Add the DocumentationFolder to the ApplicationProperties
            [System.String]$DocumentationFolder = (Get-ChildItem -Path $NewApplicationFolder -Directory | Where-Object { $_.BaseName.Contains('Document') } | Select-Object -First 1).FullName
            Add-Member -InputObject $ApplicationProperties -NotePropertyName DocumentationFolder -NotePropertyValue $DocumentationFolder
        }
    
        # Add the CreateNewApplicationFolder method (Not used)
        Add-Member -InputObject $Local:MainObject -MemberType ScriptMethod -Name CreateNewApplicationFolder -Value { param([PSCustomObject]$ApplicationProperties)
            # Set the new application folder
            [System.String]$NewApplicationFolder = Join-Path -Path $ApplicationProperties.ParentOutputFolder -ChildPath $ApplicationProperties.AssetID
            # Add the NewApplicationFolder to the ApplicationProperties
            Add-Member -InputObject $ApplicationProperties -NotePropertyName NewApplicationFolder -NotePropertyValue $NewApplicationFolder
            # Write the message
            Write-Host ('Creating the Application folder... ({0})' -f $NewApplicationFolder) -ForegroundColor DarkGray
            # Create the folder
            New-Item -Path $NewApplicationFolder -ItemType Directory -Force | Out-Null
        }

        # Add the CopyIntakeDocument method
        Add-Member -InputObject $Local:MainObject -MemberType ScriptMethod -Name CopyIntakeDocument -Value { param([PSCustomObject]$ApplicationProperties)
            # Set the destinationfile full path
            [System.String]$IntakeDocumentFileName  = ($ApplicationProperties.IntakeDocumentFileNamePrefix -f $ApplicationProperties.AssetID)
            [System.String]$IntakeDocumentFilePath  = Join-Path -Path $ApplicationProperties.DocumentationFolder -ChildPath $IntakeDocumentFileName
            # Add the IntakeDocumentFilePath to the ApplicationProperties
            Add-Member -InputObject $ApplicationProperties -NotePropertyName IntakeDocumentFilePath -NotePropertyValue $IntakeDocumentFilePath
            # Copy the source file
            Copy-Item -Path $ApplicationProperties.IntakeDocumentSourcePath -Destination $IntakeDocumentFilePath
        }

        # Add the ReplaceTextInWordDocument method
        Add-Member -InputObject $Local:MainObject -MemberType ScriptMethod -Name ReplaceTextInWordDocument -Value { param([PSCustomObject]$ApplicationProperties)
            # Set the properties
            [System.String]$IntakeDocumentFilePath = $ApplicationProperties.IntakeDocumentFilePath
            [System.Collections.Hashtable]$WordReplacementHashTable = $this.GetWordReplacementHashTable($ApplicationProperties)
            # Set the Word replacement properties
            [System.Boolean]$MatchCase          = $true
            [System.Boolean]$MatchWholeWorld    = $true
            [System.Boolean]$MatchWildcards     = $false
            [System.Boolean]$MatchSoundsLike    = $false
            [System.Boolean]$MatchAllWordForms  = $false
            [System.Boolean]$Forward            = $false
            [System.Boolean]$Format             = $false
            [System.Int32]$Wrap                 = 1
            [System.Int32]$Replace              = 2
            # Write the message
            Write-Host ('Formatting Word Document: ({0})...' -f $IntakeDocumentFilePath) -ForegroundColor DarkGray
            try {
                # Open Word
                [Microsoft.Office.Interop.Word.ApplicationClass]$WordObject = New-Object -ComObject Word.Application
                # Set the visibility
                $WordObject.Visible = $false
                # Disable macros by setting the macro security level to high
                $WordObject.AutomationSecurity = 3  # 3 means "Disable all macros without notification"
                # Open the document
                [Microsoft.Office.Interop.Word.DocumentClass]$CurrentOpenDocument = $WordObject.Documents.Open($IntakeDocumentFilePath)
                # Loop through each content control in the current open document
                foreach ($ReplacementObject in $WordReplacementHashTable.GetEnumerator()) {
                    # Find and replace the text using the variables we just setup
                    Write-Verbose ('Replacing ({0}) with ({1})...' -f $ReplacementObject.Name, $ReplacementObject.Value)
                    $CurrentOpenDocument.Content.Find.Execute($ReplacementObject.Name, $MatchCase, $MatchWholeWorld, $MatchWildcards, $MatchSoundsLike, $MatchAllWordForms, $Forward, $Wrap, $Format, $ReplacementObject.Value, $Replace)
                }
                # Save the document with the new name
                Write-Host ('Saving the Word Document: ({0})' -f $IntakeDocumentFilePath) -ForegroundColor DarkGray
                $CurrentOpenDocument.SaveAs($IntakeDocumentFilePath)
                # Close the document
                Write-Host ('Closing the Word Document: ({0})' -f $IntakeDocumentFilePath) -ForegroundColor DarkGray
                $CurrentOpenDocument.Close()    
                # Close word
                Write-Host 'Closing Word...' -ForegroundColor DarkGray
                $WordObject.Quit()
                [System.Runtime.InteropServices.Marshal]::ReleaseComObject($WordObject) | Out-Null
            }
            catch [System.Management.Automation.RuntimeException]{
                # Write the error
                Write-Warning ('MS Word could not be opened. The Word document could not be formatted. ({0})' -f $IntakeDocumentFilePath)
            }
            catch [System.Runtime.InteropServices.COMException]{
                # Write the error
                Write-Warning ('MS Word is not installed. The Word document could not be formatted. ({0})' -f $IntakeDocumentFilePath)
            }
            catch {
                # Write the error
                Write-FullError
            }
        }

        ####################################################################################################

        # Add the GetWordReplacementHashTable method
        Add-Member -InputObject $Local:MainObject -MemberType ScriptMethod -Name GetWordReplacementHashTable -Value { param([PSCustomObject]$ApplicationProperties)
            # Set the WordReplacementHashTable
            [System.Collections.Hashtable]$WordReplacementHashTable = @{
                APPLICATIONID           = $ApplicationProperties.AssetID
                VENDORNAMEFULL          = $ApplicationProperties.VendorNameFull
                VENDORNAMESHORT         = $ApplicationProperties.VendorNameShort
                APPLICATIONNAMEFULL     = $ApplicationProperties.ApplicationNameFull
                APPLICATIONNAMESHORT    = $ApplicationProperties.ApplicationNameShort
                APPLICATIONVERSIONFULL  = $ApplicationProperties.ApplicationVersionFull
                APPLICATIONVERSIONSHORT = $ApplicationProperties.ApplicationVersionShort
                APPLICATIONLANGUAGE     = $ApplicationProperties.ApplicationLanguage
                APPLICATIONBITVERSION   = $ApplicationProperties.ApplicationBitVersion
                INSTALLLOCATION         = $ApplicationProperties.InstallLocation
                CREATIONDATE            = $this.TimeStamp
                USERFULLNAME            = $ApplicationProperties.UserFullName
                USEREMAIL               = $ApplicationProperties.UserEmail
                ADGROUPNAME             = $ApplicationProperties.ADGroupName
                ADGROUPSID              = $ApplicationProperties.ADGroupSID
            }
            # Return the result
            $WordReplacementHashTable
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
