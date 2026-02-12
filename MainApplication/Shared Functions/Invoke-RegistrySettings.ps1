####################################################################################################
<#
.SYNOPSIS
    This function manages the user settings, which are stored in the registry.
.DESCRIPTION
    This function is part of the Packaging Assistant. It contains functions and variables that are in other files.
    External classes    : -
    External functions  : -
    External variables  : $Global:ApplicationObject
.EXAMPLE
    Invoke-RegistrySettings -Initialize
.EXAMPLE
    Invoke-RegistrySettings -Write -PropertyName LastUsedFolder -PropertyValue 'C:\Work'
.INPUTS
    [System.Management.Automation.SwitchParameter]
    [System.String]
.OUTPUTS
    This function returns no output.
.NOTES
    Version         : 2.0
    Author          : Imraan Noormohamed
    Creation Date   : October 2023
    Last Updated    : October 2023
#>
####################################################################################################

function Invoke-RegistrySettings {
    [CmdletBinding()]
    param (
        # Switch for creating the application registry key
        [Parameter(Mandatory=$true,ParameterSetName='Initialize')]
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

        # Switch for removing a property
        [Parameter(Mandatory=$true,ParameterSetName='ResetAllSettings')]
        [System.Management.Automation.SwitchParameter]
        $ResetAll,

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
        $PropertyValue
    )
    
    begin {
        # Set the main object
        [PSCustomObject]$Local:MainObject = @{
            # Function
            FunctionName        = [System.String]$MyInvocation.MyCommand
            FunctionArguments   = [System.String]$PSBoundParameters.GetEnumerator()
            ParameterSetName    = [System.String]$PSCmdlet.ParameterSetName
            FunctionCircumFix   = [System.String]'Function: [{0}] ParameterSetName: [{1}] Arguments: {2}'
            # Handlers
            GlobalApplicationObject = [PSCustomObject]$Global:ApplicationObject
            ParentKey           = 'HKCU:\Software'
            # Input
            PropertyName        = $PropertyName
            PropertyValue       = $PropertyValue
        }

        ####################################################################################################
        ### MAIN FUNCTION METHODS ###

        # Add the Process method
        Add-Member -InputObject $Local:MainObject -MemberType ScriptMethod -Name Process -Value {
            # Set the RegistryKey
            $this.SetRegistryKey()
            # Switch on the ParameterSetName
            switch ($this.ParameterSetName) {
                'Initialize'        { $this.Initialize($this.RegistryKey) }
                'ReadProperty'      { $this.ReadProperty($this.RegistryKey,$this.PropertyName) }
                'WriteProperty'     { $this.WriteProperty($this.RegistryKey,$this.PropertyName,$this.PropertyValue) }
                'RemoveProperty'    { $this.RemoveProperty($this.RegistryKey,$this.PropertyName) }
                'ResetAllSettings'  { $this.RemoveAllSettings($this.RegistryKey) }
            }
        }

        ####################################################################################################
        
        # Add the SetRegistryKey method
        Add-Member -InputObject $Local:MainObject -MemberType ScriptMethod -Name SetRegistryKey -Value {
            # Set the RegistryKey
            [System.String]$RegistryKey = Join-Path -Path $this.ParentKey -ChildPath $this.GlobalApplicationObject.Name
            Write-Verbose ('SetRegistryKey: Setting the RegistryKey: {0}' -f $RegistryKey)
            Add-Member -InputObject $this -NotePropertyName RegistryKey -NotePropertyValue $RegistryKey
        }

        ####################################################################################################
        
        # Add the Initialize method
        Add-Member -InputObject $Local:MainObject -MemberType ScriptMethod -Name Initialize -Value { param([System.String]$Path)
            # If the key does not exist, then create it
            Write-Verbose ('Initialize: Testing if the Registry Key exists... ({0})' -f $Path )
            if (Test-Path -Path $Path) {
                Write-Verbose ('Initialize: The Registry Key exists. No action has been taken. ({0})' -f $Path )
            }
            else {
                New-Item -Path $Path | Out-Null
            }
        }

        ####################################################################################################
        
        # Add the ReadProperty method
        Add-Member -InputObject $Local:MainObject -MemberType ScriptMethod -Name ReadProperty -Value { param([System.String]$Path,[System.String]$Name)
            try {
                # Write the message
                # Read the Property
                [System.String]$PropertyValue = Get-ItemPropertyValue -Path $Path -Name $Name -ErrorAction SilentlyContinue
            }
            catch [System.Management.Automation.PSArgumentException] {
                # The property does not exist in the registry
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
                New-ItemProperty -Path $Path -Name $Name -Value $Value -Force | Out-Null
            }
            catch {
                Clear-ItemProperty -Path $Path -Name $Name
            }
        }
        
        # Add the RemoveProperty method
        Add-Member -InputObject $Local:MainObject -MemberType ScriptMethod -Name RemoveProperty -Value { param([System.String]$Path,[System.String]$Name)
            # Remove the Property
            Remove-ItemProperty -Path $Path -Name $Name
        }
        
        # Add the RemoveAllSettings method
        Add-Member -InputObject $Local:MainObject -MemberType ScriptMethod -Name RemoveAllSettings -Value { param([System.String]$Path)
            # Get user confirmation
            [System.Boolean]$UserHasConfirmed = Get-UserConfirmation -Title 'RESET TO DEFAULT' -Body ('This will return the application to the default settings, and remove all user settings. Are you sure?') -Type Warning
            if (-Not($UserHasConfirmed)) { Return }
            # Remove the registry key
            Remove-Item -Path $Path -Recurse -Force | Out-Null
            # Get user confirmation (used a variable to catch the stream output)
            [System.Boolean]$UserHasConfirmed = Get-UserConfirmation -Title 'RESTART NEEDED' -Body ('All user settings have been removed. Please restart the application for the changes to take effect.') -Type Information           
        }

        ####################################################################################################

        #region BEGIN
        # Write the Begin message
        #Write-Message -FunctionBegin -Details $Local:MainObject.FunctionDetails
        #endregion BEGIN
    }
    
    process {
        #region PROCESS
        $Local:MainObject.Process()
        #endregion PROCESS
    }
    
    end {
        #region END
        # Return the output
        $Local:MainObject.OutputObject
        # Write the End message
        #Write-Message -FunctionEnd -Details $Local:MainObject.FunctionDetails
        #endregion END
    }
}



