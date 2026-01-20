####################################################################################################
<#
.SYNOPSIS
    This function manages the user settings, which are stored in the registry.
.DESCRIPTION
    This function is part of the Packaging Assistant. It contains references to classes, functions or variables, that are in other files.
    External classes    : -
    External functions  : -
    External variables  : $Global:ApplicationObject
.EXAMPLE
    Invoke-UserSettings -Initialize
.EXAMPLE
    Invoke-UserSettings -Write -PropertyName OutputFolder -PropertyValue 'C:\Demo\WorkFolder'
.EXAMPLE
    Invoke-UserSettings -Read -PropertyName OutputFolder
.EXAMPLE
    Invoke-UserSettings -Remove -PropertyName OutputFolder
.INPUTS
    [System.Management.Automation.SwitchParameter]
    [System.String]
.OUTPUTS
    [System.String]
.NOTES
    Version         : 5.0
    Author          : Imraan Iotana
    Creation Date   : October 2023
    Last Update     : October 2024
#>
####################################################################################################

function Invoke-UserSettings {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory=$true,ParameterSetName='Initialize',HelpMessage='Switch for creating the application registry key.')]
        [System.Management.Automation.SwitchParameter]
        $Initialize,

        # Switch for reading a property value
        [Parameter(Mandatory=$true,ParameterSetName='ReadProperty')]
        [System.Management.Automation.SwitchParameter]
        $Read,

        # Switch for writing a property value
        [Parameter(Mandatory=$true,ParameterSetName='WriteProperty')]
        [System.Management.Automation.SwitchParameter]
        $Write,

        # Switch for removing a property
        [Parameter(Mandatory=$true,ParameterSetName='RemoveProperty')]
        [System.Management.Automation.SwitchParameter]
        $Remove,

        # The name of the property
        [Parameter(Mandatory=$true,ParameterSetName='ReadProperty')]
        [Parameter(Mandatory=$true,ParameterSetName='WriteProperty')]
        [Parameter(Mandatory=$true,ParameterSetName='RemoveProperty')]
        [System.String]
        $PropertyName,

        # The value of the property
        [Parameter(Mandatory=$true,ParameterSetName='WriteProperty')]
        [AllowEmptyString()]
        [System.String]
        $PropertyValue,

        [Parameter(Mandatory=$false,HelpMessage='The name of the application, that will be used as the name of the RegistryKey.')]
        [System.String]
        $ApplicationName = $Global:ApplicationObject.Name
    )
    
    begin {
        ####################################################################################################
        ### MAIN OBJECT ###

        [PSCustomObject]$Local:MainObject = @{
            # Function
            FunctionName        = [System.String]$MyInvocation.MyCommand
            FunctionArguments   = [System.String]$PSBoundParameters.GetEnumerator()
            ParameterSetName    = [System.String]$PSCmdlet.ParameterSetName
            FunctionCircumFix   = [System.String]'Function: [{0}] ParameterSetName: [{1}] Arguments: {2}'
            # Input
            ParentRegistryKey   = [System.String]('HKCU:\Software\{0}' -f $ApplicationName)
            PropertyName        = $PropertyName
            PropertyValue       = $PropertyValue
        }

        ####################################################################################################
        ### MAIN FUNCTION METHODS ###
        
        # Add the Begin method
        Add-Member -InputObject $Local:MainObject -MemberType ScriptMethod -Name Begin -Value {
            # Add the function details
            Add-Member -InputObject $this -NotePropertyName FunctionDetails -NotePropertyValue ($this.FunctionCircumFix -f $this.FunctionName, $this.ParameterSetName, $this.FunctionArguments)
            # Write the Begin message
            Write-Verbose ('+++ BEGIN {0}' -f $this.FunctionDetails)
        }
    
        # Add the End method
        Add-Member -InputObject $Local:MainObject -MemberType ScriptMethod -Name End -Value {
            # Write the End message
            Write-Verbose ('___ END {0}' -f $this.FunctionDetails)
        }

        # Add the Process method
        Add-Member -InputObject $Local:MainObject -MemberType ScriptMethod -Name Process -Value {
            # Switch on the ParameterSetName
            switch ($this.ParameterSetName) {
                'Initialize'        { $this.InitializeRegistryKey($this.ParentRegistryKey) }
                'ReadProperty'      { $this.ReadProperty($this.RegistryKey,$this.PropertyName) }
                'WriteProperty'     { $this.WriteProperty($this.RegistryKey,$this.PropertyName,$this.PropertyValue) }
                'RemoveProperty'    { $this.RemoveProperty($this.RegistryKey,$this.PropertyName) }
            }
        }

        ####################################################################################################
        ### MAIN PROCESSING METHODS ###
        
        # Add the InitializeRegistryKey method
        Add-Member -InputObject $Local:MainObject -MemberType ScriptMethod -Name InitializeRegistryKey -Value { param([System.String]$Path)
            # If the key does not exist, then create it
            Write-Verbose ('InitializeRegistryKey: Testing if the Registry Key exists... ({0})' -f $Path )
            if (Test-Path -Path $Path) { Write-Verbose ('InitializeRegistryKey: The Registry Key exists. No action has been taken. ({0})' -f $Path ) }
            else { Write-Verbose ('InitializeRegistryKey: The Registry Key does not exist. Creating the Registry Key: ({0})' -f $Path ) ; New-Item -Path $Path | Out-Null }
        }
        
        # Add the ReadProperty method
        Add-Member -InputObject $Local:MainObject -MemberType ScriptMethod -Name ReadProperty -Value { param([System.String]$Path,[System.String]$Name)
            try {
                # Write the message
                Write-Verbose ('ReadProperty: Reading the value of the property ({0}) in the RegistryKey ({1})...' -f $Name,$Path)
                # Read the Property
                [System.String]$PropertyValue = Get-ItemPropertyValue -Path $Path -Name $Name -ErrorAction SilentlyContinue
            }
            catch [System.Management.Automation.PSArgumentException] {
                # The property does not exist in the registry
                Write-Verbose ('ReadProperty: The propertyname ({0}) does not exist in the RegistryKey ({1})' -f $Name,$Path)
                [System.String]$PropertyValue = $null
            }
            catch {
                Write-Host ('ReadProperty: An unknow error has occured.') -ForegroundColor Red
                [System.String]$PropertyValue = $null
            }
            # Add the OutputObject to the main object
            Add-Member -InputObject $this -NotePropertyName OutputObject -NotePropertyValue $PropertyValue
        }
        
        # Add the WriteProperty method
        Add-Member -InputObject $Local:MainObject -MemberType ScriptMethod -Name WriteProperty -Value { param([System.String]$Path,[System.String]$Name,[System.String]$Value)
            # Write the Property
            try {
                Write-Verbose ('WriteProperty: Writing the property ({0}) with the value ({1}) in the RegistryKey ({2})'-f $Path, $Name, $Value)
                New-ItemProperty -Path $Path -Name $Name -Value $Value -Force | Out-Null
            }
            catch {
                Write-Host ('WriteProperty: The value could not be written. Clearing the property ({0})' -f $Name) -ForegroundColor Red
                Clear-ItemProperty -Path $Path -Name $Name
            }
        }
        
        # Add the RemoveProperty method
        Add-Member -InputObject $Local:MainObject -MemberType ScriptMethod -Name RemoveProperty -Value { param([System.String]$Path,[System.String]$Name)
            # Remove the Property
            Write-Verbose ('RemoveProperty: Removing the property ({0}) from the RegistryKey ({1})' -f $Name,$Path)
            Remove-ItemProperty -Path $Path -Name $Name
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
        Return $Local:MainObject.OutputObject
        #endregion END
    }
}
