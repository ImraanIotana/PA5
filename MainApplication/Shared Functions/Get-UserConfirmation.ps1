####################################################################################################
<#
.SYNOPSIS
    This function ask the user for confirmation with a message box.
.DESCRIPTION
    This function is self-contained and does not refer to functions or variables, that are in other files.
.EXAMPLE
    Get-UserConfirmation -Title 'Removing File' -Body 'Are you sure you want to remove this file?'
.INPUTS
    [System.String]
.OUTPUTS
    [System.Boolean]
.NOTES
    Version         : 5.2.5
    Author          : Imraan Iotana
    Creation Date   : June 2023
    Last Update     : May 2025
#>
####################################################################################################

function Get-UserConfirmation {
    [CmdletBinding()]
    [Alias('Show-MessageBox')]
    param (
        [Parameter(Mandatory=$true,HelpMessage='The text that will be written in the HEADER of the Message Box.')]
        [System.String]
        $Title,

        [Parameter(Mandatory=$true,HelpMessage='The main text that will be written in the MIDDLE of the Message Box.')]
        [System.String]
        $Body,

        [Parameter(Mandatory=$false,HelpMessage='String that will decide which icon and buttons to show. Valid values are: Information/Question/Warning/Error.')]
        [ValidateSet('Information','Question','Warning','Error')]
        [System.String]
        $Type = 'Question'
    )
    
    begin {
        # Set the MessageBox object
        [PSCustomObject]$Local:MainObject = @{
            # Input
            MessageTitle        = [System.String]$Title
            MessageBody         = [System.String]$Body
            MessageType         = [System.String]$Type
            # Output
            OutputObject        = [System.Boolean]$null
        }

        ####################################################################################################

        # Add the Process method
        Add-Member -InputObject $Local:MainObject -MemberType ScriptMethod -Name Process -Value {
            # Get the ButtonType based on the MessageType
            [System.String]$ButtonType = $this.GetButtonType($this.MessageType)
            # Set the Image equal to the MessageType
            [System.String]$Image = $this.MessageType
            # Show the message box
            [System.Windows.Forms.DialogResult]$UserChoice = [System.Windows.Forms.MessageBox]::Show($this.MessageBody, $this.MessageTitle, $ButtonType, $Image)
            # Get the user confirmation
            [System.Boolean]$UserHasConfirmed = (($UserChoice -eq 'Yes') -or ($UserChoice -eq 'OK'))
            # Write the message
            $this.WriteResultMessage($UserHasConfirmed)
            # Set the output object
            $this.OutputObject = $UserHasConfirmed
        }

        # Add the GetButtonType method
        Add-Member -InputObject $Local:MainObject -MemberType ScriptMethod -Name GetButtonType -Value { param([System.String]$MessageType)
            # Set the ButtonType based on the MessageType
            [System.String]$ButtonType = switch ($MessageType) {
                'Information'   { 'OK' }
                'Question'      { 'YesNoCancel' }
                'Warning'       { 'YesNoCancel' }
                'Error'         { 'Cancel' }
            }
            # Return the result
            $ButtonType
        }

        # Add the WriteResultMessage method
        Add-Member -InputObject $Local:MainObject -MemberType ScriptMethod -Name WriteResultMessage -Value { param([System.Boolean]$UserHasConfirmed)
            # Write the message
            if ($UserHasConfirmed) {
                Write-Line 'The user confirmed.'
            } else {
                Write-Host 'The user did not confirm. ' -ForegroundColor DarkGray -NoNewLine
                Write-NoAction
            }
        }
    }
    
    process {
        $Local:MainObject.Process()
    }
    
    end {
        # Return the output
        $Local:MainObject.OutputObject
    }
}



