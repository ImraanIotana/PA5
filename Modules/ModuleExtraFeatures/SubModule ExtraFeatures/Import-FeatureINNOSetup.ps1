####################################################################################################
<#
.SYNOPSIS
    This Feature creates AppLocker XML files and saves them in the Appliction Folder on the DSL.
.DESCRIPTION
    This function is part of the Packaging Assistant. It contains functions and variables that are in other files.
.EXAMPLE
    Import-FeatureINNOSetup
.INPUTS
    [System.Windows.Forms.TabPage]
.OUTPUTS
    This function returns no stream output.
.NOTES
    Version         : 4.8
    Author          : Imraan Iotana
    Creation Date   : June 2024
    Last Updated    : September 2024
#>
####################################################################################################

function Import-FeatureINNOSetup {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory=$true,HelpMessage='The Parent TabPage to which this Feature will be added.')]
        [System.Windows.Forms.TabPage]
        $ParentTabPage
    )

    begin {
        ####################################################################################################
        ### MAIN PROPERTIES ###

        # Function
        [System.String[]]$FunctionDetails   = @($MyInvocation.MyCommand,$PSCmdlet.ParameterSetName,$PSBoundParameters.GetEnumerator())

        # GroupBox properties
        [PSCustomObject]$GroupBox   = @{
            Title                   = [System.String]'Create INNO Inf file'
            Color                   = [System.String]'Cyan'
            NumberOfRows            = [System.Int32]2
            GroupBoxAbove           = $Global:SIShorcutExportGroupbox
        }

        ####################################################################################################
        ### BUTTON PROPERTIES ###

        [System.Collections.Hashtable[]]$InnoSetupFileTextBoxButtons = @(
            @{
                ColumnNumber    = 1
                Text            = 'Browse'
                TextColor       = 'LightCyan'
                Image           = 'folders_explorer.png'
                SizeType        = 'Medium'
                Function        = { [System.String]$File = Select-Item -File ; if ($File) { $Global:InnoSetupFileTextBox.Text = $File } }
            }
            @{
                ColumnNumber    = 2
                Text            = 'Paste'
                TextColor       = 'LightCyan'
                Image           = 'page_paste.png'
                SizeType        = 'Medium'
                Function        = { Invoke-ClipBoard -PasteToBox $Global:InnoSetupFileTextBox }
            }
        )

        [System.Collections.Hashtable[]]$ActionButtons = @(
           @{
                ColumnNumber    = 5
                Text            = 'Create INF file'
                Image           = 'cd.png'
                SizeType        = 'Large'
                ToolTip         = 'Create an INF file by running the executable'
                Function        = { New-INNOConfigurationFile -Path $Global:InnoSetupFileTextBox.Text }
            }
        )

        ####################################################################################################

        # Write the begin message
        Write-Function -Begin $FunctionDetails
    } 
    
    process {
        # Create the GroupBox
        [System.Windows.Forms.GroupBox]$Global:InnoSetupGroupbox = $ParentGroupBox = Invoke-Groupbox -ParentTabPage $ParentTabPage -Title $Groupbox.Title -NumberOfRows $Groupbox.NumberOfRows -Color $Groupbox.Color -GroupBoxAbove $GroupBox.GroupBoxAbove
        # Create the InnoSetupFileTextBox
        [System.Windows.Forms.TextBox]$Global:InnoSetupFileTextBox = Invoke-TextBox -ParentGroupBox $ParentGroupBox -RowNumber 1 -SizeType Medium -Type Input -Label 'Select Setup file:' -PropertyName 'InnoSetupFileTextBox'
        Invoke-ButtonLine -ButtonPropertiesArray $InnoSetupFileTextBoxButtons -ParentGroupBox $ParentGroupBox -RowNumber 2
        # Create the action button
        Invoke-ButtonLine -ButtonPropertiesArray $ActionButtons -ParentGroupBox $ParentGroupBox -RowNumber 1
    }

    end {
        # Write the end message
        Write-Function -End $FunctionDetails
    }
}

### END OF SCRIPT
####################################################################################################
