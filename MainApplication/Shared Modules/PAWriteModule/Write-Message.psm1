####################################################################################################
<#
.SYNOPSIS
    This function writes standard function messages.
.DESCRIPTION
    This function is part of the Packaging Assistant. It contains references to classes, functions or variables, that are in other files.
    External classes    : -
    External functions  : Write-FullError
    External variables  : $Global:ApplicationObject
.EXAMPLE
    Write-Message -FunctionBegin -Details $FunctionDetails
.EXAMPLE
    Write-Message -MandatoryField
.INPUTS
    [System.Management.Automation.SwitchParameter]
    [System.String[]]
.OUTPUTS
    This function returns no stream-output.
.NOTES
    Version         : 5.2.5
    Author          : Imraan Iotana
    Creation Date   : February 2025
    Last Update     : May 2025
#>
####################################################################################################

function Write-Message {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory=$true,ParameterSetName='WriteFunctionBegin',HelpMessage='Switch for writing the Function Begin message')]
        [System.Management.Automation.SwitchParameter]
        $FunctionBegin,

        [Parameter(Mandatory=$true,ParameterSetName='WriteFunctionEnd',HelpMessage='Switch for writing the Function End message')]
        [System.Management.Automation.SwitchParameter]
        $FunctionEnd,

        [Parameter(Mandatory=$true,ParameterSetName='WriteFunctionBegin',HelpMessage='This details of the function')]
        [Parameter(Mandatory=$true,ParameterSetName='WriteFunctionEnd')]
        [AllowEmptyString()]
        [System.String[]]
        $Details,

        [Parameter(Mandatory=$true,ParameterSetName='WriteFunctionBeginVerbose',HelpMessage='This details of the function')]
        [AllowEmptyString()]
        [System.String[]]
        $Begin,

        [Parameter(Mandatory=$true,ParameterSetName='WriteFunctionEndVerbose',HelpMessage='This details of the function')]
        [AllowEmptyString()]
        [System.String[]]
        $End,

        [Parameter(Mandatory=$true,ParameterSetName='WriteValidationSuccess',HelpMessage='Switch for writing the ValidationSuccess message')]
        [System.Management.Automation.SwitchParameter]
        $ValidationSuccess,

        [Parameter(Mandatory=$true,ParameterSetName='WriteValidationFailed',HelpMessage='Switch for writing the ValidationFailed message')]
        [System.Management.Automation.SwitchParameter]
        $ValidationFailed,

        [Parameter(Mandatory=$true,ParameterSetName='WriteMandatoryField',HelpMessage='Switch for writing the MandatoryField message')]
        [System.Management.Automation.SwitchParameter]
        $MandatoryField,

        [Parameter(Mandatory=$true,ParameterSetName='WriteNoAction',HelpMessage='Switch for writing the NoAction message')]
        [System.Management.Automation.SwitchParameter]
        $NoAction
    )

    begin {
        ####################################################################################################
        ### MAIN OBJECT ###

        # Set the main object
        [PSCustomObject]$Local:MainObject = @{
            # ParameterSetName
            ParameterSetName    = [System.String]$PSCmdlet.ParameterSetName
            # Fixes
            FunctionCircumFix   = [System.String]'Function: [{0}] ParameterSetName: [{1}] Arguments: {2}'
            BeginMessagePreFix  = [System.String]'+++ BEGIN {0}'
            EndMessagePreFix    = [System.String]'___ END {0}'
            # Input
            Details             = $Details
            Begin               = $Begin
            End                 = $End
        }

        ####################################################################################################
        ### MAIN FUNCTION METHODS ###

        # Add the Process method
        Add-Member -InputObject $Local:MainObject -MemberType ScriptMethod -Name Process -Value {
            try {
            # Switch on the ParameterSetName
            switch ($this.ParameterSetName) {
                'WriteFunctionBeginVerbose' { $this.WriteFunctionMessageVerbose($this.Begin,$this.BeginMessagePreFix,$this.FunctionCircumFix) } #NEW
                'WriteFunctionEndVerbose'   { $this.WriteFunctionMessageVerbose($this.End,$this.EndMessagePreFix,$this.FunctionCircumFix) } #NEW
                'WriteFunctionBegin'        { $this.WriteFunctionMessageVerbose($this.Details,$this.BeginMessagePreFix,$this.FunctionCircumFix) } #OLD
                'WriteFunctionEnd'          { $this.WriteFunctionMessageVerbose($this.Details,$this.EndMessagePreFix,$this.FunctionCircumFix) } #OLD
                'WriteValidationSuccess'    { $this.WriteValidationSuccessMessage() }
                'WriteValidationFailed'     { $this.WriteValidationFailedMessage() }
                'WriteMandatoryField'       { $this.WriteMandatoryFieldMessage() }
                'WriteNoAction'             { $this.WriteNoActionMessage() }
            }
            }
            catch {
                Write-FullError
            }
        }

        ####################################################################################################
        ### MAIN PROCESSING METHODS ###
    
        # Add the WriteNormalMessage method
        Add-Member -InputObject $Local:MainObject -MemberType ScriptMethod -Name WriteNormalMessage -Value { param([System.String]$Text)
            # Write the message
            Write-Host $Text -ForegroundColor DarkGray
        }

        # Add the WriteFunctionMessageVerbose method
        Add-Member -InputObject $Local:MainObject -MemberType ScriptMethod -Name WriteFunctionMessageVerbose -Value { param([System.String[]]$FunctionDetails,[System.String]$MessagePreFix,[System.String]$FunctionCircumFix)
            try {
                # Set the text
                [System.String]$FunctionTextLine = ($FunctionCircumFix -f $FunctionDetails[0],$FunctionDetails[1],$FunctionDetails[2])
                # Write the message
                Write-Verbose ($MessagePreFix -f $FunctionTextLine)
            }
            catch {
                Write-FullError
            }
        }
    
        # Add the WriteValidationSuccessMessage method
        Add-Member -InputObject $Local:MainObject -MemberType ScriptMethod -Name WriteValidationSuccessMessage -Value {
            # Write the message
            Write-Host 'The validation is successful. The process method will now start.'
        }
    
        # Add the WriteValidationFailedMessage method
        Add-Member -InputObject $Local:MainObject -MemberType ScriptMethod -Name WriteValidationFailedMessage -Value {
            # Write the message
            Write-Host 'The validation failed. The process method will NOT start.' -ForegroundColor Red
            #Write-FullError -Message 'The validation failed. The process method will NOT start.'
        }
    
        # Add the WriteMandatoryFieldMessage method
        Add-Member -InputObject $Local:MainObject -MemberType ScriptMethod -Name WriteMandatoryFieldMessage -Value {
            Write-Red 'A mandatory field is empty.' ; Write-NoAction
        }
    
        # Add the WriteNoActionMessage method
        Add-Member -InputObject $Local:MainObject -MemberType ScriptMethod -Name WriteNoActionMessage -Value {
            # Write the message
            Write-Host 'No action has been taken' -ForegroundColor DarkGray
        }
    }
    
    process {
        $Local:MainObject.Process()
    }

    end {
    }
}

### END OF SCRIPT
####################################################################################################
