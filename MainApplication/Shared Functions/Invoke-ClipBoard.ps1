####################################################################################################
<#
.SYNOPSIS
    This function copies text from, or pastes text to, or clears a TextBox/ComboBox.
.DESCRIPTION
    This function is part of the Packaging Assistant. It contains functions and variables that are in other files.
    External classes    : -
    External functions  : Test-Object, Get-UserConfirmation, Write-FullError, Invoke-RegistrySettings
    External variables  : -
.EXAMPLE
    Invoke-ClipBoard -CopyFromBox $MyTextBox
.EXAMPLE
    Invoke-ClipBoard -PasteToBox $MyComboBox
.EXAMPLE
    Invoke-ClipBoard -Clear $MyComboBox
.INPUTS
    [System.Object]
    [System.Management.Automation.SwitchParameter]
.OUTPUTS
    This function returns no stream output.
.NOTES
    Version         : 5.2.6
    Author          : Imraan Iotana
    Creation Date   : October 2023
    Last Update     : May 2025
#>
####################################################################################################

function Invoke-ClipBoard {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory=$true,ParameterSetName='CopyFromBox',HelpMessage='The TexBox/ComboBox from which the text will be copied.')]
        [System.Object]
        $CopyFromBox,

        [Parameter(Mandatory=$true,ParameterSetName='PasteToBox',HelpMessage='The TexBox/ComboBox to which the text will be pasted.')]
        [System.Object]
        $PasteToBox,

        [Parameter(Mandatory=$true,ParameterSetName='ClearBox',HelpMessage='The TexBox/ComboBox from which the text will be cleared.')]
        [System.Object]
        $ClearBox,

        [Parameter(Mandatory=$false,HelpMessage='Switch for hiding the confirmation dialog.')]
        [System.Management.Automation.SwitchParameter]
        $HideConfirmation
    )
    
    begin {
        # Set the Main object
        [PSCustomObject]$Local:MainObject = @{
            # Function
            ParameterSetName        = [System.String]$PSCmdlet.ParameterSetName
            # Handlers
            ApprovedBoxTypes        = @('System.Windows.Forms.TextBox','System.Windows.Forms.ComboBox')
            ValidationIsSuccessful  = [System.Boolean]$true
            # Input
            HideConfirmation        = $HideConfirmation
        }

        ####################################################################################################
        # Main

        # Add the Begin method
        Add-Member -InputObject $Local:MainObject -MemberType ScriptMethod -Name Begin -Value {
            # Set the BoxToHandle
            $BoxToHandle = switch ($this.ParameterSetName) {
                'CopyFromBox'           { $CopyFromBox }
                'PasteToBox'            { $PasteToBox }
                'ClearBox'              { $ClearBox }
                'ResetToDefaultValue'   { $ResetToDefaultValue }
            }
            Add-Member -InputObject $this -NotePropertyName BoxToHandle -NotePropertyValue $BoxToHandle
            # Validate the input
            $this.ValidateInput()
        }

        # Add the Process method
        Add-Member -InputObject $Local:MainObject -MemberType ScriptMethod -Name Process -Value {
            # If the validation was successful
            if ($this.ValidationIsSuccessful) {
                # Switch on the ParameterSetName
                switch ($this.ParameterSetName) {
                    'CopyFromBox'           { $this.CopyFromBoxToClipBoard($this.BoxToHandle) }
                    'PasteToBox'            { $this.PasteFromClipBoardToBox($this.BoxToHandle) }
                    'ClearBox'              { $this.ClearBox($this.BoxToHandle) }
                    'ResetToDefaultValue'   { $this.ResetToDefaultValue($this.BoxToHandle) }
                }
            } else {
                # Write the fail message and return
                Write-Host 'The validation was NOT successful. The Process method will not start.' -ForegroundColor Red
                Return
            }
        }

        ####################################################################################################
        # VALIDATION

        # Add the ValidateInput method
        Add-Member -InputObject $Local:MainObject -MemberType ScriptMethod -Name ValidateInput -Value {
            # Validate the box type
            Write-Verbose ('Testing if the boxtype is an approved type... (Approved Types: {0})' -f [System.String]$this.ApprovedBoxTypes)
            $BoxType = $this.BoxToHandle.GetType()
            if ($BoxType -in $this.ApprovedBoxTypes) {
                Write-Verbose ('The boxtype is an approved type: ({0}).' -f $BoxType)
            }
            else {
                Write-Host ('The boxtype ({0}) is NOT an approved type. (Approved Types: {1})' -f $BoxType, [System.String]$this.ApprovedBoxTypes) -ForegroundColor Red
                $this.ValidationIsSuccessful = $false
            }
        }

        ####################################################################################################
        ### MAIN PROCESSING METHODS ###

        # Add the CopyFromBoxToClipBoard method
        Add-Member -InputObject $Local:MainObject -MemberType ScriptMethod -Name CopyFromBoxToClipBoard -Value { param([System.Object]$BoxToCopyFrom)
            # Get the text from the box
            [System.String]$TextToCopyFromBox = $BoxToCopyFrom.Text
            # If the text is empty
            if ([System.String]::IsNullOrWhiteSpace($TextToCopyFromBox)) {
                # Write the message
                Write-Host 'The box contains no text. No action has been taken.' -ForegroundColor DarkGray
            } else {
                # Copy the text to the clipboard
                Set-Clipboard -Value $TextToCopyFromBox
                Write-Host ('The following text has been copied from the box to your clipboard: {0}' -f $TextToCopyFromBox) -ForegroundColor DarkGray
            }
        }

        # Add the PasteFromClipBoardToBox method
        Add-Member -InputObject $Local:MainObject -MemberType ScriptMethod -Name PasteFromClipBoardToBox -Value { param([System.Object]$BoxToCopyTo)
            try {
                # Get the text from the clipboard
                [System.String]$TextToPaste = Get-Clipboard -ErrorAction Continue
                # If the text is empty
                if (Test-Object -IsEmpty $TextToPaste) {
                    # Write the message
                    Write-Host 'The clipboard contains no text. No action has been taken.' -ForegroundColor DarkGray
                } else {
                    # Get user confirmation
                    [System.Boolean]$UserHasConfirmed = Get-UserConfirmation -Title 'Overwrite textbox/combobox' -Body ('This will overwrite the current value with "{0}". Are you sure?' -f $TextToPaste)
                    if (-Not($UserHasConfirmed)) { Return }
                    # Paste the text to the box
                    $BoxToCopyTo.Text = $TextToPaste
                    Write-Host ('The following text has been pasted from your clipboard to the box: {0}' -f $TextToPaste) -ForegroundColor DarkGray
                }
            }
            catch {
                Write-FullError 'The content of the Clipboard could not be pasted in the textbox.'
            }
        }

        # Add the ClearBox method
        Add-Member -InputObject $Local:MainObject -MemberType ScriptMethod -Name ClearBox -Value { param([System.Object]$BoxToClear)
            try {
                # Get user confirmation
                if (-Not($this.HideConfirmation.IsPresent)) {
                    [System.Boolean]$UserHasConfirmed = Get-UserConfirmation -Title 'Clear textbox/combobox' -Body 'This will clear the field. Are you sure?'
                    if (-Not($UserHasConfirmed)) { Return }
                }
                # Determine the boxtype, and clear the text from the box
                $BoxType = $BoxToClear.GetType()
                switch ($BoxType) {
                    $this.ApprovedBoxTypes[0] { $BoxToClear.Clear() } # TextBox
                    $this.ApprovedBoxTypes[1] { $BoxToClear.ResetText() ; Invoke-RegistrySettings -Remove -PropertyName $BoxToClear.PropertyName } # ComboBox
                }
                Write-Host 'The box has been cleared.' -ForegroundColor DarkGray
            }
            catch {
                Write-FullError 'The box could not be cleared.'
            }
        }

        ####################################################################################################

        $Local:MainObject.Begin()
    }
    
    process {
        $Local:MainObject.Process()
    }
    
    end {
    }
}



