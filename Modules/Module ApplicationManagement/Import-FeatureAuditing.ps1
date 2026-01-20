####################################################################################################
<#
.SYNOPSIS
    This feature performs predefined audits on an Application.
.DESCRIPTION
    This function is part of the Packaging Assistant. It may contain functions or variables, that are in other files.
.EXAMPLE
    Import-FeatureAuditing
.INPUTS
    [System.Windows.Forms.TabPage]
.OUTPUTS
    This function returns no stream output.
.NOTES
    Version         : 5.5.2
    Author          : Imraan Iotana
    Creation Date   : September 2025
    Last Updated    : October 2025
#>
####################################################################################################

function Import-FeatureAuditing {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory=$true,HelpMessage='The Parent TabPage to which this Feature will be added.')]
        [System.Windows.Forms.TabPage]
        $ParentTabPage
    )

    begin {
        ####################################################################################################
        ### MAIN PROPERTIES ###

        # GroupBox properties
        [PSCustomObject]$GroupBox   = @{
            Title                   = [System.String]'Application Audit'
            Color                   = [System.String]'Yellow'
            NumberOfRows            = [System.Int32]3
            GroupBoxAbove           = $Global:MDSLMFSPOGroupBox
        }

        # Audit Handlers
        [System.Collections.Hashtable]$Script:AuditHashtable = @{
            NameConvention          = 'GENERAL: The application NAME must meet the NAMING CONVENTION.'
            LogFileExistence        = 'LOGGING: The application must have a LOGFILE.'
        }

        ####################################################################################################
        ### BUTTON PROPERTIES ###

        [System.Collections.Hashtable[]]$ActionButtons = @(
           @{
                ColumnNumber    = 5
                Text            = 'Perform the Audit'
                Image           = 'tubes.png'
                SizeType        = 'Large'
                ToolTip         = 'Perform the selected Audit on the selected Application'
                Function        = {
                    [System.String]$ApplicationID       = $Global:DSApplicationIDComboBox.Text
                    [System.String]$AuditName           = $Script:MDSLMFAAuditComboBox.Text
                    [System.String]$SelectedAuditKey    = $Script:AuditHashtable.Keys | Where-Object { $Script:AuditHashtable.$_ -eq $AuditName }
                    switch ($SelectedAuditKey) {
                        'NameConvention'    { Write-NoAction }
                        'LogFileExistence'  { Confirm-LogFileExistence -ApplicationID $ApplicationID -AuditName $AuditName }
                    }
                }
            }
        )

        ####################################################################################################
    } 
    
    process {
        # Create the GroupBox
        [System.Windows.Forms.GroupBox]$Global:MDSLMFAGroupBox = $ParentGroupBox = Invoke-Groupbox -ParentTabPage $ParentTabPage -Title $Groupbox.Title -NumberOfRows $Groupbox.NumberOfRows -Color $Groupbox.Color -GroupBoxAbove $Groupbox.GroupBoxAbove
        # Create the Audit ComboBox
        [System.Windows.Forms.ComboBox]$Script:MDSLMFAAuditComboBox = Invoke-ComboBox -ParentGroupBox $ParentGroupBox -RowNumber 1 -SizeType Large -Type Output -Label 'Select Audit:' -ContentArray $Script:AuditHashtable.Values -PropertyName 'MDSLMFAAuditComboBox'
        # Create the buttons
        Invoke-ButtonLine -ButtonPropertiesArray $ActionButtons -ParentGroupBox $ParentGroupBox -RowNumber 2
    }

    end {
    }
}

### END OF SCRIPT
####################################################################################################
