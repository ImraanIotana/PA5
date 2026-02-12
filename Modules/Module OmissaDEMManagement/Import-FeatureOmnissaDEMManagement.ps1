####################################################################################################
<#
.SYNOPSIS
    This feature checks if Omissa DEM objects exist, for an Application.
.DESCRIPTION
    This function is part of the Packaging Assistant. It contains functions and variables that are in other files.
.EXAMPLE
    Import-FeatureOmissaDEMManagement
.INPUTS
    [System.Windows.Forms.TabPage]
.OUTPUTS
    This function returns no stream output.
.NOTES
    Version         : 5.5.1
    Author          : Imraan Iotana
    Creation Date   : September 2025
    Last Updated    : September 2025
#>
####################################################################################################

function Import-FeatureOmnissaDEMManagement {
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
        #[System.String[]]$FunctionDetails   = @($MyInvocation.MyCommand,$PSCmdlet.ParameterSetName,$PSBoundParameters.GetEnumerator())
        # Handlers
        [System.String]$DEMLogFolder        = $Global:ApplicationObject.Settings.DEMLogFolder

        # GroupBox properties
        [PSCustomObject]$GroupBox   = @{
            Title                   = [System.String]'Omissa DEM Object Management'
            Color                   = [System.String]'Blue'
            NumberOfRows            = [System.Int32]4
        }

        ####################################################################################################
        ### BUTTON PROPERTIES ###

        [System.Collections.Hashtable[]]$SmallButtons = @(
            @{
                ColumnNumber    = 5
                Text            = 'Open Folder'
                Image           = 'folder.png'
                SizeType        = 'Small'
                ToolTip         = 'Open the DEM folder of this application'
                Function        = { Open-Folder -Path (Get-Path -ApplicationID $Global:ODMApplicationIDComboBox.Text -SubFolder DEMFolder) }
            }
            @{
                ColumnNumber    = 6
                Text            = 'Show Application Log'
                Image           = 'file_extension_log.png'
                SizeType        = 'Small'
                ToolTip         = 'Open the logfile of the selected Application'
                Function        = { Show-ApplicationLogFile -ApplicationID $Global:ODMApplicationIDComboBox.Text }
            }
        )

        [System.Collections.Hashtable[]]$RightButtons = @(
            @{
                RowNumber   = 3
                Text        = 'Start Omnissa'
                Image       = 'omnissa_dem.png'
                SizeType    = 'Medium'
                ToolTip     = 'Start the Omnissa DEM Management Console'
                Function    = {
                    [System.String]$Path = 'C:\Program Files\Omnissa\DEM\Flex+ Management Console.exe'
                    if (Test-Path -Path $Path) { Write-Line "Starting the Omnissa DEM Management Console" ; Start-Process -FilePath $Path } else { Write-Host ('The file could not be found: ({0})' -f $Path) }
                }
            }
            @{
                RowNumber   = 4
                Text        = 'Open LogFolder'
                Image       = 'folder.png'
                SizeType    = 'Medium'
                ToolTip     = 'Open the Omnissa DEM LogFolder'
                Function    = { Open-Folder -Path $Global:OmissaDEMManagementGroupbox.DEMLogFolder }
            }
        )

        [System.Collections.Hashtable[]]$ActionButtons = @(
            @{
                ColumnNumber    = 1
                Text            = 'Check Application'
                Image           = 'table_tab_search.png'
                SizeType        = 'Large'
                ToolTip         = 'Check if this application has objects in Omnissa DEM'
                Function        = {
                    [System.String]$ApplicationID = $Global:ODMApplicationIDComboBox.Text
                    if (Test-Object -IsEmpty $ApplicationID) { Write-Red 'The Application ID field is empty.' ; Return }
                    Write-Line ('Searching the DEM Repositories for the application ({0})...' -f $ApplicationID)
                    Test-OmnissaDEMObjects -ApplicationID $ApplicationID -Shortcuts -OutHost
                    Test-OmnissaDEMObjects -ApplicationID $ApplicationID -UserFiles -OutHost
                    Test-OmnissaDEMObjects -ApplicationID $ApplicationID -UserRegistry -OutHost
                    Write-Host
                }
            }
        )

        ####################################################################################################

        # Write the begin message
        #Write-Function -Begin $FunctionDetails
    } 
    
    process {
        # Create the GroupBox, and add the extra properties
        [System.Windows.Forms.GroupBox]$Global:OmissaDEMManagementGroupbox = $ParentGroupBox = Invoke-Groupbox -ParentTabPage $ParentTabPage -Title $Groupbox.Title -NumberOfRows $Groupbox.NumberOfRows -Color $Groupbox.Color
        $Global:OmissaDEMManagementGroupbox | Add-Member -NotePropertyName DEMLogFolder -NotePropertyValue $DEMLogFolder
        # Create the ApplicationID ComboBox
        [System.Windows.Forms.ComboBox]$Global:ODMApplicationIDComboBox = Invoke-ComboBox -ParentGroupBox $ParentGroupBox -RowNumber 1 -SizeType Medium -Type Output -Label 'Select Application:' -ContentArray (Get-DSLApplicationFolder -All -Basenames) -PropertyName 'ODMApplicationIDComboBox'
        Invoke-ButtonLine -ButtonPropertiesArray $SmallButtons -ParentGroupBox $ParentGroupBox -RowNumber 1
        Invoke-ButtonLine -ButtonPropertiesArray $RightButtons -ParentGroupBox $ParentGroupBox -ColumnNumber 5
        Invoke-ButtonLine -ButtonPropertiesArray $ActionButtons -ParentGroupBox $ParentGroupBox -RowNumber 3
    }

    end {
        # Write the end message
        #Write-Function -End $FunctionDetails
    }
}

### END OF SCRIPT
####################################################################################################
