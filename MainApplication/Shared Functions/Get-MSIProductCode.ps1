####################################################################################################
<#
.SYNOPSIS
    This function obtains the GUID of an MSI file.
.DESCRIPTION
    This function is part of the Packaging Assistant. It contains functions and variables that are in other files.
.EXAMPLE
    Get-MSIProductCode -Path C:\Temp\MyApplication.msi
.INPUTS
    [System.String]
.OUTPUTS
    [System.String]
.NOTES
    Version         : 5.4.7
    Author          : Imraan Iotana
    Creation Date   : August 2023
    Last Update     : July 2025
#>
####################################################################################################

function Get-MSIProductCode {
    [CmdletBinding()]
    param (
        # Path of the MSI file, of which the GUID will be obtained
        [Parameter(Mandatory=$true)]
        [System.String]
        $Path
    )
    
    begin {
        # Create the main object
        [PSCustomObject]$Local:MainObject = @{
            # Function
            #FunctionName            = [System.String]$MyInvocation.MyCommand
            #FunctionArguments       = [System.String]$PSBoundParameters.GetEnumerator()
            #ParameterSetName        = [System.String]$PSCmdlet.ParameterSetName
            #FunctionCircumFix       = [System.String]'Function: [{0}] ParameterSetName: [{1}] Arguments: {2}'
            FunctionDetails     = [System.String[]]@($MyInvocation.MyCommand,$PSCmdlet.ParameterSetName,$PSBoundParameters.GetEnumerator())
            # Validation
            ValidationArray     = [System.Boolean[]]@()
            # Handlers
            PowerShellVersion   = $PSVersionTable.PSVersion.Major
            # Input
            MSIFilePath         = $Path
            # Output
            MSIGUID             = [System.String]::Empty
        }

        ####################################################################################################
        ### MAIN FUNCTION METHODS ###
        
        # Add the Begin method
        Add-Member -InputObject $Local:MainObject -MemberType ScriptMethod -Name Begin -Value {
            # Write the Begin message
            Write-Message -FunctionBegin -Details $this.FunctionDetails
            # Validate the input
            $this.ValidationArray += Confirm-Object -MandatoryPath $this.MSIFilePath
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
            # Get the GUID
            [System.String]$MSIGUID = $this.GetMSIGUIDProcess($this.MSIFilePath)
            $this.MSIGUID = if ($this.TestGUIDIsValid($MSIGUID)) { $MSIGUID }
        }

        ####################################################################################################
        ### MAIN PROCESSING METHODS ###
    
        # Add the TestMSIIsSigned method
        Add-Member -InputObject $Local:MainObject -MemberType ScriptMethod -Name TestMSIIsSigned -Value { param([System.String]$Path)
            try {
                # Test if the MSI is signed
                Write-Host ('Testing if the MSI has a valid Digital Signature... ({0})' -f $Path) -ForegroundColor DarkGray
                [System.String]$SignatureStatus = (Get-AuthenticodeSignature $Path).Status
                [System.Boolean]$MSIIsSigned    = ($SignatureStatus -eq 'Valid')
                # Write the result
                [System.String]$ResultInFix = if (-Not($MSIIsSigned)) { ' NOT' }
                Write-Host ('The MSI is{0} signed. ({1})' -f $ResultInFix,$Path) -ForegroundColor DarkGray
                # Return the result
                $MSIIsSigned
            }
            catch {
                Write-FullError
                $null
            }
        }

        # Add the TestGUIDIsValid method
        Add-Member -InputObject $Local:MainObject -MemberType ScriptMethod -Name TestGUIDIsValid -Value { param([System.String]$GUIDAsString)
            try {
                # Parse the string
                Write-Verbose ('TestGUIDIsValid: Validating the GUID: {0}' -f $GUIDAsString)
                [System.Guid]::Parse($GUIDAsString) | Out-Null
                # Return true
                Write-Verbose ('TestGUIDIsValid: The GUID {0} meets the GUID requirements of 32 digits with 4 dashes.' -f $GUIDAsString)
                $true
            }
            catch [System.Management.Automation.MethodInvocationException] {
                Write-FullError ('The GUID does not meet the GUID requirements of 32 digits with 4 dashes {xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx}: {0}' -f $GUIDAsString)
                $false
            }
            catch {
                Write-FullError
                $false
            }
        }

        ####################################################################################################
    
        # Add the GetMSIGUIDProcess method
        Add-Member -InputObject $Local:MainObject -MemberType ScriptMethod -Name GetMSIGUIDProcess -Value { param([System.String]$Path)
            # Get the GUID
            [System.String]$MSIGUID = switch ($this.TestMSIIsSigned($Path)) {
                $false  { $this.GetMSIProperty($Path,'ProductCode') }
                $true   {
                    switch ($this.PowerShellVersion) {
                        5 { $this.PS5GetGUIDFromSignedMSI($Path) }
                        7 { $this.PS7GetGUIDFromSignedMSI($Path) }
                    }
                }
            }
            # Return the result
            $MSIGUID
        }

        ####################################################################################################

        # Add the PS5GetGUIDFromSignedMSI method
        Add-Member -InputObject $Local:MainObject -MemberType ScriptMethod -Name PS5GetGUIDFromSignedMSI -Value { param([System.String]$Path)
            try {
                # Get the GUID
                Write-Host ('Obtaining the GUID with Get-AppLockerFileInformation... ({0})' -f $Path) -ForegroundColor DarkGray
                [System.String]$MSIGUID = ((Get-AppLockerFileInformation -Path $Path).Publisher).BinaryName
                # Return the GUID
                Write-Host ('The GUID of the MSI is: {0}' -f $MSIGUID) -ForegroundColor DarkGray
                $MSIGUID
            }
            catch {
                # Return null
                Write-Host ('The GUID of the MSI could not be obtained. ({0})' -f $Path) -ForegroundColor Red
                $null
            }
        }

        # Add the PS7GetGUIDFromSignedMSI method
        Add-Member -InputObject $Local:MainObject -MemberType ScriptMethod -Name PS7GetGUIDFromSignedMSI -Value { param([System.String]$Path)
            try {
                # Write the message
                Write-Host ('Obtaining the GUID with Get-AppLockerFileInformation... ({0})' -f $Path)
                # Get the Publisher
                [System.String]$Publisher = (Get-AppLockerFileInformation -Path $Path).Publisher
                Write-Verbose ('PS7GetGUIDFromSignedMSI: The Publisher is: {0}' -f $Publisher)
                # Get the index of the first character
                [System.Int32]$FirstCharacterIndex = $Publisher.IndexOf('{')
                # Get the index of the last character
                [System.Int32]$LastCharacterIndex = $Publisher.IndexOf('}')
                # Set the length
                [System.Int32]$Length = $LastCharacterIndex - $FirstCharacterIndex + 1
                # Get the substring
                [System.String]$MSIGUID = $Publisher.Substring($FirstCharacterIndex, $Length)
                # Write the message
                Write-Host ('The GUID of the MSI is: {0}' -f $MSIGUID)
                # Return the GUID
                $MSIGUID
            }
            catch {
                # Write the error
                Write-Host ('The GUID of the MSI could not be obtained. ({0})' -f $Path) -ForegroundColor Red
                # Return null
                $null
            }
        }

        ####################################################################################################

        # Add the GetMSIProperty method
        Add-Member -InputObject $Local:MainObject -MemberType ScriptMethod -Name GetMSIProperty -Value { param([System.String]$MSIPath,[System.String]$PropertyToGet)
            try {
                # Write the message
                Write-Host ('Getting the property ({0}) of the MSI ({1})...' -f $PropertyToGet,$MSIPath) -ForegroundColor DarkGray

                # Set the needed functions
                function Get-Property ( $Object, $PropertyName, [object[]]$ArgumentList ) { $Object.GetType().InvokeMember($PropertyName, 'Public, Instance, GetProperty', $null, $Object, $ArgumentList) }
                function Invoke-Method ( $Object, $MethodName, $ArgumentList ) { $Object.GetType().InvokeMember( $MethodName, 'Public, Instance, InvokeMethod', $null, $Object, $ArgumentList ) }
                # Set the value for read-only mode
                Write-Verbose 'GetMSIProperty: Setting the OpenDatabase method to ReadOnly...'
                [System.Int32]$OpenMSIReadOnlyMode = 0
                # Create a new installer object
                Write-Verbose 'GetMSIProperty: Creating a WindowsInstaller object...'
                [System.__ComObject]$InstallerObject = New-Object -ComObject WindowsInstaller.Installer
                # Create a new database object
                Write-Verbose 'GetMSIProperty: Creating a database object...'
                [System.__ComObject]$DatabaseObject = Invoke-Method -Object $InstallerObject -MethodName OpenDatabase -ArgumentList ($MSIPath,$OpenMSIReadOnlyMode)
                # Create a view
                Write-Verbose 'GetMSIProperty: Creating a view...'
                [System.__ComObject]$View = Invoke-Method -Object $DatabaseObject -MethodName OpenView -ArgumentList "SELECT Value FROM Property WHERE Property='$($PropertyToGet)'"
                # Execute the view
                Write-Verbose 'GetMSIProperty: Executing the view...'
                [Void]( Invoke-Method -Object $View -MethodName Execute )
                # Get the record that contains the guid
                Write-Verbose 'GetMSIProperty: Getting the record containing the GUID...'
                [System.__ComObject]$Record = Invoke-Method -Object $View -MethodName Fetch
                # Get the stringdata from the record
                Write-Verbose 'GetMSIProperty: Getting the property value from the stringdata of the record...'
                [System.String]$PropertyValue = Get-Property -Object $Record -PropertyName StringData -ArgumentList 1
                # Close the view
                Write-Verbose 'GetMSIProperty: Closing the view...'
                [Void](Invoke-Method -Object $View -MethodName Close -ArgumentList @())

                # Write the message
                Write-Host ('The value of the property ({0}) is: {1}' -f $PropertyToGet,$PropertyValue) -ForegroundColor DarkGray
                # Return the PropertyValue
                $PropertyValue
            }
            catch {
                # Write the error
                Write-Host ('The property ({0}) could not be obtained from the MSI ({1}).' -f $PropertyToGet,$MSIPath) -ForegroundColor Red
                $this.WriteError()
                # Return null
                $null
            }
        }

        ####################################################################################################

        #region BEGIN
        $Local:MainObject.Begin()
        #endregion BEGIN
    }
    
    process {
        #region PROCESS
        $Local:MainObject.Process()
        #endregion PROCESS
    }

    end {
        #region END
        $Local:MainObject.End()
        # Return the GUID
        $Local:MainObject.MSIGUID
        #endregion END
    }
}

